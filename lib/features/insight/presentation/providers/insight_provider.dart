import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../data/datasources/insight_remote_datasource.dart';
import '../../data/repositories/insight_repository_impl.dart';
import '../../domain/entities/trend_log_entity.dart';
import '../../domain/repositories/insight_repository.dart';
import '../../domain/usecases/get_trending_insights_usecase.dart';
import '../../domain/usecases/toggle_trend_bookmark_usecase.dart';

part 'insight_provider.g.dart';

@riverpod
InsightRemoteDatasource insightRemoteDatasource(InsightRemoteDatasourceRef ref) =>
    InsightRemoteDatasourceImpl(supabase: ref.watch(supabaseClientProvider));

@riverpod
InsightRepository insightRepository(InsightRepositoryRef ref) =>
    InsightRepositoryImpl(remote: ref.watch(insightRemoteDatasourceProvider));

@riverpod
GetTrendingInsightsUsecase getTrendingInsightsUsecase(
  GetTrendingInsightsUsecaseRef ref,
) =>
    GetTrendingInsightsUsecase(repository: ref.watch(insightRepositoryProvider));

@riverpod
ToggleTrendBookmarkUsecase toggleTrendBookmarkUsecase(
  ToggleTrendBookmarkUsecaseRef ref,
) =>
    ToggleTrendBookmarkUsecase(repository: ref.watch(insightRepositoryProvider));

/// 탭별 트렌드 목록
@riverpod
Future<List<TrendLogEntity>> trendLogsForCategory(
  TrendLogsForCategoryRef ref,
  InsightCategory category,
) async {
  final usecase = ref.watch(getTrendingInsightsUsecaseProvider);
  final result = await usecase.execute(category: category);
  return result.fold((f) => throw Exception(f.message), (list) => list);
}

/// 로그인 사용자의 북마크 id (없으면 빈 집합)
@riverpod
Future<Set<String>> bookmarkedTrendIds(BookmarkedTrendIdsRef ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return {};
  final result =
      await ref.watch(insightRepositoryProvider).fetchBookmarkedTrendIds(user.id);
  return result.fold((f) => throw Exception(f.message), (s) => s);
}
