part of 'my_space_bloc.dart';

sealed class MySpaceState {}

final class MySpaceInitial extends MySpaceState {}

final class MySpaceLoadingState extends MySpaceState {}

//! add my space

final class AddMySpaceLoadedSuccessState extends MySpaceState {
  final AddOnMySpaceEntity addOnMySpaceEntity;
  final String mySpaceType;
  AddMySpaceLoadedSuccessState({
    required this.addOnMySpaceEntity,
    required this.mySpaceType,
  });
}

final class AddMySpaceFailedErrorState extends MySpaceState {
  final String error;
  final String mySpaceType;
  AddMySpaceFailedErrorState({
    required this.error,
    required this.mySpaceType,
  });
}

//! my space list

final class MySpaceListLoadedSuccessState extends MySpaceState {
  final MySpaceListEntity mySpaceListEntity;
  MySpaceListLoadedSuccessState({required this.mySpaceListEntity});
}

final class MySpaceListFailedErrorState extends MySpaceState {
  final String error;
  MySpaceListFailedErrorState({required this.error});
}

//! delete my space

final class DeleteMySpaceLoadedSuccessState extends MySpaceState {
  final DeleteMySpaceEntity deleteMySpaceEntity;
  DeleteMySpaceLoadedSuccessState({required this.deleteMySpaceEntity});
}

final class DeleteMySpaceFailedErrorState extends MySpaceState {
  final String error;
  DeleteMySpaceFailedErrorState({required this.error});
}
