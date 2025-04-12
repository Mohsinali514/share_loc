import 'package:share_loc/core/common/views/loading_view.dart';
import 'package:share_loc/core/common/widgets/gradient_background.dart';
import 'package:share_loc/core/res/colours.dart';
import 'package:share_loc/core/res/media_res.dart';
import 'package:share_loc/features/on_boarding/domain/entities/page_content.dart';
import 'package:share_loc/features/on_boarding/presentation/cubit/on_boarding_cubit.dart';
import 'package:share_loc/features/on_boarding/presentation/widgets/on_boarding_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final pageController = PageController();

  @override
  void initState() {
    super.initState();

    BlocProvider.of<OnBoardingCubit>(context).checkIfUserIsFirstTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        image: MediaRes.onBoardingBackground,
        child: BlocConsumer<OnBoardingCubit, OnBoardingState>(
          listener: (context, state) {
            if (state is OnBoardingStatus && !state.isFirstTime) {
              return;
            }
          },
          builder: (BuildContext context, OnBoardingState state) {
            if (state.checkIfUserIsFirstTimeState.isLoading ||
                state.cacheFirstTimeState.isLoading) {
              return const Center(
                child: LoadingView(),
              );
            }
            return Stack(
              children: [
                PageView(
                  controller: pageController,
                  onPageChanged: (index) {
                    index += 1;
                  },
                  children: const [
                    OnBoardingBody(
                      pageContent: PageContent.first(),
                    ),
                    OnBoardingBody(
                      pageContent: PageContent.second(),
                    ),
                    OnBoardingBody(
                      pageContent: PageContent.third(),
                    ),
                  ],
                ),
                Align(
                  alignment: const Alignment(0, .04),
                  child: SmoothPageIndicator(
                    controller: pageController,
                    count: 3,
                    onDotClicked: (index) {
                      pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    effect: const WormEffect(
                      dotHeight: 10,
                      dotWidth: 10,
                      spacing: 40,
                      activeDotColor: AppColors.mainColor,
                      dotColor: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
