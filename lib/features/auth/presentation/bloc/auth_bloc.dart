import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:share_loc/core/enums/update_user.dart';
import 'package:share_loc/core/network/data_state.dart';
import 'package:share_loc/core/utils/typedef.dart';
import 'package:share_loc/features/auth/domain/entities/user.dart';
import 'package:share_loc/features/auth/domain/usecases/forgot_password.dart';
import 'package:share_loc/features/auth/domain/usecases/sign_in.dart';
import 'package:share_loc/features/auth/domain/usecases/sign_up.dart';
import 'package:share_loc/features/auth/domain/usecases/update_user.dart';
import 'package:equatable/equatable.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required SignIn signIn,
    required SignUp signUp,
    required ForgotPassword forgotPassword,
    required UpdateUser updateUser,
  })  : _signIn = signIn,
        _signUp = signUp,
        _forgotPassword = forgotPassword,
        _updateUser = updateUser,
        super(const AuthState()) {
    on<SignInEvent>(_signInHandler);
    on<SignUpEvent>(_signUpHandler);
    on<ForgotPasswordEvent>(_forgotPasswordHandler);
    on<UpdateUserEvent>(_updateUserHandler);
  }
  final SignIn _signIn;
  final SignUp _signUp;
  final ForgotPassword _forgotPassword;
  final UpdateUser _updateUser;

  Future<void> _signInHandler(
    SignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(signInState: const Data.loading()));
    final result = await _signIn(
      SignInParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          signInState: Data.failure(error: failure.errorMessage),
        ),
      ),
      (user) => emit(state.copyWith(signInState: Data.loaded(value: user))),
    );
  }

  Future<void> _signUpHandler(
    SignUpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(signUpState: const Data.loading()));

    final result = await _signUp(
      SignUpParams(
        email: event.email,
        password: event.password,
        fullName: event.name,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          signUpState: Data.failure(error: failure.errorMessage),
        ),
      ),
      (_) => emit(state.copyWith(signUpState: const Data.loaded())),
    );
  }

  Future<void> _forgotPasswordHandler(
    ForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(forgotPasswordState: const Data.loading()));
    final result = await _forgotPassword(event.email);

    result.fold(
      (failure) => emit(
        state.copyWith(
          forgotPasswordState: Data.failure(error: failure.errorMessage),
        ),
      ),
      (_) => emit(state.copyWith(forgotPasswordState: const Data.loaded())),
    );
  }

  Future<void> _updateUserHandler(
    UpdateUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(updateUserState: const Data.loading()));

    final result = await _updateUser(
      UpdateUserParams(action: event.action, userData: event.userData),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          updateUserState: Data.failure(error: failure.errorMessage),
        ),
      ),
      (_) => emit(state.copyWith(updateUserState: const Data.loaded())),
    );
  }
}
