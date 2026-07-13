import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:haqvox/app/src/global/repositories/global_repo.dart';
import 'package:haqvox/app/src/notifications/models/notification_entity.dart';
import 'package:haqvox/app/src/subscription/models/subscription_plan_entity.dart';
import 'package:meta/meta.dart';


part 'global_event.dart';
part 'global_state.dart';

class GlobalBloc extends Bloc<GlobalEvent, GlobalState> {
  GlobalBloc() : super(GlobalInitial()) {
    on<SubscriptionPlanFetchingEvent>(_subscriptionPlanFetchingEvent);
    on<NotificationFetchingEvent>(_notificationFetchingEvent);
  }

  FutureOr<void> _subscriptionPlanFetchingEvent(
      SubscriptionPlanFetchingEvent event, Emitter<GlobalState> emit) async {
    emit(GlobalLoadingState());
    try {
      final subscriptionPlan = await GlobalRepository.subscriptionPlan();
      if (subscriptionPlan.status == 1) {
        emit(GlobalSubscriptionPlanLoadedSuccessState(
            subscriptionsPlanEntity: subscriptionPlan));
      }
    } catch (e) {
      log('Subscription Plan Bloc Error:', error: e.toString());
      emit(GlobalSubscriptionPlanFailedErrorState(error: e.toString()));
    }
  }

  FutureOr<void> _notificationFetchingEvent(
      NotificationFetchingEvent event, Emitter<GlobalState> emit) async {
    emit(GlobalLoadingState());
    try {
      final notification = await GlobalRepository.notifications();
      emit(GlobalNotificationFetchingSuccessState(
          notificationEntity: notification));
    } catch (e) {
      log('Notification Bloc Error $e');
      emit(GlobalNotificationFetchingFailedErrorState(error: e.toString()));
    }
  }
}
