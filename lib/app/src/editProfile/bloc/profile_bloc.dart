import 'dart:async';
import 'dart:io';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:haqvox/app/core/database/key.dart';
import 'package:haqvox/app/core/database/shared_prefs_config.dart';
import 'package:haqvox/app/core/database/user/hive_db.dart';
import 'package:haqvox/app/core/widgets/custom_snackbar.dart';
import 'package:haqvox/app/src/editProfile/model/edit_profile_details_entity.dart';
import 'package:haqvox/app/src/editProfile/model/profile_image_entity.dart';
import 'package:haqvox/app/src/editProfile/model/user.dart';
import 'package:haqvox/app/src/editProfile/repositories/profile_repo.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<EditUserProfileDetailsEvent>(_editUserProfileDetailsEvent);
    on<UpdateUserProfileImageEvent>(_updateUserProfileImageEvent);
    on<FetchUserProfileDetailsEvent>(_fetchUserProfileDetailsEvent);
  }

  Future<bool> _validateImage(File file) async {
    // Check file size (max 5MB)
    final fileSize = await file.length();
    if (fileSize > 5 * 1024 * 1024) {
      return false;
    }

    // Check file format
    final validFormats = ['.jpg', '.jpeg', '.png'];
    final extension = file.path.toLowerCase().split('.').last;
    return validFormats.contains('.$extension');
  }

  FutureOr<void> _editUserProfileDetailsEvent(
    EditUserProfileDetailsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoadingState());
    try {
      final updateProfile = await ProfileRepository.editProfileDetails(
        event.fName,
        event.lName,
        event.email,
        event.mobile,
        event.alternateMobile,
        event.dob,
        event.gender,
        event.uStep,
        event.context,
      );
      emit(
        ProfileEditUserDetailsLoadedSuccessState(editProfile: updateProfile),
      );
      CustomSnackBar.show(
        context: event.context,
        message: updateProfile.message.toString(),
        type:
            updateProfile.status == 1
                ? SnackBarType.success
                : SnackBarType.error,
      );
    } catch (e) {
      log('Edit Profile details Repo Error $e');
      emit(ProfileEditUserDetailsFailedErrorState(error: e.toString()));
    }
  }

  FutureOr<void> _updateUserProfileImageEvent(
    UpdateUserProfileImageEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoadingState());
    try {
      if (event.file == null) {
        throw Exception('No image file selected');
      }

      // Validate image
      final isValid = await _validateImage(event.file!);
      if (!isValid) {
        throw Exception(
          'Invalid image file. Please select a JPG, JPEG or PNG file under 5MB',
        );
      }

      // StorageConfig config = StorageConfig();

      // Clean up old profile image
      final oldImagePath = await HiveService.userImage();
      if (oldImagePath != null) {
        final oldFile = File(oldImagePath);
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      }

      final updateProfileImage = await ProfileRepository.editUserProfileImage(
        file: event.file!,
      );
      emit(
        UserProfileImageUpdateSuccessState(
          profileImageEntity: updateProfileImage,
        ),
      );

      // Show success message
      CustomSnackBar.show(
        context: event.context,
        message: updateProfileImage.message.toString(),
        type: SnackBarType.success,
      );

      // Save new image path
      await HiveService.setter(
        key: DBKeys.localImgKey,
        value: event.file!.path,
      );
    } catch (e) {
      log('Update User Profile Image Repo Error $e');
      emit(UserProfileUpdateFailedErrorState(error: e.toString()));
      CustomSnackBar.show(
        context: event.context,
        message: e.toString(),
        type: SnackBarType.error,
      );
    }
  }

  FutureOr<void> _fetchUserProfileDetailsEvent(
    FetchUserProfileDetailsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoadingState());
    try {
      final user = User();
      emit(ProfileUserDetailsLoadedSuccessState(user: user));
    } catch (e) {
      log('ProfileBlocError: $e');
      emit(ProfileUserDetailsFailedToLoadErrorState(error: e.toString()));
    }
  }
}
