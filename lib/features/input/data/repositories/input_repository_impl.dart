import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/supabase_error_mapper.dart';
import '../../../../core/utils/user_id_guard.dart';
import '../../../garden/domain/entities/groo_entity.dart';
import '../../domain/repositories/input_repository.dart';
import '../datasources/input_remote_datasource.dart';

class InputRepositoryImpl implements InputRepository {
  final InputRemoteDatasource _remote;
  const InputRepositoryImpl({required InputRemoteDatasource remote}) : _remote = remote;

  @override
  Future<Either<Failure, GrooEntity>> plantSeed({
    required String userId, required String title, String? category}) async {
    final invalid = UserIdGuard.validationFailure(userId);
    if (invalid != null) return Left(invalid);
    try {
      return Right(
        (await _remote.plantSeed(
          userId: userId.trim(),
          title: title,
          category: category,
        ))
            .toEntity(),
      );
    } on ArgumentError catch (e) {
      return Left(ValidationFailure(message: e.message?.toString() ?? '유저 ID가 올바르지 않습니다.'));
    } on StateError catch (e) {
      return Left(ValidationFailure(message: e.message));
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
}
