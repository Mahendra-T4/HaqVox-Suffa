// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/src/auth/view/login.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';


class Onboarding extends StatefulWidget {
  const Onboarding({super.key});
  static const String routeName = '/onboarding';

  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  double? height, width;
  final pageViewController = PageController(initialPage: 0);
  int currentPage = 0;
  DateTime? currentBackPressTime;

  @override
  void initState() {
    super.initState();
    Timer.periodic(
      const Duration(seconds: 5),
      (Timer time) {
        if (currentPage < 2) {
          currentPage++;
        } else {
          currentPage = 0;
        }
        pageViewController.animateToPage(
          currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    pageViewController.dispose();
  }

  onChanged(int index) {
    setState(() {
      currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool key, t) {
        bool backStatus = onWillPop();
        if (backStatus) {
          exit(0);
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: PageView(
                controller: pageViewController,
                scrollDirection: Axis.horizontal,
                onPageChanged: onChanged,
                children: [
                  page1(),
                  page2(),
                  page3(),
                ],
              ),
            ),
            pageIndicator(),
          ],
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

  pageIndicator() {
    return Padding(
      padding: const EdgeInsets.all(fixPadding * 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          currentPage != 2
              ? InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  Login()),
                  ),
                  child: Text(
                    'Skip',
                    style: grey14MediumTextStyle,
                  ),
                )
              : Container(width: 30),
          SmoothPageIndicator(
            controller: pageViewController,
            count: 3,
            effect: const WormEffect(
              paintStyle: PaintingStyle.stroke,
              dotHeight: 10,
              dotWidth: 10,
              dotColor: greyColor,
              activeDotColor: primaryColor,
            ),
          ),
          currentPage == 2
              ? InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  Login()),
                  ),
                  child: Text(
                    'Login',
                    style: primaryColor14MediumTextStyle,
                  ),
                )
              : InkWell(
                  onTap: () {
                    setState(() {
                      currentPage++;
                    });
                    pageViewController.animateToPage(
                      currentPage,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Text(
                    'Next',
                    style: primaryColor14MediumTextStyle,
                  ),
                ),
        ],
      ),
    );
  }

  page1() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/learning.png',
          height: height! * 0.28,
          width: width! - 40,
          fit: BoxFit.cover,
        ),
        heightSpace,
        heightSpace,
        Text(
          'Welcomes',
          style: black18MediumTextStyle,
        ),
        heightSpace,
        heightSpace,
        Text(
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Placerat nulla hac fermentum pulvinar morbi pretium ut nibh. Maecenas ut et at nec.',
          textAlign: TextAlign.center,
          style: grey14RegularTextStyle,
        ),
      ],
    );
  }

  page2() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/playlist.png',
          height: height! * 0.28,
          width: width! - 40,
          fit: BoxFit.cover,
        ),
        heightSpace,
        heightSpace,
        Text(
          'Listen Your Books',
          style: black18MediumTextStyle,
        ),
        heightSpace,
        heightSpace,
        Text(
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Placerat nulla hac fermentum pulvinar morbi pretium ut nibh. Maecenas ut et at nec.',
          textAlign: TextAlign.center,
          style: grey14RegularTextStyle,
        ),
      ],
    );
  }

  page3() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/bookLover.png',
          height: height! * 0.28,
          width: width! - 40,
          fit: BoxFit.cover,
        ),
        heightSpace,
        heightSpace,
        Text(
          'Easy Explore',
          style: black18MediumTextStyle,
        ),
        heightSpace,
        heightSpace,
        Text(
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Placerat nulla hac fermentum pulvinar morbi pretium ut nibh. Maecenas ut et at nec.',
          textAlign: TextAlign.center,
          style: grey14RegularTextStyle,
        ),
      ],
    );
  }
}
