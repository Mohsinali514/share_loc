import 'package:share_loc/core/common/usecase/usecase.dart';
import 'package:share_loc/core/enums/update_creator.dart';
import 'package:share_loc/core/utils/typedef.dart';
import 'package:share_loc/features/circle/domain/repositories/circle_repo.dart';
import 'package:equatable/equatable.dart';

class UpdateCreatorRole extends UsecaseWithParams<void, RequiredParams> {
  UpdateCreatorRole(this._repo);
  final CircleRepo _repo;

  @override
  FutureResult<void> call(RequiredParams params) =>
      _repo.updateCreatorRole(circleId: params.circleId, role: params.role);
}

class RequiredParams extends Equatable {
  const RequiredParams({
    required this.circleId,
    required this.role,
  });

  const RequiredParams.empty()
      : circleId = '',
        role = Role.other;

  final String circleId;
  final Role role;

  @override
  List<Object?> get props => [circleId, role];
}
