import 'dart:convert';

import 'package:share_loc/features/circle/domain/entities/circle.dart';

class LocalCircleModel extends Circle {
  const LocalCircleModel({
    required super.circleName,
    required super.circleId,
    required super.creatorId,
    required super.creatorRole,
    required super.invitationCode,
    super.members,
  });

  const LocalCircleModel.empty()
      : this(
          circleName: '',
          circleId: '',
          creatorId: '',
          invitationCode: '',
          creatorRole: '',
        );

  factory LocalCircleModel.fromMap(Map<String, dynamic> map) {
    return LocalCircleModel(
      circleName: map['circleName'] as String? ?? '',
      circleId: map['circleId'] as String? ?? '',
      creatorId: map['creatorId'] as String? ?? '',
      creatorRole: map['creatorRole'] as String? ?? '',
      invitationCode: map['invitationCode'] as String? ?? '',
      members: List<String>.from(map['members'] as List<String>? ?? []),
    );
  }

  Circle copyWith({
    String? circleName,
    String? circleId,
    String? creatorId,
    String? creatorRole,
    String? invitationCode,
    List<String>? members,
  }) {
    return Circle(
      circleName: circleName ?? this.circleName,
      circleId: circleId ?? this.circleId,
      creatorId: creatorId ?? this.creatorId,
      creatorRole: creatorRole ?? this.creatorRole,
      invitationCode: invitationCode ?? this.invitationCode,
      members: members ?? this.members,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'circleName': circleName,
      'circleId': circleId,
      'creatorId': creatorId,
      'creatorRole': creatorRole,
      'invitationCode': invitationCode,
      'members': members,
    };
  }

  String toJson() => json.encode(toMap());
}
