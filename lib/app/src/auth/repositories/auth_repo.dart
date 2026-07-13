import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:haqvox/app/config/environment.dart';
import 'package:haqvox/app/core/database/key.dart';
import 'package:haqvox/app/core/database/user/hive_db.dart';
import 'package:haqvox/app/core/models/verification_params.dart';
import 'package:haqvox/app/core/widgets/custom_snackbar.dart';
import 'package:haqvox/app/src/auth/models/change_pass_entity.dart';
import 'package:haqvox/app/src/auth/models/forgot_pass_entity.dart';
import 'package:haqvox/app/src/auth/models/gender_entity.dart';
import 'package:haqvox/app/src/auth/models/login_entity.dart';
import 'package:haqvox/app/src/auth/models/otp_entity.dart';
import 'package:haqvox/app/src/auth/models/register_user_entity.dart';
import 'package:haqvox/app/src/auth/models/set_password_entity.dart';
import 'package:haqvox/app/src/auth/view/login.dart';
import 'package:haqvox/app/src/auth/view/otp/register_otp.dart';
import 'package:haqvox/app/src/auth/view/setpassword.dart';
import 'package:haqvox/app/src/auth/view/verification/set_pass_verification.dart';
import 'package:haqvox/app/src/bottom_bar.dart';
import 'package:http/http.dart' as http;

abstract class AuthRepository {
  static final client = http.Client();
  static final url = Uri.parse(Environment.baseUrl);

  static Future<LoginEntity> signInWithEmailAndPassword(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      final url = Uri.parse(Environment.baseUrl);
      final body = ({
        'activity': 'login',
        'uEmail': email,
        'uPassword': password,
      });
      final response = await client.post(url, body: body);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final loginEntity = LoginEntity.fromJson(jsonResponse);

        if (loginEntity.status == 1 && loginEntity.record != null) {
          // Save user data to SharedPreferences

          await HiveService.setter(key: DBKeys.isLoggedIn, value: true);
          await HiveService.setter(
            key: DBKeys.userKey,
            value: loginEntity.record!.userKey,
          );
          await HiveService.setter(
            key: DBKeys.uFirstName,
            value: loginEntity.record!.uFirstName,
          );
          await HiveService.setter(
            key: DBKeys.uLastName,
            value: loginEntity.record!.uLastName,
          );
          await HiveService.setter(
            key: DBKeys.uEmail,
            value: loginEntity.record!.uEmail,
          );
          await HiveService.setter(
            key: DBKeys.uMobile,
            value: loginEntity.record!.uMobile,
          );
          await HiveService.setter(
            key: DBKeys.uSubscriptionKey,
            value: loginEntity.record!.uSubscription,
          );
          if (loginEntity.record!.uAlternateNumber != null) {
            await HiveService.setter(
              key: DBKeys.uAlternateNumber,
              value: loginEntity.record!.uAlternateNumber,
            );
          }
          if (loginEntity.record!.uDOB != null) {
            await HiveService.setter(
              key: DBKeys.uDOB,
              value: loginEntity.record!.uDOB,
            );
          }

          //  await HiveService.setter(
          //   key: DBKeys.imageKey,
          //   value: loginEntity.record!.,
          // );

          if (loginEntity.record!.uGender != null) {
            await HiveService.setter(
              key: DBKeys.uGender,
              value: loginEntity.record!.uGender,
            );
          }

          debugPrint('✅ User data saved: ${loginEntity.record?.userKey}');

          GoRouter.of(context).goNamed(BottomBar.routeName);

          CustomSnackBar.show(
            context: context,
            message: loginEntity.message.toString(),
            type: SnackBarType.success,
          );
        } else {
          CustomSnackBar.show(
            context: context,
            message: loginEntity.message ?? 'Login failed',
            type: SnackBarType.error,
          );
        }

        return loginEntity;
      } else {
        CustomSnackBar.show(
          context: context,
          message: 'Login failed. Please check your credentials.',
          type: SnackBarType.error,
        );
        return LoginEntity(
          status: 0,
          message: 'Login failed. Please check your credentials.',
        );
      }
    } catch (e) {
      log('Login Repository Error: $e');
      CustomSnackBar.show(
        context: context,
        message: 'An error occurred. Please try again.',
        type: SnackBarType.error,
      );
      return LoginEntity(status: 0, message: e.toString());
    }
  }

  static Future<RegisterEntity> signUpWithEmailAndPassword(
    String fName,
    String lName,
    String email,
    String mobile,
    String? alternateMobile,
    String dob,
    String gender,
    String password,
    String uTerms,
    BuildContext context,
  ) async {
    RegisterEntity registerEntity = RegisterEntity();
    try {
      final url = Uri.parse(Environment.baseUrl);
      // Convert all values to strings and handle nulls
      Map<String, String> body = {
        'activity': 'register',
        'uFirstName': fName.trim(),
        'uLastName': lName.trim(),
        'uEmail': email.trim(),
        'uMobile': mobile.trim(),
        'uAlternateNumber': (alternateMobile?.trim() ?? ''),
        'uDOB': dob.trim(),
        'uGender': gender.trim(),
        'uPassword': password,
        'uTerms': uTerms,
      };
      final response = await client.post(url, body: body);
      if (response.statusCode == 200) {
        log('Response body: ${response.body}');
        final jsonResponse = jsonDecode(response.body);

        // Convert numeric values to string before creating entity
        if (jsonResponse['uOTP'] is int) {
          jsonResponse['uOTP'] = jsonResponse['uOTP'].toString();
        }

        registerEntity = RegisterEntity.fromJson(jsonResponse);

        if (registerEntity.status == 1) {
          // Log before navigation to check OTP value
          log('Register OTP : ${registerEntity.uOTP}');

          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => RegisterVerification(
                    verificationParams: VerificationParams(
                      flag: BottomBar.routeName,
                      mobileNumber: mobile,
                      rKey: registerEntity.rKey.toString(),
                    ),
                  ),
            ),
          );
        }
        return registerEntity;
      } else {
        return RegisterEntity(status: 0, message: 'Registration failed');
      }
    } catch (e) {
      log('Registration Repository Error: $e');
      return RegisterEntity(status: 0, message: e.toString());
    }
  }

  static Future<OTPVerificationEntity> otpVerification({
    required String uOTP,
    required String rKey,
    required BuildContext context,
  }) async {
    try {
      final url = Uri.parse(Environment.baseUrl);
      // TODO: Retrieve user key from UserRepository
      // final userRepository = GetIt.I<UserRepository>();
      // final user = await userRepository.getLoggedInUser();

      OTPVerificationEntity otpVerificationEntity = OTPVerificationEntity();
      final response = await client.post(
        url,
        body: {'activity': 'otp-verification', 'uOTP': uOTP, 'rKey': rKey},
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        otpVerificationEntity = OTPVerificationEntity.fromJson(jsonResponse);
        log('OTP Verification Status ${otpVerificationEntity.message}');
        if (otpVerificationEntity.status == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SetPassword(rKey: rKey)),
          );
          CustomSnackBar.show(
            context: context,
            message: jsonResponse['message'],
            type: SnackBarType.success,
          );

          // GoRouter.of(context).goNamed(Login.routeName);
        } else {
          CustomSnackBar.show(
            context: context,
            message: jsonResponse['message'],
            type: SnackBarType.error,
          );
        }
        return OTPVerificationEntity.fromJson(jsonResponse);
      } else {
        log('Failed To Get OTP From Server');
        return OTPVerificationEntity(
          status: 0,
          message: 'Failed To Get OTP From Server',
        );
      }
    } catch (e) {
      log('OTP Verification Error From Repository : $e');
      return OTPVerificationEntity(status: 0, message: e.toString());
    }
  }

  static Future<OTPVerificationEntity> otpVerificationRegister({
    required String uOTP,
    required String rKey,
    required BuildContext context,
  }) async {
    try {
      final url = Uri.parse(Environment.baseUrl);
      // TODO: Retrieve user key from UserRepository
      // final userRepository = GetIt.I<UserRepository>();
      // final user = await userRepository.getLoggedInUser();

      OTPVerificationEntity otpVerificationEntity = OTPVerificationEntity();
      final response = await client.post(
        url,
        body: {'activity': 'otp-verification', 'uOTP': uOTP, 'rKey': rKey},
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        otpVerificationEntity = OTPVerificationEntity.fromJson(jsonResponse);
        log('OTP Verification Status ${otpVerificationEntity.message}');
        if (otpVerificationEntity.status == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Login()),
          );
          CustomSnackBar.show(
            context: context,
            message: jsonResponse['message'],
            type: SnackBarType.success,
          );

          // GoRouter.of(context).goNamed(Login.routeName);
        } else {
          CustomSnackBar.show(
            context: context,
            message: jsonResponse['message'],
            type: SnackBarType.error,
          );
        }
        return OTPVerificationEntity.fromJson(jsonResponse);
      } else {
        log('Failed To Get OTP From Server');
        return OTPVerificationEntity(
          status: 0,
          message: 'Failed To Get OTP From Server',
        );
      }
    } catch (e) {
      log('OTP Verification Error From Repository : $e');
      return OTPVerificationEntity(status: 0, message: e.toString());
    }
  }

  static Future<SetPasswordEntity> resetPassword({
    required String newPass,
    required String confPass,
    required String rKey,
    required BuildContext context,
  }) async {
    try {
      SetPasswordEntity setPasswordEntity = SetPasswordEntity();
      final response = await client.post(
        url,
        body: {
          'activity': 'set-password',
          'newPassword': newPass,
          'confirmPassword': confPass,
          'rKey': rKey.toString(),
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        setPasswordEntity = SetPasswordEntity.fromJson(jsonResponse);
        log(response.body);
        if (setPasswordEntity.status == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => Login()),
          );
        }
        return SetPasswordEntity.fromJson(jsonResponse);
      } else {
        log(response.body);
        return SetPasswordEntity(
          status: response.statusCode,
          message: 'failed to set password',
        );
      }
    } catch (e) {
      log('Set Password Error From Repo $e');
      return SetPasswordEntity(status: 500, message: e.toString());
    }
  }

  static Future<ChangePasswordEntity> changePassword({
    required String newPass,
    required String confPass,
    required String currentPass,
    required BuildContext context,
  }) async {
    try {
      ChangePasswordEntity changePasswordEntity = ChangePasswordEntity();
      // TODO: Retrieve user key from UserRepository
      // final userRepository = GetIt.I<UserRepository>();
      // final user = await userRepository.getLoggedInUser();
      // final userKey = user?.userKey ?? '';
      final userKey = ''; // Placeholder until UserRepository is migrated

      final response = await client.post(
        url,
        body: {
          'activity': 'change-password',
          'newPassword': newPass,
          'confirmPassword': confPass,
          'userKey': userKey,
          'currentPassword': currentPass,
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        changePasswordEntity = ChangePasswordEntity.fromJson(jsonResponse);
        if (changePasswordEntity.status == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => Login()),
          );
        }

        log(response.body);
        return ChangePasswordEntity.fromJson(jsonResponse);
      } else {
        log('Failed to change password');
        return ChangePasswordEntity(
          status: response.statusCode,
          message: 'Failed to change password',
        );
      }
    } catch (e) {
      log('Change Password Error From Repo $e');
      return ChangePasswordEntity(status: 500, message: e.toString());
    }
  }

  static Future<GenderEntity> genderList() async {
    try {
      final url = Uri.parse(Environment.baseUrl);
      GenderEntity genderEntity = GenderEntity();
      final response = await http.post(url, body: {'activity': 'gender-list'});
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        genderEntity = GenderEntity.fromJson(jsonResponse);
        log('GenderList Message : ${genderEntity.message}');
        return GenderEntity.fromJson(jsonResponse);
      } else {
        log('Failed to Load GenderList : ${response.statusCode}');
        return GenderEntity(status: 0, message: 'Failed to load data');
      }
    } catch (e) {
      log('GenderList Fetching Error : $e');
      return GenderEntity(status: 500, message: e.toString());
    }
  }

  static Future<ForgotPasswordEntity> forgotPassword({
    required String uMobile,
    required BuildContext context,
  }) async {
    try {
      final url = Uri.parse(Environment.baseUrl);

      ForgotPasswordEntity forgotPasswordEntity = ForgotPasswordEntity();
      final response = await http.post(
        url,
        body: {
          'activity': 'forget-password',
          'uMobile': uMobile.trim().toString(),
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        forgotPasswordEntity = ForgotPasswordEntity.fromJson(jsonResponse);
        if (jsonResponse['uOTP'] is int) {
          jsonResponse['uOTP'] = jsonResponse['uOTP'].toString();
        }

        if (forgotPasswordEntity.status == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => SetPasswordVerification(
                    verificationParams: VerificationParams(
                      mobileNumber: uMobile.toString(),
                      rKey: forgotPasswordEntity.rKey.toString(),
                    ),
                  ),
            ),
          );

          CustomSnackBar.show(
            context: context,
            message: forgotPasswordEntity.message.toString(),
            type: SnackBarType.success,
          );
          log(
            'Forgot Password Response : ${forgotPasswordEntity.message} and OTP : ${forgotPasswordEntity.uOTP}',
          );
        } else {
          CustomSnackBar.show(
            context: context,
            message: forgotPasswordEntity.message.toString(),
            type: SnackBarType.error,
          );
        }
        return ForgotPasswordEntity.fromJson(jsonResponse);
      } else {
        log('Failed to load otp from server');
        return ForgotPasswordEntity(
          status: 0,
          message: 'Failed to load otp from server',
        );
      }
    } catch (e) {
      log('Forgot Password Error : $e');
      return ForgotPasswordEntity(status: 500, message: e.toString());
    }
  }
}
  //   static Future<void> signOut(BuildContext context) async {
  //     try {
  //       // TODO: Clear user data using UserRepository
  //       // await _userRepository.logoutUser();

  //       GoRouter.of(context).goNamed(Splash.routeName);

  //       CustomSnackBar.show(
  //         context: context,
  //         message: 'Logged out successfully',
  //         type: SnackBarType.success,
  //       );
  //     } catch (e) {
  //       debugPrint('Logout error: $e');
  //     }
  //   }
  // }
