import 'package:share_loc/core/common/providers/user_provider.dart';
import 'package:share_loc/core/common/widgets/btn.dart';
import 'package:share_loc/core/common/widgets/gradient_background.dart';
import 'package:share_loc/core/res/colours.dart';
import 'package:share_loc/core/res/media_res.dart';
import 'package:share_loc/core/utils/constants.dart';
import 'package:share_loc/core/utils/core_utils.dart';
import 'package:share_loc/features/auth/data/models/user_model.dart';
import 'package:share_loc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final emailController = TextEditingController();
  final fullNameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool isPasswordValid = false;
  bool doPasswordsMatch = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    emailController.dispose();
    fullNameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (_, state) {
          if (state.signUpState.isFailure) {
            CoreUtils.toastInfo(
              msg: state.signUpState.error as String,
              backgroundColor: Colors.red,
              gravity: ToastGravity.TOP,
            );
          } else if (state.signUpState.isLoading) {
            CoreUtils.toastInfo(
              msg: 'Signing up...',
            );
          } else if (state.signUpState.isLoaded) {
            context.read<AuthBloc>().add(
                  SignInEvent(
                    email: emailController.text.trim(),
                    password: passwordController.text.trim(),
                  ),
                );
          } else if (state.signInState.isLoaded) {
            context
                .read<UserProvider>()
                .initUser(state.signInState.value! as LocalUserModel);
            Navigator.pushReplacementNamed(context, Constants.welcome);
          }
        },
        child: Stack(
          children: [
            GradientBackground(
              image: MediaRes.authGradientBackground,
              child: SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 25,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            const Text(
                              'Create your new account',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Create account and enjoy all services',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.dimText,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildFieldTitle('Username'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: fullNameController,
                              hint: 'Type your username',
                              icon: Icons.person,
                              validator: (value) =>
                                  value!.isEmpty ? 'Enter a username' : null,
                            ),
                            const SizedBox(height: 15),
                            _buildFieldTitle('Email'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: emailController,
                              hint: 'Type your email',
                              icon: Icons.email,
                              validator: (value) => value!.contains('@')
                                  ? null
                                  : 'Enter a valid email',
                            ),
                            const SizedBox(height: 15),
                            _buildFieldTitle('Password'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: passwordController,
                              hint: 'Type your password',
                              icon: Icons.lock,
                              obscureText: obscurePassword,
                              toggleObscure: () => setState(
                                () => obscurePassword = !obscurePassword,
                              ),
                              onChanged: (value) => setState(() {
                                isPasswordValid = _isPasswordValid(value);
                                doPasswordsMatch =
                                    value == confirmPasswordController.text;
                              }),
                              validator: (value) => value!.length >= 6
                                  ? null
                                  : 'Password too short',
                            ),
                            const SizedBox(height: 15),
                            _buildFieldTitle('Confirm Password'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: confirmPasswordController,
                              hint: 'Confirm password',
                              icon: Icons.lock_outline,
                              obscureText: obscureConfirmPassword,
                              toggleObscure: () => setState(
                                () => obscureConfirmPassword =
                                    !obscureConfirmPassword,
                              ),
                              onChanged: (value) => setState(() {
                                doPasswordsMatch =
                                    value == passwordController.text;
                              }),
                              validator: (value) =>
                                  value == passwordController.text
                                      ? null
                                      : 'Passwords do not match',
                            ),
                            const SizedBox(height: 10),
                            if (passwordController.text.isNotEmpty)
                              _buildValidationText(
                                isPasswordValid,
                                'Minimum 8 characters',
                              ),
                            if (confirmPasswordController.text.isNotEmpty)
                              _buildValidationText(
                                doPasswordsMatch,
                                'Passwords match',
                                isErrorText: false,
                              ),
                            const SizedBox(height: 80),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: true,
                                  onChanged: (bool? value) {},
                                  activeColor: AppColors.mainColor,
                                ),
                                const Expanded(
                                  child: Text(
                                    'I Agree with Terms of Service and Privacy Policy',
                                    style: TextStyle(
                                      color: AppColors.text,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ResponsiveButton(
                              label: 'Next',
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  context.read<AuthBloc>().add(
                                        SignUpEvent(
                                          email: emailController.text.trim(),
                                          password:
                                              passwordController.text.trim(),
                                          name: fullNameController.text.trim(),
                                        ),
                                      );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isPasswordValid(String password) {
    return password.length >= 8;
  }

  Widget _buildFieldTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.lightText,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    VoidCallback? toggleObscure,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      height: 45,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          prefixIcon: Icon(icon, color: Colors.grey),
          suffixIcon: toggleObscure != null
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: toggleObscure,
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildValidationText(
    bool condition,
    String message, {
    bool isErrorText = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            condition ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: condition ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 6),
          Text(
            message,
            style: TextStyle(
              color: condition
                  ? (isErrorText ? Colors.green : Colors.green)
                  : Colors.red,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
