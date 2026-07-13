import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:audio_service/audio_service.dart';
import 'package:haqvox/app/assets/assets.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/services/connectivity.dart';
import 'package:haqvox/app/src/Player/services/audio_player_handler.dart';
import 'package:haqvox/app/src/home/view/home.dart';
import 'package:haqvox/app/src/myspace/view/myspace.dart';
import 'package:haqvox/app/src/myspace/view/offline_download.dart';
import 'package:haqvox/app/src/profile/profile.dart';
import 'package:haqvox/app/src/searchResult/search_result.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});
  static const String routeName = '/bottomBar';

  @override
  _BottomBarState createState() => _BottomBarState();
}

int currentIndex = 0;

class _BottomBarState extends State<BottomBar> {
  DateTime? currentBackPressTime;
  late AudioHandler audioHandler;

  @override
  void initState() {
    super.initState();
    _initAudioHandler();
  }

  Future<void> _initAudioHandler() async {
    try {
      audioHandler = await AudioService.init(
        builder: () => AudioPlayerHandler(),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.example.haqvox.audio',
          androidNotificationChannelName: 'Audio playback',
          androidNotificationIcon: 'drawable/notification_icon',
          androidShowNotificationBadge: true,
          notificationColor: Colors.blue,
          androidStopForegroundOnPause: false,
        ),
      );
      if (mounted) setState(() {});
    } catch (e) {
      print('Error initializing audio handler: $e');
    }
  }

  void changeIndex(index) {
    setState(() {
      currentIndex = index;
    });
  }

  final List<Widget> _pages = [Home(), SearchResult(), MySpace(), Profile()];
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
          body: Column(children: [Expanded(child: _pages[currentIndex])]),
          bottomNavigationBar: NavigationBarTheme(
            data: NavigationBarThemeData(
              labelTextStyle: MaterialStateProperty.all(
                const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BottomNavigationBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: primaryColor.withOpacity(.8),
                  unselectedItemColor: Colors.grey.shade400,
                  selectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                  currentIndex: currentIndex,
                  onTap: (index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  items: [
                    _buildNavItem(FontAwesomeIcons.house, 'Home'),
                    _buildNavItem(FontAwesomeIcons.search, 'Search'),
                    _buildNavItemImg(Assets.bookIconImage, 'MySpace'),
                    _buildNavItemImg(Assets.settingsIconImage, 'Settings'),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              currentIndex == _getIndex(label)
                  ? Colors.blue.withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: currentIndex == _getIndex(label) ? 23 : 20),
      ),
      label: label,
    );
  }

  BottomNavigationBarItem _buildNavItemImg(String imgPath, String label) {
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              currentIndex == _getIndex(label)
                  ? Colors.blue.withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Image.asset(
          imgPath,
          color: currentIndex == _getIndex(label) ? primaryColor : Colors.grey,
          scale: currentIndex == _getIndex(label) ? 18 : 20,
        ),
      ),
      label: label,
    );
  }

  int _getIndex(String label) {
    switch (label) {
      case 'Home':
        return 0;
      case 'Search':
        return 1;
      case 'MySpace':
        return 2;
      case 'Settings':
        return 3;
      default:
        return 0;
    }
  }

  bool onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
        msg: "Press Again To Exit App",
        backgroundColor: blackColor,
        textColor: whiteColor,
      );
      return false;
    }
    return true;
  }
}
