import 'dart:async';

import 'package:share_loc/core/common/widgets/btn.dart';
import 'package:share_loc/core/extensions/context_extension.dart';
import 'package:share_loc/core/res/colours.dart';
import 'package:share_loc/core/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            SizedBox(height: context.height * 0.05),

            // Heading
            Text(
              'Hi Aldo! You can now join or create your circle.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.width * 0.06,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            SizedBox(height: context.height * 0.46),

            // Description
            Text(
              'The circle, serving as a secure enclave, provides exclusive '
              'access solely to you and your family members.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.width * 0.045,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            //!SizedBox(height: context.height * 0.10),
            const SizedBox(
              height: 30,
            ),

            ResponsiveButton(
              label: 'Next',
              borderColor: Colors.white,
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  Constants.joinOrCreateCircleScreen,
                );
              },
            ),
            const SizedBox(
              height: 10,
            ),
            // ResponsiveButton(
            //   label: 'Signout',
            //   backgroundColor: Colors.red,
            //   borderColor: Colors.white,
            //   onPressed: () async {
            //     final navigator = Navigator.of(context);
            //     await FirebaseAuth.instance.signOut();
            //     unawaited(
            //       navigator.pushNamedAndRemoveUntil(
            //         '/',
            //         (route) => false,
            //       ),
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
