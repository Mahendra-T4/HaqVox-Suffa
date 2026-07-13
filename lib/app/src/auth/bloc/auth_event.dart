part of 'auth_bloc.dart';

sealed class AuthEvent {}

final class AuthSuffaUserLoginEvent extends AuthEvent {
  final String email;
  final String password;
  final BuildContext context;

  AuthSuffaUserLoginEvent({
    required this.email,
    required this.password,
    required this.context,
  });
}

final class AuthNewSuffaUserRegistrationEvent extends AuthEvent {
  final String? fName;
  final String? lName;
  final String? email;
  final String? mobile;
  final String? alternateMobile;
  final String? dob;
  final String? gender; // Should b String, not int
  final String? password;
  final String? uTerms;
  final BuildContext context;

  AuthNewSuffaUserRegistrationEvent(
      {this.fName,
      this.lName,
      this.email,
      this.mobile,
      this.alternateMobile,
      this.dob,
      this.gender,
      this.password,
      this.uTerms,
      required this.context});
}

final class AuthSuffaNewUserRegistrationVerificationEvent extends AuthEvent {
  final OTPEntity OtpEntity;

  AuthSuffaNewUserRegistrationVerificationEvent({required this.OtpEntity});
}

final class AuthOTPVerificationEvent extends AuthEvent {
  final String uOTP;
  final String? rKey;
  final BuildContext context;

  AuthOTPVerificationEvent(
      {required this.uOTP, required this.context, this.rKey});
}

final class AuthOTPVerificationForRegisterEvent extends AuthEvent {
  final String uOTP;
  final String? rKey;
  final BuildContext context;

  AuthOTPVerificationForRegisterEvent(
      {required this.uOTP, required this.context, this.rKey});
}

final class FetchingGenderListEvent extends AuthEvent {}

final class AuthSetPasswordEvent extends AuthEvent {
  final String newPass;
  final String confPass;
  final String rKey;
  final BuildContext context;

  AuthSetPasswordEvent(
      {required this.newPass, required this.confPass,required this.rKey 
      ,required this.context});
}

final class AuthChangePasswordEvent extends AuthEvent {
  final String newPass;
  final String confPass;
  final String currentPass;
  final BuildContext context;

  AuthChangePasswordEvent(
      {required this.newPass,
      required this.confPass,
      required this.currentPass,
      required this.context});
}

final class AuthForgotPasswordEvent extends AuthEvent {
  final String uMobile;
  final BuildContext context;

  AuthForgotPasswordEvent({required this.uMobile, required this.context});
}
