import 'package:share_loc/core/utils/typedef.dart';

abstract class OnBoardingRepository {
  const OnBoardingRepository();

  FutureResult<void> cacheFirstTime();
  FutureResult<bool> checkIfUserIsFirstTime();
}
