import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_loc/core/common/providers/user_provider.dart';
import 'package:share_loc/core/common/views/page_under_construction.dart';
import 'package:share_loc/core/services/di.dart';
import 'package:share_loc/core/utils/constants.dart';
import 'package:share_loc/features/auth/data/models/user_model.dart';
import 'package:share_loc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:share_loc/features/auth/presentation/pages/sign_in_screen.dart';
import 'package:share_loc/features/auth/presentation/pages/sign_up_screen.dart';
import 'package:share_loc/features/circle/presentation/cubit/circle_cubit.dart';
import 'package:share_loc/features/circle/presentation/pages/add_location_screen.dart';
import 'package:share_loc/features/circle/presentation/pages/add_photo_screen.dart';
import 'package:share_loc/features/circle/presentation/pages/chat_screen.dart';
import 'package:share_loc/features/circle/presentation/pages/create_circle.dart';
import 'package:share_loc/features/circle/presentation/pages/designated_role_screen.dart';
import 'package:share_loc/features/circle/presentation/pages/invitation_code_screen.dart';
import 'package:share_loc/features/circle/presentation/pages/join_or_create_circle.dart';
import 'package:share_loc/features/circle/presentation/pages/onboarding.dart';
import 'package:share_loc/features/circle/presentation/pages/permission_screen.dart';
import 'package:share_loc/features/homepage/presentation/pages/add_place_screen.dart';
import 'package:share_loc/features/homepage/presentation/pages/add_see_places_screen.dart';
import 'package:share_loc/features/homepage/presentation/pages/homepage.dart';
import 'package:share_loc/features/on_boarding/presentation/cubit/on_boarding_cubit.dart';
import 'package:share_loc/features/on_boarding/presentation/pages/on_boarding_screen.dart';
import 'package:share_loc/features/settings/presentation/pages/circle_management_screen.dart';
import 'package:share_loc/features/settings/presentation/pages/settings_screen.dart';
import 'package:share_loc/features/welcome/presentation/pages/welcome.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _getUserDataOnAppStart({
  required String userId,
  required BuildContext context,
}) async {
  final userData = await sl<FirebaseFirestore>()
      .collection(Constants.dbUsers)
      .doc(userId)
      .get();
  final data = userData.data();
  if (data != null) {
    final userLocal = LocalUserModel.fromMap(data);
    context.read<UserProvider>().initUser(userLocal);
    if (userLocal.currentCircle != null) {
      Navigator.pushNamed(context, Constants.homePage);
    }
  }
}

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      final prefs = sl<SharedPreferences>();
      return _pageBuilder(
        (context) {
          if (prefs.getBool(Constants.kFirstTimeKey) ?? true) {
            return BlocProvider(
              create: (_) => sl<OnBoardingCubit>(),
              child: const OnBoardingScreen(),
            );
          } else if (sl<FirebaseAuth>().currentUser != null) {
            final user = sl<FirebaseAuth>().currentUser!;
            _getUserDataOnAppStart(userId: user.uid, context: context);
            return BlocProvider(
              create: (_) => sl<CircleCubit>(),
              child: const WelcomeScreen(),
            );
          }
          return BlocProvider(
            create: (_) => sl<AuthBloc>(),
            child: const SignInScreen(),
          );
        },
        settings: settings,
      );

    case Constants.welcome:
      return _pageBuilder(
        (_) => BlocProvider(
          create: (_) => sl<AuthBloc>(),
          child: const WelcomeScreen(),
        ),
        settings: settings,
      );

    case Constants.signInScreen:
      return _pageBuilder(
        (_) => BlocProvider(
          create: (_) => sl<AuthBloc>(),
          child: const SignInScreen(),
        ),
        settings: settings,
      );
    case Constants.signUpScreen:
      return _pageBuilder(
        (_) => BlocProvider(
          create: (_) => sl<AuthBloc>(),
          child: const SignUpScreen(),
        ),
        settings: settings,
      );

    case Constants.joinOrCreateCircleScreen:
      return _pageBuilder(
        (_) => BlocProvider.value(
          value: sl<CircleCubit>(),
          child: const JoinOrCreateCircleScreen(),
        ),
        settings: settings,
      );
    case Constants.createCircleScreen:
      return _pageBuilder(
        (_) => BlocProvider.value(
          value: sl<CircleCubit>(),
          child: const CreateCircleScreen(),
        ),
        settings: settings,
      );

    case Constants.invitationCodeSreen:
      return _pageBuilder(
        (_) => BlocProvider.value(
          value: sl<CircleCubit>(),
          child: const InvitationCodeScreen(),
        ),
        settings: settings,
      );

    case Constants.designatedRoleScreen:
      return _pageBuilder(
        (_) => BlocProvider.value(
          value: sl<CircleCubit>(),
          child: const DesignatedRoleScreen(),
        ),
        settings: settings,
      );

    case Constants.addPhotoScreen:
      return _pageBuilder(
        (_) => BlocProvider.value(
          value: sl<CircleCubit>(),
          child: const AddPhotoScreen(),
        ),
        settings: settings,
      );

    case Constants.permissionScreen:
      return _pageBuilder(
        (_) => BlocProvider.value(
          value: sl<CircleCubit>(),
          child: const PermissionScreen(),
        ),
        settings: settings,
      );

    case Constants.onBoarding:
      return _pageBuilder(
        (_) => BlocProvider.value(
          value: sl<CircleCubit>(),
          child: const OnBoarding(),
        ),
        settings: settings,
      );

    case Constants.addLocationScreen:
      return _pageBuilder(
        (_) => BlocProvider.value(
          value: sl<CircleCubit>(),
          child: const AddLocationScreen(),
        ),
        settings: settings,
      );

    case Constants.homePage:
      return _pageBuilder(
        (_) => BlocProvider.value(
          value: sl<CircleCubit>(),
          child: const HomePageScreen(),
        ),
        settings: settings,
      );

    case Constants.addSeePlacesScreen:
      return _pageBuilder(
        (_) => BlocProvider.value(
          value: sl<CircleCubit>(),
          child: const AddSeePlacesScreen(),
        ),
        settings: settings,
      );

    case Constants.addPlaceScreen:
      return _pageBuilder(
        (_) => BlocProvider.value(
          value: sl<CircleCubit>(),
          child: const AddPlaceScreen(),
        ),
        settings: settings,
      );

    case Constants.chatScreen:
      return _pageBuilder(
        (_) => BlocProvider.value(
          value: sl<CircleCubit>(),
          child: const ChatScreen(),
        ),
        settings: settings,
      );
    case Constants.settingScreen:
      return _pageBuilder(
        (_) => BlocProvider.value(
          value: sl<CircleCubit>(),
          child: const SettingsScreen(),
        ),
        settings: settings,
      );

    case Constants.circleManagement:
      return _pageBuilder(
        (_) => BlocProvider.value(
          value: sl<CircleCubit>(),
          child: const CircleManagementScreen(),
        ),
        settings: settings,
      );

    //  case '/forgot-password':
    // return _pageBuilder(
    //   (_) => const fui.ForgotPasswordScreen(),
    //   settings: settings,
    // );
    default:
      return _pageBuilder(
        (_) => const PageUnderConstruction(),
        settings: settings,
      );
  }
}

PageRouteBuilder<dynamic> _pageBuilder(
  Widget Function(BuildContext) page, {
  required RouteSettings settings,
}) {
  return PageRouteBuilder(
    settings: settings,
    transitionsBuilder: (_, animation, __, child) => FadeTransition(
      opacity: animation,
      child: child,
    ),
    pageBuilder: (context, _, __) => page(context),
  );
}
