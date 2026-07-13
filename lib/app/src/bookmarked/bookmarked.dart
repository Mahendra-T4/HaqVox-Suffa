// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/core/widgets/appbar.dart';

class Bookmarked extends StatefulWidget {
  const Bookmarked({super.key});
  static const String routeName = '/bookmarked';

  @override
  _BookmarkedState createState() => _BookmarkedState();
}

class _BookmarkedState extends State<Bookmarked> {
  double? width;

  final booksList = [
    {
      'image': 'assets/books/book8.png',
      'bookName': 'Tresure of The Lost Sea',
      'bookAuthor': 'Robert F. Marx',
      'rating': '4.2',
      'rated': '124',
      'time': '3hr • 20min',
      'chapter': '12',
      'price': '\$2.50',
    },
    {
      'image': 'assets/books/book19.png',
      'bookName': 'War and Peace',
      'bookAuthor': 'Leo Tolstoy',
      'rating': '4.0',
      'rated': '120',
      'time': '2hr • 20min',
      'chapter': '10',
      'price': '\$3.50',
    },
    {
      'image': 'assets/books/book6.png',
      'bookName': 'Good to Great',
      'bookAuthor': 'James C. Collins',
      'rating': '4.0',
      'rated': '124',
      'time': '3hr • 20min',
      'chapter': '12',
      'price': '\$3.50',
    },
  ];

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: customAppBar(title: 'Bookmarked', context: context),
      body: booksList.isEmpty ? emptyBookmark() : books(),
    );
  }

  emptyBookmark() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Center(
          child: Icon(
            Icons.bookmark_outline,
            color: greyColor,
            size: 35,
          ),
        ),
        heightSpace,
        Text(
          'No Items in Bookmarked',
          style: grey18RegularTextStyle,
        ),
      ],
    );
  }

  books() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: booksList.length,
      itemBuilder: (context, index) {
        final item = booksList[index];
        return Slidable(
          key: ValueKey(index),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.16,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    booksList.removeAt(index);
                  });

                  // Then show a snackbar.
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('${item['bookName']} removed from bookmark.'),
                  ));
                },
                child: Container(
                  margin: EdgeInsets.only(
                    top: index == 0 ? fixPadding * 4.2 : fixPadding * 2.2,
                    bottom: index == booksList.length - 1
                        ? fixPadding * 4.2
                        : fixPadding * 3.2,
                  ),
                  width: MediaQuery.of(context).size.width * 0.16,
                  decoration: BoxDecoration(
                    color: redColor,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.delete,
                    color: whiteColor,
                  ),
                ),
              ),
            ],
          ),
          // actionPane: const SlidableDrawerActionPane(),
          // actionExtentRatio: 0.25,
          // secondaryActions: [
          //   Padding(
          //     padding: EdgeInsets.only(
          //       top: index == 0 ? fixPadding * 4.2 : fixPadding * 2.2,
          //       bottom: index == booksList.length - 1
          //           ? fixPadding * 4.2
          //           : fixPadding * 3.2,
          //     ),
          //     child: ClipPath(
          //       clipper: const ShapeBorderClipper(
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.only(
          //             topLeft: Radius.circular(5),
          //             bottomLeft: Radius.circular(5),
          //           ),
          //         ),
          //       ),
          //       child: IconSlideAction(
          //         color: redColor,
          //         icon: Icons.delete,
          //         foregroundColor: whiteColor,
          //         onTap: () {
          //           setState(() {
          //             booksList.removeAt(index);
          //           });
          //           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //             content:
          //                 Text('${item['bookName']} removed from bookmark.'),
          //           ));
          //         },
          //       ),
          //     ),
          //   ),
          // ],
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              fixPadding * 2.0,
              index == 0 ? fixPadding * 2.0 : 0,
              fixPadding * 2.0,
              index == booksList.length - 1 ? fixPadding * 2.0 : fixPadding,
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
              //       rated: item['rated']!,
              //       time: item['time']!,
              //       chapter: item['chapter']!,
              //       price: item['price']!,
              //     ),
              //     type: PageTransitionType.rightToLeft,
              //   ),
              // ),
              child: Stack(
                children: [
                  Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: fixPadding * 2.2),
                    padding: const EdgeInsets.fromLTRB(
                      0,
                      fixPadding,
                      fixPadding,
                      fixPadding,
                    ),
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
                        Container(width: width! * 0.3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['bookName']!,
                                overflow: TextOverflow.ellipsis,
                                style: black16MediumTextStyle,
                              ),
                              Text(
                                item['bookAuthor']!,
                                style: grey12RegularTextStyle,
                              ),
                              heightSpace,
                              Row(
                                children: [
                                  Text(
                                    item['rating']!,
                                    style: yellow12MediumTextStyle,
                                  ),
                                  const Icon(
                                    Icons.star_rounded,
                                    color: yellowColor,
                                    size: 14,
                                  ),
                                  widthSpace,
                                  Text(
                                    '${item['rated']} rated',
                                    style: grey10RegularTextStyle,
                                  ),
                                ],
                              ),
                              heightSpace,
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${item['time']} | ${item['chapter']} Chapters',
                                    style: grey12RegularTextStyle,
                                  ),
                                  Text(
                                    item['price']!,
                                    style: green12MediumTextStyle,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    bottom: 0,
                    child: Hero(
                      tag: booksList[index],
                      child: Container(
                        width: width! * 0.27,
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
