import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:haqvox/app/assets/assets.dart';
import 'package:haqvox/app/constant/constant.dart';

PreferredSizeWidget customAppBar({
  required String title,
  required BuildContext context,
}) {
  return AppBar(
    automaticallyImplyLeading: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
    ),
    // leading: IconButton(
    //   onPressed: () => GoRouter.of(context).pop(),
    //   icon: Image.asset(
    //     Assets.backButtonIconImage,
    //     color: whiteColor,
    //   ),
    // ),
    title: Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    ),
  );
}

PreferredSizeWidget customAppBar1({
  required String title,
  required BuildContext context,
}) {
  return AppBar(
    automaticallyImplyLeading: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
    ),
    leading: IconButton(
      onPressed: () {
        context.pop();
      },
      icon: Image.asset(Assets.backButtonIconImage, color: whiteColor),
    ),
    title: Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    ),
  );
}
