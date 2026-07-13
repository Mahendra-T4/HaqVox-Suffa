part of 'info_bloc.dart';

sealed class InfoEvent {}

final class InfoTermAndConditionFetchingEvent extends InfoEvent {
  final String pageRole;

  InfoTermAndConditionFetchingEvent({required this.pageRole});
}
