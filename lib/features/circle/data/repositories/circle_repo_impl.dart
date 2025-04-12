import 'package:dartz/dartz.dart';
import 'package:share_loc/core/common/errors/exceptions.dart';
import 'package:share_loc/core/common/errors/failure.dart';
import 'package:share_loc/core/enums/update_creator.dart';
import 'package:share_loc/core/utils/typedef.dart';
import 'package:share_loc/features/circle/data/datasources/circle_remote_data_src.dart';
import 'package:share_loc/features/circle/domain/entities/circle.dart';
import 'package:share_loc/features/circle/domain/repositories/circle_repo.dart';

class CircleRepoImpl implements CircleRepo {
  CircleRepoImpl(this._dataSource);
  final CircleRemoteDataSrc _dataSource;

  @override
  FutureResult<Circle> createCircle({
    required String name,
    required String phoneNumber,
  }) async {
    try {
      final result =
          await _dataSource.createCircle(name: name, phoneNumber: phoneNumber);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  FutureResult<void> joinCircle(String invitationCode) async {
    try {
      await _dataSource.joinCircle(invitationCode);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  FutureResult<void> updateCreatorRole({
    required Role role,
    required String circleId,
  }) async {
    try {
      await _dataSource.updateCreatorRole(role: role, circleId: circleId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
