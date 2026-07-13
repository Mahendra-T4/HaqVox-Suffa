import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:haqvox/app/config/environment.dart';
import 'package:haqvox/app/src/home/models/home_entity.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

abstract class HomeRepository {
  static final url = Uri.parse(Environment.baseUrl);
  static const String _cacheBox = 'homeApiCacheBox';
  static const String _cacheKey = 'homeApiData';
  static const Duration _cacheDuration = Duration(hours: 6);

  static Future<HomeEntity> getHomeData() async {
    HomeEntity homeEntity = HomeEntity();
    try {
      final box = await Hive.openBox(_cacheBox);
      final cached = box.get(_cacheKey);
      if (cached != null) {
        final cachedMap = jsonDecode(cached['data']) as Map<String, dynamic>;
        final cachedTime = DateTime.parse(cached['timestamp']);
        if (DateTime.now().difference(cachedTime) < _cacheDuration) {
          log('Loaded HomeEntity from Hive cache');
          return HomeEntity.fromJson(cachedMap);
        }
      }

      final response = await http.post(url, body: {'activity': 'home'});
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        homeEntity = HomeEntity.fromJson(jsonResponse);
        log('API response: ${response.body}');
        log('API message: ${homeEntity.message}');
        // Cache the data with timestamp
        await box.put(_cacheKey, {
          'data': jsonEncode(jsonResponse),
          'timestamp': DateTime.now().toIso8601String(),
        });
      } else {
        log('API Error: ${response.statusCode}');
        // If API fails, try to return stale cache if available
        if (cached != null) {
          log('Returning stale cache due to API error');
          homeEntity = HomeEntity.fromJson(jsonDecode(cached['data']));
        }
      }
    } on SocketException {
      log('No Internet. Trying to load from Hive cache.');
      final box = await Hive.openBox(_cacheBox);
      final cached = box.get(_cacheKey);
      if (cached != null) {
        log('Loaded HomeEntity from Hive cache (offline)');
        homeEntity = HomeEntity.fromJson(jsonDecode(cached['data']));
      }
    } catch (e, st) {
      log('Home Contents Error from Repo : $e\n$st');
    }
    return homeEntity;
  }
}
