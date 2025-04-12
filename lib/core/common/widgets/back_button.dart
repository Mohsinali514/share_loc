import 'package:flutter/material.dart';

class BackButtonWidget extends StatelessWidget {
  const BackButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context), // Back button action
      child: const CircleAvatar(
        backgroundColor: Colors.black,
        child: Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
