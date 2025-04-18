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
import 'package:share_loc/core/services/di.dart';
import 'package:share_loc/core/utils/constants.dart';
import 'package:share_loc/core/utils/map_utils.dart';
import 'package:share_loc/features/circle/data/models/circle_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen>
    with osm.OSMMixinObserver {
  final osm.MapController mapController = createMapController();
  final osm.OSMOption osmOptions = getOSMOptions();
  final Location location = Location();
  StreamSubscription<LocationData>? locationSubscription;
  StreamSubscription<QuerySnapshot>? membersLocationSubscription;

  @override
  Future<void> mapIsReady(bool isReady) async {}

  bool isSharingEnabled = false;
  String? currentCircleId;
  List<String> memberIds = [];

  Future<void> permissionsCheck() async {
    var serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      // Case when the user does not enable location services
      if (!serviceEnabled) {
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
      // Case when the user does not grant location permissions
      if (permissionGranted != PermissionStatus.granted) {
        return showCustomDialog(
          context: context,
          title: 'Location permissions denied',
          titleColor: Colors.red,
          content: 'You have canceled the location permission',
        );
      }
    }
  }

  Future<void> fetchCurrentCircleMembers() async {
    final user = context.read<UserProvider>().user;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection(Constants.dbUsers)
        .doc(user.uid)
        .get();

    final userData = userDoc.data();
    if (userData == null) return;

    currentCircleId = userData['currentCircle'].toString();
    if (currentCircleId == null) return;

    final circleDoc = await FirebaseFirestore.instance
        .collection(Constants.dbCircle)
        .doc(currentCircleId)
        .get();

    final members = circleDoc.data()?['members'] as List<dynamic>?;

    setState(() {
      memberIds = members?.cast<String>() ?? [];
    });
  }

  Future<List<Map<String, dynamic>>>? members;
  Future<List<Map<String, dynamic>>>? futureMembers;
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

  @override
  void initState() {
    permissionsCheck();
    fetchCurrentCircleMembers().then((_) async {
      members = fetchMemberDetails();
      setState(() {
        futureMembers = Future.value(members);
      });
    });
    mapController.addObserver(this);
    super.initState();
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   final user = context.read<UserProvider>().user;
  //   if (user != null) {
  //     final newCircleId = user.currentCircle;
  //     if (newCircleId != currentCircleId) {
  //       currentCircleId = newCircleId;
  //       fetchCurrentCircleMembers().then((_) async {
  //         members = fetchMemberDetails();
  //         setState(() {
  //           futureMembers = Future.value(members);
  //         });
  //       }); // Re-fetch members if circle changes
  //     }
  //   }
  // }

  @override
  void dispose() {
    mapController.removeObserver(this);
    locationSubscription?.cancel();
    membersLocationSubscription?.cancel();
    super.dispose();
  }

  Future<void> checkLocationSharingEnabled() async {
    final prefs = sl<SharedPreferences>();
    final isSharing = prefs.getBool(Constants.kLocationSharingEnabled);
    setState(() {
      isSharingEnabled = isSharing ?? false;
    });
    if (isSharingEnabled) {
      await myLocationUpdates();
    } else {
      await stopLocationUpdates();
    }
  }

  // Current user location updates
  Future<void> myLocationUpdates() async {
    locationSubscription = location.onLocationChanged.listen(
      updateUserLocation,
    );
  }

  Future<void> stopLocationUpdates() async {
    // Stop location stream

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Clear location data in Firestore
    await FirebaseFirestore.instance
        .collection(Constants.dbUsers)
        .doc(user.uid)
        .update({
      'geoPoint': null,
      'currentLocation': '',
      'locationSyncAt': DateTime.now().toIso8601String(),
    });
    await locationSubscription?.cancel();
  }

  osm.GeoPoint? oldUserMarker;
  Future<void> updateUserLocation(LocationData currentLocation) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final geoPoint = {
      'lat': currentLocation.latitude,
      'lon': currentLocation.longitude,
    };

    await FirebaseFirestore.instance
        .collection(Constants.dbUsers)
        .doc(user.uid)
        .update({
      'geoPoint': geoPoint,
      'currentLocation':
          '${currentLocation.latitude}, ${currentLocation.longitude}',
      'locationSyncAt': DateTime.now().toIso8601String(),
    });

    //! Additional Marker
    // final userGeoPoint = osm.GeoPoint(
    //   latitude: currentLocation.latitude!,
    //   longitude: currentLocation.longitude!,
    // );

    //! Remove old marker
    // if (oldUserMarker != null) {
    //   await mapController.removeMarker(oldUserMarker!);
    // }

    // // Add new user marker
    // await mapController.addMarker(
    //   userGeoPoint,
    //   markerIcon: Constants.myMarker,
    // );

    // oldUserMarker = userGeoPoint;
  }

  Map<String, osm.GeoPoint?> oldMemberMarkers = {};
  Future<void> listenToMemberLocations() async {
    if (currentCircleId == null || memberIds.isEmpty) return;

    final memberDataList = await fetchMemberDetails();
    final memberDataMap = {
      for (final member in memberDataList) member['uid']: member,
    };

    membersLocationSubscription = FirebaseFirestore.instance
        .collection(Constants.dbUsers)
        .where(FieldPath.documentId, whereIn: memberIds)
        .snapshots()
        .listen((snapshot) async {
      final memberLocations = <osm.GeoPoint>[];

      for (final doc in snapshot.docs) {
        final uid = doc.id;
        final data = doc.data();
        final geoPoint = data['geoPoint'];
        final currentLocation = data['currentLocation'];

        if (geoPoint != null) {
          final memberLocation = osm.GeoPoint(
            latitude: (geoPoint['lat'] as num).toDouble(),
            longitude: (geoPoint['lon'] as num).toDouble(),
          );

          // Extract member detail
          final member = memberDataMap[uid] ?? {};
          final profilePictureUrl = member['profilePic']?.toString();

          // Remove old marker
          if (oldMemberMarkers[uid] != null) {
            await mapController.removeMarker(oldMemberMarkers[uid]!);
          }

          // Marker with profile picture
          // final markerIcon =
          // await createNetworkMarkerIcon(profilePictureUrl);
          await mapController.addMarker(
            memberLocation,
            markerIcon: Constants.memberMarker,
          );

          oldMemberMarkers[uid] = memberLocation;
          memberLocations.add(memberLocation);
        }
      }
      if (memberLocations.isNotEmpty) {
        // final bounds = osm.BoundingBox.fromGeoPoints(memberLocations);
        // await mapController.zoomToBoundingBox(bounds);
      }
    });
  }

  // NetworkImage marker
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

  String selectedValue = 'Option 1';
  final List<String> dropdownItems = ['Option 1', 'Option 2', 'Option 3'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          osm.OSMFlutter(
            controller: mapController,
            osmOption: osmOptions,
            onMapIsReady: (isReady) async {
              await myLocationUpdates();
              await listenToMemberLocations();
            },
          ),

          // Top Map Controls
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
                      if (currentCircleId != null) {
                        Navigator.pushNamed(
                          context,
                          Constants.chatScreen,
                          arguments: {
                            'circleId': currentCircleId,
                            'futureMembers': futureMembers,
                          },
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Circle ID not loaded yet'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          // Sheet
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
                  // People & Places header
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

                  // Circle Members
                  Expanded(
                    child: FutureBuilder(
                      future: futureMembers,
                      builder: (context, snapshot) {
                        if (futureMembers == null) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Text('No members found');
                        }

                        // Helper function
                        String formatLocationSyncAt(String? isoDateString) {
                          if (isoDateString == null || isoDateString.isEmpty)
                            return 'N/A';
                          try {
                            final dateTime = DateTime.parse(isoDateString);
                            return DateFormat('d MMM yyyy, h:mm a')
                                .format(dateTime);
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
