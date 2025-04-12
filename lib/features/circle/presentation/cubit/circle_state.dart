import 'package:share_loc/core/network/data_state.dart';
import 'package:share_loc/core/utils/typedef.dart';
import 'package:equatable/equatable.dart';

class CircleState extends Equatable {
  const CircleState({
    this.createCircleState = const Data(),
    this.updateCreatorRoleState = const Data(),
    this.joinCircleState = const Data(),
  });

  final CreateCircleState createCircleState;
  final UpdateCreatorRoleState updateCreatorRoleState;
  final JoinCircleState joinCircleState;

  CircleState copyWith({
    CreateCircleState? createCircleState,
    UpdateCreatorRoleState? updateCreatorRoleState,
    JoinCircleState? joinCircleState,
  }) {
    return CircleState(
      createCircleState: createCircleState ?? this.createCircleState,
      updateCreatorRoleState:
          updateCreatorRoleState ?? this.updateCreatorRoleState,
      joinCircleState: joinCircleState ?? this.joinCircleState,
    );
  }

  @override
  List<Object> get props =>
      [createCircleState, updateCreatorRoleState, joinCircleState];
}
