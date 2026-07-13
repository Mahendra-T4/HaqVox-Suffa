part of 'profile_bloc.dart';

sealed class ProfileEvent {}

final class EditUserProfileDetailsEvent extends ProfileEvent {
  final String fName;
  final String lName;
  final String email;
  final String mobile;
  final String alternateMobile;
  final String dob;
  final String gender;
  final String uStep;

  final BuildContext context;

  EditUserProfileDetailsEvent(
      {required this.fName,
      required this.lName,
      required this.email,
      required this.mobile,
      required this.alternateMobile,
      required this.dob,
      required this.gender,
      required this.uStep,
      required this.context});
}

final class UpdateUserProfileImageEvent extends ProfileEvent {
  final File? file;
  final BuildContext context;

  UpdateUserProfileImageEvent({required this.file, required this.context});
}

final class FetchUserProfileDetailsEvent extends ProfileEvent {}
