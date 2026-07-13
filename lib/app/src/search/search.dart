// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/core/widgets/appbar.dart';
import 'package:haqvox/app/services/connectivity.dart';
import 'package:haqvox/app/src/myspace/view/myspace.dart';
import 'package:haqvox/app/src/myspace/view/offline_download.dart';
import 'package:haqvox/app/src/searchResult/search_result.dart';
import 'package:haqvox/app/widget/column_builder.dart';

class Search extends StatelessWidget {
  Search({super.key});
  static const String routeName = '/search';

  final searchList = [
    {'search': 'Americon gods'},
    {'search': 'Neil geiman'},
    {'search': 'Lord of the rings'},
    {'search': 'Harry potter books'},
  ];

  final recommendedList = [
    {'image': 'assets/books/book5.png'},
    {'image': 'assets/books/book6.png'},
    {'image': 'assets/books/book7.png'},
    {'image': 'assets/books/book8.png'},
    {'image': 'assets/books/book9.png'},
    {'image': 'assets/books/book10.png'},
    {'image': 'assets/books/book11.png'},
    {'image': 'assets/books/book12.png'},
    {'image': 'assets/books/book13.png'},
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
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
          appBar: customAppBar(title: 'Search', context: context),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              searchTextField(context),
              recentSearch(),
              suggestion(screenHeight, screenWidth),
            ],
          ),
        );
      },
    );
  }

  searchTextField(context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        fixPadding * 2.0,
        fixPadding * 2.0,
        fixPadding * 2.0,
        0,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SearchResult()),
            ),

        child: Container(
          height: 40,
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
          child: Row(
            children: [
              widthSpace,
              widthSpace,
              const Icon(Icons.search, color: greyColor, size: 16),
              widthSpace,
              widthSpace,
              Text(
                'Search among audiobooks, authors...',
                style: grey12RegularTextStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  recentSearch() {
    return Padding(
      padding: const EdgeInsets.all(fixPadding * 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Searches:', style: black16MediumTextStyle),
          ColumnBuilder(
            crossAxisAlignment: CrossAxisAlignment.start,
            itemCount: searchList.length,
            itemBuilder: (context, index) {
              final item = searchList[index];
              return Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(top: 8),
                child: Text(item['search']!, style: grey12RegularTextStyle),
              );
            },
          ),
        ],
      ),
    );
  }

  suggestion(double screenHeight, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            fixPadding * 2.0,
            0,
            fixPadding * 2.0,
            fixPadding,
          ),
          child: Text('Suggestion For You', style: black16MediumTextStyle),
        ),
        SizedBox(
          height: screenHeight * 0.145,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: recommendedList.length,
            itemBuilder: (context, index) {
              final item = recommendedList[index];
              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? fixPadding * 2.0 : 0,
                  right:
                      index == recommendedList.length - 1
                          ? fixPadding * 2.0
                          : fixPadding,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(5),
                  // onTap: () => Navigator.push(
                  //   context,
                  //   PageTransition(
                  //     child: BookDetail(
                  //         tag: recommendedList[index], image: item['image']!),
                  //     type: PageTransitionType.rightToLeft,
                  //   ),
                  // ),
                  child: Hero(
                    tag: recommendedList[index],
                    child: Container(
                      height: screenHeight * 0.145,
                      width: screenWidth * 0.19,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        image: DecorationImage(
                          image: AssetImage(item['image']!),
                          fit: BoxFit.cover,
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
    );
  }
}
