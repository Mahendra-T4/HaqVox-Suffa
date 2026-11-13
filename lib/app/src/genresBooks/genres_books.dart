// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:haqvox/app/assets/assets.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/core/widgets/appbar.dart';
import 'package:haqvox/app/services/connectivity.dart';
import 'package:haqvox/app/src/eBook/bloc/e_book_bloc.dart';
import 'package:haqvox/app/src/eBook/models/ebook_details_params.dart';
import 'package:haqvox/app/src/eBook/view/book_detail.dart';
import 'package:haqvox/app/src/home/models/ebook_params.dart';
import 'package:haqvox/app/src/myspace/view/offline_download.dart';

class GenersBooks extends StatefulWidget {
  const GenersBooks({super.key, required this.eBookListParams});
  final EBookListParams eBookListParams;
  static const String routeName = '/GenersBooks';

  @override
  State<GenersBooks> createState() => _GenersBooksState();
}

class _GenersBooksState extends State<GenersBooks> {
  late EBookBloc _eBookBloc;

  @override
  initState() {
    super.initState();
    _eBookBloc = EBookBloc();
    _eBookBloc.add(
      EBookGeneraFromServerEvent(
        categorySlug: widget.eBookListParams.categorySlug,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
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
          appBar: customAppBar1(
            title: '${widget.eBookListParams.title} eBooks Library',
            context: context,
          ),
          body: BlocBuilder(
            bloc: _eBookBloc,
            builder: (context, state) {
              switch (state.runtimeType) {
                case const (EBookLoadingState):
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                case const (EBookLoadFromServerSuccessState):
                  final successState =
                      (state as EBookLoadFromServerSuccessState).eBookEntity;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          fixPadding * 2.0,
                          fixPadding * 1.5,
                          fixPadding * 2.0,
                          fixPadding,
                        ),
                        child: Text(
                          '${widget.eBookListParams.title} For You',
                          style: black16MediumTextStyle,
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(
                            bottom: fixPadding * 9.0,
                          ),
                          itemCount: successState.record?.length ?? 0,
                          itemBuilder: (context, index) {
                            // final book = successState.record![index];
                            return Padding(
                              padding: EdgeInsets.fromLTRB(
                                fixPadding * 2.0,
                                index == 0 ? fixPadding : 0,
                                fixPadding * 2.0,
                                fixPadding,
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(5),
                                onTap: () {
                                  GoRouter.of(context).pushNamed(
                                    BookDetail.routeName,
                                    extra: EBooksDetailsParams(
                                      eBookName:
                                          successState.record![index].ebookName
                                              .toString(),
                                      eBookImage:
                                          successState.record![index].ebookImage
                                              .toString(),
                                      eBookDescription:
                                          successState
                                              .record![index]
                                              .ebookDescription
                                              .toString(),
                                      ebookTagline:
                                          successState
                                              .record![index]
                                              .ebookTagline
                                              .toString(),
                                      ebookSlug:
                                          successState.record![index].ebookSlug
                                              .toString(),
                                      bookmarkStatus:
                                          successState
                                              .record![index]
                                              .bookmarkStatus,
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.grey.withValues(alpha: .3),
                                  ),
                                  child: Stack(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                          vertical: fixPadding * 2.2,
                                        ),
                                        padding: const EdgeInsets.fromLTRB(
                                          0,
                                          0,
                                          fixPadding,
                                          fixPadding,
                                        ),
                                        child: Row(
                                          children: [
                                            Container(width: size.width * 0.3),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          successState
                                                              .record![index]
                                                              .ebookName
                                                              .toString(),
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                          style:
                                                              black16MediumTextStyle,
                                                        ),
                                                      ),
                                                      widthSpace,
                                                      // widthSpace,
                                                      // Icon(
                                                      //   Icons.bookmark_add_outlined,
                                                      //   color: blackColor,
                                                      //   size: 20,
                                                      // ),
                                                    ],
                                                  ),
                                                  Text(
                                                    successState
                                                        .record![index]
                                                        .ebookTagline
                                                        .toString(),
                                                    style: TextStyle(
                                                      color: primaryColor,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                  heightSpace,
                                                  Text(
                                                    successState
                                                        .record![index]
                                                        .ebookDescription
                                                        .toString(),
                                                    maxLines: 3,
                                                    style:
                                                        grey12RegularTextStyle,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        // top: 0,
                                        // left: 0,
                                        // bottom: 0,
                                        child: Container(
                                          height: 160,
                                          width: size.width * 0.27,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                            image:
                                                successState
                                                            .record![index]
                                                            .ebookImage !=
                                                        ''
                                                    ? DecorationImage(
                                                      image: NetworkImage(
                                                        successState
                                                            .record![index]
                                                            .ebookImage
                                                            .toString(),
                                                      ),
                                                      fit: BoxFit.cover,
                                                    )
                                                    : const DecorationImage(
                                                      image: AssetImage(
                                                        Assets
                                                            .defaulteBookCover,
                                                      ),
                                                      fit: BoxFit.cover,
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
                        ),
                      ),
                    ],
                  );
                case const (EBookLoadFromServerFailedErrorState):
                  final error =
                      (state as EBookLoadFromServerFailedErrorState).error;
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          error,
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            _eBookBloc.add(EBookListFetchFromServerEvent());
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                default:
                  return const Center(child: Text('Something went wrong'));
              }
            },
          ),
        );
      },
    );
  }
}
