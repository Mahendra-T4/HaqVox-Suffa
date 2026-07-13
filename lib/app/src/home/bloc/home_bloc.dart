import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:haqvox/app/src/home/models/home_entity.dart';
import 'package:haqvox/app/src/home/repositories/home_repo.dart';


part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<HomeGlobalContentFetchingEvent>(_homeGlobalContentFetchingEvent);
  }

  FutureOr<void> _homeGlobalContentFetchingEvent(
      HomeGlobalContentFetchingEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoadingState());
    try {
      final home = await HomeRepository.getHomeData();
      emit(HomeGlobalContentsLoadedSuccessState(homeEntity: home));
    } catch (e) {
      log('Home Contents Error Bloc: $e');
      emit(HomeGlobalContentsFailedErrorState(error: e.toString()));
    }
  }
}
