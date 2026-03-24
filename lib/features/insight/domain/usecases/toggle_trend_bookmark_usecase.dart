import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../repositories/insight_repository.dart';

class ToggleTrendBookmarkUsecase {
  final InsightRepository _repository;

  const ToggleTrendBookmarkUsecase({required InsightRepository repository})
      : _repository = repository;

  /// 이미 북마크면 제거, 아니면 추가
  Future<Either<Failure, Unit>> execute({
    required String userId,
    required String trendLogId,
    required bool currentlyBookmarked,
  }) {
    if (currentlyBookmarked) {
      return _repository.removeBookmark(userId, trendLogId);
    }
    return _repository.addBookmark(userId, trendLogId);
  }
}
