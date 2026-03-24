import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/message_entity.dart';

abstract interface class InterviewRepository {
  Future<Either<Failure, List<MessageEntity>>> getMessages(String sessionId);
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String sessionId, required String grooId,
    required String content, required List<Map<String, String>> history,
  });
}
