import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/groo_entity.dart';
import '../repositories/garden_repository.dart';

class GetAllGroosUsecase {
  final GardenRepository _repository;
  const GetAllGroosUsecase({required GardenRepository repository}) : _repository = repository;
  Future<Either<Failure, List<GrooEntity>>> execute(String userId) =>
      _repository.getAllGroos(userId);
}
