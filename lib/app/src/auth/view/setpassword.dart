// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/core/widgets/custom_snackbar.dart';
import 'package:haqvox/app/src/auth/bloc/auth_bloc.dart';
import 'package:haqvox/app/src/auth/view/widget/textfields.dart';

class SetPassword extends StatefulWidget {
  const SetPassword({super.key, required this.rKey});
  final String rKey;

  static const String routeName = '/set-password';

  @override
  State<SetPassword> createState() => _SetPasswordState();
}

class _SetPasswordState extends State<SetPassword> {
  late AuthBloc _authBloc;
  @override
  void initState() {
    _authBloc = AuthBloc();
    super.initState();
  }

  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isVisible = false;
  bool psw = false;
  bool confirmPsw = false;
  String? gender;
  String? rKey;
  // Password strength variables
  bool hasMinLength = false;
  bool hasUpperCase = false;
  bool hasLowerCase = false;
  bool hasDigit = false;
  bool hasSpecialChar = false;
  bool passwordsMatch = false;

  // Check password strength
  void _checkPasswordStrength(String password) {
    setState(() {
      hasMinLength = password.length >= 8;
      hasUpperCase = password.contains(RegExp(r'[A-Z]'));
      hasLowerCase = password.contains(RegExp(r'[a-z]'));
      hasDigit = password.contains(RegExp(r'[0-9]'));
      hasSpecialChar = password.contains(RegExp(r'[!@#\$&*~]'));
    });
  }

  // Password validation checklist widget
  Widget _buildPasswordChecklist() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildChecklistItem(hasMinLength, 'At least 8 characters'),
        _buildChecklistItem(hasUpperCase, 'At least one uppercase letter'),
        _buildChecklistItem(hasLowerCase, 'At least one lowercase letter'),
        _buildChecklistItem(hasDigit, 'At least one number'),
        _buildChecklistItem(hasSpecialChar, 'At least one special character'),
        if (newPasswordController.text.isNotEmpty)
          _buildChecklistItem(
            passwordsMatch,
            'Passwords match',
          ),
      ],
    );
  }

  // Helper widget for checklist items
  Widget _buildChecklistItem(bool isValid, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.circle_outlined,
            color: isValid ? Colors.green : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isValid ? Colors.green : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Set Password',
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 22,
                  color: primaryColor),
            ),
            SizedBox(
              height: size.width * .10,
            ),
            CustomTextField(
              controller: newPasswordController,
              hintText: 'Password',
              icon: Icons.password_rounded,
              keyboardType: TextInputType.text,
              suffixIcon: IconButton(
                icon: Icon(
                  psw ? Icons.visibility : Icons.visibility_off,
                  color: primaryColor,
                ),
                onPressed: () {
                  setState(() {
                    psw = !psw;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter password';
                }
                if (!hasMinLength ||
                    !hasUpperCase ||
                    !hasLowerCase ||
                    !hasDigit ||
                    !hasSpecialChar) {
                  return 'Password does not meet requirements';
                }
                return null;
              },
              obscureText: !psw,
              onChanged: (value) {
                _checkPasswordStrength(value);
                if (newPasswordController.text.isNotEmpty) {
                  setState(() {
                    passwordsMatch = value == confirmPasswordController.text;
                  });
                }
              },
            ),
            SizedBox(height: 8),
            _buildPasswordChecklist(), // Add checklist here
            SizedBox(height: size.height * 0.025),
            CustomTextField(
              controller: confirmPasswordController,
              hintText: 'Confirm Password',
              icon: Icons.password_rounded,
              keyboardType: TextInputType.text,
              suffixIcon: IconButton(
                icon: Icon(
                  confirmPsw ? Icons.visibility : Icons.visibility_off,
                  color: primaryColor,
                ),
                onPressed: () {
                  setState(() {
                    confirmPsw = !confirmPsw;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm password';
                }
                if (value != newPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
              obscureText: !confirmPsw,
              onChanged: (value) {
                setState(() {
                  passwordsMatch = value == newPasswordController.text;
                });
              },
            ),
            SizedBox(
              height: size.height * 0.025,
            ),
            resetPassButton()
          ],
        ),
      ),
    );
  }

  resetPassButton() {
    return BlocConsumer<AuthBloc, AuthState>(
      bloc: _authBloc,
      listener: (context, state) {
        if (state is AuthSetPasswordFailedErrorState) {
          return CustomSnackBar.show(
              context: context, message: state.error, type: SnackBarType.error);
        }
      },
      builder: (context, state) {
        if (state is AuthLoadingState) {
          return Center(child: CircularProgressIndicator.adaptive());
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: fixPadding * 5.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap: () {
              _authBloc.add(AuthSetPasswordEvent(
                  newPass: newPasswordController.text,
                  confPass: confirmPasswordController.text,
                  rKey: widget.rKey,
                  context: context));
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
              child: Text(
                'Set Password',
                style: white18SemiBoldTextStyle,
              ),
            ),
          ),
        );
      },
    );
  }
}
