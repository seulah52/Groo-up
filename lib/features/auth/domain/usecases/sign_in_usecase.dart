import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInUsecase {
  final AuthRepository _repository;
  const SignInUsecase({required AuthRepository repository}) : _repository = repository;

  Future<Either<Failure, UserEntity>> execute({
    required String email, required String password}) =>
      _repository.signInWithEmail(email: email, password: password);
}
