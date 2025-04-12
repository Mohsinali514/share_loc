import 'package:share_loc/core/common/usecase/usecase.dart';
import 'package:share_loc/core/enums/update_user.dart';
import 'package:share_loc/core/utils/typedef.dart';
import 'package:share_loc/features/auth/domain/repositories/auth_repo.dart';
import 'package:equatable/equatable.dart';

class UpdateUser extends UsecaseWithParams<void, UpdateUserParams> {
  UpdateUser(this._repo);
  final AuthRepo _repo;

  @override
  FutureResult<void> call(UpdateUserParams params) =>
      _repo.updateUser(action: params.action, userData: params.userData);
}

class UpdateUserParams extends Equatable {
  const UpdateUserParams({required this.action, required this.userData});

  const UpdateUserParams.empty()
      : this(action: UpdateUserAction.displayName, userData: '');

  final UpdateUserAction action;
  final dynamic userData;

  @override
  List<dynamic> get props => [action, userData];
}
