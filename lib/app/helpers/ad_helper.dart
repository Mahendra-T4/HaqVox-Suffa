import 'dart:io';
import 'package:flutter/foundation.dart';

class AdHelper {
  static String get bannerAdUnitId {
    if (kDebugMode) {
      // Test ad units from https://developers.google.com/admob/android/test-ads
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2934735716';
      }
    } else {
      // Production ad units
      if (Platform.isAndroid) {
        return 'ca-app-pub-5171681551474171/3040881671';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-5171681551474171/3040881671';
      }
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get interstitialAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/1033173712';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/4411151713';
      }
    } else {
      if (Platform.isAndroid) {
        return 'ca-app-pub-5171681551474171/XXXXXXXXXXXXX';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-5171681551474171/XXXXXXXXXXXXX';
      }
    }
    throw UnsupportedError('Unsupported platform');
  }
}
