import 'package:share_loc/core/common/usecase/usecase.dart';
import 'package:share_loc/core/utils/typedef.dart';
import 'package:share_loc/features/auth/domain/entities/user.dart';
import 'package:share_loc/features/auth/domain/repositories/auth_repo.dart';
import 'package:equatable/equatable.dart';

class SignIn extends UsecaseWithParams<LocalUser, SignInParams> {
  SignIn(this._repo);
  final AuthRepo _repo;

  @override
  FutureResult<LocalUser> call(SignInParams params) {
    return _repo.signIn(email: params.email, password: params.password);
  }
}

class SignInParams extends Equatable {
  const SignInParams({
    required this.email,
    required this.password,
  });

  const SignInParams.empty()
      : email = '',
        password = '';

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}
