import 'package:share_loc/core/common/usecase/usecase.dart';
import 'package:share_loc/core/utils/typedef.dart';
import 'package:share_loc/features/auth/domain/repositories/auth_repo.dart';
import 'package:equatable/equatable.dart';

class SignUp extends UsecaseWithParams<void, SignUpParams> {
  const SignUp(this._repo);

  final AuthRepo _repo;
  @override
  FutureResult<void> call(SignUpParams params) => _repo.signUp(
        email: params.email,
        fullName: params.fullName,
        password: params.password,
      );
}

class SignUpParams extends Equatable {
  const SignUpParams({
    required this.email,
    required this.password,
    required this.fullName,
  });

  static const empty = SignUpParams(email: '', password: '', fullName: '');

  final String email;
  final String password;
  final String fullName;

  @override
  List<Object?> get props => [email, password, fullName];
}
