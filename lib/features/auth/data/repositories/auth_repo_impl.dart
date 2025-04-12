import 'package:dartz/dartz.dart';
import 'package:share_loc/core/common/errors/exceptions.dart';
import 'package:share_loc/core/common/errors/failure.dart';
import 'package:share_loc/core/enums/update_user.dart';
import 'package:share_loc/core/utils/typedef.dart';
import 'package:share_loc/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:share_loc/features/auth/domain/entities/user.dart';
import 'package:share_loc/features/auth/domain/repositories/auth_repo.dart';

class AuthRepoImpl implements AuthRepo {
  AuthRepoImpl(this._dataSource);
  final AuthRemoteDataSource _dataSource;

  @override
  FutureResult<void> forgotPassword(String email) async {
    try {
      await _dataSource.forgotPassword(email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  FutureResult<LocalUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _dataSource.signIn(
        email: email,
        password: password,
      );

      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  FutureResult<void> signUp({
    required String email,
    required String fullName,
    required String password,
  }) async {
    try {
      await _dataSource.signUp(
        email: email,
        fullName: fullName,
        password: password,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  FutureResult<void> updateUser({
    required UpdateUserAction action,
    required dynamic userData,
  }) async {
    try {
      await _dataSource.updateUser(action: action, userData: userData);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
