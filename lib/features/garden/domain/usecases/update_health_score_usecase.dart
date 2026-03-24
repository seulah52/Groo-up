import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/growth_calculator.dart';
import '../entities/groo_entity.dart';
import '../repositories/garden_repository.dart';

class UpdateHealthScoreUsecase {
  final GardenRepository _repository;
  const UpdateHealthScoreUsecase({required GardenRepository repository}) : _repository = repository;

  Future<Either<Failure, List<GrooEntity>>> execute(List<GrooEntity> groos) async {
    final updated = <GrooEntity>[];
    for (final groo in groos) {
      final newScore = GrowthCalculator.applyDecay(groo.healthScore, groo.lastActivityAt);
      if (newScore != groo.healthScore) {
        final result = await _repository.updateHealthScore(groo.id, newScore);
        result.fold((_) => updated.add(groo), (e) => updated.add(e));
      } else {
        updated.add(groo);
      }
    }
    return Right(updated);
  }
}
