import 'package:flutter/material.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/core/widgets/appbar.dart';
import 'package:haqvox/app/services/connectivity.dart';
import 'package:haqvox/app/src/myspace/view/offline_download.dart';

class Support extends StatelessWidget {
  const Support({super.key});
  static const String routeName = '/support';

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
          appBar: customAppBar1(title: 'Support', context: context),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(fixPadding * 2.0),
            children: [
              nameTextField(),
              heightSpace,
              heightSpace,
              emailTextField(),
              heightSpace,
              heightSpace,
              messageTextField(),
              heightSpace,
              heightSpace,
              heightSpace,
              heightSpace,
              submitButton(context),
            ],
          ),
        );
      },
    );
  }

  nameTextField() {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: blackColor.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 1,
          ),
        ],
      ),
      child: TextField(
        keyboardType: TextInputType.name,
        cursorColor: primaryColor,
        style: black16RegularTextStyle,
        decoration: InputDecoration(
          hintText: 'Name',
          hintStyle: grey14RegularTextStyle,
          contentPadding: const EdgeInsets.symmetric(horizontal: fixPadding),
          border: const UnderlineInputBorder(borderSide: BorderSide.none),
        ),
      ),
    );
  }

  emailTextField() {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: blackColor.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 1,
          ),
        ],
      ),
      child: TextField(
        keyboardType: TextInputType.emailAddress,
        cursorColor: primaryColor,
        style: black16RegularTextStyle,
        decoration: InputDecoration(
          hintText: 'Email',
          hintStyle: grey14RegularTextStyle,
          contentPadding: const EdgeInsets.symmetric(horizontal: fixPadding),
          border: const UnderlineInputBorder(borderSide: BorderSide.none),
        ),
      ),
    );
  }

  messageTextField() {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: blackColor.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 1,
          ),
        ],
      ),
      child: TextField(
        cursorColor: primaryColor,
        style: black16RegularTextStyle,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: 'Write Here',
          hintStyle: grey14RegularTextStyle,
          contentPadding: const EdgeInsets.all(fixPadding),
          border: const UnderlineInputBorder(borderSide: BorderSide.none),
        ),
      ),
    );
  }

  submitButton(context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 5.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: () => Navigator.pop(context),
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
          child: Text('Submit', style: white18SemiBoldTextStyle),
        ),
      ),
    );
  }
}
