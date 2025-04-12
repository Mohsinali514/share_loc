import 'package:share_loc/core/common/usecase/usecase.dart';
import 'package:share_loc/core/utils/typedef.dart';
import 'package:share_loc/features/circle/domain/entities/circle.dart';
import 'package:share_loc/features/circle/domain/repositories/circle_repo.dart';
import 'package:equatable/equatable.dart';

class CreateCircle extends UsecaseWithParams<Circle, CreateCircleParams> {
  CreateCircle(this._repo);
  final CircleRepo _repo;

  @override
  FutureResult<Circle> call(CreateCircleParams params) =>
      _repo.createCircle(name: params.name, phoneNumber: params.phoneNumber);
}

class CreateCircleParams extends Equatable {
  const CreateCircleParams({
    required this.name,
    required this.phoneNumber,
  });

  const CreateCircleParams.empty()
      : name = '',
        phoneNumber = '';

  final String name;
  final String phoneNumber;

  @override
  List<Object?> get props => [name, phoneNumber];
}
