import 'package:share_loc/core/res/colours.dart';
import 'package:flutter/material.dart';

class SignInForm extends StatelessWidget {
  const SignInForm({
    required this.emailController,
    required this.passwordController,
    required this.formKey,
    super.key,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldTitle('Email'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: emailController,
            hint: 'Type your email',
            icon: Icons.email,
            validator: (value) =>
                value!.contains('@') ? null : 'Enter a valid email',
          ),
          const SizedBox(height: 15),
          _buildFieldTitle('Password'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: passwordController,
            hint: 'Type your password',
            icon: Icons.lock,
            obscureText: true,
            validator: (value) =>
                value!.length >= 6 ? null : 'Password too short',
          ),
        ],
      ),
    );
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
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      height: 45,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
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
        ),
      ),
    );
  }
}
