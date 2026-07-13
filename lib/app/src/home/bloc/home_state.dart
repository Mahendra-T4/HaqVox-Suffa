part of 'home_bloc.dart';

sealed class HomeState {}

final class HomeInitial extends HomeState {}


final class HomeLoadingState extends HomeState{}


final class HomeGlobalContentsLoadedSuccessState extends HomeState {
  final HomeEntity homeEntity;

  HomeGlobalContentsLoadedSuccessState({required this.homeEntity});
}

final class HomeGlobalContentsFailedErrorState extends HomeState {
  final String error;

  HomeGlobalContentsFailedErrorState({required this.error});
}