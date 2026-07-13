part of 'ticket_bloc.dart';

sealed class TicketEvent {}

final class TicketSubjectListFetchingEvent extends TicketEvent {}

final class GenerateTicketEvent extends TicketEvent {
  final GenerateTicketParams generateTicketParams;
  final File? file;
  final BuildContext context;
  GenerateTicketEvent({required this.generateTicketParams, this.file,required this.context});
}

final class TicketHistoryFetchingEvent extends TicketEvent {}

final class SendTicketChatToServerEvent extends TicketEvent {
  final String ticketKey;
  final String ticketMsg;
  final File? file;

  SendTicketChatToServerEvent(
      {required this.ticketKey, required this.ticketMsg, this.file});
}

final class LoadUserChatConversationMessageEvent extends TicketEvent {
  final String ticketKey;

  LoadUserChatConversationMessageEvent({required this.ticketKey});
}
