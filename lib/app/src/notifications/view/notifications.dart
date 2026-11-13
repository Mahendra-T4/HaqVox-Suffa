// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/core/widgets/appbar.dart';
import 'package:haqvox/app/services/connectivity.dart';
import 'package:haqvox/app/src/global/bloc/global_bloc.dart';
import 'package:haqvox/app/src/myspace/view/offline_download.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});
  static const String routeName = '/notifications';

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  late final GlobalBloc _globalBloc;

  @override
  void initState() {
    super.initState();
    _globalBloc = GlobalBloc();
    _globalBloc.add(NotificationFetchingEvent());
  }

  @override
  void dispose() {
    _globalBloc.close();
    super.dispose();
  }

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
          backgroundColor: Colors.grey[50],
          appBar: customAppBar1(title: 'Notifications', context: context),
          body: notifications(),
        );
      },
    );
  }

  Widget notificationsEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.notifications_off_outlined,
            color: Colors.grey,
            size: 80,
          ),
          heightSpace,
          Text(
            'No New Notifications',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget notifications() {
    return BlocBuilder(
      bloc: _globalBloc,
      builder: (context, state) {
        switch (state.runtimeType) {
          case const (GlobalLoadingState):
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            );
          case const (GlobalNotificationFetchingSuccessState):
            final blocSnapshot =
                (state as GlobalNotificationFetchingSuccessState)
                    .notificationEntity;
            return blocSnapshot.status == 1
                ? ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: blocSnapshot.record?.length ?? 0,
                  itemBuilder: (context, index) {
                    final notification = blocSnapshot.record![index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            // Handle notification tap
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha:0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.notifications_outlined,
                                    color: primaryColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        notification.notMsg.toString(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        notification.notDate.toString(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                )
                : notificationsEmpty();
          case const (GlobalNotificationFetchingFailedErrorState):
            final error =
                (state as GlobalNotificationFetchingFailedErrorState).error;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Something went wrong',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () {
                      _globalBloc.add(NotificationFetchingEvent());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}
