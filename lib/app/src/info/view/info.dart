import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/core/widgets/appbar.dart';
import 'package:haqvox/app/services/connectivity.dart';
import 'package:haqvox/app/src/info/bloc/info_bloc.dart';
import 'package:haqvox/app/src/myspace/view/myspace.dart';

class InfoPage extends StatefulWidget {
  static const String routeName = '/terms';
  final String pageRole;

  const InfoPage({super.key, required this.pageRole});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  late InfoBloc _infoBloc;
  @override
  void initState() {
    _infoBloc = InfoBloc();
    _infoBloc.add(InfoTermAndConditionFetchingEvent(pageRole: widget.pageRole));
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
        return BlocBuilder(
          bloc: _infoBloc,
          builder: (context, state) {
            switch (state.runtimeType) {
              case const (InfoLoadingState):
                return const Center(child: CircularProgressIndicator());
              case const (InfoTermAndConditionSuccessState):
                final blocSnapshot =
                    (state as InfoTermAndConditionSuccessState)
                        .termAndConditionEntity;
                return Scaffold(
                  appBar: customAppBar1(
                    title:
                        blocSnapshot.status == 1
                            ? blocSnapshot.record!.pageHeading.toString()
                            : '',
                    context: context,
                  ),
                  body:
                      blocSnapshot.status == 1
                          ? SingleChildScrollView(
                            child: _buildSection(
                              content:
                                  blocSnapshot.record!.pageDescription
                                      .toString(),
                            ),
                          )
                          : Center(
                            child: Text(blocSnapshot.message.toString()),
                          ),
                );
              case const (InfoTermAndConditionErrorState):
                final error = (state as InfoTermAndConditionErrorState).error;
                return Center(child: Text(error));
              default:
                return const SizedBox();
            }
          },
        );
      },
    );
  }

  Widget _buildSection({required String content}) {
    return Padding(
      padding: const EdgeInsets.only(
        left: fixPadding * 2.0,
        right: fixPadding * 2.0,
        top: fixPadding * 2.0,
        bottom: fixPadding * 9.0,
      ),
      child: Text(content, style: grey14RegularTextStyle),
    );
  }

  // Unused UI builder methods - kept for potential future use
  // Widget _buildDivider() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: fixPadding),
  //     child: Divider(color: greyColor.withOpacity(0.3), thickness: 1),
  //   );
  // }
  //
  // Widget _buildLastUpdated() {
  //   return Padding(
  //     padding: const EdgeInsets.only(top: fixPadding * 2.0),
  //     child: Text('Last updated: May 8, 2025', style: grey12RegularTextStyle),
  //   );
  // }
}
