import 'package:flutter/material.dart';
import 'package:share_loc/core/common/widgets/btn.dart';
import 'package:share_loc/core/common/widgets/custom_header.dart';
import 'package:share_loc/core/res/colours.dart';
import 'package:share_loc/core/res/media_res.dart';
import 'package:share_loc/core/utils/constants.dart';
import 'package:share_loc/features/circle/data/models/circle_model.dart';
import 'package:share_plus/share_plus.dart';

class InvitationCodeScreen extends StatelessWidget {
  const InvitationCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final circle =
        ModalRoute.of(context)!.settings.arguments! as LocalCircleModel;
    final invitationCode = circle.invitationCode ?? 'HGF7V4'; // Default value
    final circleId = circle.circleId; // Access the circleId

    // Get the screen size
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final height = mediaQuery.size.height;

    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body: Stack(
        children: [
          CustomHeader(
            imagePath: MediaRes.bgImage,
            onBackPressed: () {
              Navigator.pop(context);
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.05, // 5% of screen width for padding
                vertical: height *
                    0.015, // 1.5% of screen height for vertical padding
              ),
              height: height * 0.83, // 83% of screen height for the container
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: height * 0.02,
                    ), // 2% of screen height for spacing
                    Center(
                      child: Text(
                        'Share this invitation code with your family',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: width *
                              0.058, // 5.5% of screen width for font size
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.04,
                    ), // 4% of screen height for spacing
                    Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: height * 0.04, // 4% vertical padding
                          horizontal: width * 0.2, // 20% horizontal padding
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.mainColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.mainColor),
                        ),
                        child: Column(
                          children: [
                            Text(
                              invitationCode,
                              style: TextStyle(
                                fontSize: width *
                                    0.06, // 6% of screen width for font size
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              height: height * 0.015,
                            ), // Small vertical spacing
                            FittedBox(
                              child: Text(
                                'This code will be active for 3 days',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: width * 0.05, // 5% font size
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.04),
                    Center(
                      child: Text(
                        'Tip: You can share this code in any way: SMS, '
                        'Email, Written or Verbal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                          fontSize: width * 0.045,
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.28),
                    SizedBox(
                      width: double.infinity,
                      child: ResponsiveButton(
                        label: 'Share Code',
                        onPressed: () {
                          Share.share(
                            'Join my Circle using this invitation code: '
                            '$invitationCode',
                            subject: 'Circle Invitation Code',
                          );
                        },
                      ),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            Constants.designatedRoleScreen,
                            arguments: circle,
                          );
                        },
                        child: Text(
                          "I'm done sharing",
                          style: TextStyle(
                            fontSize: width * 0.035,
                            color: AppColors.lightText,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.02),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
