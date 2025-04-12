import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart' as osm;
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:share_loc/core/common/providers/user_provider.dart';
import 'package:share_loc/core/common/widgets/custom_dialog.dart';
import 'package:share_loc/core/res/colours.dart';
import 'package:share_loc/core/utils/constants.dart';
import 'package:share_loc/core/utils/map_utils.dart';
import 'package:share_loc/features/homepage/presentation/widgets/custom_marker.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen>
    with osm.OSMMixinObserver {
  final osm.MapController mapController = createMapController();
  final osm.OSMOption osmOptions = getOSMOptions();

  StreamSubscription<LocationData>? locationSubscription;
  StreamSubscription<QuerySnapshot>? membersLocationSubscription;

  String? currentCircleId;
  List<String> memberIds = [];

  @override
  Future<void> mapIsReady(bool isReady) async {}

  //osm.GeoPoint? currentLocation;

  // Future<void> _addMarker({osm.GeoPoint? markerPoint}) async {
  //   await Future.delayed(const Duration(milliseconds: 500));
  //   final geoPoint = await mapController.myLocation();
  //   await mapController.addMarker(
  //     markerPoint ?? geoPoint,
  //     markerIcon: Constants.myMarker,
  //     angle: 3.14 / 3,
  //   );
  //   currentLocation = markerPoint ?? geoPoint;
  // }

  @override
  void initState() {
    super.initState();
    mapController.addObserver(this);
    fetchCurrentCircleAndMembers();
    //startLocationUpdates();
  }

  @override
  void dispose() {
    mapController.removeObserver(this);
    //locationSubscription?.cancel();
    membersLocationSubscription?.cancel();
    super.dispose();
  }

  // Current user live location
  Future<void> startLocationUpdates() async {
    final location = Location();
    var serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        // Case when the user does not enable location services
        return showCustomDialog(
          context: context,
          title: 'Location not enabled',
          titleColor: Colors.red,
          content: 'Please turn on your location service',
        );
      }
    }

    var permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        // Case when the user does not grant location permissions
        return showCustomDialog(
          context: context,
          title: 'Location permissions denied',
          titleColor: Colors.red,
          content: 'You have canceled the location permission',
        );
      }
    }

    locationSubscription = location.onLocationChanged.listen(
      updateUserLocation,
      onError: (error) {
        // Handle any errors that occur during location updates
        print('Location update error: $error');
        showCustomDialog(
          context: context,
          title: 'Location Update Error',
          titleColor: Colors.red,
          content: 'An error occurred while updating location: $error',
        );
      },
    );
  }

  osm.GeoPoint? oldUserMarker;
  // Update currentLocation user data
  Future<void> updateUserLocation(LocationData currentLocation) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final geoPoint = {
      'lat': currentLocation.latitude,
      'lon': currentLocation.longitude,
    };

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'geoPoint': geoPoint,
      'currentLocation':
          '${currentLocation.latitude}, ${currentLocation.longitude}',
      'locationSyncAt': DateTime.now().toIso8601String(),
    });

    final userGeoPoint = osm.GeoPoint(
      latitude: currentLocation.latitude!,
      longitude: currentLocation.longitude!,
    );

    // Remove old user marker
    if (oldUserMarker != null) {
      await mapController.removeMarker(oldUserMarker!);
    }

    // Add new user marker
    await mapController.addMarker(
      userGeoPoint,
      markerIcon: Constants.myMarker,
    );

    oldUserMarker = userGeoPoint;
  }

  Future<void> fetchCurrentCircleAndMembers() async {
    final user = context.read<UserProvider>().user;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection(Constants.dbUsers)
        .doc(user.uid)
        .get();

    currentCircleId = userDoc.data()?['currentCircle'].toString();

    if (currentCircleId == null) return;
    final circleDoc = await FirebaseFirestore.instance
        .collection(Constants.dbCircle)
        .doc(currentCircleId)
        .get();

    final members = circleDoc.data()?['members'] as List<dynamic>?;

    setState(() {
      memberIds = members?.cast<String>() ?? [];
    });
    listenToMemberLocations();
  }

  Future<List<Map<String, dynamic>>> fetchMemberDetails() async {
    final membersData = <Map<String, dynamic>>[];

    for (final uid in memberIds) {
      final userDoc = await FirebaseFirestore.instance
          .collection(Constants.dbUsers)
          .doc(uid)
          .get();

      if (userDoc.exists) {
        membersData.add(userDoc.data()!);
      }
    }

    return membersData;
  }

  // Keep track of old member markers to remove them on each update
  Map<String, osm.GeoPoint> oldMemberMarkers = {};

  void listenToMemberLocations() {
    if (currentCircleId == null) return;

    membersLocationSubscription = FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: memberIds)
        .snapshots()
        .listen((snapshot) async {
      final memberLocations = <osm.GeoPoint>[];
      for (final doc in snapshot.docs) {
        final uid = doc.id;
        final data = doc.data();
        final geoPoint = data['geoPoint'];
        if (geoPoint != null) {
          final memberLocation = osm.GeoPoint(
            latitude: (geoPoint['lat'] as num).toDouble(),
            longitude: (geoPoint['lon'] as num).toDouble(),
          );

          // Fetch member details from membersData
          final memberData = await fetchMemberDetails();
          final member =
              memberData.firstWhere((m) => m['uid'] == uid, orElse: () => {});
          final profilePictureUrl = member['profilePic'].toString();

          // Remove old marker
          if (oldMemberMarkers[uid] != null) {
            await mapController.removeMarker(oldMemberMarkers[uid]!);
          }

          // Marker with profile picture
          final markerIcon = await createNetworkMarkerIcon(profilePictureUrl);
          await mapController.addMarker(
            memberLocation,
            markerIcon: markerIcon,
          );

          oldMemberMarkers[uid] = memberLocation;
          memberLocations.add(memberLocation);
        }
      }

      if (memberLocations.isNotEmpty) {
        // Average position of all members
        final avgLat =
            memberLocations.map((e) => e.latitude).reduce((a, b) => a + b) /
                memberLocations.length;
        final avgLon =
            memberLocations.map((e) => e.longitude).reduce((a, b) => a + b) /
                memberLocations.length;

        final shiftedLat = avgLat + 0.002;
        await mapController.setZoom(zoomLevel: 25);

        await mapController.moveTo(
          osm.GeoPoint(latitude: avgLat, longitude: avgLon),
          animate: true,
        );
      }
    });
  }

  // Simple NetworkImage marker
  Future<osm.MarkerIcon> createNetworkMarkerIcon(String imageUrl) async {
    return osm.MarkerIcon(
      iconWidget: Image.network(
        imageUrl,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
      ),
    );
  }

  // Custom painter marker
  // Future<osm.MarkerIcon> createCustomMarkerIcon(String imageUrl) async {
  //   return osm.MarkerIcon(
  //     iconWidget: CustomMarkerWidget(imageUrl: imageUrl),
  //   );
  // }

  String selectedValue = 'Option 1';
  final List<String> dropdownItems = ['Option 1', 'Option 2', 'Option 3'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Fullscreen Map
          osm.OSMFlutter(
            controller: mapController,
            osmOption: osmOptions,
            onMapIsReady: (isReady) async {
              // Wait until map is loaded
              await Future.delayed(const Duration(milliseconds: 500));
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // _addMarker();
              });
            },
          ),

          /// Top Map Controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _circleIconButton(
                    icon: Icons.settings,
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        Constants.settingScreen,
                      );
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedValue,
                        icon: const Icon(Icons.arrow_drop_down),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedValue = newValue!;
                          });
                        },
                        items: dropdownItems
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  _circleIconButton(
                    icon: Icons.chat,
                    onPressed: () {
                      final circleId =
                          context.read<UserProvider>().user?.currentCircle;
                      Navigator.pushNamed(
                        context,
                        Constants.chatScreen,
                        arguments: circleId,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          /// BottomSheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 350,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// People & Places header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'People',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.lightText,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Constants.addSeePlacesScreen,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(255, 240, 217, 1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Places',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// Circle Members
                  Expanded(
                    child: FutureBuilder(
                      future: fetchMemberDetails(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.mainColor,
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('No members found'));
                        }

                        // Format date helper function
                        String formatLocationSyncAt(String? isoDateString) {
                          if (isoDateString == null || isoDateString.isEmpty)
                            return 'N/A';
                          try {
                            final dateTime = DateTime.parse(isoDateString);
                            return DateFormat('h:mm a').format(dateTime);
                            //d MMM yyyy,
                          } catch (e) {
                            return 'Invalid date';
                          }
                        }

                        final members = snapshot.data!;
                        return ListView.builder(
                          itemCount: members.length,
                          itemBuilder: (context, index) {
                            final member = members[index];
                            return _personTile(
                              name: member['fullName']?.toString() ?? 'No Name',
                              status: member['bio']?.toString() ?? 'Unknown',
                              locationSyncAt:
                                  "Since ${formatLocationSyncAt(member['locationSyncAt']?.toString())}",
                              imageUrl: member['profilePic']?.toString() ??
                                  'https://i.pravatar.cc/150?img=3',
                            );
                          },
                        );
                      },
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        Constants.addPlaceScreen,
                      );
                    },
                    child: const Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.mainColor,
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 15),
                        Text(
                          'Add a new Place',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.text,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      /// Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.mainColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_outlined, size: 20),
                  SizedBox(height: 2),
                  Text(
                    'Location',
                    style: TextStyle(fontSize: 11, color: Colors.white),
                  ),
                ],
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.security_outlined, size: 20),
                  SizedBox(height: 2),
                  Text(
                    'Safety',
                    style: TextStyle(fontSize: 11, color: Colors.white),
                  ),
                ],
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_outlined, size: 20),
                  SizedBox(height: 2),
                  Text(
                    'Membership',
                    style: TextStyle(fontSize: 11, color: Colors.white),
                  ),
                ],
              ),
            ),
            label: '',
          ),
        ],
      ),
    );
  }

  Widget _personTile({
    required String name,
    required String status,
    required String locationSyncAt,
    required String imageUrl,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 6),
      leading: CircleAvatar(
        radius: 22,
        backgroundImage: NetworkImage(imageUrl),
      ),
      title: Text(
        name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(status, style: const TextStyle(color: Colors.grey)),
          Text(
            locationSyncAt,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.favorite_border, size: 20),
        onPressed: () {},
      ),
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black87),
        onPressed: onPressed,
        iconSize: 20,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
