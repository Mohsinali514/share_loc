import 'package:share_loc/core/common/usecase/usecase.dart';
import 'package:share_loc/core/utils/typedef.dart';
import 'package:share_loc/features/circle/domain/repositories/circle_repo.dart';

class JoinCircle extends UsecaseWithParams<void, String> {
  JoinCircle(this._repo);
  final CircleRepo _repo;

  @override
  FutureResult<void> call(String params) => _repo.joinCircle(params);
}
