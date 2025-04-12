import 'package:equatable/equatable.dart';

class Circle extends Equatable {
  const Circle({
    required this.circleName,
    required this.circleId,
    required this.creatorId,
    required this.creatorRole,
    required this.invitationCode,
    this.members = const [],
  });

  const Circle.empty()
      : this(
          circleName: '',
          circleId: '',
          creatorId: '',
          invitationCode: '',
          creatorRole: '',
        );

  final String circleName;
  final String circleId;
  final String creatorId;
  final String creatorRole;
  final String? invitationCode;
  final List<String> members;

  @override
  String toString() {
    return 'LocalCircle(circleName: $circleName, circleId: $circleId, creatorId: $creatorId, creatorRole: $creatorRole, invitationCode: $invitationCode, members: $members)';
  }

  @override
  List<Object?> get props {
    return [
      circleName,
      circleId,
      creatorId,
      creatorRole,
      invitationCode,
      members,
    ];
  }
}
