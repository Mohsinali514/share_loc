import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_loc/core/common/providers/user_provider.dart';
import 'package:share_loc/core/common/widgets/btn.dart';
import 'package:share_loc/core/common/widgets/gradient_background.dart';
import 'package:share_loc/core/res/colours.dart';
import 'package:share_loc/core/res/fonts.dart';
import 'package:share_loc/core/res/media_res.dart';
import 'package:share_loc/core/services/di.dart';
import 'package:share_loc/core/utils/constants.dart';
import 'package:share_loc/core/utils/core_utils.dart';
import 'package:share_loc/features/auth/data/models/user_model.dart';
import 'package:share_loc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:share_loc/features/auth/presentation/widgets/sign_in_form.dart';
import 'package:share_loc/features/on_boarding/presentation/cubit/on_boarding_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (_, state) {
          if (state.signInState.isFailure) {
            CoreUtils.toastInfo(
              msg: state.signInState.error as String,
              backgroundColor: Colors.red,
              gravity: ToastGravity.TOP,
            );
          } else if (state.signInState.isLoading) {
            CoreUtils.toastInfo(
              msg: 'Signing in..',
              backgroundColor: AppColors.mainColor,
              gravity: ToastGravity.TOP,
            );
          } else if (state.signInState.isLoaded) {
            context
                .read<UserProvider>()
                .initUser(state.signInState.value! as LocalUserModel);
            CoreUtils.toastInfo(
              msg: 'Success',
              gravity: ToastGravity.TOP,
              backgroundColor: Colors.green,
            );
            Navigator.of(context).pushNamedAndRemoveUntil(
              Constants.welcome,
              (Route<dynamic> route) => false,
            );
          }
        },
        builder: (context, state) {
          return GradientBackground(
            image: MediaRes.authGradientBackground,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Easy to learn, discover more skills.',
                        style: TextStyle(
                          fontFamily: Fonts.aeonik,
                          fontWeight: FontWeight.w700,
                          fontSize: 32,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sign in to your account',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              fontFamily: Fonts.aeonik,
                              letterSpacing: 0.8,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SignInForm(
                        emailController: emailController,
                        passwordController: passwordController,
                        formKey: formKey,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/forgot-password');
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(color: AppColors.mainColor),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                Constants.signUpScreen,
                              );
                            },
                            child: const Text(
                              'Register Account?',
                              style: TextStyle(color: AppColors.mainColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      ResponsiveButton(
                        label: 'Sign In',
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          FirebaseAuth.instance.currentUser?.reload();
                          if (formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(
                                  SignInEvent(
                                    email: emailController.text.trim(),
                                    password: passwordController.text.trim(),
                                  ),
                                );
                          }
                        },
                        isLoading: state.signInState.isLoading,
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool(
                              Constants.kFirstTimeKey,
                              true,
                            );
                            await sl<OnBoardingCubit>()
                                .checkIfUserIsFirstTime();
                            await Navigator.pushReplacementNamed(
                              context,
                              Constants.onBoardingScreen,
                            );
                          },
                          child: const Text(
                            'Remove cache!',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
