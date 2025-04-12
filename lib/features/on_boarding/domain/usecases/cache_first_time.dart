import 'package:share_loc/core/common/usecase/usecase.dart';
import 'package:share_loc/core/utils/typedef.dart';
import 'package:share_loc/features/on_boarding/domain/repositories/on_boarding_repository.dart';

class CacheFirstTime extends UsecaseWithOutParams {
  CacheFirstTime(this._repository);

  final OnBoardingRepository _repository;

  @override
  FutureResult call() async => _repository.cacheFirstTime();
}
