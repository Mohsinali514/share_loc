import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_loc/core/common/providers/user_provider.dart';
import 'package:share_loc/core/common/widgets/btn.dart';
import 'package:share_loc/core/common/widgets/custom_header.dart';
import 'package:share_loc/core/res/colours.dart';
import 'package:share_loc/core/res/media_res.dart';
import 'package:share_loc/core/services/di.dart';
import 'package:share_loc/core/utils/constants.dart';
import 'package:share_loc/core/utils/core_utils.dart';
import 'package:share_loc/features/auth/data/models/user_model.dart';

class CircleManagementScreen extends StatefulWidget {
  const CircleManagementScreen({super.key});

  @override
  State<CircleManagementScreen> createState() => _CircleManagementScreenState();
}

class _CircleManagementScreenState extends State<CircleManagementScreen> {
  List<Map<String, dynamic>> myCircles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCircles();
  }

  Future<void> fetchCircles() async {
    final uid = context.read<UserProvider>().user?.uid;

    if (uid != null) {
      final snapshot =
          await FirebaseFirestore.instance.collection('circles').get();

      final filtered = snapshot.docs
          .where((doc) {
            final data = doc.data();
            final members = List<String>.from(data['members'] as List? ?? []);
            return members.contains(uid);
          })
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();

      setState(() {
        myCircles = filtered;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final height = mediaQuery.size.height;

    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body: Stack(
        children: [
          CustomHeader(
            imagePath: MediaRes.bgImage,
            title: 'My Circles',
            onBackPressed: () => Navigator.pop(context),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.05,
                vertical: height * 0.02,
              ),
              height: height * 0.83,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ResponsiveButton(
                      label: 'Create New Circle',
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          Constants.joinOrCreateCircleScreen,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : myCircles.isEmpty
                            ? const Center(child: Text('No circles found.'))
                            : ListView.builder(
                                itemCount: myCircles.length,
                                itemBuilder: (context, index) {
                                  final circle = myCircles[index];
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const CircleAvatar(
                                      backgroundColor: AppColors.mainColor,
                                      child: Icon(
                                        Icons.group,
                                        color: Colors.white,
                                      ),
                                    ),
                                    title: Text(
                                      circle['circleName']?.toString() ??
                                          'Unnamed Circle',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${(circle['members'] as List).length} members',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                    trailing: Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Colors.grey.shade400,
                                    ),
                                    onTap: () async {
                                      final uid = context
                                          .read<UserProvider>()
                                          .user
                                          ?.uid;
                                      if (uid != null) {
                                        try {
                                          // Update Firestore
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(uid)
                                              .update({
                                            'currentCircle': circle['id'],
                                          });

                                          // Fetch updated user data
                                          final userData =
                                              await sl<FirebaseFirestore>()
                                                  .collection(Constants.dbUsers)
                                                  .doc(uid)
                                                  .get();

                                          final data = userData.data();
                                          if (data != null) {
                                            // Update UserProvider
                                            final userLocal =
                                                LocalUserModel.fromMap(data);
                                            context
                                                .read<UserProvider>()
                                                .initUser(userLocal);
                                            await Future.delayed(
                                              const Duration(
                                                milliseconds: 100,
                                              ),
                                            );
                                            // Navigate
                                            Navigator.pushReplacementNamed(
                                              context,
                                              Constants.homePage,
                                            );
                                          }
                                        } catch (e) {
                                          CoreUtils.showSnackBar(
                                            context,
                                            'Failed to select circle',
                                            color: Colors.red,
                                          );
                                        }
                                      }
                                    },
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
