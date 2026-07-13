import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:haqvox/app/helpers/ad_helper.dart';

class AdsService {
  static final AdsService instance = AdsService._internal();
  factory AdsService() => instance;
  AdsService._internal();

  bool _isInitialized = false;
  AdSize _currentAdSize = AdSize.banner;

  bool get isInitialized => _isInitialized;
  AdSize get currentAdSize => _currentAdSize;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await MobileAds.instance.initialize().then((initStatus) {
        initStatus.adapterStatuses.forEach((key, value) {
          debugPrint('Adapter status for $key: ${value.description}');
        });
      });

      debugPrint('Mobile Ads SDK initialized successfully');
      _isInitialized = true;

      if (kDebugMode) {
        final deviceIds = ['kGADSimulatorID'];
        if (defaultTargetPlatform == TargetPlatform.android) {
          deviceIds.add(
            '98FC0E17C64F0B5FDA3221453C34F06A',
          ); // Example test device
        }
        await MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(testDeviceIds: deviceIds),
        );
        debugPrint('Test ads configuration updated');
      }
    } catch (e) {
      debugPrint('Error initializing Mobile Ads: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  Future<void> updateAdSize(BuildContext context) async {
    if (!_isInitialized) return;

    try {
      final mediaQuery = MediaQuery.of(context);
      final screenWidth = mediaQuery.size.width;

      // Try to use adaptive banner size first
      if (defaultTargetPlatform == TargetPlatform.android) {
        final width = screenWidth.truncate();
        try {
          final adaptiveSize =
              await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
                width,
              );
          if (adaptiveSize != null) {
            _currentAdSize = adaptiveSize;
            debugPrint(
              'Using adaptive banner size: ${adaptiveSize.width}x${adaptiveSize.height}',
            );
            return;
          }
        } catch (e) {
          debugPrint('Error getting adaptive banner size: $e');
        }
      }

      // Fall back to standard banner size if adaptive size fails
      _currentAdSize = AdSize.banner;
      debugPrint(
        'Using standard banner size: ${AdSize.banner.width}x${AdSize.banner.height}',
      );
    } catch (e) {
      debugPrint('Error updating ad size: $e');
      _currentAdSize = AdSize.banner;
    }
  }

  BannerAd createBannerAd() {
    if (!_isInitialized) {
      throw StateError('AdsService must be initialized before creating ads');
    }

    return BannerAd(
      size: _currentAdSize,
      adUnitId: AdHelper.bannerAdUnitId,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint(
            'Banner Ad loaded successfully: ${ad.responseInfo?.responseId}',
          );
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner Ad failed to load: ${error.message}');
          debugPrint('Error code: ${error.code}, domain: ${error.domain}');
          ad.dispose();
        },
        onAdOpened: (ad) => debugPrint('Banner Ad opened'),
        onAdClosed: (ad) => debugPrint('Banner Ad closed'),
        onAdImpression: (ad) => debugPrint('Banner Ad impression recorded'),
      ),
      request: const AdRequest(),
    );
  }
}
