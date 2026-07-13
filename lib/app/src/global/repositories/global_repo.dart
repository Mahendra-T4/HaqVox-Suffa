import 'dart:convert';
import 'dart:developer';

import 'package:haqvox/app/config/environment.dart';
import 'package:haqvox/app/core/database/key.dart';
import 'package:haqvox/app/core/database/shared_prefs_config.dart';
import 'package:haqvox/app/core/database/user/hive_db.dart';
import 'package:haqvox/app/src/notifications/models/notification_entity.dart';
import 'package:haqvox/app/src/subscription/models/subscription_plan_entity.dart';
import 'package:http/http.dart' as http;

abstract class GlobalRepository {
  static final client = http.Client();
  // static final StorageConfig _config = StorageConfig();
  static final url = Uri.parse(Environment.baseUrl);

  static Future<SubscriptionsPlanEntity> subscriptionPlan() async {
    try {
      // final userKey = await _config.getUserData(key: DBKeys.userKey);
      final response = await client.post(
        url,
        body: {'activity': 'subscription-plan'},
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print(response.body);
        return SubscriptionsPlanEntity.fromJson(jsonResponse);
      } else {
        log('Ops! Failed to load Subscription Plan');
        return SubscriptionsPlanEntity(
          status: response.statusCode,
          message: 'Ops! Failed to load Subscription Plan',
        );
      }
    } catch (e) {
      log('Subscription Plan Repo Error', error: e);
      return SubscriptionsPlanEntity(status: 500, message: e.toString());
    }
  }

  static Future<NotificationEntity> notifications() async {
    try {
      // final userKey = await _config.getUserData(key: DBKeys.userKey);
      final response = await client.post(
        url,
        body: {
          'activity': 'notification',
          'userKey': HiveService.getUserId().toString(),
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print(response.body);
        return NotificationEntity.fromJson(jsonResponse);
      } else {
        log('Ops! Failed to load Notifications');
        return NotificationEntity(
          status: response.statusCode,
          message: 'Ops! Failed to load Notifications',
        );
      }
    } catch (e) {
      log('Subscription Plan Repo Error', error: e);
      return NotificationEntity(status: 500, message: e.toString());
    }
  }
}
