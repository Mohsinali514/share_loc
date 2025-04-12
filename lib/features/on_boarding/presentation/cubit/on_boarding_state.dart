part of 'on_boarding_cubit.dart';

class OnBoardingState extends Equatable {
  const OnBoardingState({
    this.cacheFirstTimeState = const Data(),
    this.checkIfUserIsFirstTimeState = const Data(),
  });

  final CacheFirstTimeState cacheFirstTimeState;
  final CheckIfUserIsFirstTimeState checkIfUserIsFirstTimeState;

  @override
  List<Object> get props => [cacheFirstTimeState, checkIfUserIsFirstTimeState];

  OnBoardingState copyWith({
    CacheFirstTimeState? cacheFirstTimeState,
    CheckIfUserIsFirstTimeState? checkIfUserIsFirstTimeState,
  }) {
    return OnBoardingState(
      cacheFirstTimeState: cacheFirstTimeState ?? this.cacheFirstTimeState,
      checkIfUserIsFirstTimeState:
          checkIfUserIsFirstTimeState ?? this.checkIfUserIsFirstTimeState,
    );
  }
}

class OnBoardingStatus extends OnBoardingState {
  const OnBoardingStatus({
    required this.isFirstTime,
    super.cacheFirstTimeState,
    super.checkIfUserIsFirstTimeState,
  });

  final bool isFirstTime;

  @override
  List<Object> get props => [isFirstTime, ...super.props];
}
