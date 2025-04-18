import 'package:flutter/material.dart';
import 'package:share_loc/core/common/widgets/btn.dart';
import 'package:share_loc/core/extensions/context_extension.dart';
import 'package:share_loc/core/res/colours.dart';
import 'package:share_loc/core/res/media_res.dart';
import 'package:share_loc/core/utils/constants.dart';

class OnBoarding extends StatelessWidget {
  const OnBoarding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: context.height * 0.05),

              // Heading
              Text(
                'Add places your family often visits, such as home, school, etc',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: context.width * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: context.height * 0.05),

              // Asset image
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: context.height * 0.40,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Exact outer border hug image with no visible spacing
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          MediaRes.map,
                          fit: BoxFit.cover,
                          width: context.height * 0.40,
                          height: context.height * 0.38,
                        ),
                      ),

                      Column(
                        children: [
                          SizedBox(height: context.height * 0.02),
                          ElevatedButton(
                            onPressed: null,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: AppColors.lightText,
                              backgroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  20,
                                ),
                              ),
                            ),
                            child: const Text('Albert Steven Arabian'),
                          ),
                          Image.asset(
                            height: 65,
                            width: 65,
                            MediaRes.houseAvatar,
                            // fit: BoxFit.contain,
                          ),
                          Container(
                            height: 80,
                            width: 80,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(231, 84, 47, 0.2),
                              borderRadius: BorderRadius.circular(80),
                            ),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(48),
                              ),
                              child: const Icon(
                                Icons.home,
                                color: AppColors.mainColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: context.height * 0.15),

              // Description
              Text(
                'You can turn on notifications to get alerts when members of your circle come and go',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: context.width * 0.03,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: context.height * 0.035),

              ResponsiveButton(
                label: 'Next',
                borderColor: Colors.white,
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    Constants.addLocationScreen,
                  );
                },
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
