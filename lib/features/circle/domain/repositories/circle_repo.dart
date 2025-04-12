import 'package:share_loc/core/enums/update_creator.dart';
import 'package:share_loc/core/utils/typedef.dart';
import 'package:share_loc/features/circle/domain/entities/circle.dart';

abstract class CircleRepo {
  const CircleRepo();

  FutureResult<Circle> createCircle({
    required String name,
    required String phoneNumber,
  });

  FutureResult<void> updateCreatorRole({
    required Role role,
    required String circleId,
  });

  FutureResult<void> joinCircle(
    String invitationCode,
  );
}
