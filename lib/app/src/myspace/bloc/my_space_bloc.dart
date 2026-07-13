import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:haqvox/app/src/myspace/models/add_audio_on_myspace.dart';
import 'package:haqvox/app/src/myspace/models/delete_myspace_entity.dart';
import 'package:haqvox/app/src/myspace/models/myspace_list_entity.dart';
import 'package:haqvox/app/src/myspace/repositories/myspace_repo.dart';

part 'my_space_event.dart';
part 'my_space_state.dart';

class MySpaceBloc extends Bloc<MySpaceEvent, MySpaceState> {
  MySpaceBloc() : super(MySpaceInitial()) {
    on<AddOnMySpaceEvent>(_addOnMySpaceEvent);
    on<FetchMySpaceListFromServerEvent>(_fetchMySpaceListFromServerEvent);
    on<DeleteMySpaceRecordsFromServerEvent>(
        _deleteMySpaceRecordsFromServerEvent);
  }

  FutureOr<void> _addOnMySpaceEvent(
      AddOnMySpaceEvent event, Emitter<MySpaceState> emit) async {
    emit(MySpaceLoadingState());
    try {
      final addOnMySpace = await MySpaceRepository.addAudioOnMySpace(
          event.audioSlug, event.mySpaceType, event.context);
      emit(AddMySpaceLoadedSuccessState(addOnMySpaceEntity: addOnMySpace));
    } catch (e) {

      log('AddMySpaceError Bloc: $e');
      emit(AddMySpaceFailedErrorState(error: e.toString()));
    }
  }

  FutureOr<void> _fetchMySpaceListFromServerEvent(
      FetchMySpaceListFromServerEvent event, Emitter<MySpaceState> emit) async {
    emit(MySpaceLoadingState());
    try {
      final mySpaceList =
          await MySpaceRepository.mySpaceList(event.mySpaceType, event.context);
      emit(MySpaceListLoadedSuccessState(mySpaceListEntity: mySpaceList));
      // if (mySpaceList.status == 1) {
      //     CustomSnackBar.show(
      //         context: event.context,
      //         message: mySpaceList.message.toString(),
      //         type: SnackBarType.success);
      //   } else {
      //     CustomSnackBar.show(
      //         context: event.context,
      //         message: mySpaceList.message.toString(),
      //         type: SnackBarType.error);
      //   }
    } catch (e) {
      log('MySpaceListError Bloc: $e');
      emit(MySpaceListFailedErrorState(error: e.toString()));
    }
  }

  FutureOr<void> _deleteMySpaceRecordsFromServerEvent(
      DeleteMySpaceRecordsFromServerEvent event,
      Emitter<MySpaceState> emit) async {
    emit(MySpaceLoadingState());
    try {
      final deleteMySpace = await MySpaceRepository.deleteMySpace(
          event.mySpaceKey, event.mySpaceType, event.context);
      emit(DeleteMySpaceLoadedSuccessState(deleteMySpaceEntity: deleteMySpace));
    } catch (e) {
      log('DeleteMySpaceError Bloc: $e');
      emit(DeleteMySpaceFailedErrorState(error: e.toString()));
    }
  }
}
