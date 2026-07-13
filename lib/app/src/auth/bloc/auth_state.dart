part of 'auth_bloc.dart';

sealed class AuthState {}

sealed class AuthActionState extends AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoadingState extends AuthState {}

//! Login State

final class AuthSuffaUserLoginSuccessState extends AuthState {
  final LoginEntity loginEntity;

  AuthSuffaUserLoginSuccessState({required this.loginEntity});
}

final class AuthSuffaUserLoginFailureState extends AuthState {
  final String error;
  AuthSuffaUserLoginFailureState({required this.error});
}

final class NavigateUserOnSuffaHomeActionState extends AuthActionState {}

//! Registration State

final class AuthSuffaNewUserRegistrationSuccessState extends AuthState {
  final RegisterEntity registerEntity;

  AuthSuffaNewUserRegistrationSuccessState({required this.registerEntity});
}

final class AuthSuffaNewUserRegistrationFailureState extends AuthState {
  final String error;
  AuthSuffaNewUserRegistrationFailureState({required this.error});
}

final class NavigateUserOnOTPVerificationPageActionState
    extends AuthActionState {}

final class AuthOTPVerificationSuccessState extends AuthState {
  final OTPVerificationEntity otpVerificationEntity;

  AuthOTPVerificationSuccessState({required this.otpVerificationEntity});
}

final class AuthOTPVerificationFailedErrorState extends AuthState {
  final String error;

  AuthOTPVerificationFailedErrorState({required this.error});
}

final class AuthGenderListFetchingLoadedSuccessState extends AuthState {
  final GenderEntity genderEntity;

  AuthGenderListFetchingLoadedSuccessState({required this.genderEntity});
}

final class AuthGenderListFetchingFailedErrorState extends AuthState {
  final String error;

  AuthGenderListFetchingFailedErrorState({required this.error});
}

final class AuthOTPVerifiedAndNavigateToNextViewState extends AuthActionState {}

final class AuthSetPasswordSuccessState extends AuthState {
  final SetPasswordEntity setPasswordEntity;

  AuthSetPasswordSuccessState({required this.setPasswordEntity});
}

final class AuthSetPasswordFailedErrorState extends AuthState {
  final String error;

  AuthSetPasswordFailedErrorState({required this.error});
}

final class NavigateToSetPasswordActionState extends AuthActionState{}

final class AuthChangePasswordSuccessState extends AuthState {
  final ChangePasswordEntity changePasswordEntity;

  AuthChangePasswordSuccessState({required this.changePasswordEntity});
}


final class AuthChangePasswordFailedErrorState extends AuthState {
  final String error;

  AuthChangePasswordFailedErrorState({required this.error});
}


final class AuthForgotPasswordSuccessState extends AuthState {
  final ForgotPasswordEntity forgotPasswordEntity;

  AuthForgotPasswordSuccessState({required this.forgotPasswordEntity});
}

final class AuthForgotPasswordFailedErrorState extends AuthState {
  final String error;

  AuthForgotPasswordFailedErrorState({required this.error});
}