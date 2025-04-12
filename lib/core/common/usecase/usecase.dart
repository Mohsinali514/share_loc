import 'package:share_loc/core/utils/typedef.dart';

abstract class UsecaseWithParams<T, Params> {
  const UsecaseWithParams();

  FutureResult<T> call(Params params);
}

abstract class UsecaseWithOutParams<T> {
  const UsecaseWithOutParams();
  FutureResult<T> call();
}
