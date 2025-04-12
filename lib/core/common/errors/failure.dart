import 'package:share_loc/core/common/errors/exceptions.dart';
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  Failure({
    required this.statusCode,
    required this.message,
  }) : assert(
          statusCode is String || statusCode is int,
          'StatusCode cannot be a ${statusCode.runtimeType}',
        );

  final dynamic statusCode;
  final String message;

  String get errorMessage => '$statusCode' 'Error: $message';

  @override
  List<Object?> get props => [
        message,
        statusCode,
      ];
}

class CacheFailure extends Failure {
  CacheFailure({required super.statusCode, required super.message});

  CacheFailure.fromException(CacheException exception)
      : this(
          statusCode: exception.statusCode,
          message: exception.message,
        );
}

class ServerFailure extends Failure {
  ServerFailure({required super.statusCode, required super.message});

  ServerFailure.fromException(ServerException exception)
      : this(
          statusCode: exception.statusCode,
          message: exception.message,
        );
}

class APIFailure extends Failure {
  APIFailure({required super.statusCode, required super.message});

  APIFailure.fromException(APIException exception)
      : this(
          statusCode: exception.statusCode,
          message: exception.message,
        );
}
