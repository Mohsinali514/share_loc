import 'package:share_loc/core/common/usecase/usecase.dart';
import 'package:share_loc/core/utils/typedef.dart';
import 'package:share_loc/features/auth/domain/repositories/auth_repo.dart';

class ForgotPassword extends UsecaseWithParams<void, String> {
  const ForgotPassword(this._repo);

  final AuthRepo _repo;

  @override
  FutureResult<void> call(String params) => _repo.forgotPassword(params);
}
