import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:share_loc/core/res/colours.dart';

class Constants {
  Constants._();

  static const kFirstTimeKey = 'First_time';
  static const kLocationSharingEnabled = 'location_sharing_enabled';

  static const kDefaultAvatar = 'https://images.freeimages'
      '.com/fic/images/icons/573/must_have/256/user.png';

  // Map Markers
  static const myMarker = MarkerIcon(
    icon: Icon(
      Icons.location_pin,
      color: AppColors.mainColor,
      size: 52,
    ),
  );
  static const memberMarker = MarkerIcon(
    icon: Icon(
      Icons.location_on,
      color: Colors.red,
      size: 48,
    ),
  );

  /// DATABASE
  static const dbUsers = 'users';
  static const dbCircle = 'circles';
  static const dbPlaces = 'places';

  // SCREEN PATHS
  static const onBoardingScreen = '/';
  static const signInScreen = '/signIn';
  static const signUpScreen = '/signup';
  static const dashboard = '/dashboard';
  static const welcome = '/welcome';
  static const joinOrCreateCircleScreen = '/joinOrCreateCircleScreen';
  static const createCircleScreen = '/createCircleScreen';
  static const invitationCodeSreen = '/invitationCodeSreen';
  static const designatedRoleScreen = '/designatedRoleScreen';
  static const addPhotoScreen = '/addPhotoScreen';
  static const permissionScreen = '/permissionScreen';
  static const onBoarding = '/onBoarding';
  static const addLocationScreen = '/addLocationScreen';
  static const chatScreen = '/chatScreen';
  static const homePage = '/homePage';
  static const addSeePlacesScreen = '/addSeePlacesScreen';
  static const addPlaceScreen = '/addPlaceScreen';
  static const settingScreen = '/settingsScreen';
  static const circleManagement = '/circleManagement';
}
