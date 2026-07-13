import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:haqvox/app/config/environment.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/core/database/key.dart';
import 'package:haqvox/app/core/database/shared_prefs_config.dart';
import 'package:haqvox/app/core/database/user/hive_db.dart';
import 'package:haqvox/app/core/widgets/custom_snackbar.dart';
import 'package:haqvox/app/core/widgets/ios_alert_dialog.dart';
import 'package:haqvox/app/services/connectivity.dart';
import 'package:haqvox/app/services/no_internate_page.dart';
import 'package:haqvox/app/src/auth/models/otp_entity.dart';
import 'package:haqvox/app/src/bottom_bar.dart';
import 'package:haqvox/app/src/editProfile/model/edit_profile_details_entity.dart';
import 'package:haqvox/app/src/editProfile/model/edit_profile_verification_params.dart';
import 'package:haqvox/app/src/myspace/view/myspace.dart';
import 'package:haqvox/app/src/myspace/view/offline_download.dart';
import 'package:haqvox/app/src/splash.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';

class EditProfileVerification extends StatefulWidget {
  const EditProfileVerification({super.key, required this.editProfileParams});
  static const String routeName = '/verification';
  final EditProfileParams editProfileParams;

  @override
  State<EditProfileVerification> createState() => _VerificationState();
}

class _VerificationState extends State<EditProfileVerification> {
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  TextEditingController controller3 = TextEditingController();
  TextEditingController controller4 = TextEditingController();
  TextEditingController controller5 = TextEditingController();
  TextEditingController controller6 = TextEditingController();

  FocusNode focusNode1 = FocusNode();
  FocusNode focusNode2 = FocusNode();
  FocusNode focusNode3 = FocusNode();
  FocusNode focusNode4 = FocusNode();
  FocusNode focusNode5 = FocusNode();
  FocusNode focusNode6 = FocusNode();

  final client = http.Client();
  final url = Uri.parse(Environment.baseUrl);
  // final StorageConfig _config = StorageConfig();

  Future<EditProfileEntity> editProfileDetails() async {
    try {
      // final userKey = await _config.getUserData(key: DBKeys.userKey);
      EditProfileEntity editProfileEntity = EditProfileEntity();
      final body = ({
        'activity': 'account-settings',
        'uFirstName': widget.editProfileParams.uFirstName,
        'uLastName': widget.editProfileParams.uLastName,
        'uEmail': widget.editProfileParams.uEmail,
        'uMobile': widget.editProfileParams.uMobile,
        'uAlternateNumber': widget.editProfileParams.uAlternateNumber,
        'uDOB': widget.editProfileParams.uDOB,
        'uGender': widget.editProfileParams.uGender,
        'uStep': '2',
        'userKey': HiveService.getUserId().toString(),
      });
      final response = await client.post(url, body: body);
      log(body.toString());
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        log(response.body);

        editProfileEntity = EditProfileEntity.fromJson(jsonResponse);

        if (editProfileEntity.status == 1) {
          HiveService.logout(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Splash()),
          );
          CustomSnackBar.show(
            context: context,
            message: editProfileEntity.message.toString(),
          );
        }

        CustomSnackBar.show(
          context: context,
          message: editProfileEntity.message.toString(),
        );
        return EditProfileEntity.fromJson(jsonResponse);
      } else {
        log('Failed to edit and load user profile data');
        return EditProfileEntity(
          status: response.statusCode,
          message: 'Failed to edit and load user profile data',
        );
      }
    } catch (e) {
      log('Edit Profile Verification Details  Error $e');
      return EditProfileEntity(status: 500, message: e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: InternetConnectionService().connectionStream,
      initialData: true, // Assume connected initially
      builder: (context, snapshot) {
        // Handle error state
        if (snapshot.hasError) {
          return const OfflineDownloads();
        }

        // Handle disconnected state
        if (snapshot.data == false) {
          return const OfflineDownloads();
        }

        // Handle loading state
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return Scaffold(
          appBar: AppBar(
            backgroundColor: primaryColor,
            automaticallyImplyLeading: false,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              color: whiteColor,
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(45),
              child: Container(),
            ),
          ),
          body: ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height - 166,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: fixPadding * 2.0,
                  ),
                  child: Column(
                    children: [
                      heightSpace,
                      heightSpace,
                      heightSpace,
                      heightSpace,
                      heightSpace,
                      heightSpace,
                      heightSpace,
                      Text(
                        'Verify Your Mobile Number',
                        style: primaryColor18RegularTextStyle,
                      ),
                      heightSpace,
                      heightSpace,
                      Text(
                        'Please check your messages and enter the\nverification code we just sent you\n+91 1236547890',
                        textAlign: TextAlign.center,
                        style: grey14RegularTextStyle,
                      ),
                      heightSpace,
                      heightSpace,
                      heightSpace,
                      codeTextField(),
                      heightSpace,
                      heightSpace,
                      heightSpace,
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Didn’t you receive code? ',
                              style: grey14RegularTextStyle,
                            ),
                            TextSpan(
                              text: 'Resend',
                              style: primaryColor14RegularTextStyle,
                            ),
                          ],
                        ),
                      ),
                      heightSpace,
                      heightSpace,
                      heightSpace,
                      heightSpace,
                      continueButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  codeTextField() {
    return Column(
      children: [
        Text('Enter Code Here', style: black16RegularTextStyle),
        heightSpace,
        heightSpace,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildOTPField(
              controller: controller1,
              focusNode: focusNode1,
              nextFocusNode: focusNode2,
              autoFocus: true,
            ),
            _buildOTPField(
              controller: controller2,
              focusNode: focusNode2,
              nextFocusNode: focusNode3,
            ),
            _buildOTPField(
              controller: controller3,
              focusNode: focusNode3,
              nextFocusNode: focusNode4,
            ),
            _buildOTPField(
              controller: controller4,
              focusNode: focusNode4,
              nextFocusNode: focusNode5,
            ),
            _buildOTPField(
              controller: controller5,
              focusNode: focusNode5,
              nextFocusNode: focusNode6,
            ),
            _buildOTPField(
              controller: controller6,
              focusNode: focusNode6,
              isLast: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOTPField({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocusNode,
    bool autoFocus = false,
    bool isLast = false,
  }) {
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autoFocus,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (value) {
          if (value.length == 1) {
            controller.text = value;
            if (!isLast && nextFocusNode != null) {
              nextFocusNode.requestFocus();
            }
          } else if (value.isEmpty && !autoFocus) {
            focusNode.previousFocus();
          }
        },
      ),
    );
  }

  String get _otpCode =>
      '${controller1.text}${controller2.text}${controller3.text}${controller4.text}${controller5.text}${controller6.text}';

  // void _verifyOTP() {
  //   if (!_isOTPComplete) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Please enter the complete OTP code'),
  //         backgroundColor: Colors.red,
  //       )
  //     );
  //     return;
  //   }
  //   waitDialog();
  // }

  continueButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 5.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: () {
          otpVerification();
          // _authBloc.add(
          //     AuthOTPVerificationEvent(uOTP: _otpCode, context: context));
        },
        child: Container(
          padding: const EdgeInsets.all(fixPadding * 1.5),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.3),
                spreadRadius: 1,
                blurRadius: 1,
              ),
            ],
          ),
          child: Text('Continue', style: white18SemiBoldTextStyle),
        ),
      ),
    );
  }

  waitDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SpinKitRing(color: primaryColor, lineWidth: 3, size: 50),
                heightSpace,
                heightSpace,
                Text(
                  'Please Wait...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Verifying your OTP',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
        );
      },
    );
    Timer(const Duration(seconds: 3), () {
      Navigator.pushAndRemoveUntil(
        context,
        PageTransition(
          child: const BottomBar(),
          type: PageTransitionType.rightToLeft,
        ),
        (route) => false, // This removes all previous routes
      );
    });
  }

  Future<void> otpVerification() async {
    try {
      final url = Uri.parse(Environment.baseUrl);
      final client = http.Client();
      // StorageConfig config = StorageConfig();
      // final userKey = await config.getUserData(key: DBKeys.userKey);
      OTPVerificationEntity otpVerificationEntity = OTPVerificationEntity();
      final response = await client.post(
        url,
        body: {
          'activity': 'otp-verification',
          'uOTP': _otpCode,
          'rKey': HiveService.getUserId().toString(),
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        otpVerificationEntity = OTPVerificationEntity.fromJson(jsonResponse);
        log('OTP Verification Status ${otpVerificationEntity.message}');
        if (otpVerificationEntity.status == 1) {
          CustomAlertDialog.show(
            context: context,
            title: 'Success',
            message: 'Your profile has been updated successfully.',
            buttonText: 'Confirm', // optional, defaults to 'Confirm'
            onConfirm: () {
              editProfileDetails();
            },
          );
        } else {
          CustomSnackBar.show(
            context: context,
            message: jsonResponse['message'],
            type: SnackBarType.error,
          );
        }
        // return OTPVerificationEntity.fromJson(jsonResponse);
      } else {
        log('Failed To Get OTP From Server');
        // // return OTPVerificationEntity(
        //     status: 0, message: 'Failed To Get OTP From Server');
      }
    } catch (e) {
      log('OTP Verification Error From Repository : $e');
      // return OTPVerificationEntity(status: 0, message: e.toString());
    }
  }
}
