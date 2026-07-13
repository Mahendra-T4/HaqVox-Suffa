import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/services/ads_service.dart';
import 'package:haqvox/app/src/home/view/home.dart';

abstract class HomeBuilder extends State<Home> {
  double? height;
  double? width;
  BannerAd? topBannerAd;
  BannerAd? bottomBannerAd;
  bool topBannerAdReady = false;
  bool bottomBannerAdReady = false;
  bool _isAdsInitialized = false;
  BannerAd? _persistentTopBannerAd;
  BannerAd? _persistentBottomBannerAd;

  @override
  void initState() {
    super.initState();
    _initializeAdsAsync();
  }

  @override
  void dispose() {
    _persistentTopBannerAd?.dispose();
    _persistentBottomBannerAd?.dispose();
    super.dispose();
  }

  void _loadPersistentBannerAds() {
    if (!_isAdsInitialized || !mounted) return;

    // Only create if not already created
    if (_persistentTopBannerAd == null) {
      final topAd = AdsService.instance.createBannerAd();
      _persistentTopBannerAd = topAd;
      topAd
          .load()
          .then((_) {
            if (!mounted) return;
            setState(() {
              topBannerAd = topAd;
              topBannerAdReady = true;
            });
          })
          .catchError((error) {
            debugPrint('Top banner ad failed to load: $error');
            topAd.dispose();
            if (mounted) {
              setState(() {
                topBannerAd = null;
                topBannerAdReady = false;
              });
            }
          });
    } else {
      setState(() {
        topBannerAd = _persistentTopBannerAd;
        topBannerAdReady = true;
      });
    }

    if (_persistentBottomBannerAd == null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        final bottomAd = AdsService.instance.createBannerAd();
        _persistentBottomBannerAd = bottomAd;
        bottomAd
            .load()
            .then((_) {
              if (!mounted) return;
              setState(() {
                bottomBannerAd = bottomAd;
                bottomBannerAdReady = true;
              });
            })
            .catchError((error) {
              debugPrint('Bottom banner ad failed to load: $error');
              bottomAd.dispose();
              if (mounted) {
                setState(() {
                  bottomBannerAd = null;
                  bottomBannerAdReady = false;
                });
              }
            });
      });
    } else {
      setState(() {
        bottomBannerAd = _persistentBottomBannerAd;
        bottomBannerAdReady = true;
      });
    }
  }

  Future<void> _initializeAdsAsync() async {
    if (!mounted) return;
    try {
      if (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) {
        await AdsService.instance.initialize();
        if (!mounted) return;
        await AdsService.instance.updateAdSize(context);
        if (mounted) {
          setState(() {
            _isAdsInitialized = true;
            topBannerAdReady = false;
            bottomBannerAdReady = false;
          });
          _loadPersistentBannerAds();
        }
      } else {
        debugPrint('Ads are only supported on mobile platforms');
        _updateAdsState(false);
      }
    } catch (e) {
      debugPrint('Failed to initialize ads: $e');
      _updateAdsState(false);
    }
  }

  void _updateAdsState(bool initialized) {
    if (!mounted) return;
    setState(() {
      _isAdsInitialized = initialized;
      topBannerAdReady = false;
      bottomBannerAdReady = false;
    });
  }

  final bannerList = [
    {
      'bgColor': 'lightPink',
      'color': 'darkPink',
      'image': 'assets/banner/banner_img1.png',
      'title': 'Get Audio Books',
      'detail': 'Lorem ipsum dolor sit amet, consectetur.',
    },
    {
      'bgColor': 'lightPink',
      'color': 'darkPink',
      'image': 'assets/banner/banner_img2.png',
      'title': 'Listening is a new',
      'detail': 'Lorem ipsum dolor sit amet, consectetur.',
    },
  ];

  getColor(String? colorName) {
    switch (colorName) {
      case 'lightPink':
        return const Color(0xffE1BEE7);
      case 'darkPink':
        return const Color(0xffAF8EB5);
      case 'darkPinkRed':
        return const Color(0xffAF8EB5);
      case 'purple':
        return const Color(0xffAF8EB5);
      case 'teal':
        return const Color(0xff8AACC8);
      case 'darkTeal':
        return const Color(0xff81B9BF);
      case 'lightGreen':
        return const Color(0xff97B498);
      case 'lightOrange':
        return const Color(0xffCBC693);
    }
  }

  banners() {
    return SizedBox(
      height: height! * 0.145,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: bannerList.length,
        itemBuilder: (context, index) {
          final item = bannerList[index];
          return Container(
            width: width! - 140,
            margin: EdgeInsets.fromLTRB(
              index == 0 ? fixPadding * 2.0 : fixPadding,
              0,
              index == bannerList.length - 1 ? fixPadding * 2.0 : 0,
              0,
            ),
            decoration: BoxDecoration(
              color: getColor(item['bgColor']),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: fixPadding,
                      vertical: fixPadding / 2,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title']!,
                          overflow: TextOverflow.ellipsis,
                          style: white18BoldTextStyle,
                        ),
                        Text(
                          item['detail']!,
                          overflow: TextOverflow.fade,
                          style: white12RegularTextStyle,
                        ),
                        heightSpace,
                        heightSpace,
                        InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () {
                            //   Navigator.push(
                            //   context,
                            //   PageTransition(
                            //     child: const GenersBooks(),
                            //     type: PageTransitionType.rightToLeft,

                            //   )
                            // );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: fixPadding,
                              vertical: fixPadding / 2,
                            ),
                            decoration: BoxDecoration(
                              color: getColor(item['color']),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              'Explore Now',
                              style: white12SemiBoldTextStyle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Image.asset(
                  item['image']!,
                  height: height! * 0.125,
                  width: width! * 0.195,
                  fit: BoxFit.cover,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget topAdsContainer() {
    final adSize = AdsService.instance.currentAdSize;

    if (!_isAdsInitialized || topBannerAd == null || !topBannerAdReady) {
      return const SizedBox.shrink();
    }

    return Container(
      width: adSize.width.toDouble(),
      height: adSize.height.toDouble(),
      margin: const EdgeInsets.symmetric(
        vertical: fixPadding,
        horizontal: fixPadding,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: AdWidget(key: ValueKey(topBannerAd), ad: topBannerAd!),
    );
  }

  Widget bottomAdsContainer() {
    final adSize = AdsService.instance.currentAdSize;

    if (!_isAdsInitialized || bottomBannerAd == null || !bottomBannerAdReady) {
      return const SizedBox.shrink();
    }

    return Container(
      width: adSize.width.toDouble(),
      height: adSize.height.toDouble(),
      margin: const EdgeInsets.symmetric(
        vertical: fixPadding,
        horizontal: fixPadding,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: AdWidget(key: ValueKey(bottomBannerAd), ad: bottomBannerAd!),
    );
  }
}
