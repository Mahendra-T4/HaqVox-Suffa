part of 'ticket_bloc.dart';

@immutable
sealed class TicketState {}

final class TicketActionState extends TicketState {}

final class TicketInitial extends TicketState {}

final class TicketGlobalLoadingState extends TicketState {}

//! Ticket Subject List States --------------------------------------->

final class TicketSubjectListFetchingLoadedSuccessState extends TicketState {
  final TicketsSubjectEntity ticketsSubjectEntity;

  TicketSubjectListFetchingLoadedSuccessState(
      {required this.ticketsSubjectEntity});
}

final class TicketSubjectListFailedErrorState extends TicketState {
  final String error;

  TicketSubjectListFailedErrorState({required this.error});
}

//! Generate Ticket State ---------------------------------->

final class GenerateTicketLoadedSuccessState extends TicketState {
  final GenerateTicketsEntity generateTicketsEntity;

  GenerateTicketLoadedSuccessState({required this.generateTicketsEntity});
}

final class GenerateTicketFailedErrorState extends TicketState {
  final String error;

  GenerateTicketFailedErrorState({required this.error});
}

final class NavigateToTicketHistoryActionState extends TicketActionState {}

//! Ticket History States ----------------------------------->

final class TicketHistoryLoadedSuccessState extends TicketState {
  final TicketsHistoryEntity ticketsHistoryEntity;

  TicketHistoryLoadedSuccessState({required this.ticketsHistoryEntity});
}

final class TicketHistoryFailedErrorState extends TicketState {
  final String error;

  TicketHistoryFailedErrorState({required this.error});
}

//! Send Ticket Chat State -------------------------------->

final class SendTicketChatToSupportSuccessState extends TicketState {
  final TicketChatResponseEntity ticketChatResponseEntity;

  SendTicketChatToSupportSuccessState({required this.ticketChatResponseEntity});
}

final class TicketChatRoomConversationSuccessState extends TicketState{
  final TicketChatResponseEntity ticketChatResponseEntity;
   final ChatConversationEntity chatConversationEntity;

  TicketChatRoomConversationSuccessState({required this.ticketChatResponseEntity, required this.chatConversationEntity});
}

final class SendTicketChatToSupportFailedErrorState extends TicketState {
  final String error;

  SendTicketChatToSupportFailedErrorState({required this.error});
}



//! Load User Chat Messages

final class LoadUserChatMessagesLoadedSuccessState extends TicketState {
  final ChatConversationEntity chatConversationEntity;

  LoadUserChatMessagesLoadedSuccessState(
      {required this.chatConversationEntity});
}

final class LoadUserChatMessagesFailedErrorState extends TicketState {
  final String error;

  LoadUserChatMessagesFailedErrorState({required this.error});
}
