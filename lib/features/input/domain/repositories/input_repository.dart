import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../garden/domain/entities/groo_entity.dart';

abstract interface class InputRepository {
  Future<Either<Failure, GrooEntity>> plantSeed({
    required String userId, required String title, String? category});
}
