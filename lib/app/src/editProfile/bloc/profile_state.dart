part of 'profile_bloc.dart';

sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class ProfileLoadingState extends ProfileState {}

final class ProfileEditUserDetailsLoadedSuccessState extends ProfileState {
  final EditProfileEntity editProfile;

  ProfileEditUserDetailsLoadedSuccessState({required this.editProfile});
}

final class ProfileEditUserDetailsFailedErrorState extends ProfileState {
  final String error;

  ProfileEditUserDetailsFailedErrorState({required this.error});
}

final class UserProfileImageUpdateSuccessState extends ProfileState {
  final ProfileImageEntity profileImageEntity;

  UserProfileImageUpdateSuccessState({required this.profileImageEntity});
}

final class UserProfileUpdateFailedErrorState extends ProfileState {
  final String error;

  UserProfileUpdateFailedErrorState({required this.error});
}




final class ProfileUserDetailsLoadedSuccessState extends ProfileState{
  final User user;

  ProfileUserDetailsLoadedSuccessState({required this.user});
}


final class ProfileUserDetailsFailedToLoadErrorState extends ProfileState{
  final String error;

  ProfileUserDetailsFailedToLoadErrorState({required this.error});
}
