import 'package:share_loc/core/common/providers/user_provider.dart';
import 'package:share_loc/core/common/widgets/btn.dart';
import 'package:share_loc/core/common/widgets/custom_header.dart';
import 'package:share_loc/core/enums/update_creator.dart';
import 'package:share_loc/core/res/colours.dart';
import 'package:share_loc/core/res/media_res.dart';
import 'package:share_loc/core/utils/constants.dart';
import 'package:share_loc/core/utils/core_utils.dart';
import 'package:share_loc/features/circle/data/models/circle_model.dart';
import 'package:share_loc/features/circle/presentation/cubit/circle_cubit.dart';
import 'package:share_loc/features/circle/presentation/cubit/circle_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DesignatedRoleScreen extends StatefulWidget {
  const DesignatedRoleScreen({super.key});

  @override
  _DesignatedRoleScreenState createState() => _DesignatedRoleScreenState();
}

class _DesignatedRoleScreenState extends State<DesignatedRoleScreen> {
  final Map<Role, String> roleLabels = {
    Role.mother: 'Mother',
    Role.father: 'Father',
    Role.boysGirls: 'Boys/Girls',
    Role.grandParents: 'Grandparents',
    Role.partner: 'Partner',
    Role.friend: 'Friend',
    Role.other: 'Other',
  };

  @override
  Widget build(BuildContext context) {
    final circle =
        ModalRoute.of(context)!.settings.arguments! as LocalCircleModel;
    final circleId = circle.circleId;

    return BlocConsumer<CircleCubit, CircleState>(
      listener: (context, state) {
        if (state.updateCreatorRoleState.isLoading) {
          CoreUtils.toastInfo(
            msg: 'Updating creator role...',
            backgroundColor: AppColors.mainColor,
            gravity: ToastGravity.TOP,
          );
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );
        }

        if (state.updateCreatorRoleState.isLoaded) {
          Navigator.pop(context);
          CoreUtils.toastInfo(
            msg: 'Role updated successfully',
            backgroundColor: Colors.green,
          );
          final user = context.read<UserProvider>().user;
          final checkPhoto = user?.profilePic;
          if (checkPhoto == null) {
            Navigator.pushNamed(context, Constants.addPhotoScreen);
          } else {
            if (checkPhoto.isEmpty) {
              Navigator.pushNamed(context, Constants.addPhotoScreen);
            } else {
              Navigator.pushNamed(context, Constants.permissionScreen);
            }
          }
        }

        if (state.updateCreatorRoleState.isFailure) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.updateCreatorRoleState.error as String),
            ),
          );
        }
      },
      builder: (context, state) {
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
                        const Center(
                          child: Text(
                            textAlign: TextAlign.center,
                            'What is your designated role within this circle?',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // buttons
                        ...roleLabels.entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildRoleButton(
                              role: entry.key,
                              label: entry.value,
                              circleId: circleId,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoleButton({
    required Role role,
    required String label,
    required String circleId,
  }) {
    return ResponsiveButton(
      label: label,
      onPressed: () {
        context.read<CircleCubit>().updateCreatorRole(circleId, role);
      },
    );
  }
}
