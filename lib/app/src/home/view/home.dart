import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:haqvox/app/assets/assets.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/constant/text.dart';
import 'package:haqvox/app/core/database/user/hive_db.dart';
import 'package:haqvox/app/services/connectivity.dart';
import 'package:haqvox/app/src/auth/view/login.dart';
import 'package:haqvox/app/src/eBook/models/ebook_details_params.dart';
import 'package:haqvox/app/src/eBook/view/book_detail.dart';
import 'package:haqvox/app/src/genresBooks/genres_books.dart';
import 'package:haqvox/app/src/home/bloc/home_bloc.dart';
import 'package:haqvox/app/src/home/models/ebook_params.dart';
import 'package:haqvox/app/src/home/view/eBook%20List/ebook_listview.dart';
import 'package:haqvox/app/src/home/view/widgets/home_builder.dart';
import 'package:haqvox/app/src/home/widgets/recent_plays_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:haqvox/app/src/myspace/view/offline_download.dart';
import 'package:haqvox/app/src/notifications/view/notifications.dart';



class Home extends StatefulWidget {
  static const String routeName = '/home';

  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends HomeBuilder with WidgetsBindingObserver {
  late HomeBloc _homeBloc;

  dynamic name;
  // String? uKey;
  int? uSubscription;

  Future<void> initName() async {
    try {
      // Only update state if widget is still mounted
      if (mounted) {
        setState(() {
          name = '${HiveService.getFName()} ${HiveService.getLName() ?? ''}';
          // uKey = userKey;
          uSubscription = HiveService.getSubscription();
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Timer? _timer;

  @override
  void initState() {
    _homeBloc = HomeBloc();
    _homeBloc.add(HomeGlobalContentFetchingEvent());

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        initName();
      }
    });

    // Listen to app lifecycle changes
    WidgetsBinding.instance.addObserver(this);

    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

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
            backgroundColor: primaryColor,
            // shape: const RoundedRectangleBorder(
            //   borderRadius: BorderRadius.only(
            //     bottomLeft: Radius.circular(20),
            //     bottomRight: Radius.circular(20),
            //   ),
            // ),
            leading: Container(
              margin: const EdgeInsets.only(left: fixPadding * 2.0),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Image.asset(
                Assets.appLogoIconImage,
                height: 40,
                width: 40,
              ),
            ),
            title: appBarText(title: 'HaqVox'),
            actions: [
              HiveService.getUserId() != null
                  ? IconButton(
                    onPressed: () {
                      GoRouter.of(context).pushNamed(Notifications.routeName);
                    },
                    icon: Image.asset(
                      Assets.notificationIconImage,
                      height: 30,
                      width: 30,
                      color: whiteColor,
                    ),
                  )
                  : IconButton(
                    onPressed: () {
                      GoRouter.of(context).pushNamed(Login.routeName);
                    },
                    icon: Image.asset(
                      Assets.loginImage,
                      height: 30,
                      width: 30,
                      color: whiteColor,
                    ),
                  ),
              widthSpace,
            ],
          ),
          body: BlocConsumer(
            bloc: _homeBloc,
            listener: (context, state) {},
            builder: (context, state) {
              if (state is HomeLoadingState) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is HomeGlobalContentsLoadedSuccessState) {
                final successState = state.homeEntity;
                if (successState.record == null) {
                  return Center(child: Text(successState.message.toString()));
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display recently played tracks
                      SizedBox(height: 20),
                      banners(),
                      RecentPlaysWidget(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              fixPadding * 2.0,
                              fixPadding * 2.0,
                              fixPadding * 2.0,
                              fixPadding,
                            ),
                            child: Text(
                              'Genres',
                              style: black16MediumTextStyle,
                            ),
                          ),
                          SizedBox(
                            height: height! * 0.120,
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              itemCount:
                                  successState.record!.categoryList.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    left:
                                        index == 0
                                            ? fixPadding * 2.0
                                            : fixPadding,
                                    right:
                                        index ==
                                                successState
                                                        .record!
                                                        .categoryList
                                                        .length -
                                                    1
                                            ? fixPadding * 2.0
                                            : 0,
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(5),
                                    onTap: () {
                                      GoRouter.of(context).pushNamed(
                                        GenersBooks.routeName,
                                        extra: EBookListParams(
                                          categorySlug:
                                              successState
                                                  .record!
                                                  .categoryList[index]
                                                  .categorySlug,
                                          title:
                                              successState
                                                  .record!
                                                  .categoryList[index]
                                                  .categoryName,
                                        ),
                                      );
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: height! * 0.086,
                                          width: width! * 0.21,
                                          padding: const EdgeInsets.all(8),
                                          clipBehavior: Clip.antiAlias,
                                          alignment: Alignment.center,

                                          decoration: BoxDecoration(
                                            color: primaryColor,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                successState
                                                    .record!
                                                    .categoryList[index]
                                                    .categoryIcon
                                                    .toString(),
                                            // height: 50,
                                            // width: 50,
                                            fit: BoxFit.cover,
                                            placeholder:
                                                (
                                                  context,
                                                  url,
                                                ) => const SizedBox(
                                                  height: 30,
                                                  width: 30,

                                                  child: Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                  ),
                                                ),
                                            errorWidget:
                                                (context, url, error) => Icon(
                                                  Icons.broken_image,
                                                  size: 30,
                                                ),
                                          ),
                                        ),
                                        heightSpace,
                                        Text(
                                          successState
                                              .record!
                                              .categoryList[index]
                                              .categoryName,
                                          style: primaryColor14MediumTextStyle,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      //! recommended() ------------------------------------->                      // Recent Plays section
                      // uKey != null ? const RecentPlaysWidget() : const SizedBox(),
                      //! recommended() ------------------------------------->
                      // const RecentPlaysWidget(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              fixPadding * 2.0,
                              fixPadding * 2.0,
                              fixPadding * 2.0,
                              fixPadding,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Recommended',
                                  style: black16MediumTextStyle,
                                ),
                                InkWell(
                                  onTap:
                                      () => GoRouter.of(context).pushNamed(
                                        EBookListView.routeName,
                                        extra: EBookListParams(
                                          filterBy: '1',
                                          title: 'Recommended',
                                        ),
                                      ),
                                  child: Text(
                                    'View All',
                                    style: primaryColor14MediumTextStyle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: height! * 0.145,
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              itemCount:
                                  successState.record!.recommendedBook.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    left: index == 0 ? fixPadding * 2.0 : 0,
                                    right:
                                        index ==
                                                successState
                                                        .record!
                                                        .recommendedBook
                                                        .length -
                                                    1
                                            ? fixPadding * 2.0
                                            : fixPadding,
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(5),
                                    onTap: () {
                                      GoRouter.of(context).pushNamed(
                                        BookDetail.routeName,
                                        extra: EBooksDetailsParams(
                                          eBookName:
                                              successState
                                                  .record!
                                                  .recommendedBook[index]
                                                  .ebookName
                                                  .toString(),
                                          eBookImage:
                                              successState
                                                  .record!
                                                  .recommendedBook[index]
                                                  .ebookImage
                                                  .toString(),
                                          eBookDescription:
                                              successState
                                                  .record!
                                                  .recommendedBook[index]
                                                  .ebookDescription
                                                  .toString(),
                                          ebookTagline:
                                              successState
                                                  .record!
                                                  .recommendedBook[index]
                                                  .ebookTagline
                                                  .toString(),
                                          ebookSlug:
                                              successState
                                                  .record!
                                                  .recommendedBook[index]
                                                  .ebookSlug
                                                  .toString(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      height: height! * 0.145,
                                      width: width! * 0.2054,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        image:
                                            successState
                                                        .record!
                                                        .recommendedBook[index]
                                                        .ebookImage !=
                                                    ''
                                                ? DecorationImage(
                                                  image: CachedNetworkImageProvider(
                                                    successState
                                                        .record!
                                                        .recommendedBook[index]
                                                        .ebookImage,
                                                  ),
                                                  fit: BoxFit.cover,
                                                )
                                                : DecorationImage(
                                                  image: AssetImage(
                                                    Assets.defaulteBookCover,
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
                      ),
                      HiveService.getSubscription() != 1
                          ? topAdsContainer()
                          : SizedBox(),

                      //! trending(context) ------------------------>
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              fixPadding * 2.0,
                              fixPadding * 2.0,
                              fixPadding * 2.0,
                              fixPadding,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Trending', style: black16MediumTextStyle),
                                InkWell(
                                  onTap:
                                      () => GoRouter.of(context).pushNamed(
                                        EBookListView.routeName,
                                        extra: EBookListParams(
                                          filterBy: '2',
                                          title: 'Trending',
                                        ),
                                      ),
                                  child: Text(
                                    'View All',
                                    style: primaryColor14MediumTextStyle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: height! * 0.145,
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              itemCount:
                                  successState.record!.trendingBook.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    left: index == 0 ? fixPadding * 2.0 : 0,
                                    right:
                                        index ==
                                                successState
                                                        .record!
                                                        .trendingBook
                                                        .length -
                                                    1
                                            ? fixPadding * 2.0
                                            : fixPadding,
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(5),
                                    onTap: () {
                                      GoRouter.of(context).pushNamed(
                                        BookDetail.routeName,
                                        extra: EBooksDetailsParams(
                                          eBookName:
                                              successState
                                                  .record!
                                                  .trendingBook[index]
                                                  .ebookName
                                                  .toString(),
                                          eBookImage:
                                              successState
                                                  .record!
                                                  .trendingBook[index]
                                                  .ebookImage
                                                  .toString(),
                                          eBookDescription:
                                              successState
                                                  .record!
                                                  .trendingBook[index]
                                                  .ebookDescription
                                                  .toString(),
                                          ebookTagline:
                                              successState
                                                  .record!
                                                  .trendingBook[index]
                                                  .ebookTagline
                                                  .toString(),
                                          ebookSlug:
                                              successState
                                                  .record!
                                                  .trendingBook[index]
                                                  .ebookSlug
                                                  .toString(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      height: height! * 0.145,
                                      width: width! * 0.2054,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        image:
                                            successState
                                                        .record!
                                                        .trendingBook[index]
                                                        .ebookImage !=
                                                    ''
                                                ? DecorationImage(
                                                  image:
                                                      CachedNetworkImageProvider(
                                                        successState
                                                            .record!
                                                            .trendingBook[index]
                                                            .ebookImage,
                                                      ),
                                                  fit: BoxFit.cover,
                                                )
                                                : DecorationImage(
                                                  image: AssetImage(
                                                    Assets.defaulteBookCover,
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
                      ),
                      HiveService.getSubscription() != 1
                          ? bottomAdsContainer()
                          : SizedBox(),
                      //! latest(context),---------------------------->
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              fixPadding * 2.0,
                              fixPadding * 2.0,
                              fixPadding * 2.0,
                              fixPadding,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Latest', style: black16MediumTextStyle),
                                InkWell(
                                  onTap:
                                      () => GoRouter.of(context).pushNamed(
                                        EBookListView.routeName,
                                        extra: EBookListParams(
                                          filterBy: '3',
                                          title: 'Latest',
                                        ),
                                      ),
                                  child: Text(
                                    'View All',
                                    style: primaryColor14MediumTextStyle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: height! * 0.145,
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              itemCount: successState.record!.latestBook.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    left: index == 0 ? fixPadding * 2.0 : 0,
                                    right:
                                        index ==
                                                successState
                                                        .record!
                                                        .latestBook
                                                        .length -
                                                    1
                                            ? fixPadding * 2.0
                                            : fixPadding,
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(5),
                                    onTap: () {
                                      GoRouter.of(context).pushNamed(
                                        BookDetail.routeName,
                                        extra: EBooksDetailsParams(
                                          eBookName:
                                              successState
                                                  .record!
                                                  .latestBook[index]
                                                  .ebookName
                                                  .toString(),
                                          eBookImage:
                                              successState
                                                  .record!
                                                  .latestBook[index]
                                                  .ebookImage
                                                  .toString(),
                                          eBookDescription:
                                              successState
                                                  .record!
                                                  .latestBook[index]
                                                  .ebookDescription
                                                  .toString(),
                                          ebookTagline:
                                              successState
                                                  .record!
                                                  .latestBook[index]
                                                  .ebookTagline
                                                  .toString(),
                                          ebookSlug:
                                              successState
                                                  .record!
                                                  .latestBook[index]
                                                  .ebookSlug
                                                  .toString(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      height: height! * 0.145,
                                      width: width! * 0.2054,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        image:
                                            successState
                                                        .record!
                                                        .latestBook[index]
                                                        .ebookImage !=
                                                    ''
                                                ? DecorationImage(
                                                  image:
                                                      CachedNetworkImageProvider(
                                                        successState
                                                            .record!
                                                            .latestBook[index]
                                                            .ebookImage,
                                                      ),
                                                  fit: BoxFit.cover,
                                                )
                                                : DecorationImage(
                                                  image: AssetImage(
                                                    Assets.defaulteBookCover,
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
                      ),
                      SizedBox(height: 100),
                    ],
                  ),
                );
              } else if (state is HomeGlobalContentsFailedErrorState) {
                return Center(child: Text('Error: ${state.error}'));
              } else {
                return const CircularProgressIndicator(color: primaryColor);
              }
            },
          ),
        );
      },
    );
  }
}
