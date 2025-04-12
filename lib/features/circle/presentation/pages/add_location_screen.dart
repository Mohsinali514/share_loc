import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart'
    as osm; // Add alias 'osm' for flutter_osm_plugin
import 'package:permission_handler/permission_handler.dart';
import 'package:share_loc/core/common/errors/exceptions.dart';
import 'package:share_loc/core/common/providers/user_provider.dart';
import 'package:share_loc/core/common/widgets/btn.dart';
import 'package:share_loc/core/common/widgets/custom_header.dart';
import 'package:share_loc/core/res/colours.dart';
import 'package:share_loc/core/res/media_res.dart';
import 'package:share_loc/core/utils/constants.dart';
import 'package:share_loc/core/utils/map_utils.dart';

class AddLocationScreen extends StatefulWidget {
  const AddLocationScreen({super.key});

  @override
  State<AddLocationScreen> createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen>
    with osm.OSMMixinObserver {
  osm.GeoPoint? selectedGeoPoint;
  // Map Controller
  final osm.MapController mapController = createMapController();
  final osm.OSMOption osmOptions = getOSMOptions();

  @override
  void initState() {
    super.initState();
    _checkAndRequestLocationPermission();
    mapController.addObserver(this);
  }

  Future<void> _checkAndRequestLocationPermission() async {
    if (await Permission.location.isDenied) {
      final statuses = await [Permission.location].request();
      if (statuses[Permission.location]?.isPermanentlyDenied ?? false) {
        await openAppSettings();
      }
    }
  }

  @override
  void dispose() {
    mapController.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> mapIsReady(bool isReady) async {
    if (isReady) {
      /// put you logic
    }
  }

  @override
  void onSingleTap(osm.GeoPoint position) {
    _addMarker(markerPoint: position);
  }

  Future<void> _addMarker({osm.GeoPoint? markerPoint}) async {
    final geoPoints = await mapController.geopoints;
    await mapController.removeMarkers(geoPoints);
    final geoPoint = await mapController.myLocation();
    await mapController.addMarker(
      markerPoint ?? geoPoint,
      markerIcon: Constants.myMarker,
      angle: 3.14 / 3,
    );
    selectedGeoPoint = markerPoint ?? geoPoint;
  }

  Future<void> savePlace({
    required osm.GeoPoint geoPoint,
    required String userId,
    required String placeName,
  }) async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection(Constants.dbPlaces).doc();

      await docRef.set({
        'userId': userId,
        'placeName': placeName,
        'lat': geoPoint.latitude,
        'long': geoPoint.longitude,
      });

      print('Place saved successfully');
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: '500');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

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
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.05,
                vertical: height * 0.015,
              ),
              height: height * 0.83,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  SizedBox(height: height * 0.02),
                  _buildTitle(width),
                  SizedBox(height: height * 0.01),
                  _buildSearchField(),
                  SizedBox(height: height * 0.03),
                  _buildMap(height),
                  SizedBox(height: height * 0.09),
                  _buildSaveButton(context),
                  _buildSkipButton(width),
                  SizedBox(height: height * 0.02),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(double height) => Center(
        child: Container(
          height: height * 0.38 + 6,
          width: height * 0.40 + 6,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade100, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: osm.OSMFlutter(
              controller: mapController,
              osmOption: osmOptions,
              onGeoPointClicked: (geoPoint) {
                // Handle the geo point click
                print('GeoPoint clicked: $geoPoint');
                _addMarker(markerPoint: geoPoint);
              },
              onLocationChanged: (geoPoint) {
                // Handle location change
                print('Location changed: $geoPoint');
              },
              onMapMoved: (region) {
                // Handle map move
                print('Map moved: $region');
              },
              onMapIsReady: (isReady) {
                // Map readiness status
                print('Map is ready: $isReady');
                _addMarker();
              },
            ),
          ),
        ),
      );

  Widget _buildTitle(double width) => Text(
        'Add your Location',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: width * 0.058,
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
      );

  Widget _buildSearchField() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextField(
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.location_pin, color: Colors.grey),
            hintText: 'Search your Location',
            hintStyle: const TextStyle(color: Colors.grey),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      );

  Widget _buildCenterPin() => Container(
        height: 80,
        width: 80,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(136, 125, 250, 1),
          borderRadius: BorderRadius.circular(80),
        ),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(48),
          ),
          child: const Icon(
            Icons.location_pin,
            color: AppColors.mainColor,
          ),
        ),
      );

  Widget _buildSaveButton(BuildContext context) => SizedBox(
        width: double.infinity,
        child: ResponsiveButton(
          label: 'Save',
          borderColor: AppColors.dimColor,
          onPressed: () async {
            final userId = context.read<UserProvider>().user?.uid;
            await savePlace(
              userId: userId!,
              placeName: 'Home',
              geoPoint: selectedGeoPoint!,
            );
            await Navigator.pushNamed(context, Constants.homePage);
          },
        ),
      );

  Widget _buildSkipButton(double width) => TextButton(
        onPressed: () async {
          await Navigator.pushNamed(context, Constants.homePage);
        },
        child: Text(
          'Skip',
          style: TextStyle(
            fontSize: width * 0.040,
            color: AppColors.mainColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
