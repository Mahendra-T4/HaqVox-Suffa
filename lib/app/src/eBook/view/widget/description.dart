// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:haqvox/app/constant/constant.dart';


class Description extends StatelessWidget {
  const Description({
    super.key,
    required this.description,
  });
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
      // height: height,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: black16MediumTextStyle,
            ),
            heightSpace,
            SizedBox(
              width: MediaQuery.sizeOf(context).width,
              child: Text(
                description,
                style: grey14RegularTextStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
