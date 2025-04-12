import 'package:bloc/bloc.dart';
import 'package:share_loc/core/network/data_state.dart';
import 'package:share_loc/core/utils/typedef.dart';
import 'package:share_loc/features/on_boarding/domain/usecases/cache_first_time.dart';
import 'package:share_loc/features/on_boarding/domain/usecases/check_if_user_is_first_time.dart';
import 'package:equatable/equatable.dart';

part 'on_boarding_state.dart';

class OnBoardingCubit extends Cubit<OnBoardingState> {
  OnBoardingCubit({
    required CacheFirstTime cacheFirstTime,
    required CheckIfUserIsFirstTime checkIfUserIsFirstTime,
  })  : _cacheFirstTime = cacheFirstTime,
        _checkIfUserIsFirstTime = checkIfUserIsFirstTime,
        super(const OnBoardingState());
  final CacheFirstTime _cacheFirstTime;
  final CheckIfUserIsFirstTime _checkIfUserIsFirstTime;

  Future<void> cacheFirstTime() async {
    emit(state.copyWith(cacheFirstTimeState: const Data.loading()));
    final result = await _cacheFirstTime();
    result.fold(
      (failure) => emit(
        state.copyWith(
          cacheFirstTimeState: Data.failure(error: failure.errorMessage),
        ),
      ),
      (_) => emit(
        state.copyWith(cacheFirstTimeState: const Data.loaded()),
      ),
    );
  }

  Future<void> checkIfUserIsFirstTime() async {
    emit(state.copyWith(checkIfUserIsFirstTimeState: const Data.loading()));
    final result = await _checkIfUserIsFirstTime();
    result.fold(
      (failure) => emit(const OnBoardingStatus(isFirstTime: true)),
      (status) => emit(OnBoardingStatus(isFirstTime: status)),
    );
  }
}
