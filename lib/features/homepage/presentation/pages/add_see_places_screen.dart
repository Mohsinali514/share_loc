import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_loc/core/common/providers/user_provider.dart';
import 'package:share_loc/core/common/widgets/custom_dialog.dart';
import 'package:share_loc/core/common/widgets/custom_header.dart';
import 'package:share_loc/core/extensions/context_extension.dart';
import 'package:share_loc/core/res/colours.dart';
import 'package:share_loc/core/res/media_res.dart';
import 'package:share_loc/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart' as osm;
import 'package:provider/provider.dart';

class AddSeePlacesScreen extends StatefulWidget {
  const AddSeePlacesScreen({super.key});

  @override
  State<AddSeePlacesScreen> createState() => _AddSeePlacesScreenState();
}

class _AddSeePlacesScreenState extends State<AddSeePlacesScreen> {
  List<Map<String, dynamic>> userPlaces = [];

  Future<void> _loadUserPlaces() async {
    final userId = context.read<UserProvider>().user?.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection(Constants.dbPlaces)
        .where('userId', isEqualTo: userId)
        .get();

    final places = snapshot.docs.map((doc) {
      final data = doc.data();
      final name = data['placeName'] ?? 'No Name';
      final lat = (data['lat'] as num).toDouble();
      final long = (data['long'] as num).toDouble();

      return {
        'docId': doc.id,
        'name': name,
        'point': osm.GeoPoint(latitude: lat, longitude: long),
      };
    }).toList();

    setState(() {
      userPlaces = places;
    });
  }

  @override
  void initState() {
    _loadUserPlaces();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body: Stack(
        children: [
          CustomHeader(
            title: 'Place',
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
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // Add Place
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, Constants.addPlaceScreen);
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
                  const SizedBox(height: 10),

                  // List
                  Expanded(
                    child: userPlaces.isEmpty
                        ? const Center(child: Text('Add places to see here'))
                        : ListView.separated(
                            itemCount: userPlaces.length,
                            separatorBuilder: (context, index) =>
                                const Divider(thickness: 1, color: Colors.grey),
                            itemBuilder: (context, index) {
                              final place = userPlaces[index];
                              final point = place['point'] as osm.GeoPoint;

                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      place['name'] as String,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.place,
                                          size: 18,
                                          color: AppColors.mainColor,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Lat: ${point.latitude.toStringAsFixed(4)}, '
                                            'Long: ${point.longitude.toStringAsFixed(4)}',
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            showCustomDialog(
                                              context: context,
                                              title: 'Delete Place',
                                              titleColor: Colors.red,
                                              content:
                                                  'Are you sure you want to delete this place?',
                                              showCancelButton: true,
                                              onPressed: () async {
                                                await FirebaseFirestore.instance
                                                    .collection(
                                                      Constants.dbPlaces,
                                                    )
                                                    .doc(
                                                      place['docId'].toString(),
                                                    )
                                                    .delete();

                                                Navigator.pop(context);
                                                await _loadUserPlaces();
                                              },
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.cancel,
                                            size: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
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
}
