import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/trend_log_entity.dart';

abstract interface class InsightRepository {
  Future<Either<Failure, List<TrendLogEntity>>> getTrending({InsightCategory? category});
  /// 현재 사용자의 북마크된 트렌드 로그 id 집합
  Future<Either<Failure, Set<String>>> fetchBookmarkedTrendIds(String userId);
  Future<Either<Failure, Unit>> addBookmark(String userId, String trendLogId);
  Future<Either<Failure, Unit>> removeBookmark(String userId, String trendLogId);
}
