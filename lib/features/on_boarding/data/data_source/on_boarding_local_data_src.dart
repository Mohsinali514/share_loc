import 'package:share_loc/core/common/errors/exceptions.dart';
import 'package:share_loc/core/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class OnBoardingLDS {
  const OnBoardingLDS();
  Future<void> cacheFirstTime();
  Future<bool> checkIfUserIsFirstTime();
}

class OnBoardingLDSImpl implements OnBoardingLDS {
  OnBoardingLDSImpl(this._preferences);

  final SharedPreferences _preferences;

  @override
  Future<void> cacheFirstTime() async {
    await _preferences.setBool(Constants.kFirstTimeKey, false);
  }

  @override
  Future<bool> checkIfUserIsFirstTime() async {
    try {
      final result = _preferences.getBool(Constants.kFirstTimeKey) ?? true;
      return result;
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }
}
