import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_loc/core/common/errors/exceptions.dart';
import 'package:share_loc/core/common/providers/user_provider.dart';
import 'package:share_loc/core/common/widgets/btn.dart';
import 'package:share_loc/core/common/widgets/custom_dialog.dart';
import 'package:share_loc/core/common/widgets/custom_header.dart';
import 'package:share_loc/core/extensions/context_extension.dart';
import 'package:share_loc/core/res/colours.dart';
import 'package:share_loc/core/res/media_res.dart';
import 'package:share_loc/core/utils/constants.dart';
import 'package:share_loc/core/utils/map_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart' as osm;
import 'package:geocoding/geocoding.dart';

class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen>
    with osm.OSMMixinObserver {
  final osm.MapController mapController = createMapController();
  final osm.OSMOption osmOptions = getOSMOptions();

  final _placeController = TextEditingController();
  final _locationController = TextEditingController();

  osm.GeoPoint? selectedGeoPoint;

  @override
  void initState() {
    super.initState();
    mapController.addObserver(this);
  }

  @override
  void dispose() {
    _placeController.dispose();
    _locationController.dispose();
    super.dispose();
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
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: '500');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body: Stack(
        children: [
          CustomHeader(
            title: 'Add Place',
            imagePath: MediaRes.bgImage,
            onBackPressed: () => Navigator.pop(context),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.width * 0.05,
                vertical: context.height * 0.015,
              ),
              height: context.height * 0.83,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: context.height * 0.025),
                  _buildTextField(
                    controller: _placeController,
                    hint: 'Enter place',
                    prefix: Icons.input,
                    suffix: Icons.check_circle,
                  ),
                  SizedBox(height: context.height * 0.03),
                  _buildTextField(
                    controller: _locationController,
                    hint: 'Location',
                    prefix: Icons.location_pin,
                  ),
                  SizedBox(height: context.height * 0.04),
                  SizedBox(
                    width: double.infinity,
                    child: ResponsiveButton(
                      label: 'Save Place',
                      onPressed: () async {
                        final userId = context.read<UserProvider>().user?.uid;
                        final placeName = _placeController.text.trim();
                        final locationText = _locationController.text.trim();

                        if (placeName.isEmpty) {
                          return showCustomDialog(
                            context: context,
                            title: 'Missing Place Name',
                            content: 'Please enter a place name to save',
                          );
                        }

                        osm.GeoPoint geoPoint;

                        if (locationText.isNotEmpty) {
                          try {
                            final locations =
                                await locationFromAddress(locationText);
                            final loc = locations.first;
                            geoPoint = osm.GeoPoint(
                              latitude: loc.latitude,
                              longitude: loc.longitude,
                            );
                          } catch (e) {
                            return showCustomDialog(
                              context: context,
                              title: 'Invalid Location',
                              content: 'Could not find the typed location.',
                            );
                          }
                        } else if (selectedGeoPoint != null) {
                          geoPoint = selectedGeoPoint!;
                        } else {
                          return showCustomDialog(
                            context: context,
                            title: 'No Location Selected',
                            content:
                                'Please tap on the map or type a location.',
                          );
                        }

                        await savePlace(
                          userId: userId!,
                          placeName: placeName,
                          geoPoint: geoPoint,
                        );

                        await Navigator.pushNamed(
                          context,
                          Constants.addSeePlacesScreen,
                        );
                      },
                    ),
                  ),
                  SizedBox(height: context.height * 0.015),
                  SizedBox(
                    height: context.height * 0.48,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: osm.OSMFlutter(
                        controller: mapController,
                        osmOption: osmOptions,
                        onGeoPointClicked: (geoPoint) {
                          // Handle the geo point click
                          print('GeoPoint clicked: $geoPoint');
                          _addMarker(markerPoint: geoPoint);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefix,
    IconData? suffix,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(prefix, color: Colors.grey),
        suffixIcon:
            suffix != null ? Icon(suffix, color: AppColors.mainColor) : null,
        hintStyle: const TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade100),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  @override
  Future<void> mapIsReady(bool isReady) async {}
}
