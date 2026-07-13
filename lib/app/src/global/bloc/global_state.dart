part of 'global_bloc.dart';


sealed class GlobalState {}

sealed class GlobalActionState extends GlobalState {}

final class GlobalInitial extends GlobalState {}

final class GlobalLoadingState extends GlobalState {}

final class GlobalSubscriptionPlanLoadedSuccessState extends GlobalState {
  final SubscriptionsPlanEntity subscriptionsPlanEntity;

  GlobalSubscriptionPlanLoadedSuccessState(
      {required this.subscriptionsPlanEntity});
}

final class GlobalSubscriptionPlanFailedErrorState extends GlobalState {
  final String error;

  GlobalSubscriptionPlanFailedErrorState({required this.error});
}

final class GlobalNotificationFetchingSuccessState extends GlobalState {
  final NotificationEntity notificationEntity;

  GlobalNotificationFetchingSuccessState({required this.notificationEntity});
}

final class GlobalNotificationFetchingFailedErrorState extends GlobalState {
  final String error;

  GlobalNotificationFetchingFailedErrorState({required this.error});
}

final class NavigateToNotificationDetailsPageActionState extends GlobalActionState{}
