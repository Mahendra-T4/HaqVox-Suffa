import 'dart:async';
import 'package:flutter/material.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/core/database/user/hive_db.dart';
import 'package:haqvox/app/core/widgets/appbar.dart';
import 'package:haqvox/app/services/connectivity.dart';
import 'package:haqvox/app/src/downloads/services/download_manager.dart';
import 'package:haqvox/app/src/myspace/bloc/my_space_bloc.dart';
import 'package:haqvox/app/src/myspace/view/offline_download.dart';
import 'package:haqvox/app/src/myspace/view/widgets/downloads_tab.dart';
import 'package:haqvox/app/src/myspace/view/widgets/myspace_list_tab.dart';

class MySpace extends StatefulWidget {
  const MySpace({super.key});
  static const String routeName = '/myspace';

  @override
  State<MySpace> createState() => _MySpaceState();
}

class _MySpaceState extends State<MySpace> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final MySpaceBloc _mySpaceBloc;

  // bool isInternetConnected = false;
  // String? uKey;
  Timer? _updateTimer;
  Timer? _timer;
  bool _disposed = false;
  StreamSubscription? _connectivitySubscription;

  Future<void> initUser() async {
    if (_disposed) return;
    try {
      // Only fetch data if we have a valid user key and the widget is still mounted
      if (HiveService.getUserId() != null && !_disposed) {
        _mySpaceBloc.add(
          FetchMySpaceListFromServerEvent(
            mySpaceType: 'bookmarks',
            context: context,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error getting user data: $e');
    }
  }

  clearAllDownloads() async {
    final DownloadManager _downloadManager = DownloadManager();
    _timer = Timer.periodic(Duration(seconds: 3), (timer) async {
      if (HiveService.getUserId() == '') {
        await _downloadManager.deleteAllDownloads();
        // setState(() {});
      }
    });
    // await _downloadManager.deleteAllDownloads();
    // setState(() {});
  }


  @override
  void initState() {
    super.initState();
    _disposed = false;

    _tabController = TabController(length: 3, vsync: this);
    _mySpaceBloc = MySpaceBloc();
    clearAllDownloads();

    // Periodic data refresh every 30 seconds
    _updateTimer = Timer.periodic(
      const Duration(seconds: 30),
      (Timer t) => initUser(),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _updateTimer?.cancel();
    _connectivitySubscription?.cancel();
    _tabController.dispose();
    // _mySpaceBloc.close();
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
          appBar: customAppBar(title: 'MySpace', context: context),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 64),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey,
                        indicatorSize: TabBarIndicatorSize.tab,
                        tabAlignment: TabAlignment.start,
                        dividerColor: Colors.transparent,
                        isScrollable: true,
                        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                        indicator: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryColor, primaryColor],
                          ),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        tabs: [
                          _buildTab(Icons.bookmark, 'Bookmarks'),
                          _buildTab(Icons.download, 'Downloads'),
                          _buildTab(Icons.history, 'History'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          HiveService.getUserId() != null
                              ? MySpaceListTab(mySpaceType: '2')
                              : const Center(
                                child: Text(
                                  'Please log in to view your space',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                          const DownloadsTab(),
                          HiveService.getUserId() != null
                              ? MySpaceListTab(mySpaceType: '1')
                              : const Center(
                                child: Text(
                                  'Please log in to view your space',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // const Positioned(
              //   left: 0,
              //   right: 0,
              //   bottom: 0,
              //   child: OfflineMiniPlayer(),
              // ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTab(IconData icon, String label) {
    return Tab(
      height: 45,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        constraints: const BoxConstraints(minWidth: 90),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
