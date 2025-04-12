import 'package:share_loc/core/common/widgets/btn.dart';
import 'package:share_loc/core/common/widgets/custom_header.dart';
import 'package:share_loc/core/res/colours.dart';
import 'package:share_loc/core/res/media_res.dart';
import 'package:share_loc/core/utils/constants.dart';
import 'package:share_loc/core/utils/core_utils.dart';
import 'package:share_loc/features/circle/presentation/cubit/circle_cubit.dart';
import 'package:share_loc/features/circle/presentation/cubit/circle_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CreateCircleScreen extends StatefulWidget {
  const CreateCircleScreen({super.key});

  @override
  _CreateCircleScreenState createState() => _CreateCircleScreenState();
}

class _CreateCircleScreenState extends State<CreateCircleScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CircleCubit, CircleState>(
      listener: (context, state) {
        if (state.createCircleState.isLoading) {
          CoreUtils.toastInfo(
            msg: 'Creating circle...',
            backgroundColor: AppColors.mainColor,
            gravity: ToastGravity.TOP,
          );
          // Show loading indicator
          showDialog(
            context: context,
            builder: (context) => const Center(
              child: CircularProgressIndicator(
                color: AppColors.mainColor,
              ),
            ),
          );
        } else if (state.createCircleState.isLoaded) {
          Navigator.pop(
            context,
          );
          final circle = state.createCircleState.value;
          // final invitationCode = circle?.invitationCode;
          // final circleId = circle?.circleId;

          CoreUtils.toastInfo(
            msg: 'Circle Created Successfully!',
            backgroundColor: Colors.green,
            gravity: ToastGravity.TOP,
          );

          Future.delayed(const Duration(milliseconds: 300), () {
            Navigator.pushNamed(
              context,
              Constants.invitationCodeSreen,
              arguments: circle,
            );
          });
        } else if (state.createCircleState.isFailure) {
          Navigator.pop(context); // Dismiss dialog

          CoreUtils.showSnackBar(
            color: Colors.red,
            context,
            'Failed to create circle. Please try again.',
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.mainColor,
        body: Stack(
          children: [
            CustomHeader(
              imagePath: MediaRes.bgImage,
              onBackPressed: () {
                Navigator.pop(context);
              },
            ),
            // Sheet with SingleChildScrollView
            Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  height: MediaQuery.of(context).size.height * 0.83,
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
                      const SizedBox(height: 20),
                      const Text(
                        'Give your Circle a Name',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "What's your cell phone number?",
                        style: TextStyle(color: AppColors.dimText),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: '03xx-xxxxxxx',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(12),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey, // Default color
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.mainColor, // when focused
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Circle Name',
                        style: TextStyle(color: AppColors.text),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          hintText: 'Albert Edison',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(12),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey, // Default color
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.mainColor, // when focused
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Tip: You may need to ask the circle creator for the code',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 200),
                      SizedBox(
                        width: double.infinity,
                        child: ResponsiveButton(
                          label: 'Next',
                          onPressed: () {
                            final name = nameController.text.trim();
                            final phoneNumber = phoneController.text.trim();

                            // Validate inputs
                            if (name.isEmpty || phoneNumber.isEmpty) {
                              // Validation message
                              CoreUtils.showSnackBar(
                                color: Colors.red,
                                context,
                                'Please enter both fields.',
                              );

                              return;
                            }

                            // Trigger createCircle
                            BlocProvider.of<CircleCubit>(context)
                                .createCircle(name, phoneNumber);

                            // Optionally, reset input fields
                            nameController.clear();
                            phoneController.clear();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
