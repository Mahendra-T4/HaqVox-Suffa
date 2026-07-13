part of 'my_space_bloc.dart';

sealed class MySpaceEvent {}

final class AddOnMySpaceEvent extends MySpaceEvent {
  final String audioSlug;
  final String mySpaceType;
  final BuildContext context;

  AddOnMySpaceEvent(
      {required this.audioSlug,
      required this.mySpaceType,
      required this.context});
}

final class FetchMySpaceListFromServerEvent extends MySpaceEvent {
  final String mySpaceType;
  final BuildContext context;
  FetchMySpaceListFromServerEvent(
      {required this.mySpaceType, required this.context});
}

final class DeleteMySpaceRecordsFromServerEvent extends MySpaceEvent {
  final String mySpaceKey;
  final String mySpaceType;
  final BuildContext context;

  DeleteMySpaceRecordsFromServerEvent(
      {required this.mySpaceKey,
      required this.mySpaceType,
      required this.context});
}
