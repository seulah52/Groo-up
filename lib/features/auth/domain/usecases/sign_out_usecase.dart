import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../repositories/auth_repository.dart';

class SignOutUsecase {
  final AuthRepository _repository;
  const SignOutUsecase({required AuthRepository repository}) : _repository = repository;

  Future<Either<Failure, Unit>> execute() => _repository.signOut();
}
