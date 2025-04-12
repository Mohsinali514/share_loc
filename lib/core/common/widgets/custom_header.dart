import 'package:share_loc/core/res/colours.dart';
import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget {
  const CustomHeader({
    required this.imagePath,
    required this.onBackPressed,
    this.title = '',
    super.key,
  });

  final String imagePath;
  final String title;
  final VoidCallback onBackPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            height: 140,
          ),
        ),

        // Back button
        Positioned(
          top: 60,
          left: 20,
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.mainColor,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onBackPressed,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Padding(
                    padding: EdgeInsetsDirectional.only(start: 8),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Optional
        if (title.isNotEmpty)
          Positioned(
            top: 65,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
