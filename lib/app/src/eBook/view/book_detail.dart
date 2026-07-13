import 'dart:developer' as dev;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haqvox/app/assets/assets.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/services/connectivity.dart';
import 'package:haqvox/app/services/no_internate_page.dart';
import 'package:haqvox/app/src/eBook/bloc/e_book_bloc.dart';
import 'package:haqvox/app/src/eBook/models/ebook_details_params.dart';
import 'package:haqvox/app/src/eBook/view/ebook_chapter_audio_view_new.dart'
    as audio;
import 'package:haqvox/app/src/eBook/view/widget/description.dart';
import 'package:haqvox/app/src/myspace/view/myspace.dart';
import 'package:haqvox/app/src/myspace/view/offline_download.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BookDetail extends StatefulWidget {
  final EBooksDetailsParams params;
  const BookDetail({super.key, required this.params});

  static const String routeName = '/bookDetail';

  @override
  _BookDetailState createState() => _BookDetailState();
}

class _BookDetailState extends State<BookDetail> {
  late EBookBloc _eBookBloc;
  @override
  void initState() {
    super.initState();
    _eBookBloc = EBookBloc();
    _eBookBloc.add(
      EBookChapterFetchingEvent(ebookSlug: widget.params.ebookSlug),
    );
    dev.log('Loading book: ${widget.params.ebookSlug}');
  }

  bool isSave = false;
  double? height;
  double? width;
  String isSelected = 'chapters';

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
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
          appBar: AppBar(
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
            actions: [
              IconButton(
                onPressed: () => _shareBook(),
                icon: const Icon(Icons.share, color: whiteColor),
              ),
              widthSpace,
              widthSpace,
              widthSpace,
              widthSpace,
            ],
          ),
          body: ListView(
            children: [
              bookInfo(),
              tabBar(),
              isSelected == 'about'
                  ? Description(description: widget.params.eBookDescription)
                  : isSelected == 'chapters'
                  ? chapters()
                  : '',
            ],
          ),
          // bottomNavigationBar: bottomBar(),
        );
      },
    );
  }

  bookInfo() {
    return Padding(
      padding: const EdgeInsets.all(fixPadding * 2.0),
      child: Column(
        children: [
          Container(
            height: height! * 0.18,
            width: width! * 0.26,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 3),
                  color: blackColor.withValues(alpha: 0.1),
                  spreadRadius: 2,
                  blurRadius: 2,
                ),
              ],
            ),
            child:
                widget.params.eBookImage != ''
                    ? Image.network(widget.params.eBookImage, fit: BoxFit.cover)
                    : Image.asset(Assets.defaulteBookCover, fit: BoxFit.cover),
          ),
          heightSpace,
          Text(widget.params.eBookName, style: black16MediumTextStyle),
          heightSpace,
          const SizedBox(height: 1),
          Text(widget.params.ebookTagline, style: grey12RegularTextStyle),
        ],
      ),
    );
  }

  tabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: fixPadding * 1.7),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  setState(() {
                    isSelected = 'chapters';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: fixPadding * 1.2,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:
                        isSelected == 'chapters'
                            ? primaryColor
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow:
                        isSelected == 'chapters'
                            ? [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 0,
                                offset: const Offset(0, 2),
                              ),
                            ]
                            : null,
                  ),
                  child: Text(
                    'Chapters',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected == 'chapters'
                              ? whiteColor
                              : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  setState(() {
                    isSelected = 'about';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: fixPadding * 1.2,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:
                        isSelected == 'about'
                            ? primaryColor
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow:
                        isSelected == 'about'
                            ? [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 0,
                                offset: const Offset(0, 2),
                              ),
                            ]
                            : null,
                  ),
                  child: Text(
                    'About',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected == 'about' ? whiteColor : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bookBrief() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Book Brief', style: black16MediumTextStyle),
        heightSpace,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.timelapse, color: primaryColor, size: 16),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Duration', style: grey12RegularTextStyle),
                Text('time', style: black12MediumTextStyle),
              ],
            ),
            widthSpace,
            widthSpace,
            widthSpace,
            widthSpace,
            widthSpace,
            widthSpace,
            const Icon(Icons.tv, color: primaryColor, size: 16),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chapters', style: grey12RegularTextStyle),
                Text('chapter', style: black12MediumTextStyle),
              ],
            ),
            widthSpace,
            widthSpace,
            widthSpace,
            widthSpace,
            widthSpace,
            widthSpace,
            const Icon(
              Icons.monetization_on_outlined,
              color: primaryColor,
              size: 16,
            ),
            const SizedBox(width: 8),
          ],
        ),
      ],
    );
  }

  chapters() {
    return BlocBuilder(
      bloc: _eBookBloc,
      builder: (context, state) {
        switch (state.runtimeType) {
          case const (EBookLoadingState):
            return const Center(child: CircularProgressIndicator.adaptive());
          case const (EBookChapterLoadedSuccessState):
            final successState =
                (state as EBookChapterLoadedSuccessState).eBookChapterEntity;
            return successState.status == 1
                ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      fixPadding * 2.0,
                      fixPadding * 2.0,
                      fixPadding * 2.0,
                      fixPadding * 9.0,
                    ),
                    itemCount: successState.record!.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          GoRouter.of(context).pushNamed(
                            audio.EBookChapterAudio.routeName,
                            extra: audio.AudioParams(
                              chapterSlug:
                                  successState.record![index].chapterSlug
                                      .toString(),
                              ebookSlug: widget.params.ebookSlug,
                              ebookTitle: widget.params.eBookName,
                              chapterTitle:
                                  successState.record![index].chapterName
                                      .toString(),
                              image: widget.params.eBookImage,
                            ),
                          );
                        },
                        child: Container(
                          width: MediaQuery.sizeOf(context).width,
                          margin: const EdgeInsets.only(top: 5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            color: Colors.grey.withOpacity(.4),
                          ),
                          child: Row(
                            spacing: 10,
                            children: [
                              Text(
                                '${index + 1}.',
                                style: primaryColor14RegularTextStyle,
                              ),
                              Text(
                                successState.record![index].chapterName
                                    .toString(),
                                overflow: TextOverflow.ellipsis,
                                style: black14RegularTextStyle,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
                : Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.sizeOf(context).height / 5,
                  ),
                  child: Center(child: Text(successState.message.toString())),
                );
          case const (EBookChapterFailedToLoadErrorState):
            final error = (state as EBookChapterFailedToLoadErrorState).error;
            return Center(child: Text(error));
          default:
            return Center(child: Text('State not found'));
        }
      },
    );
  }

  bottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        fixPadding * 2.0,
        0,
        fixPadding * 2.0,
        fixPadding * 2.0,
      ),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(fixPadding * 1.5),
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
              child: const Icon(
                Icons.file_download_outlined,
                color: primaryColor,
                size: 22,
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
                Navigator.pop(context);
                // Navigator.push(
                //   context,
                //   PageTransition(
                //     child: StartListening(
                //       image: widget.params.eBookImage,
                //       bookName: widget.params.eBookName,
                //     ),
                //     type: PageTransitionType.rightToLeft,
                //   ),
                // );
              },
              child: Container(
                padding: const EdgeInsets.all(fixPadding * 1.5),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_circle, color: whiteColor, size: 22),
                    widthSpace,
                    widthSpace,
                    Text('Start Listening', style: white18SemiBoldTextStyle),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  paymentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: fixPadding * 6.0,
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(fixPadding * 2.0),
                child: Column(
                  children: [
                    Container(
                      height: height! * 0.18,
                      width: width! * 0.26,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        image: DecorationImage(
                          image: AssetImage(widget.params.eBookImage),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, 3),
                            color: blackColor.withValues(alpha: 0.1),
                            spreadRadius: 2,
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    heightSpace,
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: widget.params.eBookName,
                            style: black14MediumTextStyle,
                          ),
                        ],
                      ),
                    ),
                    heightSpace,
                    heightSpace,
                    heightSpace,
                    InkWell(
                      borderRadius: BorderRadius.circular(5),
                      onTap: () {
                        Navigator.pop(context);
                        // Navigator.push(
                        //   context,
                        //   PageTransition(
                        //     child: StartListening(
                        //       image: widget.params.eBookImage,
                        //       bookName: widget.params.eBookName,
                        //     ),
                        //     type: PageTransitionType.rightToLeft,
                        //   ),
                        // );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: fixPadding * 1.5,
                          horizontal: fixPadding * 6.0,
                        ),
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
                        child: Text(
                          'Continue',
                          style: white18SemiBoldTextStyle,
                        ),
                      ),
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

  showAudioListBottomSheet(BuildContext context) {
    return BlocConsumer<EBookBloc, EBookState>(
      bloc: _eBookBloc,
      listener: (context, state) {},
      builder: (context, state) {
        if (state is EBookLoadingState) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (state is EBookChapterAudioFailedToLoadErrorState) {
          return Center(child: Text(state.error));
        }

        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Bottom Sheet Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Handle Bar
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Available Audio Chapters',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              // Audio List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 2,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.08),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          'Unknown Chapter',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          'Duration: ',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            FontAwesomeIcons.play,
                            size: 18,
                            color: primaryColor,
                          ),
                          onPressed: () {
                            // Navigator.push(
                            //   context,
                            //   PageTransition(
                            //     child: StartListening(
                            //       image: widget.params.eBookImage,
                            //       bookName: audio.chapterName ?? '',
                            //     ),
                            //     type: PageTransitionType.rightToLeft,
                            //   ),
                            // );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _shareBook() async {
    String? tempFilePath;
    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 16),
                Text('Preparing to share...'),
              ],
            ),
            duration: Duration(seconds: 1),
          ),
        );
      }

      final bookInfo = '''
📚 Check out this awesome book on HAQ VOX!

${widget.params.eBookName}
${widget.params.ebookTagline}

Description:
${widget.params.eBookDescription}

Download HAQ VOX to start reading!
''';

      if (widget.params.eBookImage.startsWith('http')) {
        try {
          final response = await http.get(Uri.parse(widget.params.eBookImage));
          final bytes = response.bodyBytes;
          final temp = await getTemporaryDirectory();
          tempFilePath =
              '${temp.path}/book_cover_${DateTime.now().millisecondsSinceEpoch}.jpg';
          await File(tempFilePath).writeAsBytes(bytes);

          await Share.shareXFiles(
            [XFile(tempFilePath)],
            text: bookInfo,
            subject: widget.params.eBookName,
          );
        } catch (e) {
          dev.log('Error sharing with image: $e');
          await Share.share(bookInfo, subject: widget.params.eBookName);
        }
      } else {
        await Share.share(bookInfo, subject: widget.params.eBookName);
      }
    } catch (e) {
      dev.log('Error sharing: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unable to share book: ${e.toString().split('\n')[0]}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Clean up temporary file
      if (tempFilePath != null) {
        try {
          final file = File(tempFilePath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          dev.log('Error cleaning up temporary file: $e');
        }
      }
    }
  }
}

divider() {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    color: greyColor.withValues(alpha: 0.5),
    height: 1,
    width: double.infinity,
  );
}
