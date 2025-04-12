import 'dart:io';

import 'package:share_loc/core/common/widgets/btn.dart';
import 'package:share_loc/core/common/widgets/custom_header.dart';
import 'package:share_loc/core/enums/update_user.dart';
import 'package:share_loc/core/res/colours.dart';
import 'package:share_loc/core/res/media_res.dart';
import 'package:share_loc/core/utils/constants.dart';
import 'package:share_loc/core/utils/core_utils.dart';
import 'package:share_loc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class AddPhotoScreen extends StatefulWidget {
  const AddPhotoScreen({super.key});

  @override
  State<AddPhotoScreen> createState() => _AddPhotoScreenState();
}

class _AddPhotoScreenState extends State<AddPhotoScreen> {
  File? pickedImage;
  bool _isUploading = false;

  Future<void> pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        pickedImage = File(image.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (pickedImage == null) {
      // Handle case where no image is selected
      CoreUtils.showSnackBar(
        context,
        'Please select an image first.',
        color: Colors.red,
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        // Handle case where user is not logged in
        CoreUtils.showSnackBar(context, 'User not logged in.');
        return;
      }
      context.read<AuthBloc>().add(
            UpdateUserEvent(
              action: UpdateUserAction.profilePic,
              userData: pickedImage!,
            ),
          );
      CoreUtils.showSnackBar(context, 'Image uploaded successfully!');
      await Navigator.pushNamed(
        context,
        Constants.permissionScreen,
      );
    } catch (e) {
      // Handle any errors during the upload process
      print('Error during upload: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
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
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: height * 0.02),

                    // Title
                    Text(
                      'Feel free to add your photo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: width * 0.058,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: height * 0.01),

                    // Subtitle
                    Text(
                      'This makes it easier for your family to find you on a map',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: width * 0.040,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: height * 0.02),

                    // Asset image
                    if (pickedImage != null)
                      Image.file(pickedImage!)
                    else
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Exact outer border hugging image with no visible spacing
                            Container(
                              height: height * 0.38 +
                                  6, // + border*2 to compensate inner size
                              width: height * 0.40 + 6,
                              padding: const EdgeInsets.all(
                                2,
                              ), // Equal to border width
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.grey.shade100,
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  MediaRes.personImage,
                                  fit: BoxFit.cover,
                                  width: height * 0.40,
                                  height: height * 0.38,
                                ),
                              ),
                            ),

                            // Person icon
                            Positioned(
                              height: 120,
                              width: 120,
                              child: Image.asset(
                                MediaRes.userIcon,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: height * 0.03),

                    // Add your photo button
                    SizedBox(
                      width: double.infinity,
                      child: ResponsiveButton(
                        leadingIcon: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                        ),
                        label: 'Add your photo',
                        onPressed: pickImage,
                      ),
                    ),
                    SizedBox(height: height * 0.05),

                    // Next button
                    SizedBox(
                      width: double.infinity,
                      child: ResponsiveButton(
                        label: 'Next',
                        labelColor: AppColors.lightText,
                        backgroundColor: Colors.white,
                        borderColor: AppColors.dimColor,
                        onPressed: _uploadImage,
                      ),
                    ),

                    // Skip
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          Constants.permissionScreen,
                        );
                      },
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: width * 0.040,
                          color: AppColors.mainColor,
                          fontWeight: FontWeight.w600,
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
}
