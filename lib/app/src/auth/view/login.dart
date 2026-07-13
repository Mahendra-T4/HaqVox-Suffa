// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/core/widgets/custom_snackbar.dart';
import 'package:haqvox/app/src/auth/bloc/auth_bloc.dart';
import 'package:haqvox/app/src/auth/view/forgot_password.dart';
import 'package:haqvox/app/src/auth/view/register.dart';
import 'package:haqvox/app/src/auth/view/widget/textfields.dart';
import 'package:haqvox/app/src/bottom_bar.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  static const String routeName = '/login';

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  bool visible = false;
  bool psw = false;
  bool confirmPsw = false;
  bool isCheck = false;
  DateTime? currentBackPressTime;
  TabController? _controller;

  bool hasMinLength = false;
  bool hasMaxLength = false;
  bool hasUpperCase = false;
  bool hasLowerCase = false;
  bool hasDigit = false;
  bool hasSpecialChar = false;
  bool passwordsMatch = false;
  final int _selectedIndex = 0;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  late AuthBloc _authBloc;

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
  void initState() {
    super.initState();
    _authBloc = AuthBloc();
    _controller = TabController(length: 2, vsync: this);
  }

  // @override
  // void dispose() {
  //   _controller!.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: _selectedIndex,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: whiteColor),
            onPressed: () {
              GoRouter.of(context).goNamed(BottomBar.routeName);
            },
          ),
          automaticallyImplyLeading: false,
          backgroundColor: primaryColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
          bottom: TabBar(
            controller: _controller,
            indicatorColor: whiteColor,
            dividerColor: Colors.transparent,
            indicatorWeight: 2,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorPadding: EdgeInsets.zero,
            labelPadding: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            labelStyle: white16SemiBoldTextStyle,
            unselectedLabelColor: whiteColor,
            tabs: const <Widget>[Tab(text: 'LOGIN'), Tab(text: 'REGISTER')],
          ),
        ),
        body: TabBarView(
          controller: _controller,
          children: [loginDetail(), RegisterScreen()],
        ),
      ),
    );
  }

  onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
        msg: 'Press Back Once Again to Exit.',
        backgroundColor: blackColor,
        textColor: whiteColor,
      );
      return false;
    } else {
      return true;
    }
  }

  loginDetail() {
    Size size = MediaQuery.sizeOf(context);
    return Form(
      key: _formKey,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height - 166,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.04),
                  Text('Welcome Back!', style: primaryColor18RegularTextStyle),
                  heightSpace,
                  heightSpace,
                  heightSpace,
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
                  _buildPasswordChecklist(),
                  SizedBox(height: size.height * 0.025),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          GoRouter.of(
                            context,
                          ).pushNamed(ForgotPassword.routeName);
                        },
                        child: Text(
                          'Forget Password?',
                          style: red12RegularTextStyle,
                        ),
                      ),
                    ],
                  ),
                  loginButton(),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  loginButton() {
    return BlocConsumer<AuthBloc, AuthState>(
      bloc: _authBloc,
      // listenWhen: (previous, current) => current is AuthActionState,
      // Remove buildWhen or modify it to handle loading states
      // buildWhen: (previous, current) => current is! AuthActionState,
      listener: (context, state) {
        // if (state is NavigateUserOnSuffaHomeActionState) {
        //   GoRouter.of(context).goNamed(BottomBar.routeName);
        // }
        if (state is AuthSuffaUserLoginFailureState) {
          return CustomSnackBar.show(
            context: context,
            message: state.error,
            type: SnackBarType.error,
          );
        }
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: fixPadding * 5.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap:
                state is AuthLoadingState
                    ? null
                    : () {
                      if (_formKey.currentState!.validate()) {
                        _authBloc.add(
                          AuthSuffaUserLoginEvent(
                            email: emailController.text,
                            password: passwordController.text,
                            context: context,
                          ),
                        );
                      }
                    },
            child: Container(
              padding: const EdgeInsets.all(fixPadding * 1.5),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color:
                    state is AuthLoadingState
                        ? primaryColor.withOpacity(0.7)
                        : primaryColor,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.3),
                    spreadRadius: 1,
                    blurRadius: 1,
                  ),
                ],
              ),
              child:
                  state is AuthLoadingState
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 2,
                        ),
                      )
                      : Text('Login', style: white18SemiBoldTextStyle),
            ),
          ),
        );
      },
    );
  }

  divider() {
    return Expanded(
      child: Container(color: greyColor.withValues(alpha: 0.5), height: 1),
    );
  }
}
