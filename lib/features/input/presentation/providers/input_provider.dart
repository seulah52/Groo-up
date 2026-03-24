import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/utils/user_id_guard.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../data/datasources/input_remote_datasource.dart';
import '../../data/repositories/input_repository_impl.dart';
import '../../domain/repositories/input_repository.dart';
import '../../domain/usecases/plant_seed_usecase.dart';

part 'input_provider.g.dart';

@riverpod
InputRemoteDatasource inputRemoteDatasource(InputRemoteDatasourceRef ref) =>
    InputRemoteDatasourceImpl(supabase: ref.watch(supabaseClientProvider));

@riverpod
InputRepository inputRepository(InputRepositoryRef ref) =>
    InputRepositoryImpl(remote: ref.watch(inputRemoteDatasourceProvider));

@riverpod
PlantSeedUsecase plantSeedUsecase(PlantSeedUsecaseRef ref) =>
    PlantSeedUsecase(repository: ref.watch(inputRepositoryProvider));

enum InputStatus { idle, loading, success, error }

class InputState {
  final InputStatus status;
  final String? errorMessage;
  const InputState({this.status = InputStatus.idle, this.errorMessage});
}

@riverpod
class InputNotifier extends _$InputNotifier {
  @override
  InputState build() => const InputState();

  Future<bool> plantSeed({required String title, String? category}) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      state = const InputState(status: InputStatus.error, errorMessage: '로그인이 필요합니다.');
      return false;
    }
    final uid = user.id;
    final uidMsg = UserIdGuard.validationMessage(uid);
    if (uidMsg != null) {
      state = InputState(status: InputStatus.error, errorMessage: uidMsg);
      return false;
    }
    state = const InputState(status: InputStatus.loading);
    final result = await ref.read(plantSeedUsecaseProvider)
        .execute(userId: uid, title: title, category: category);
    return result.fold(
      (f) { state = InputState(status: InputStatus.error, errorMessage: f.message); return false; },
      (_) { state = const InputState(status: InputStatus.success); return true; },
    );
  }

  void reset() => state = const InputState();
}
