import 'package:bloc/bloc.dart';
import 'package:share_loc/core/enums/update_creator.dart';
import 'package:share_loc/core/network/data_state.dart';
import 'package:share_loc/features/circle/domain/usecases/create_circle.dart';
import 'package:share_loc/features/circle/domain/usecases/join_circle.dart';
import 'package:share_loc/features/circle/domain/usecases/update_creator_role.dart';
import 'package:share_loc/features/circle/presentation/cubit/circle_state.dart';

class CircleCubit extends Cubit<CircleState> {
  CircleCubit({
    required CreateCircle createCircle,
    required UpdateCreatorRole updateCreatorRole,
    required JoinCircle joinCircle,
  })  : _createCircle = createCircle,
        _updateCreatorRole = updateCreatorRole,
        _joinCircle = joinCircle,
        super(const CircleState());

  final CreateCircle _createCircle;
  final JoinCircle _joinCircle;
  final UpdateCreatorRole _updateCreatorRole;

  //! Create Circle ****************
  Future<void> createCircle(String name, String phoneNumber) async {
    emit(state.copyWith(createCircleState: const Data.loading()));

    final result = await _createCircle(
      CreateCircleParams(name: name, phoneNumber: phoneNumber),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          createCircleState: Data.failure(error: failure.errorMessage),
        ),
      ),
      (circle) => emit(
        state.copyWith(
          createCircleState: Data.loaded(value: circle),
        ),
      ),
    );
  }

  //! Update Creator Role  ****************
  Future<void> updateCreatorRole(String circleId, Role role) async {
    emit(state.copyWith(updateCreatorRoleState: const Data.loading()));

    final result = await _updateCreatorRole(
      RequiredParams(circleId: circleId, role: role),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          updateCreatorRoleState: Data.failure(error: failure.errorMessage),
        ),
      ),
      (_) => emit(
        state.copyWith(
          updateCreatorRoleState: const Data.loaded(),
        ),
      ),
    );
  }

  //! Join Circle ****************
  Future<void> joinCircle(String invitationCode) async {
    emit(state.copyWith(joinCircleState: const Data.loading()));

    final result = await _joinCircle(invitationCode);

    result.fold(
      (failure) => emit(
        state.copyWith(
          joinCircleState: Data.failure(error: failure.errorMessage),
        ),
      ),
      (_) => emit(
        state.copyWith(
          joinCircleState: const Data.loaded(),
        ),
      ),
    );
  }
}
