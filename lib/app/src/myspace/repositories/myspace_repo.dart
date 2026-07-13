import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:haqvox/app/config/environment.dart';
import 'package:haqvox/app/core/database/key.dart';
import 'package:haqvox/app/core/database/shared_prefs_config.dart';
import 'package:haqvox/app/core/database/user/hive_db.dart';
import 'package:haqvox/app/core/widgets/custom_snackbar.dart';
import 'package:haqvox/app/src/myspace/models/add_audio_on_myspace.dart';
import 'package:haqvox/app/src/myspace/models/delete_myspace_entity.dart';
import 'package:haqvox/app/src/myspace/models/myspace_list_entity.dart';
import 'package:http/http.dart' as http;

abstract class MySpaceRepository {
  static final client = http.Client();
  // static StorageConfig config = StorageConfig();
  static final url = Uri.parse(Environment.baseUrl);
  static Future<AddOnMySpaceEntity> addAudioOnMySpace(
    String audioSlug,
    String mySpaceType,
    BuildContext context,
  ) async {
    try {
      AddOnMySpaceEntity addOnMySpaceEntity = AddOnMySpaceEntity();
      // final userKey = await config.getUserData(key: DBKeys.userKey);
      final response = await client.post(
        url,
        body: {
          'activity': 'add-my-space',
          'userKey': HiveService.getUserId().toString(),
          'audioSlug': audioSlug,
          'mySpaceType': mySpaceType,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        addOnMySpaceEntity = AddOnMySpaceEntity.fromJson(jsonResponse);
        log(response.body);
        log('Audio added to my space Response: ${addOnMySpaceEntity.message}');
        return AddOnMySpaceEntity.fromJson(jsonResponse);
      } else {
        log('Failed to add audio to my space');
        return AddOnMySpaceEntity(
          status: 0,
          message: 'Failed to add audio to my space',
        );
      }
    } catch (e) {
      log('AddMySpaceError From Repo: $e');
      return AddOnMySpaceEntity(status: 500, message: e.toString());
    }
  }

  static Future<MySpaceListEntity> mySpaceList(
    String mySpaceType,
    BuildContext context,
  ) async {
    try {
      // final userKey = await config.getUserData(key: DBKeys.userKey);
      final response = await client.post(
        url,
        body: {
          'activity': 'my-space',
          'userKey': HiveService.getUserId().toString(),
          'mySpaceType': mySpaceType,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        log(response.body);

        return MySpaceListEntity.fromJson(jsonResponse);
      } else {
        log('Failed to load myspace list');
        return MySpaceListEntity(
          status: 0,
          message: 'Failed to load myspace list',
        );
      }
    } catch (e) {
      log('MySpace List Error From Repo: $e');
      return MySpaceListEntity(status: 500, message: e.toString());
    }
  }

  static Future<DeleteMySpaceEntity> deleteMySpace(
    String mySpaceKey,
    String mySpaceType,
    BuildContext context,
  ) async {
    try {
      DeleteMySpaceEntity deleteMySpaceEntity = DeleteMySpaceEntity();
      // final userKey = await config.getUserData(key: DBKeys.userKey);
      final response = await client.post(
        url,
        body: {
          'activity': 'delete-my-space',
          'userKey': HiveService.getUserId().toString(),
          'mySpaceKey': mySpaceKey,
          'mySpaceType': mySpaceType,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        deleteMySpaceEntity = DeleteMySpaceEntity.fromJson(jsonResponse);
        log(response.body);
        if (deleteMySpaceEntity.status == 1) {
          CustomSnackBar.show(
            context: context,
            message: deleteMySpaceEntity.message.toString(),
            type: SnackBarType.success,
          );
        } else {
          CustomSnackBar.show(
            context: context,
            message: deleteMySpaceEntity.message.toString(),
            type: SnackBarType.error,
          );
        }
        return DeleteMySpaceEntity.fromJson(jsonResponse);
      } else {
        log('Failed to delete data from  myspace list');
        return DeleteMySpaceEntity(
          status: 0,
          message: 'Failed to delete data from  myspace list',
        );
      }
    } catch (e) {
      log('Delete MySpace Error From Repo: $e');
      return DeleteMySpaceEntity(status: 500, message: e.toString());
    }
  }
}
