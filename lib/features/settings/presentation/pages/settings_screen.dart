import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_loc/core/common/widgets/custom_dialog.dart';
import 'package:share_loc/core/common/widgets/custom_header.dart';
import 'package:share_loc/core/extensions/context_extension.dart';
import 'package:share_loc/core/res/colours.dart';
import 'package:share_loc/core/res/media_res.dart';
import 'package:share_loc/core/services/di.dart';
import 'package:share_loc/core/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isSharingEnabled = true;

  @override
  void initState() {
    super.initState();
    loadLocationSharingPreference();
  }

  Future<void> loadLocationSharingPreference() async {
    final prefs = sl<SharedPreferences>();
    final sharing = prefs.getBool(Constants.kLocationSharingEnabled) ?? false;
    setState(() {
      isSharingEnabled = sharing;
    });
    print('Testing booloean value: $isSharingEnabled');
  }

  Future<void> toggleLocationSharing(bool value) async {
    final prefs = sl<SharedPreferences>();
    await prefs.setBool(Constants.kLocationSharingEnabled, value);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.currentUser;

    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body: Stack(
        children: [
          CustomHeader(
            imagePath: MediaRes.bgImage,
            title: 'Settings',
            onBackPressed: () => Navigator.pop(context),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.width * 0.05,
                vertical: context.height * 0.02,
              ),
              height: context.height * 0.83,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    /// Profile Section
                    Row(
                      children: [
                        CircleAvatar(
                          radius: context.width * 0.08,
                          backgroundImage: (user?.profilePic != null &&
                                  user!.profilePic!.isNotEmpty)
                              ? NetworkImage(user.profilePic!)
                              : const AssetImage(
                                  'assets/images/default_avatar.png',
                                ) as ImageProvider,
                        ),
                        SizedBox(width: context.width * 0.04),
                        Expanded(
                          child: Text(
                            (user?.fullName != null &&
                                    user!.fullName.isNotEmpty)
                                ? user.fullName
                                : 'N/A',
                            style: TextStyle(
                              fontSize: context.width * 0.05,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Switch(
                          activeColor: Colors.white,
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: AppColors.inactiveTrackColor,
                          activeTrackColor: AppColors.mainColor,
                          value: isSharingEnabled,
                          onChanged: (value) {
                            setState(() {
                              isSharingEnabled = value;
                            });
                            toggleLocationSharing(value);
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: context.height * 0.03),

                    /// General Settings
                    sectionTitle(
                      'General Settings',
                      context.width,
                    ),
                    settingTile(
                      Icons.notifications,
                      'Smart Notifications',
                      circleColor: const Color.fromRGBO(255, 98, 98, 1),
                    ),
                    settingTile(
                      Icons.group,
                      'Circle Management',
                      circleColor: const Color.fromRGBO(95, 194, 248, 1),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          Constants.circleManagement,
                        );
                      },
                    ),

                    settingTile(
                      Icons.location_on,
                      'Location Sharing',
                      circleColor: AppColors.mainColor,
                    ),
                    SizedBox(height: context.height * 0.03),

                    /// Universal Settings
                    sectionTitle('Universal Settings', context.width),

                    settingTile(
                      Icons.account_circle,
                      'Account',
                      circleColor: Colors.grey,
                    ),
                    settingTile(
                      Icons.lock,
                      'Privacy & Security',
                      circleColor: AppColors.mainColor,
                    ),
                    settingTile(
                      Icons.support,
                      'Support',
                      circleColor: const Color.fromRGBO(106, 197, 120, 1),
                    ),
                    settingTile(
                      Icons.logout,
                      'Log Out',
                      isLogout: true,
                      circleColor: Colors.red.shade50,
                      iconColor: Colors.red,
                      onPressed: () {
                        showCustomDialog(
                          context: context,
                          title: 'Confirm Logout',
                          titleColor: Colors.red,
                          content: 'Are you sure to logout from your account?',
                          onPressed: () async {
                            final navigator = Navigator.of(context);
                            await FirebaseAuth.instance.signOut();
                            unawaited(
                              navigator.pushNamedAndRemoveUntil(
                                '/',
                                (route) => false,
                              ),
                            );
                          },
                          showCancelButton: true,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget for section title
  Widget sectionTitle(String title, double width) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: TextStyle(
            fontSize: width * 0.045,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget settingTile(
    IconData icon,
    String title, {
    bool isLogout = false,
    Color? circleColor,
    Color? iconColor,
    VoidCallback? onPressed,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: circleColor ?? Colors.grey.shade200,
        child: Icon(
          icon,
          color: iconColor ?? (isLogout ? Colors.red : Colors.white),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.red : Colors.black87,
          fontWeight: isLogout ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey.shade400,
      ),
      onTap: onPressed,
    );
  }
}
