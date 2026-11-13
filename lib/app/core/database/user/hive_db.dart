import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:haqvox/app/core/database/key.dart';
import 'package:haqvox/app/src/Player/services/music_player_service.dart';
import 'package:haqvox/app/src/splash.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

class HiveService {
  static const String userBox = 'userBox';
  static Box<dynamic>? _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(userBox);
  }

  static Future<void> setter({
    required String key,
    required dynamic value,
  }) async {
    await _box?.put(key, value);
  }

  /// Delete a value by key
  static Future<void> delete(String key) async {
    await _box?.delete(key);
  }

  static dynamic getter({required String key}) {
    return _box?.get(key);
  }

  // /// Check if user is logged in
  // static bool get isLoggedIn {
  //   final value = getter(key: DBKeys.kIsLoggedIn) ?? false;
  //   print('DEBUG: HiveService.isLoggedIn = $value');
  //   print('DEBUG: Hive box contents: ${_box?.toMap()}');
  //   return value;
  // }

  /// Set user as logged in
  static Future<void> setLoggedIn(bool value) async {
    await setter(key: DBKeys.isLoggedIn, value: value);
  }

  /// Get user ID
  static String? getUserId() => getter(key: DBKeys.userKey);

  /// Get user Email

  static String? getUserEmail() => getter(key: DBKeys.uEmail);

  /// Get user name
  static String? getFName() => getter(key: DBKeys.uFirstName);

  /// Get user last name
  static String? getLName() => getter(key: DBKeys.uLastName);

  /// Get user mobile number
  static String? getMobile() => getter(key: DBKeys.uMobile);

  static bool isLoggedInUser() => getter(key: DBKeys.isLoggedIn) ?? false;

  ///Get alternate mobile number
  static String? getAlternateMobile() => getter(key: DBKeys.uAlternateNumber);

  /// Get user email
  static String? getDOB() => getter(key: DBKeys.uDOB);

  /// Get user role
  static int? getSubscription() => getter(key: DBKeys.uSubscriptionKey);

  static String? userGender() => getter(key: DBKeys.uGender);

  static String? userImage() => getter(key: DBKeys.imageKey);

  static String? getUserLocalImage() => getter(key: DBKeys.localImgKey);

  // static String? getUserProfileImage() => getter(key: DBKeys.profileImageKey);

  static Future<void> logout(BuildContext context) async {
    if (GetIt.I.isRegistered<MusicPlayerService>()) {
      await GetIt.I<MusicPlayerService>().clearQueue();
    }

    // Clear all user data
    await _box?.clear();

    // Re-initialize the box
    await _box?.close();
    _box = await Hive.openBox(userBox);

    // Set logged in to false
    await setLoggedIn(false);

    // Navigate to login
    context.goNamed(Splash.routeName);
  }

  // /// Clear all data
  // static Future<void> clearAll() async {
  //   await _box?.clear();
  // }
}
