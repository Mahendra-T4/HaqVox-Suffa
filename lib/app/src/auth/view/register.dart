import 'dart:convert';
import 'dart:developer';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haqvox/app/config/environment.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/core/widgets/custom_snackbar.dart';
import 'package:haqvox/app/src/auth/bloc/auth_bloc.dart';
import 'package:haqvox/app/src/auth/models/gender_entity.dart';
import 'package:haqvox/app/src/auth/view/widget/date_picker.dart';
import 'package:haqvox/app/src/auth/view/widget/textfields.dart';
import 'package:haqvox/app/src/info/view/info.dart';

import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late AuthBloc _authBloc;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    _authBloc = AuthBloc();
    genderList();
    super.initState();
  }

  bool _acceptedTerms = false;
  String termsValue = '2'; // Default value is '2' for not accepted

  String? rKEY;
  final fNameController = TextEditingController();
  final lNameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final dobPickerController = TextEditingController();
  final passwordController = TextEditingController();
  final alternateMobileController = TextEditingController();
  final dobController = TextEditingController();

  bool isVisible = false;
  bool psw = false;
  bool confirmPsw = false;
  String? gender;
  String? rKey;
  // Password strength variables
  bool hasMinLength = false;
  bool hasMaxLength = false;
  bool hasUpperCase = false;
  bool hasLowerCase = false;
  bool hasDigit = false;
  bool hasSpecialChar = false;
  bool passwordsMatch = false;
  // Registration is now handled by _handleRegistrationSubmit

  GenderEntity genderEntity = GenderEntity();
  String? pickedGender; // Changed from dynamic to String? to ensure type safety
  bool _isLoadingGenders = false;
  String? _genderError;

  Future<void> genderList() async {
    if (_isLoadingGenders) return;

    setState(() {
      _isLoadingGenders = true;
      _genderError = null;
    });

    try {
      final url = Uri.parse(Environment.baseUrl);

      final response = await http.post(url, body: {'activity': 'gender-list'});

      if (!mounted) return;

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        setState(() {
          genderEntity = GenderEntity.fromJson(jsonResponse);
          _isLoadingGenders = false;
          log('GenderList Message : ${genderEntity.message}');
        });
      } else {
        setState(() {
          _genderError = 'Failed to load gender list';
          _isLoadingGenders = false;
        });
        log('Failed to Load GenderList : ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _genderError = 'Error loading gender list';
        _isLoadingGenders = false;
      });
      log('GenderList Fetching Error : $e');
    }
  }

  // Check password strength
  void _checkPasswordStrength(String password) {
    setState(() {
      hasMinLength = password.length >= 8;
      hasMaxLength = password.length >= 8 || password.length <= 16;
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
        _buildChecklistItem(hasMinLength, 'At Max 16 characters'),
        _buildChecklistItem(hasUpperCase, 'At least one uppercase letter'),
        _buildChecklistItem(hasLowerCase, 'At least one lowercase letter'),
        _buildChecklistItem(hasDigit, 'At least one number'),
        _buildChecklistItem(hasSpecialChar, 'At least one special character'),
        if (passwordController.text.isNotEmpty)
          _buildChecklistItem(passwordsMatch, 'Passwords match'),
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
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          SizedBox(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.05),
                    Text(
                      'Create Account',
                      style: primaryColor18RegularTextStyle,
                    ),
                    SizedBox(height: size.height * 0.02),
                    CustomTextField(
                      controller: fNameController,
                      hintText: 'First Name',
                      icon: Icons.person,
                      keyboardType: TextInputType
                          .text, // Changed from emailAddress to text
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z\s]'),
                        ), // Allow letters and spaces
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          // Capitalize first letter of each word
                          if (newValue.text.isEmpty) return newValue;
                          return TextEditingValue(
                            text: newValue.text
                                .split(' ')
                                .map((word) {
                                  if (word.isEmpty) return '';
                                  return word[0].toUpperCase() +
                                      word.substring(1).toLowerCase();
                                })
                                .join(' '),
                            selection: newValue.selection,
                          );
                        }),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        if (value.trim().isEmpty) {
                          return 'Name cannot be only spaces';
                        }
                        if (value.length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        if (value.length > 50) {
                          return 'Name cannot exceed 50 characters';
                        }
                        // Check if name contains only letters and spaces
                        if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                          return 'Only letters and spaces are allowed';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: size.height * 0.02),
                    CustomTextField(
                      controller: lNameController,
                      hintText: 'Last Name',
                      icon: Icons.person,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z\s]'),
                        ), // Allow letters and spaces
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          // Capitalize first letter of each word
                          if (newValue.text.isEmpty) return newValue;
                          return TextEditingValue(
                            text: newValue.text
                                .split(' ')
                                .map((word) {
                                  if (word.isEmpty) return '';
                                  return word[0].toUpperCase() +
                                      word.substring(1).toLowerCase();
                                })
                                .join(' '),
                            selection: newValue.selection,
                          );
                        }),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your First Name';
                        }
                        if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                          return 'Only alphabets are allowed';
                        }
                        if (value.length < 2) {
                          return 'Name must be at least 2 characters long';
                        }
                        if (value.length > 50) {
                          return 'Name cannot exceed 50 characters';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,

                      // obscureText: false,
                    ),
                    SizedBox(height: size.height * 0.025),
                    CustomTextField(
                      controller: emailController,
                      hintText: 'Email',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        final emailRegex = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        );
                        if (!emailRegex.hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      // obscureText: false,
                    ),
                    SizedBox(height: size.height * 0.025),
                    CustomTextField(
                      controller: mobileController,
                      hintText: 'Mobile Number',
                      icon: Icons.phone,
                      maxLength: 10,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter mobile number';
                        }
                        final mobileRegex = RegExp(r'^[6-9]\d{9}$');
                        if (!mobileRegex.hasMatch(value)) {
                          return 'Please enter a valid 10 digit mobile number';
                        }
                        return null;
                      },
                      // obscureText: false,
                    ),
                    SizedBox(height: size.height * 0.025),
                    CustomTextField(
                      controller: alternateMobileController,
                      hintText: 'Alternate Number (Optional)',
                      icon: Icons.phone,
                      maxLength: 10,
                      keyboardType: TextInputType.phone,
                      validator: (String? value) {
                        // If empty, return null (field is optional)
                        if (value == null || value.isEmpty) {
                          return null;
                        }

                        // If value is provided, validate the format
                        final mobileRegex = RegExp(r'^[6-9]\d{9}$');
                        if (!mobileRegex.hasMatch(value)) {
                          return 'Please enter a valid 10 digit mobile number';
                        }

                        // Check if alternate number is same as primary number
                        if (value == mobileController.text) {
                          return 'Alternate number should be different from mobile number';
                        }

                        return null;
                      },
                    ),
                    SizedBox(height: size.height * 0.025),
                    DatePickerField(
                      controller: dobPickerController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select date of birth';
                        }
                        // final date = DateTime.tryParse(value);
                        // if (date == null) {
                        //   return 'Invalid date format';
                        // }
                        // if (date.isAfter(DateTime.now())) {
                        //   return 'Cannot select future dates';

                        // }
                        return null;
                      },
                    ),
                    SizedBox(height: size.height * 0.025),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text('Gender', style: grey14RegularTextStyle),
                        ),
                        SizedBox(
                          height: 100,
                          child: _isLoadingGenders
                              ? const Center(child: CircularProgressIndicator())
                              : _genderError != null
                              ? _buildGenderError()
                              : genderEntity.record == null
                              ? const Center(
                                  child: Text(
                                    'Unable to load genders',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: genderEntity.record?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    // Set Male as default selection when list is loaded
                                    if (pickedGender == null &&
                                        genderEntity
                                                .record![index]
                                                .genderName ==
                                            'Male') {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                            setState(() {
                                              pickedGender = genderEntity
                                                  .record![index]
                                                  .genderID
                                                  ?.toString();
                                              gender = genderEntity
                                                  .record![index]
                                                  .genderName;
                                            });
                                          });
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          onTap: () {
                                            setState(() {
                                              pickedGender = genderEntity
                                                  .record![index]
                                                  .genderID
                                                  ?.toString();
                                              gender = genderEntity
                                                  .record![index]
                                                  .genderName;
                                            });
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                              horizontal: 24,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  pickedGender ==
                                                      genderEntity
                                                          .record![index]
                                                          .genderID
                                                          ?.toString()
                                                  ? primaryColor.withOpacity(
                                                      0.15,
                                                    )
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color:
                                                    pickedGender ==
                                                        genderEntity
                                                            .record![index]
                                                            .genderID
                                                            ?.toString()
                                                    ? primaryColor
                                                    : Colors.grey.shade300,
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                genderEntity
                                                    .record![index]
                                                    .genderName
                                                    .toString(),
                                                style: TextStyle(
                                                  color:
                                                      pickedGender ==
                                                          genderEntity
                                                              .record![index]
                                                              .genderID
                                                              ?.toString()
                                                      ? primaryColor
                                                      : Colors.grey.shade600,
                                                  fontSize: 15,
                                                  fontWeight:
                                                      pickedGender ==
                                                          genderEntity
                                                              .record![index]
                                                              .genderID
                                                              ?.toString()
                                                      ? FontWeight.w600
                                                      : FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.025),
                    CustomTextField(
                      controller: passwordController,
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
                        if (passwordController.text.isNotEmpty) {
                          setState(() {
                            passwordsMatch = value == passwordController.text;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 8),
                    _buildPasswordChecklist(), // Add checklist here
                    SizedBox(height: size.height * 0.025),
                    _buildTermsCheckbox(),
                    SizedBox(height: size.height * 0.025),
                    // CustomTextField(
                    //   controller: confirmPasswordController,
                    //   hintText: 'Confirm Password',
                    //   icon: Icons.password_rounded,
                    //   keyboardType: TextInputType.text,
                    //   suffixIcon: IconButton(
                    //     icon: Icon(
                    //       confirmPsw ? Icons.visibility : Icons.visibility_off,
                    //       color: primaryColor,
                    //     ),
                    //     onPressed: () {
                    //       setState(() {
                    //         confirmPsw = !confirmPsw;
                    //       });
                    //     },
                    //   ),
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return 'Please confirm password';
                    //     }
                    //     if (value != passwordController.text) {
                    //       return 'Passwords do not match';
                    //     }
                    //     return null;
                    //   },
                    //   obscureText: !confirmPsw,
                    //   onChanged: (value) {
                    //     setState(() {
                    //       passwordsMatch = value == passwordController.text;
                    //     });
                    //   },
                    // ),
                    // SizedBox(
                    //   height: size.height * 0.025,
                    // ),
                    registerButton(),
                    SizedBox(height: fixPadding * 3.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            height: 24.0,
            width: 24.0,
            child: Checkbox(
              value: _acceptedTerms,
              activeColor: primaryColor,
              onChanged: (bool? value) {
                setState(() {
                  _acceptedTerms = value ?? false;
                  termsValue = _acceptedTerms
                      ? '1'
                      : '2'; // Convert boolean to string
                });
              },
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: grey12RegularTextStyle,
                children: [
                  const TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms & Conditions',
                    style: TextStyle(
                      color: primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InfoPage(pageRole: '3'),
                          ),
                        );
                      },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Add this helper method in the class
  Widget _buildGenderError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(height: 4),
          Text(_genderError!, style: const TextStyle(color: Colors.red)),
          TextButton.icon(
            onPressed: genderList,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _handleRegistrationSubmit() {
    if (_formKey.currentState!.validate()) {
      if (pickedGender == null) {
        CustomSnackBar.show(
          context: context,
          message: 'Please select your gender',
          type: SnackBarType.error,
        );
      } else if (!_acceptedTerms) {
        CustomSnackBar.show(
          context: context,
          message: 'Please accept the terms and conditions',
          type: SnackBarType.error,
        );
      } else {
        _authBloc.add(
          AuthNewSuffaUserRegistrationEvent(
            fName: fNameController.text,
            lName: lNameController.text,
            email: emailController.text,
            mobile: mobileController.text,
            alternateMobile: alternateMobileController.text,
            dob: dobPickerController.text,
            gender: pickedGender.toString(), // Use string gender ID
            password: passwordController.text,
            uTerms: termsValue, // Use string terms value
            context: context,
          ),
        );
      }
    }
  }

  registerButton() {
    return BlocConsumer(
      bloc: _authBloc,
      listener: (context, state) {
        if (state is AuthSuffaNewUserRegistrationFailureState) {
          CustomSnackBar.show(context: context, message: state.error);
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
              if (pickedGender == null) {
                CustomSnackBar.show(
                  context: context,
                  message: 'Please select your gender',
                  type: SnackBarType.error,
                );
                return;
              }
              _handleRegistrationSubmit();
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
              child: Text('Register', style: white18SemiBoldTextStyle),
            ),
          ),
        );
      },
    );
  }
}

int setInt(dynamic value) {
  return int.parse(value);
}
