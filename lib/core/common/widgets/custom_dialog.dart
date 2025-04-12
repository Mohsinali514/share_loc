import 'package:share_loc/core/res/colours.dart';
import 'package:flutter/material.dart';

Future<void> showCustomDialog({
  required BuildContext context,
  required String title,
  required String content,
  Color titleColor = AppColors.mainColor,
  VoidCallback? onPressed,
  bool showCancelButton = false,
}) async {
  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: titleColor,
        ),
      ),
      content: Text(
        content,
        style: const TextStyle(
          color: AppColors.text,
          fontSize: 15,
        ),
      ),
      actions: [
        if (showCancelButton)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.lightText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        TextButton(
          onPressed: onPressed ?? () => Navigator.pop(context),
          child: const Text(
            'OK',
            style: TextStyle(
              color: AppColors.mainColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
