import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/trend_log_entity.dart';
import '../repositories/insight_repository.dart';

class GetTrendingInsightsUsecase {
  final InsightRepository _repository;

  const GetTrendingInsightsUsecase({required InsightRepository repository})
      : _repository = repository;

  Future<Either<Failure, List<TrendLogEntity>>> execute({
    InsightCategory? category,
  }) =>
      _repository.getTrending(category: category);
}
