import 'package:flutter/material.dart';
import 'package:haqvox/app/constant/constant.dart';

Widget appBarText({required String title}) {
  return Text(
    title,
    style: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: whiteColor,
    ),
  );
}
