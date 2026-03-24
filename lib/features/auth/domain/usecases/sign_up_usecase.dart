import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpUsecase {
  final AuthRepository _repository;
  const SignUpUsecase({required AuthRepository repository}) : _repository = repository;

  Future<Either<Failure, UserEntity>> execute({
    required String email, required String password, required String username}) =>
      _repository.signUpWithEmail(email: email, password: password, username: username);
}
