import 'package:share_loc/core/extensions/context_extension.dart';
import 'package:share_loc/core/res/colours.dart';
import 'package:flutter/material.dart';

class ResponsiveButton extends StatelessWidget {
  const ResponsiveButton({
    required this.label,
    required this.onPressed,
    this.labelColor = Colors.white,
    this.progressIndicatorColor = Colors.white,
    this.isLoading = false,
    this.backgroundColor = AppColors.mainColor,
    this.borderColor = AppColors.mainColor,
    this.leadingIcon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color labelColor;
  final Color progressIndicatorColor;
  final Color backgroundColor;
  final Color borderColor;
  final Widget? leadingIcon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(
            color: borderColor,
            width: 2,
          ),
          padding: EdgeInsets.symmetric(
            vertical: context.height * 0.015,
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: progressIndicatorColor,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (leadingIcon != null) ...[
                    leadingIcon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// class ResponsiveButton extends StatelessWidget {
//   const ResponsiveButton({
//     required this.label,
//     required this.onPressed,
//     this.labelColor = Colors.white,
//     this.progressIndicatorColor = Colors.white,
//     this.isLoading = false,
//     this.backgroundColor = AppColors.mainColor, // Default
//     super.key,
//   });

//   final String label;
//   final VoidCallback? onPressed;
//   final bool isLoading;
//   final Color labelColor;
//   final Color progressIndicatorColor;
//   final Color backgroundColor; // Optional

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity, // always full
//       child: ElevatedButton(
//         onPressed: isLoading ? null : onPressed,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: backgroundColor,
//           padding: EdgeInsets.symmetric(
//             vertical: context.height * 0.015, // responsive only height
//           ),
//           textStyle: TextStyle(
//             fontSize: 18,
//             color: labelColor,
//           ),
//         ),
//         child: isLoading
//             ? SizedBox(
//                 height: 22,
//                 width: 22,
//                 child: CircularProgressIndicator(
//                   color: progressIndicatorColor,
//                   strokeWidth: 2,
//                 ),
//               )
//             : Text(
//                 label,
//                 style: TextStyle(
//                   color: labelColor,
//                   fontSize: 18,
//                 ),
//               ),
//       ),
//     );
//   }
// }
