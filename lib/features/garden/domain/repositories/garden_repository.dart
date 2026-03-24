import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/groo_entity.dart';
import '../entities/growth_stage.dart';

abstract interface class GardenRepository {
  Future<Either<Failure, List<GrooEntity>>> getAllGroos(String userId);
  Future<Either<Failure, GrooEntity>>       getGrooById(String id);
  Future<Either<Failure, GrooEntity>>       createGroo(GrooEntity groo);
  Future<Either<Failure, GrooEntity>>       updateGrowthStage(String grooId, GrowthStage newStage);
  Future<Either<Failure, GrooEntity>>       updateHealthScore(String grooId, int score);
  Future<Either<Failure, GrooEntity>>       updateCompletionRate(String grooId, int completionRate);
  Future<Either<Failure, Unit>>             deleteGroo(String id);
}
