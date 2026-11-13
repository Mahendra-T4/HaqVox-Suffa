import 'dart:convert';
import 'dart:developer';

import 'package:haqvox/app/config/environment.dart';
import 'package:haqvox/app/src/info/models/terms&condition_model.dart';
import 'package:http/http.dart' as http;

abstract class InfoRepository {
  static final client = http.Client();
  static final url = Uri.parse(Environment.baseUrl);

  static Future<TermAndConditionEntity> termCondition({
    required String pageRole,
  }) async {
    try {
      TermAndConditionEntity termAndConditionEntity = TermAndConditionEntity();
      final response = await client.post(
        url,
        body: {'activity': 'page-content', 'pageRole': pageRole},
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        termAndConditionEntity = TermAndConditionEntity.fromJson(jsonResponse);
        log('TermAndCondition Repo : ${termAndConditionEntity.message}');
        log('Page Content Response : $jsonResponse');
        return termAndConditionEntity;
      } else {
        log('TermAndCondition Repo : ${response.statusCode}');
        return TermAndConditionEntity(
          status: 0,
          message: 'Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      log('TermAndCondition Repo Error: $e');
      return TermAndConditionEntity(status: 0, message: 'Error: $e');
    }
  }

  // static Future<FAQEntity> fetchFAQ() async {
  //   try {
  //     final response = await client.post(url, body: {'activity': 'faq'});
  //     if (response.statusCode == 200) {
  //       final jsonResponse = jsonDecode(response.body);
  //       return FAQEntity.fromJson(jsonResponse);
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }
}
