import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:haqvox/app/config/environment.dart';
import 'package:haqvox/app/core/database/key.dart';
import 'package:haqvox/app/core/database/shared_prefs_config.dart';
import 'package:haqvox/app/core/database/user/hive_db.dart';
import 'package:haqvox/app/core/widgets/custom_snackbar.dart';
import 'package:haqvox/app/src/editProfile/pages/edit_profile_verification.dart';
import 'package:haqvox/app/src/editProfile/model/edit_profile_details_entity.dart';
import 'package:haqvox/app/src/editProfile/model/edit_profile_verification_params.dart';
import 'package:haqvox/app/src/editProfile/model/profile_image_entity.dart';
import 'package:http/http.dart' as http;

abstract class ProfileRepository {
  static final client = http.Client();
  static final url = Uri.parse(Environment.baseUrl);
  // static final StorageConfig _config = StorageConfig();

  static Future<EditProfileEntity> editProfileDetails(
    String fName,
    String lName,
    String email,
    String mobile,
    String? alternateMobile,
    String dob,
    String gender,
    String uStep,
    BuildContext context,
  ) async {
    try {
      // final userKey = await _config.getUserData(key: DBKeys.userKey);
      EditProfileEntity editProfileEntity = EditProfileEntity();

      Map<String, String> body = {
        'activity': 'account-settings',
        'uFirstName': fName.trim(),
        'uLastName': lName.trim(),
        'uEmail': email.trim(),
        'uMobile': mobile.trim(),
        'uAlternateNumber': (alternateMobile?.trim() ?? ''),
        'uDOB': dob.trim(),
        'uGender': gender,
        'uStep': uStep,
        'userKey': HiveService.getUserId().toString(),
      };
      final response = await client.post(url, body: body);
      log(body.toString());
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        // _config.clearAllData();
        editProfileEntity = EditProfileEntity.fromJson(jsonResponse);
        log(response.body);
        if (editProfileEntity.status == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => EditProfileVerification(
                    editProfileParams: EditProfileParams(
                      uFirstName: fName,
                      uLastName: lName,
                      uEmail: email,
                      uMobile: mobile,
                      uAlternateNumber: alternateMobile,
                      uDOB: dob,
                      uGender: gender,
                    ),
                  ),
            ),
          );
          CustomSnackBar.show(
            context: context,
            message: editProfileEntity.message.toString(),
            type: SnackBarType.success,
          );
        } else {
          CustomSnackBar.show(
            context: context,
            message: editProfileEntity.message.toString(),
            type: SnackBarType.error,
          );
        }
        return EditProfileEntity.fromJson(jsonResponse);
      } else {
        log('Failed to edit and load user profile data');
        return EditProfileEntity(
          status: response.statusCode,
          message: 'Failed to edit and load user profile data',
        );
      }
    } catch (e) {
      log('Edit Profile Details Repo Error $e');
      return EditProfileEntity(status: 500, message: e.toString());
    }
  }

  static Future<ProfileImageEntity> editUserProfileImage({
    required File file,
  }) async {
    try {
      // final userKey = await _config.getUserData(key: DBKeys.userKey);
      final request = http.MultipartRequest('POST', url);

      request.fields.addAll({
        'activity': 'update-profile-image',
        'userKey': HiveService.getUserId().toString(),
      });

      if (file != '') {
        final streamFile = http.ByteStream(file.openRead());
        final length = await file.length();

        final multiPartFile = http.MultipartFile(
          'uProfile',
          streamFile,
          length,
          filename: file.path.split('/').last,
        );

        request.files.add(multiPartFile);
      }

      final streamResponse = await request.send();
      final response = await http.Response.fromStream(streamResponse);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        ProfileImageEntity profileImageEntity = ProfileImageEntity.fromJson(
          jsonResponse,
        );
        if (profileImageEntity.status == 1) {
          HiveService.setter(key: DBKeys.localImgKey, value: file.toString());
        }
        log(response.body);
        return ProfileImageEntity.fromJson(jsonResponse);
      } else {
        log('Failed to update user profile image');
        return ProfileImageEntity(
          status: response.statusCode,
          message: 'Failed to update user profile image',
        );
      }
    } catch (e) {
      log('Profile Image Update Repo Error $e');
      return ProfileImageEntity(status: 500, message: e.toString());
    }
  }
}
