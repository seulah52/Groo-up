import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../data/datasources/groo_remote_datasource.dart';
import '../../data/repositories/garden_repository_impl.dart';
import '../../domain/entities/groo_entity.dart';
import '../../domain/entities/growth_stage.dart';
import '../../domain/repositories/garden_repository.dart';
import '../../domain/usecases/get_all_groos_usecase.dart';
import '../../domain/usecases/update_growth_stage_usecase.dart';
import '../../domain/usecases/update_health_score_usecase.dart';

part 'garden_provider.g.dart';

@riverpod
GrooRemoteDatasource grooRemoteDatasource(GrooRemoteDatasourceRef ref) =>
    GrooRemoteDatasourceImpl(supabase: ref.watch(supabaseClientProvider));

/// DIP 핵심: 반환 타입이 추상 GardenRepository
@riverpod
GardenRepository gardenRepository(GardenRepositoryRef ref) =>
    GardenRepositoryImpl(remote: ref.watch(grooRemoteDatasourceProvider));

@riverpod
GetAllGroosUsecase getAllGroosUsecase(GetAllGroosUsecaseRef ref) =>
    GetAllGroosUsecase(repository: ref.watch(gardenRepositoryProvider));

@riverpod
UpdateGrowthStageUsecase updateGrowthStageUsecase(UpdateGrowthStageUsecaseRef ref) =>
    UpdateGrowthStageUsecase(repository: ref.watch(gardenRepositoryProvider));

@riverpod
UpdateHealthScoreUsecase updateHealthScoreUsecase(UpdateHealthScoreUsecaseRef ref) =>
    UpdateHealthScoreUsecase(repository: ref.watch(gardenRepositoryProvider));

enum HealthFilter { all, red, orange, green }

@riverpod
class GrooFilter extends _$GrooFilter {
  @override
  HealthFilter build() => HealthFilter.all;
  void set(HealthFilter f) => state = f;
}

@riverpod
class GardenNotifier extends _$GardenNotifier {
  @override
  Future<List<GrooEntity>> build() async {
    // currentUserProvider = Supabase auth User → id 는 profiles PK 와 동일 UUID
    final user = ref.watch(currentUserProvider);
    if (user == null) return [];
    final result = await ref.watch(getAllGroosUsecaseProvider).execute(user.id);
    final groos = result.fold((f) => throw Exception(f.message), (list) => list);
    // 앱 시작 시 decay 자동 적용
    final decayed = await ref.read(updateHealthScoreUsecaseProvider).execute(groos);
    return decayed.fold((_) => groos, (list) => list);
  }

  Future<void> refresh() async => ref.invalidateSelf();

  Future<void> growStage(String grooId, GrowthStage newStage) async {
    final result = await ref.read(updateGrowthStageUsecaseProvider).execute(grooId, newStage);
    result.fold((f) => throw Exception(f.message), (_) => ref.invalidateSelf());
  }

  Future<void> deleteGroo(String grooId) async {
    final result = await ref.read(gardenRepositoryProvider).deleteGroo(grooId);
    result.fold((f) => throw Exception(f.message), (_) => ref.invalidateSelf());
  }
}

@riverpod
List<GrooEntity> filteredGroos(FilteredGroosRef ref) {
  final all    = ref.watch(gardenNotifierProvider).valueOrNull ?? [];
  final filter = ref.watch(grooFilterProvider);
  switch (filter) {
    case HealthFilter.all:    return all;
    case HealthFilter.red:    return all.where((g) => g.healthStatus == 'red').toList();
    case HealthFilter.orange: return all.where((g) => g.healthStatus == 'orange').toList();
    case HealthFilter.green:
      return all
          .where((g) => g.healthStatus == 'green' || g.healthStatus == 'gold')
          .toList();
  }
}
