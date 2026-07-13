part of 'global_bloc.dart';

@immutable
sealed class GlobalEvent {}


final class NotificationFetchingEvent extends GlobalEvent{}


final class SubscriptionPlanFetchingEvent extends GlobalEvent{}
