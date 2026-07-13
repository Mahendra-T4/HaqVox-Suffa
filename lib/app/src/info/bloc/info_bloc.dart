import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:haqvox/app/src/info/models/terms&condition_model.dart';
import 'package:haqvox/app/src/info/repositories/info_repo.dart';


part 'info_event.dart';
part 'info_state.dart';

class InfoBloc extends Bloc<InfoEvent, InfoState> {
  InfoBloc() : super(InfoInitial()) {
    on<InfoTermAndConditionFetchingEvent>(_infoTermAndConditionFetchingEvent);
  }

  FutureOr<void> _infoTermAndConditionFetchingEvent(
      InfoTermAndConditionFetchingEvent event, Emitter<InfoState> emit) async {
    emit(InfoLoadingState());
    try {
      final response = await InfoRepository.termCondition(pageRole: event.pageRole);
      emit(InfoTermAndConditionSuccessState(termAndConditionEntity: response));
    } catch (e) {
      log('Error fetching term and condition: $e');
      emit(InfoTermAndConditionErrorState(error: 'Info Bloc Error: $e'));
    }
  }
}
