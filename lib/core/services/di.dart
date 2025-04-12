import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:share_loc/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:share_loc/features/auth/data/repositories/auth_repo_impl.dart';
import 'package:share_loc/features/auth/domain/repositories/auth_repo.dart';
import 'package:share_loc/features/auth/domain/usecases/forgot_password.dart';
import 'package:share_loc/features/auth/domain/usecases/sign_in.dart';
import 'package:share_loc/features/auth/domain/usecases/sign_up.dart';
import 'package:share_loc/features/auth/domain/usecases/update_user.dart';
import 'package:share_loc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:share_loc/features/circle/data/datasources/circle_remote_data_src.dart';
import 'package:share_loc/features/circle/data/repositories/circle_repo_impl.dart';
import 'package:share_loc/features/circle/domain/repositories/circle_repo.dart';
import 'package:share_loc/features/circle/domain/usecases/create_circle.dart';
import 'package:share_loc/features/circle/domain/usecases/join_circle.dart';
import 'package:share_loc/features/circle/domain/usecases/update_creator_role.dart';
import 'package:share_loc/features/circle/presentation/cubit/circle_cubit.dart';
import 'package:share_loc/features/on_boarding/data/data_source/on_boarding_local_data_src.dart';
import 'package:share_loc/features/on_boarding/data/repositories/on_boarding_repo_impl.dart';
import 'package:share_loc/features/on_boarding/domain/repositories/on_boarding_repository.dart';
import 'package:share_loc/features/on_boarding/domain/usecases/cache_first_time.dart';
import 'package:share_loc/features/on_boarding/domain/usecases/check_if_user_is_first_time.dart';
import 'package:share_loc/features/on_boarding/presentation/cubit/on_boarding_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> inject() async {
  await _initOnBoarding();
  await _initAuth();
  await _initCircle();
}

// Auth
Future<void> _initAuth() async {
  sl
    ..registerFactory(
      () => AuthBloc(
        signIn: sl(),
        signUp: sl(),
        forgotPassword: sl(),
        updateUser: sl(),
      ),
    )
    ..registerLazySingleton(() => SignIn(sl()))
    ..registerLazySingleton(() => SignUp(sl()))
    ..registerLazySingleton(() => ForgotPassword(sl()))
    ..registerLazySingleton(() => UpdateUser(sl()))
    ..registerLazySingleton<AuthRepo>(() => AuthRepoImpl(sl()))
    ..registerCachedFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSrcImpl(
        authClient: sl(),
        cloudStoreClient: sl(),
        dbClient: sl(),
      ),
    )
    ..registerLazySingleton(() => FirebaseAuth.instance)
    ..registerLazySingleton(() => FirebaseFirestore.instance)
    ..registerLazySingleton(() => FirebaseStorage.instance);
}

// Circle
Future<void> _initCircle() async {
  sl
    ..registerFactory(
      () => CircleCubit(
        createCircle: sl(),
        updateCreatorRole: sl(),
        joinCircle: sl(),
      ),
    )
    ..registerLazySingleton(() => CreateCircle(sl()))
    ..registerLazySingleton(() => UpdateCreatorRole(sl()))
    ..registerLazySingleton(() => JoinCircle(sl()))
    ..registerLazySingleton<CircleRepo>(() => CircleRepoImpl(sl()))
    ..registerCachedFactory<CircleRemoteDataSrc>(
      () => CircleRemoteDataSrcImpl(
        cloudStoreClient: sl(),
        dbClient: sl(),
      ),
    );
}

Future<void> _initOnBoarding() async {
  final prefs = await SharedPreferences.getInstance();
  sl
    ..registerFactory(
      () => OnBoardingCubit(
        cacheFirstTime: sl(),
        checkIfUserIsFirstTime: sl(),
      ),
    )
    ..registerLazySingleton(() => CacheFirstTime(sl()))
    ..registerLazySingleton(() => CheckIfUserIsFirstTime(sl()))
    ..registerLazySingleton<OnBoardingRepository>(
      () => OnBoardingRepoImpl(sl()),
    )
    ..registerLazySingleton<OnBoardingLDS>(() => OnBoardingLDSImpl(sl()))
    ..registerLazySingleton(() => prefs);
}
