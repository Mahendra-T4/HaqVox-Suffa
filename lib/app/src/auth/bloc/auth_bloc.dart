import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:haqvox/app/core/widgets/custom_snackbar.dart';
import 'package:haqvox/app/src/auth/models/change_pass_entity.dart';
import 'package:haqvox/app/src/auth/models/forgot_pass_entity.dart';
import 'package:haqvox/app/src/auth/models/gender_entity.dart';
import 'package:haqvox/app/src/auth/models/login_entity.dart';
import 'package:haqvox/app/src/auth/models/otp_entity.dart';
import 'package:haqvox/app/src/auth/models/register_user_entity.dart';
import 'package:haqvox/app/src/auth/models/set_password_entity.dart';
import 'package:haqvox/app/src/auth/repositories/auth_repo.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthSuffaUserLoginEvent>(_authSuffaUserLoginEvent);
    on<AuthNewSuffaUserRegistrationEvent>(_authNewSuffaUserRegistrationEvent);
    on<FetchingGenderListEvent>(fetchingGenderListEvent);
    on<AuthOTPVerificationEvent>(_authOTPVerificationEvent);
    on<AuthSetPasswordEvent>(_authSetPasswordEvent);
    on<AuthChangePasswordEvent>(_authChangePasswordEvent);
    on<AuthForgotPasswordEvent>(_authForgotPasswordEvent);
    on<AuthOTPVerificationForRegisterEvent>(
      _authOTPVerificationForRegisterEvent,
    );
  }

  FutureOr<void> _authSuffaUserLoginEvent(
    AuthSuffaUserLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      final loginEntity = await AuthRepository.signInWithEmailAndPassword(
        event.email,
        event.password,
        event.context,
      );

      emit(AuthSuffaUserLoginSuccessState(loginEntity: loginEntity));
    } catch (e) {
      log('Login Bloc Error: $e');
      emit(AuthSuffaUserLoginFailureState(error: e.toString()));
    }
  }

  FutureOr<void> _authNewSuffaUserRegistrationEvent(
    AuthNewSuffaUserRegistrationEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      final registerEntity = await AuthRepository.signUpWithEmailAndPassword(
        event.fName.toString(),
        event.lName.toString(),
        event.email.toString(),
        event.mobile.toString(),
        event.alternateMobile.toString(),
        event.dob.toString(),
        event.gender.toString(),
        event.password.toString(),
        event.uTerms.toString(),
        event.context,
      );
      if (registerEntity.status == 1) {
        emit(
          AuthSuffaNewUserRegistrationSuccessState(
            registerEntity: registerEntity,
          ),
        );

        emit(NavigateUserOnOTPVerificationPageActionState());
      } else {
        CustomSnackBar.show(
          context: event.context,
          message: registerEntity.message.toString(),
          type: SnackBarType.error,
        );
        emit(
          AuthSuffaNewUserRegistrationFailureState(
            error: registerEntity.message ?? 'Registration failed',
          ),
        );
      }
    } catch (e) {
      log('Registration Bloc Error: $e');
      emit(AuthSuffaNewUserRegistrationFailureState(error: e.toString()));
    }
  }

  FutureOr<void> fetchingGenderListEvent(
    FetchingGenderListEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      final genderList = await AuthRepository.genderList();
      emit(AuthGenderListFetchingLoadedSuccessState(genderEntity: genderList));
    } catch (e) {
      log('GenderList Bloc Error: $e');
      emit(AuthGenderListFetchingFailedErrorState(error: e.toString()));
    }
  }

  FutureOr<void> _authOTPVerificationEvent(
    AuthOTPVerificationEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      final getOTP = await AuthRepository.otpVerification(
        uOTP: event.uOTP,
        rKey: event.rKey.toString(),
        context: event.context,
      );
      emit(AuthOTPVerificationSuccessState(otpVerificationEntity: getOTP));
    } catch (e) {
      log('OTP Verification Error From Bloc : $e');
      emit(AuthOTPVerificationFailedErrorState(error: e.toString()));
    }
  }

  FutureOr<void> _authSetPasswordEvent(
    AuthSetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      final setPassword = await AuthRepository.resetPassword(
        context: event.context,
        newPass: event.newPass,
        rKey: event.rKey,
        confPass: event.confPass,
      );
      emit(AuthSetPasswordSuccessState(setPasswordEntity: setPassword));
      CustomSnackBar.show(
        context: event.context,
        message: setPassword.message.toString(),
        type: SnackBarType.success,
      );
    } catch (e) {
      log('Set Password Error From Bloc $e');
      emit(AuthSetPasswordFailedErrorState(error: e.toString()));
    }
  }

  FutureOr<void> _authChangePasswordEvent(
    AuthChangePasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      final changePassword = await AuthRepository.changePassword(
        newPass: event.newPass,
        confPass: event.confPass,
        currentPass: event.currentPass,
        context: event.context,
      );
      if (changePassword.status == 1) {
        emit(
          AuthChangePasswordSuccessState(changePasswordEntity: changePassword),
        );
        CustomSnackBar.show(
          context: event.context,
          message: changePassword.message.toString(),
          type: SnackBarType.success,
        );
      } else {
        CustomSnackBar.show(
          context: event.context,
          message: changePassword.message.toString(),
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      log('Change Password Error From Bloc $e');
    }
  }

  FutureOr<void> _authForgotPasswordEvent(
    AuthForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      final forgotPassword = await AuthRepository.forgotPassword(
        uMobile: event.uMobile,
        context: event.context,
      );
      emit(
        AuthForgotPasswordSuccessState(forgotPasswordEntity: forgotPassword),
      );
    } catch (e) {
      log('Forgot Password Error From Bloc $e');
      emit(AuthForgotPasswordFailedErrorState(error: e.toString()));
    }
  }

  FutureOr<void> _authOTPVerificationForRegisterEvent(
    AuthOTPVerificationForRegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      final getOTP = await AuthRepository.otpVerificationRegister(
        uOTP: event.uOTP,
        rKey: event.rKey.toString(),
        context: event.context,
      );
      emit(AuthOTPVerificationSuccessState(otpVerificationEntity: getOTP));
    } catch (e) {
      log('OTP Verification Error From Bloc : $e');
      emit(AuthOTPVerificationFailedErrorState(error: e.toString()));
    }
  }
}
