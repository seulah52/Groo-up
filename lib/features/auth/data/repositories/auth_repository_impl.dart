import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/auth_exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/supabase_error_mapper.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remote;
  const AuthRepositoryImpl({required AuthRemoteDatasource remote}) : _remote = remote;

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email, required String password}) async {
    try {
      final user = await _remote.signInWithEmail(email: email, password: password);
      return Right(UserModel.fromSupabaseUser(user).toEntity());
    } on AuthSessionUserMismatchException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(ServerFailure(message: SupabaseErrorMapper.authMessage(e)));
    } on PostgrestException catch (e) {
      return Left(
        ServerFailure(
          message: SupabaseErrorMapper.toUserMessage(e),
          code: e.code?.toString(),
        ),
      );
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email, required String password, required String username}) async {
    try {
      final user = await _remote.signUpWithEmail(
        email: email, password: password, username: username);
      return Right(UserModel.fromSupabaseUser(user).toEntity());
    } on EmailConfirmationPendingException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthSessionUserMismatchException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(ServerFailure(message: SupabaseErrorMapper.authMessage(e)));
    } on PostgrestException catch (e) {
      return Left(
        ServerFailure(
          message: SupabaseErrorMapper.toUserMessage(e),
          code: e.code?.toString(),
        ),
      );
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await _remote.signOut();
      return const Right(unit);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  UserEntity? get currentUser {
    final user = _remote.currentUser;
    if (user == null) return null;
    return UserModel.fromSupabaseUser(user).toEntity();
  }
}
