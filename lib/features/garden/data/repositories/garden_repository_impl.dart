import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/groo_entity.dart';
import '../../domain/entities/growth_stage.dart';
import '../../domain/repositories/garden_repository.dart';
import '../datasources/groo_remote_datasource.dart';

class GardenRepositoryImpl implements GardenRepository {
  final GrooRemoteDatasource _remote;
  const GardenRepositoryImpl({required GrooRemoteDatasource remote}) : _remote = remote;

  @override
  Future<Either<Failure, List<GrooEntity>>> getAllGroos(String userId) async {
    try {
      return Right((await _remote.fetchAllGroos(userId)).map((m) => m.toEntity()).toList());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) { return Left(UnexpectedFailure(message: e.toString())); }
  }

  @override
  Future<Either<Failure, GrooEntity>> getGrooById(String id) async {
    try { return Right((await _remote.fetchGrooById(id)).toEntity()); }
    on PostgrestException catch (e) { return Left(ServerFailure(message: e.message, code: e.code)); }
    catch (e) { return Left(UnexpectedFailure(message: e.toString())); }
  }

  @override
  Future<Either<Failure, GrooEntity>> createGroo(GrooEntity groo) async {
    try {
      final model = await _remote.insertGroo({
        'user_id': groo.userId, 'title': groo.title,
        'description': groo.description, 'category': groo.category,
        'completion_rate': groo.completionRate,
        'growth_stage': groo.growthStage.name,
        'health_status': groo.healthStatus, 'health_score': groo.healthScore,
      });
      return Right(model.toEntity());
    } on PostgrestException catch (e) { return Left(ServerFailure(message: e.message, code: e.code)); }
    catch (e) { return Left(UnexpectedFailure(message: e.toString())); }
  }

  @override
  Future<Either<Failure, GrooEntity>> updateGrowthStage(String grooId, GrowthStage newStage) async {
    try { return Right((await _remote.updateStage(grooId, newStage.name)).toEntity()); }
    on PostgrestException catch (e) { return Left(ServerFailure(message: e.message, code: e.code)); }
    catch (e) { return Left(UnexpectedFailure(message: e.toString())); }
  }

  @override
  Future<Either<Failure, GrooEntity>> updateHealthScore(String grooId, int score) async {
    try { return Right((await _remote.updateHealthScore(grooId, score)).toEntity()); }
    on PostgrestException catch (e) { return Left(ServerFailure(message: e.message, code: e.code)); }
    catch (e) { return Left(UnexpectedFailure(message: e.toString())); }
  }

  @override
  Future<Either<Failure, GrooEntity>> updateCompletionRate(
    String grooId,
    int completionRate,
  ) async {
    try {
      return Right(
        (await _remote.updateCompletion(grooId, completionRate)).toEntity(),
      );
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteGroo(String id) async {
    try { await _remote.deleteGroo(id); return const Right(unit); }
    on PostgrestException catch (e) { return Left(ServerFailure(message: e.message, code: e.code)); }
    catch (e) { return Left(UnexpectedFailure(message: e.toString())); }
  }
}
