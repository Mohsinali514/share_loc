part of 'auth_bloc.dart';

class AuthState extends Equatable {
  const AuthState({
    this.signInState = const Data(),
    this.signUpState = const Data(),
    this.forgotPasswordState = const Data(),
    this.updateUserState = const Data(),
  });

  final SignInState signInState;
  final SignUpState signUpState;
  final ForgotPasswordState forgotPasswordState;
  final UpdateUserState updateUserState;

  @override
  List<Object> get props =>
      [signInState, signUpState, forgotPasswordState, updateUserState];

  AuthState copyWith({
    SignInState? signInState,
    SignUpState? signUpState,
    ForgotPasswordState? forgotPasswordState,
    UpdateUserState? updateUserState,
  }) {
    return AuthState(
      signInState: signInState ?? this.signInState,
      signUpState: signUpState ?? this.signUpState,
      forgotPasswordState: forgotPasswordState ?? this.forgotPasswordState,
      updateUserState: updateUserState ?? this.updateUserState,
    );
  }
}

class AuthStatus extends Equatable {
  const AuthStatus({
    this.isAuthenticated = false,
    this.user,
  });

  final bool isAuthenticated;
  final LocalUser? user;

  @override
  List<Object> get props => [isAuthenticated, user ?? Object()];

  AuthStatus copyWith({
    bool? isAuthenticated,
    LocalUser? user,
  }) {
    return AuthStatus(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
    );
  }
}
