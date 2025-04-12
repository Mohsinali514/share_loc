import 'package:dartz/dartz.dart';
import 'package:share_loc/core/common/errors/failure.dart';
import 'package:share_loc/core/network/data_state.dart';
import 'package:share_loc/features/auth/domain/entities/user.dart';
import 'package:share_loc/features/circle/domain/entities/circle.dart';

typedef FutureResult<T> = Future<Either<Failure, T>>;
typedef FutureVoid = FutureResult<void>;

typedef DataMap = Map<String, dynamic>;

// OnBoarding
typedef CacheFirstTimeState = Data<void>;
typedef CheckIfUserIsFirstTimeState = Data<bool>;

// Auth
typedef SignInState = Data<LocalUser>;
typedef SignUpState = Data<void>;
typedef ForgotPasswordState = Data<void>;
typedef UpdateUserState = Data<void>;

// Circle
typedef CreateCircleState = Data<Circle>;
typedef UpdateCreatorRoleState = Data<void>;
typedef JoinCircleState = Data<void>;
