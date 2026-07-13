import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:haqvox/app/assets/assets.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/core/database/key.dart';
import 'package:haqvox/app/core/database/shared_prefs_config.dart';
import 'package:haqvox/app/core/database/user/hive_db.dart';
import 'package:haqvox/app/core/widgets/appbar.dart';
import 'package:haqvox/app/services/connectivity.dart';
import 'package:haqvox/app/src/auth/repositories/auth_repo.dart';
import 'package:haqvox/app/src/auth/view/changePassword.dart';
import 'package:haqvox/app/src/editProfile/pages/edit_profile.dart';
import 'package:haqvox/app/src/info/view/info.dart';
import 'package:haqvox/app/src/myspace/view/myspace.dart';
import 'package:haqvox/app/src/myspace/view/offline_download.dart';
import 'package:haqvox/app/src/subscription/view/subscription_plan_view.dart';
import 'package:haqvox/app/src/support/view/suffa_support.dart';
import 'package:haqvox/app/src/support/view/ticket_history_view.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});
  static const String routeName = '/profile';

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // StorageConfig config = StorageConfig();

  // String? name;
  // String? userKey;
  // String? lName;
  // String? uMobile;
  // String? profileImage;

  // Unused navigation method - kept for potential future use
  // void _navigateToEditProfile(BuildContext context) {
  //   Navigator.push(
  //     context,
  //     PageTransition(
  //       child: BlocProvider(
  //         create: (context) => ProfileBloc(),
  //         child: EditProfile(image: profileImage),
  //       ),
  //       type: PageTransitionType.rightToLeft,
  //     ),
  //   );
  // }

  Widget _buildImageWidget() {
    if (HiveService.userImage() == null) {
      return Image.asset(Assets.defaultAvatar, fit: BoxFit.cover);
    }

    // Try to load as file first
    try {
      final file = File(HiveService.userImage()!);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) =>
                  Image.asset(Assets.defaultAvatar, fit: BoxFit.cover),
        );
      }
    } catch (_) {
      // If file loading fails, try as network image
    }

    // Try as network image if it starts with http/https
    if (HiveService.userImage()!.startsWith('http')) {
      return Image.network(
        HiveService.userImage()!,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) =>
                Image.asset(Assets.defaultAvatar, fit: BoxFit.cover),
      );
    }

    // Fallback to default avatar
    return Image.asset(Assets.defaultAvatar, fit: BoxFit.cover);
  }

  // initUser() async {
  //   final fname = await config.getUserData(key: DBKeys.uFirstName);
  //   final lname = await config.getUserData(key: DBKeys.uLastName);
  //   final mobile = await config.getUserData(key: DBKeys.uMobile);
  //   final image = await config.getUserData(key: DBKeys.localImgKey);
  //   final uKey = await config.getUserData(key: DBKeys.userKey);
  //   setState(() {
  //     name = '$fname $lname';
  //     uMobile = mobile;
  //     profileImage = image;
  //     userKey = uKey;
  //   });
  // }

  @override
  void initState() {
    // initUser();
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
          appBar: customAppBar(title: 'Profile', context: context),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              HiveService.getUserId() != null
                  ? profileDetail(context)
                  : SizedBox(),
              heightSpace,
              heightSpace,
              profileOptions(context),
              SizedBox(height: 50),
            ],
          ),
        );
      },
    );
  }

  profileDetail(context) {
    final name =
        HiveService.getFName() != null && HiveService.getLName() != null
            ? '${HiveService.getFName()} ${HiveService.getLName()}'
            : 'User';
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        fixPadding * 2.0,
        fixPadding * 2.0,
        fixPadding * 2.0,
        0,
      ),
      child: Row(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: _buildImageWidget(),
            ),
          ),
          widthSpace,
          widthSpace,
          widthSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name != '' ? name.toString() : 'User',
                  style: black16MediumTextStyle,
                ),
                const SizedBox(height: 2),
                Text(
                  HiveService.getMobile() != null
                      ? '+91${HiveService.getMobile()}'
                      : 'Mobile Number',
                  style: grey14RegularTextStyle,
                ),
              ],
            ),
          ),
          InkWell(
            onTap:
                () => GoRouter.of(context).pushNamed(
                  EditProfile.routeName,
                  extra: {'image': HiveService.userImage() ?? ''},
                ),
            child: const Icon(Icons.edit, color: primaryColor, size: 20),
          ),
        ],
      ),
    );
  }

  profileOptions(context) {
    return Column(
      children: [
        // option(
        //   ontap: () => Navigator.push(
        //     context,
        //     PageTransition(
        //       child: const MyLibrary(),
        //       type: PageTransitionType.rightToLeft,
        //     ),
        //   ),
        //   title: 'My Library',
        //   color: blackColor,
        // ),
        // divider(),
        HiveService.getUserId() != null
            ? option(
              ontap:
                  () => GoRouter.of(
                    context,
                  ).pushNamed(ChangePasswordView.routeName),
              title: 'Change password',
              color: blackColor,
            )
            : SizedBox(),

        option(
          ontap:
              () => GoRouter.of(
                context,
              ).pushNamed(SubscriptionPlanView.routeName),
          title: 'Subscription Plan',
          color: blackColor,
        ),

        HiveService.getUserId() != null
            ? option(
              ontap:
                  () => GoRouter.of(context).pushNamed(SuffaSupport.routeName),
              title: 'Generate Ticket',
              color: blackColor,
            )
            : SizedBox(),

        HiveService.getUserId() != null
            ? option(
              ontap:
                  () => GoRouter.of(
                    context,
                  ).pushNamed(TicketHistoryView.routeName),
              title: 'Ticket History',
              color: blackColor,
            )
            : SizedBox(),

        option(
          ontap:
              () => GoRouter.of(
                context,
              ).pushNamed(InfoPage.routeName, extra: '2'),
          title: 'Privacy Policy',
          color: blackColor,
        ),

        option(
          ontap:
              () => GoRouter.of(
                context,
              ).pushNamed(InfoPage.routeName, extra: '3'),
          title: 'Terms & Conditions',
          color: blackColor,
        ),

        // option(
        //   ontap: () => Navigator.push(
        //     context,
        //     PageTransition(
        //       child: InfoPage(pageRole: '3'),
        //       type: PageTransitionType.rightToLeft,
        //     ),
        //   ),
        //   title: 'Terms & Conditions',
        //   color: blackColor,
        // ),
        option(
          ontap:
              () => GoRouter.of(
                context,
              ).pushNamed(InfoPage.routeName, extra: '4'),
          title: 'Refund Policy',
          color: blackColor,
        ),

        option(
          ontap:
              () => GoRouter.of(
                context,
              ).pushNamed(InfoPage.routeName, extra: '1'),
          title: 'About Us',
          color: blackColor,
        ),

        HiveService.getUserId() != null
            ? option(
              ontap: () => logoutDialog(context),
              title: 'Logout',
              color: Colors.redAccent,
            )
            : SizedBox(),
      ],
    );
  }

  option({VoidCallback? ontap, String? title, Color? color}) {
    return InkWell(
      onTap: ontap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: fixPadding * 1.5,
          horizontal: fixPadding * 2.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title!,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  logoutDialog(context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          elevation: 5,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: fixPadding * 2.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  fixPadding * 2.0,
                  fixPadding * 1.5,
                  fixPadding * 2.0,
                  fixPadding * 2.3,
                ),
                child: Column(
                  children: [
                    Text(
                      'Sure you want to Logout?',
                      style: black16MediumTextStyle,
                    ),
                    heightSpace,
                    heightSpace,
                    heightSpace,
                    heightSpace,
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(5),
                            onTap: () => context.pop(),
                            child: Container(
                              padding: const EdgeInsets.all(fixPadding * 1.5),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: whiteColor,
                                border: Border.all(color: Colors.transparent),
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: [
                                  BoxShadow(
                                    color: blackColor.withValues(alpha: 0.1),
                                    spreadRadius: 1,
                                    blurRadius: 1,
                                  ),
                                ],
                              ),
                              child: Text(
                                'Cancel',
                                style: primaryColor18SemiBoldTextStyle,
                              ),
                            ),
                          ),
                        ),
                        widthSpace,
                        widthSpace,
                        widthSpace,
                        widthSpace,
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(5),
                            onTap: () {
                              // AuthRepository.signOut(context);
                              HiveService.logout(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(fixPadding * 1.5),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                border: Border.all(color: primaryColor),
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withValues(alpha: 0.2),
                                    spreadRadius: 2,
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              child: Text(
                                'Logout',
                                style: white18SemiBoldTextStyle,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  divider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      color: greyColor.withValues(alpha: 0.5),
      height: 1,
      width: double.infinity,
    );
  }
}
