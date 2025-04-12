import 'package:share_loc/core/enums/update_user.dart';
import 'package:share_loc/core/utils/typedef.dart';
import 'package:share_loc/features/auth/domain/entities/user.dart';

abstract class AuthRepo {
  const AuthRepo();

  FutureResult<LocalUser> signIn({
    required String email,
    required String password,
  });

  FutureResult<void> signUp({
    required String email,
    required String fullName,
    required String password,
  });

  FutureResult<void> forgotPassword(
    String email,
  );

  FutureResult<void> updateUser({
    required UpdateUserAction action,
    required dynamic userData,
  });
}
