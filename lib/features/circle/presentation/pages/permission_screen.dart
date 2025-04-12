import 'package:share_loc/core/common/widgets/btn.dart';
import 'package:share_loc/core/common/widgets/custom_header.dart';
import 'package:share_loc/core/res/colours.dart';
import 'package:share_loc/core/res/media_res.dart';
import 'package:share_loc/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool locationEnabled = false;
  bool activityEnabled = false;

  Future<void> checkandRequestLocationPermission() async {
    if (await Permission.location.isDenied) {
      final statuses = await [
        Permission.location,
      ].request();

      if (statuses[Permission.location]!.isPermanentlyDenied) {
        await openAppSettings();
      }
    }

    final isLocationGranted = await Permission.location.isGranted;
    setState(() {
      locationEnabled = isLocationGranted;
    });
  }

  Future<void> checkPermissions() async {
    final isLocationGranted = await Permission.location.isGranted;
    setState(() {
      locationEnabled = isLocationGranted;
    });
  }

  @override
  void initState() {
    super.initState();
    checkPermissions();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body: Stack(
        children: [
          CustomHeader(
            imagePath: MediaRes.bgImage,
            onBackPressed: () => Navigator.pop(context),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: height * 0.83,
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.05,
                vertical: height * 0.015,
              ),
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
                    SizedBox(height: height * 0.02),
                    Center(
                      child: Text(
                        'We need this permission\nfor it to work',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: width * 0.058,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.04),
                    _buildPermissionCard(
                      title: 'Location',
                      subtitle:
                          'Location data is used for in-app maps, place alerts and functions as a location with your circles',
                      value: locationEnabled,
                      onChanged: (val) async {
                        if (val) {
                          await checkandRequestLocationPermission();
                        } else {
                          setState(() {
                            locationEnabled = false;
                          });
                        }
                      },
                    ),
                    SizedBox(height: height * 0.025),
                    _buildPermissionCard(
                      title: 'Physical Activity',
                      subtitle:
                          'Monitor car travel, driver safety and accident detection',
                      value: activityEnabled,
                      onChanged: (val) => setState(() => activityEnabled = val),
                    ),
                    SizedBox(height: height * 0.09),
                    Center(
                      child: Text(
                        'In addition to the above, your location data will be used in accordance with our privacy policy and your preferences which may include sharing with third parties for purposes such as research, tailored advertising, and analytics.',
                        style: TextStyle(
                          fontSize: width * 0.032,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: height * 0.03),
                    SizedBox(
                      width: double.infinity,
                      child: ResponsiveButton(
                        label: 'Next',
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            Constants.onBoarding,
                          );
                        },
                      ),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Remind me later',
                          style: TextStyle(
                            fontSize: width * 0.040,
                            color: AppColors.mainColor,
                            fontWeight: FontWeight.w600,
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

  Widget _buildPermissionCard({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade100),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    height: 1.4,
                  ),
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: Colors.white,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: AppColors.inactiveTrackColor,
                activeTrackColor: AppColors.mainColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
