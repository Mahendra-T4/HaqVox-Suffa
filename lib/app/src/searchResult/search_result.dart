import 'package:flutter/material.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/core/widgets/appbar.dart';
import 'package:haqvox/app/services/connectivity.dart';
import 'package:haqvox/app/src/myspace/view/offline_download.dart';

class SearchResult extends StatefulWidget {
  const SearchResult({super.key});
  static const String routeName = '/searchResult';

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  int isSelected = 0;
  double? height, width;

  final searchOptionList = [
    {'option': 'All Results'},
    {'option': 'Audiobooks'},
    {'option': 'Authors'},
  ];

  final booksList = [
    {
      'image': 'assets/books/book9.png',
      'bookName': 'Harry Potter and the Philosopher\'s Stone',
      'bookAuthor': 'J.K Rowling',
      'rating': '4.0',
    },
    {
      'image': 'assets/books/book22.png',
      'bookName': 'Harry Potter and the Chamber of Secrets',
      'bookAuthor': 'J.K Rowling',
      'rating': '4.5',
    },
    {
      'image': 'assets/books/book23.png',
      'bookName': 'Harry Potter and the Prisoner of Azkaban',
      'bookAuthor': 'J.K Rowling',
      'rating': '4.1',
    },
    {
      'image': 'assets/books/book24.png',
      'bookName': 'Harry Potter and the Goblet of Fire',
      'bookAuthor': 'J.K Rowling',
      'rating': '4.1',
    },
    {
      'image': 'assets/books/book25.png',
      'bookName': 'Harry Potter and the Half-Blood Prince',
      'bookAuthor': 'J.K Rowling',
      'rating': '4.1',
    },
    {
      'image': 'assets/books/book26.png',
      'bookName': 'Harry Potter and the Deathly Hallows',
      'bookAuthor': 'J.K Rowling',
      'rating': '4.1',
    },
  ];

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    Size size = MediaQuery.sizeOf(context);
    return StreamBuilder(
      stream: InternetConnectionService().connectionStream,
      initialData: true,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const OfflineDownloads();
        }

        if (snapshot.data == false) {
          return const OfflineDownloads();
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          appBar: customAppBar(title: 'Search', context: context),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              searchTextField(),
              SizedBox(height: size.height * .025),
              searchOptions(),
              audioBooks(),
              // author(),
            ],
          ),
        );
      },
    );
  }

  searchTextField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        fixPadding * 2.0,
        fixPadding * 2.0,
        fixPadding * 2.0,
        0,
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
        child: TextField(
          cursorColor: primaryColor,
          style: black14MediumTextStyle,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(top: 7),
            hintText: 'Harry potter',
            hintStyle: grey12RegularTextStyle,
            prefixIcon: const Icon(Icons.search, color: greyColor, size: 16),
            border: const UnderlineInputBorder(borderSide: BorderSide.none),
          ),
        ),
      ),
    );
  }

  searchOptions() {
    return Container(
      height: 45, // Increased height to prevent overflow
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: searchOptionList.length,
        itemBuilder: (context, index) {
          final item = searchOptionList[index];
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? fixPadding * 2.0 : fixPadding,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(5),
              onTap: () {
                setState(() {
                  isSelected = index;
                });
              },
              child: Container(
                width: 108,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      isSelected == index ? primaryColor : Colors.transparent,
                  border: Border.all(color: primaryColor),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  item['option']!,
                  style:
                      isSelected == index
                          ? white14RegularTextStyle
                          : primaryColor14RegularTextStyle,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  audioBooks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            fixPadding * 2.0,
            fixPadding * 2.0,
            fixPadding * 2.0,
            fixPadding,
          ),
          child: Text('Audiobooks', style: black16MediumTextStyle),
        ),
        SizedBox(
          height: height! * 0.27,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: booksList.length,
            itemBuilder: (context, index) {
              final item = booksList[index];
              return Container(
                width: width! * 0.31,
                margin: EdgeInsets.fromLTRB(
                  index == 0 ? fixPadding * 2.0 : 0,
                  0,
                  fixPadding * 2.0,
                  0,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(5),
                  // onTap: () => Navigator.push(
                  //   context,
                  //   PageTransition(
                  //     child: BookDetail(
                  //       tag: booksList[index],
                  //       image: item['image']!,
                  //       bookName: item['bookName']!,
                  //       bookAuthor: item['bookAuthor']!,
                  //       rating: item['rating']!,
                  //     ),
                  //     type: PageTransitionType.rightToLeft,
                  //   ),
                  // ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Hero(
                            tag: booksList[index],
                            child: Container(
                              height: height! * 0.193,
                              width: width! * 0.31,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                image: DecorationImage(
                                  image: AssetImage(item['image']!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          // Positioned(
                          //   bottom: 8,
                          //   left: 10,
                          //   child: Row(
                          //     children: [
                          //       Text(
                          //         item['rating']!,
                          //         style: white12SemiBoldTextStyle,
                          //       ),
                          //       const Icon(
                          //         Icons.star_rounded,
                          //         color: whiteColor,
                          //         size: 14,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(
                        item['bookName']!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: black14RegularTextStyle,
                      ),
                      // const SizedBox(height: 4),
                      // Text(
                      //   item['bookAuthor']!,
                      //   style: grey12RegularTextStyle,
                      // ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  author() {
    return Padding(
      padding: const EdgeInsets.all(fixPadding * 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Authors', style: black16MediumTextStyle),
          const SizedBox(height: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/users/user2.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text('J.K.Rowling', style: black12RegularTextStyle),
            ],
          ),
        ],
      ),
    );
  }
}
