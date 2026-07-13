import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/core/models/verification_params.dart';
import 'package:haqvox/app/core/widgets/custom_snackbar.dart';
import 'package:haqvox/app/src/auth/bloc/auth_bloc.dart';
import 'package:haqvox/app/src/bottom_bar.dart';
import 'package:page_transition/page_transition.dart';

class RegisterVerification extends StatefulWidget {
  const RegisterVerification({super.key, required this.verificationParams});
  static const String routeName = '/register - verification';

  final VerificationParams verificationParams;

  @override
  State<RegisterVerification> createState() => _VerificationState();
}

class _VerificationState extends State<RegisterVerification> {
  late AuthBloc _authBloc;
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

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc();
  }

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
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
                    'Please check your messages and enter the\nverification code we just sent you\n+91 ${widget.verificationParams.mobileNumber}',
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
    return BlocConsumer<AuthBloc, AuthState>(
      bloc: _authBloc,
      listener: (context, state) {
        if (state is AuthOTPVerificationFailedErrorState) {
          final error = state.error;

          CustomSnackBar.show(context: context, message: error);
          log(error);
        }
      },
      builder: (context, state) {
        if (state is AuthLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: fixPadding * 5.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap: () {
              // log('rKEY From OTP Page ${widget.verificationParams.rKEY}');
              _authBloc.add(
                AuthOTPVerificationForRegisterEvent(
                  uOTP: _otpCode,
                  rKey: widget.verificationParams.rKey,
                  context: context,
                ),
              );
              // _verifyOTP();
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
      },
    );
  }

  waitDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (contxet) {
        return Dialog(
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  heightSpace,
                  heightSpace,
                  heightSpace,
                  heightSpace,
                  const SpinKitRing(color: primaryColor, lineWidth: 3),
                  heightSpace,
                  heightSpace,
                  heightSpace,
                  heightSpace,
                  heightSpace,
                  heightSpace,
                  Text('Please Wait...', style: grey12RegularTextStyle),
                  heightSpace,
                  heightSpace,
                  heightSpace,
                  heightSpace,
                ],
              ),
            ],
          ),
        );
      },
    );
    Timer(const Duration(seconds: 3), () {
      currentIndex = 0;
      Navigator.push(
        context,
        PageTransition(
          child: const BottomBar(),
          type: PageTransitionType.rightToLeft,
        ),
      );
    });
  }
}
