part of 'info_bloc.dart';


sealed class InfoState {}

final class InfoInitial extends InfoState {}


final class InfoLoadingState extends InfoState {}

final class InfoTermAndConditionSuccessState extends InfoState {
  final TermAndConditionEntity termAndConditionEntity;

  InfoTermAndConditionSuccessState({required this.termAndConditionEntity});
}

final class InfoTermAndConditionErrorState extends InfoState {
  final String error;

  InfoTermAndConditionErrorState({required this.error});
}

