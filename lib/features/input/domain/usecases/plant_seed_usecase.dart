import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/user_id_guard.dart';
import '../../../garden/domain/entities/groo_entity.dart';
import '../repositories/input_repository.dart';

class PlantSeedUsecase {
  final InputRepository _repository;
  const PlantSeedUsecase({required InputRepository repository}) : _repository = repository;

  Future<Either<Failure, GrooEntity>> execute({
    required String userId,
    required String title,
    String? category,
  }) async {
    final invalid = UserIdGuard.validationFailure(userId);
    if (invalid != null) return Left(invalid);
    return _repository.plantSeed(
      userId: userId.trim(),
      title: title,
      category: category,
    );
  }
}
