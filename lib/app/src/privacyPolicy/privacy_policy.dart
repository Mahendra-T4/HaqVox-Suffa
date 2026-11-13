import 'package:flutter/material.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/core/widgets/appbar.dart';
import 'package:haqvox/app/services/connectivity.dart';
import 'package:haqvox/app/src/myspace/view/offline_download.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

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
          appBar: customAppBar1(title: 'Privacy Policy', context: context),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(fixPadding * 2.0),
            children: [
              Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla ultrices netus sed lobortis morbi eget. Lectus aliquam a cursus in egestas tellus.',
                style: grey14RegularTextStyle,
              ),
              heightSpace,
              heightSpace,
              Text(
                'Gravida a, elementum egestas tempus hendrerit ipsum arcu. Netus pellentesque suspendisse sit malesuada neque, fermentum turpis. Nulla posuere tristique ut varius ac tincidunt vitae. Laoreet ultrices neque nunc justo, ut facilisis.',
                style: grey14RegularTextStyle,
              ),
              heightSpace,
              heightSpace,
              Text(
                'A amet eget malesuada. Condimentum tellus odio mattis etiam aenean. Enim, mauris felis, est tempor molestie eleifend. Non in adipiscing non lectus amet. Dolor nisl mi dis purus pretium odio facilisi vitae duis. Scelerisque nisl eget bibendum tortor, morbi ornare ac.',
                style: grey14RegularTextStyle,
              ),
            ],
          ),
        );
      },
    );
  }
}
