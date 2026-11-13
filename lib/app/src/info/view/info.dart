import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/core/widgets/appbar.dart';
import 'package:haqvox/app/services/connectivity.dart';
import 'package:haqvox/app/src/info/bloc/info_bloc.dart';
import 'package:haqvox/app/src/myspace/view/myspace.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InfoPage extends StatefulWidget {
  static const String routeName = '/terms';
  final String pageRole;

  const InfoPage({super.key, required this.pageRole});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  late final InfoBloc _infoBloc;
  late final WebViewController webController;
  bool _isPageLoading = true;

  @override
  void initState() {
    super.initState();
    _infoBloc = InfoBloc();
    _infoBloc.add(InfoTermAndConditionFetchingEvent(pageRole: widget.pageRole));

    webController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(primaryColor)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                if (mounted) {
                  setState(() {
                    _isPageLoading = true;
                  });
                }
              },
              onPageFinished: (String url) {
                if (mounted) {
                  setState(() {
                    _isPageLoading = false;
                  });
                }
              },
              onWebResourceError: (WebResourceError error) {
                if (mounted) {
                  setState(() {
                    _isPageLoading = false;
                  });
                }
              },
              onNavigationRequest: (NavigationRequest request) {
                return NavigationDecision.navigate;
              },
            ),
          );
  }

  @override
  void dispose() {
    _infoBloc.close();
    super.dispose();
  }

  String getTitle() {
    switch (widget.pageRole) {
      case '1':
        return 'About Us';
      case '2':
        return 'Terms & Conditions';
      case '3':
        return 'Privacy Policy';
      case '4':
        return 'Refund Policy';
      default:
        return 'Info';
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: InternetConnectionService().connectionStream,
      initialData: true, // Assume connected initially
      builder: (context, snapshot) {
        // Handle error state
        if (snapshot.hasError) {
          return const MySpace();
        }

        // Handle disconnected state
        if (snapshot.data == false) {
          return const MySpace();
        }

        // Handle loading state
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return BlocConsumer<InfoBloc, InfoState>(
          bloc: _infoBloc,
          listener: (context, state) {
            if (state is InfoTermAndConditionSuccessState) {
              final rawUrl = state.termAndConditionEntity.pageURL;
              if (rawUrl != null && rawUrl.isNotEmpty) {
                final uri = Uri.tryParse(rawUrl);
                if (uri != null && uri.hasScheme) {
                  webController.loadRequest(uri);
                }
              }
            }
          },
          builder: (context, state) {
            if (state is InfoLoadingState) {
              return Scaffold(
                appBar: customAppBar1(title: getTitle(), context: context),
                body: const Center(child: CircularProgressIndicator()),
              );
            } else if (state is InfoTermAndConditionSuccessState) {
              final blocSnapshot = state.termAndConditionEntity;
              return Scaffold(
                appBar: customAppBar1(
                  title: blocSnapshot.status == 1 ? getTitle() : '',
                  context: context,
                ),
                body:
                    blocSnapshot.status == 1
                        ? Stack(
                          children: [
                            WebViewWidget(controller: webController),
                            if (_isPageLoading)
                              const Center(child: CircularProgressIndicator()),
                          ],
                        )
                        : Center(
                          child: Text(
                            blocSnapshot.message?.toString() ??
                                'Failed to load content',
                          ),
                        ),
              );
            } else if (state is InfoTermAndConditionErrorState) {
              final error = state.error;
              return Scaffold(
                appBar: customAppBar1(title: getTitle(), context: context),
                body: Center(child: Text(error)),
              );
            }

            return const SizedBox();
          },
        );
      },
    );
  }
}
