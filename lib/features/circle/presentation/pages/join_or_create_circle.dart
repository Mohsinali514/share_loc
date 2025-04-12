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
import 'package:pin_code_fields/pin_code_fields.dart';

class JoinOrCreateCircleScreen extends StatefulWidget {
  const JoinOrCreateCircleScreen({super.key});

  @override
  _JoinOrCreateCircleScreenState createState() =>
      _JoinOrCreateCircleScreenState();
}

class _JoinOrCreateCircleScreenState extends State<JoinOrCreateCircleScreen> {
  late TextEditingController pinController;

  @override
  void initState() {
    super.initState();
    pinController = TextEditingController();
  }

  // @override
  // void dispose() {
  //   pinController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body: Stack(
        children: [
          CustomHeader(
            imagePath: MediaRes.bgImage,
            onBackPressed: () {
              Navigator.pop(context);
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              height: MediaQuery.of(context).size.height * 0.83,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: BlocConsumer<CircleCubit, CircleState>(
                listener: (context, state) {
                  if (state.joinCircleState.isLoaded) {
                    CoreUtils.showSnackBar(
                      context,
                      'Successfully joined the circle!',
                    );
                    Navigator.pushNamed(
                      context,
                      Constants.addPhotoScreen,
                    );
                  } else if (state.joinCircleState.isFailure) {
                    CoreUtils.showSnackBar(
                      context,
                      state.joinCircleState.error.toString(),
                    );
                  }
                },
                builder: (context, state) {
                  final isLoading = state.joinCircleState.isLoading;
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'Join a circle? Enter your invitation code',
                          style: TextStyle(
                            fontSize: 20,
                            color: AppColors.text,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        PinCodeTextField(
                          controller: pinController,
                          keyboardType: TextInputType.text,
                          appContext: context,
                          length: 4,
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(10),
                            fieldHeight: 50,
                            fieldWidth: 60,
                            activeFillColor: Colors.white,
                            selectedFillColor: Colors.white,
                            inactiveFillColor: Colors.white,
                            activeColor: AppColors.mainColor,
                            selectedColor: AppColors.mainColor,
                            inactiveColor: Colors.grey,
                          ),
                          onChanged: (value) {
                            print('onChanged: $value');
                          },
                          onCompleted: (code) {
                            print('onCompleted: $code');
                          },
                        ),
                        const SizedBox(height: 15),
                        const Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            'Tip: you may need to ask the circle maker for the code.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ResponsiveButton(
                          label: 'Join Circle',
                          labelColor: AppColors.lightText,
                          backgroundColor: AppColors.dimColor,
                          borderColor: AppColors.dimColor,
                          isLoading: isLoading,
                          progressIndicatorColor: AppColors.mainColor,
                          onPressed: () async {
                            final pinCode = pinController.text;

                            if (pinCode.length == 4) {
                              await context
                                  .read<CircleCubit>()
                                  .joinCircle(pinCode);
                            } else {
                              CoreUtils.showSnackBar(
                                context,
                                'Please enter a valid 4-letter code',
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 40),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 1,
                                color: AppColors.dimText,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.dimText,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                thickness: 1,
                                color: AppColors.dimText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 50),
                        const Text(
                          "Don't have a code?",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.text2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "We'll give you a code to share",
                          style: TextStyle(color: AppColors.dimText),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ResponsiveButton(
                            label: 'Create a new Circle',
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                Constants.createCircleScreen,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
