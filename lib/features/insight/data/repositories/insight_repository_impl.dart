import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/supabase_error_mapper.dart';
import '../../domain/entities/trend_log_entity.dart';
import '../../domain/repositories/insight_repository.dart';
import '../datasources/insight_remote_datasource.dart';

class InsightRepositoryImpl implements InsightRepository {
  final InsightRemoteDatasource _remote;

  const InsightRepositoryImpl({required InsightRemoteDatasource remote})
      : _remote = remote;

  @override
  Future<Either<Failure, List<TrendLogEntity>>> getTrending({
    InsightCategory? category,
  }) async {
    try {
      final models = await _remote.fetchTrendLogs(category: category);
      return Right(models.map((m) => m.toEntity()).toList());
    } on PostgrestException catch (e) {
      return Left(mapPostgrestToFailure(e));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Set<String>>> fetchBookmarkedTrendIds(
    String userId,
  ) async {
    try {
      final ids = await _remote.fetchBookmarkedTrendIds(userId);
      return Right(ids);
    } on PostgrestException catch (e) {
      return Left(mapPostgrestToFailure(e));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> addBookmark(
    String userId,
    String trendLogId,
  ) async {
    try {
      await _remote.addBookmark(userId, trendLogId);
      return const Right(unit);
    } on PostgrestException catch (e) {
      return Left(mapPostgrestToFailure(e));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeBookmark(
    String userId,
    String trendLogId,
  ) async {
    try {
      await _remote.removeBookmark(userId, trendLogId);
      return const Right(unit);
    } on PostgrestException catch (e) {
      return Left(mapPostgrestToFailure(e));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
