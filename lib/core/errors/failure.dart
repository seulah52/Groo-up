import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  final String message;
  const Failure({required this.message});
  @override
  List<Object?> get props => [message];
}

final class ServerFailure extends Failure {
  final String? code;
  const ServerFailure({required super.message, this.code});
}
final class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}
final class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required super.message});
}

/// plantSeed 등 입력 검증 실패
final class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

