import 'package:dartz/dartz.dart';
import 'package:share_loc/core/common/errors/exceptions.dart';
import 'package:share_loc/core/common/errors/failure.dart';
import 'package:share_loc/core/utils/typedef.dart';
import 'package:share_loc/features/on_boarding/data/data_source/on_boarding_local_data_src.dart';
import 'package:share_loc/features/on_boarding/domain/repositories/on_boarding_repository.dart';

class OnBoardingRepoImpl implements OnBoardingRepository {
  OnBoardingRepoImpl(this._localDataSrc);

  final OnBoardingLDS _localDataSrc;

  @override
  FutureResult<void> cacheFirstTime() async {
    try {
      await _localDataSrc.cacheFirstTime();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(
        CacheFailure.fromException(e),
      );
    }
  }

  @override
  FutureResult<bool> checkIfUserIsFirstTime() async {
    try {
      final result = await _localDataSrc.checkIfUserIsFirstTime();
      return Right(result);
    } on CacheException catch (e) {
      return Left(
        CacheFailure.fromException(e),
      );
    }
  }
}
