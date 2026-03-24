import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/groo_entity.dart';
import '../entities/growth_stage.dart';
import '../repositories/garden_repository.dart';

class UpdateGrowthStageUsecase {
  final GardenRepository _repository;
  const UpdateGrowthStageUsecase({required GardenRepository repository}) : _repository = repository;
  Future<Either<Failure, GrooEntity>> execute(String grooId, GrowthStage newStage) =>
      _repository.updateGrowthStage(grooId, newStage);
}
