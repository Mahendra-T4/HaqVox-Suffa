import 'package:flutter/material.dart';
import 'package:haqvox/app/constant/constant.dart';


class TrendingBooks extends StatefulWidget {
  final String? title;
  const TrendingBooks({super.key, this.title});
  static const String routeName = '/trendingBooks';

  @override
  _TrendingBooksState createState() => _TrendingBooksState();
}

class _TrendingBooksState extends State<TrendingBooks> {
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
      'save': true,
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
      'save': true,
    },
    {
      'image': 'assets/books/book20.png',
      'bookName': 'To Kill a Mockingbird',
      'bookAuthor': 'Harper Lee',
      'rating': '4.2',
      'rated': '124',
      'time': '4hr • 20min',
      'chapter': '15',
      'price': '\$1.50',
      'save': false,
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
      'save': true,
    },
    {
      'image': 'assets/books/book21.png',
      'bookName': 'The Ginger Man',
      'bookAuthor': 'J.P Donleavy',
      'rating': '4.2',
      'rated': '124',
      'time': '3hr • 20min',
      'chapter': '12',
      'price': '\$2.50',
      'save': true,
    },
    {
      'image': 'assets/books/book7.png',
      'bookName': 'The Habbit',
      'bookAuthor': 'J.R.R Tolkien',
      'rating': '4.2',
      'rated': '124',
      'time': '4hr • 10min',
      'chapter': '16',
      'price': '\$2.50',
      'save': false,
    },
    {
      'image': 'assets/books/book9.png',
      'bookName': 'Harry Potter and The Philosopher’s Stone',
      'bookAuthor': 'J. K. Rowling',
      'rating': '4.2',
      'rated': '124',
      'time': '3hr • 20min',
      'chapter': '16',
      'price': '\$2.50',
      'save': false,
    },
    {
      'image': 'assets/books/book10.png',
      'bookName': 'The Names they Gave Us',
      'bookAuthor': 'Fmery Lord',
      'rating': '3.2',
      'rated': '100',
      'time': '1hr • 17min',
      'chapter': '16',
      'price': '\$1.50',
      'save': false,
    },
    {
      'image': 'assets/books/book11.png',
      'bookName': 'I Have a Dream',
      'bookAuthor': 'Rasmi Bansal',
      'rating': '4.2',
      'rated': '124',
      'time': '3hr • 20min',
      'chapter': '12',
      'price': '\$2.50',
      'save': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          '${widget.title} Books',
          style: black18MediumTextStyle,
        ),
      ),
      body: books(),
    );
  }

  books() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: booksList.length,
      itemBuilder: (context, index) {
        final item = booksList[index];
        return Padding(
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
            //       image: '${item['image']}',
            //       bookName: '${item['bookName']}',
            //       bookAuthor: '${item['bookAuthor']}',
            //       rating: '${item['rating']}',
            //       rated: '${item['rated']}',
            //       time: '${item['time']}',
            //       chapter: '${item['chapter']}',
            //       price: '${item['price']}',
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item['bookName']}',
                                    overflow: TextOverflow.ellipsis,
                                    style: black16MediumTextStyle,
                                  ),
                                ),
                                widthSpace,
                                widthSpace,
                                InkWell(
                                    onTap: () {
                                      if (item['save'] == true) {
                                        item['save'] == false;
                                      } else {
                                        item['save'] == true;
                                      }
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: item['save'] == true
                                              ? Text(
                                                  '${item['bookName']} added to bookmark')
                                              : Text(
                                                  '${item['bookName']} removed from bookmark'),
                                        ),
                                      );
                                    },
                                    child: Icon(
                                      item['save'] == true
                                          ? Icons.bookmark
                                          : Icons.bookmark_outline,
                                      color: greyColor,
                                      size: 20,
                                    )),
                              ],
                            ),
                            Text(
                              '${item['bookAuthor']}',
                              style: grey12RegularTextStyle,
                            ),
                            heightSpace,
                            Row(
                              children: [
                                Text(
                                  '${item['rating']}',
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${item['time']} | ${item['chapter']} Chapters',
                                  style: grey12RegularTextStyle,
                                ),
                                Text(
                                  '${item['price']}',
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
                          image: AssetImage('${item['image']}'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
