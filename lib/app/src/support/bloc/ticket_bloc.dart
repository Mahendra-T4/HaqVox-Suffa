import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:haqvox/app/src/support/models/chat_conversation.dart';
import 'package:haqvox/app/src/support/models/generate_ticket_params.dart';
import 'package:haqvox/app/src/support/models/generate_tickets.dart';
import 'package:haqvox/app/src/support/models/ticket_chat_entity.dart';
import 'package:haqvox/app/src/support/models/tickets_history.dart';
import 'package:haqvox/app/src/support/models/tickets_subject_list_entity.dart';
import 'package:haqvox/app/src/support/repositories/ticket_repo.dart';
import 'package:meta/meta.dart';


part 'ticket_event.dart';
part 'ticket_state.dart';

class TicketBloc extends Bloc<TicketEvent, TicketState> {
  TicketBloc() : super(TicketInitial()) {
    on<TicketSubjectListFetchingEvent>(_ticketSubjectListFetchingEvent);
    on<GenerateTicketEvent>(_generateTicketEvent);
    on<TicketHistoryFetchingEvent>(_ticketHistoryFetchingEvent);
    on<SendTicketChatToServerEvent>(_sendTicketChatToServerEvent);
    on<LoadUserChatConversationMessageEvent>(
        _loadUserChatConversationMessageEvent);
  }

  FutureOr<void> _ticketSubjectListFetchingEvent(
      TicketSubjectListFetchingEvent event, Emitter<TicketState> emit) async {
    emit(TicketGlobalLoadingState());
    try {
      final subjectList = await TicketRepository.ticketSubject();
      emit(TicketSubjectListFetchingLoadedSuccessState(
          ticketsSubjectEntity: subjectList));
    } catch (e) {
      log('Ticket Subject Error From Bloc => $e');
      emit(TicketSubjectListFailedErrorState(error: e.toString()));
    }
  }

  FutureOr<void> _generateTicketEvent(
      GenerateTicketEvent event, Emitter<TicketState> emit) async {
    emit(TicketGlobalLoadingState());
    try {
      final generateTicket = await TicketRepository.generateTicket(
          event.generateTicketParams, event.file, event.context);
      emit(GenerateTicketLoadedSuccessState(
          generateTicketsEntity: generateTicket));
      emit(NavigateToTicketHistoryActionState());
    } catch (e) {
      print(e);
      emit(GenerateTicketFailedErrorState(error: e.toString()));
    }
  }

  FutureOr<void> _ticketHistoryFetchingEvent(
      TicketHistoryFetchingEvent event, Emitter<TicketState> emit) async {
    emit(TicketGlobalLoadingState());
    try {
      final ticketHistory = await TicketRepository.ticketHistory();
      emit(
          TicketHistoryLoadedSuccessState(ticketsHistoryEntity: ticketHistory));
    } catch (e) {
      log('Ticket History Bloc Error => $e');
      emit(TicketHistoryFailedErrorState(error: e.toString()));
    }
  }

  FutureOr<void> _sendTicketChatToServerEvent(
      SendTicketChatToServerEvent event, Emitter<TicketState> emit) async {
    emit(TicketGlobalLoadingState());
    try {
      final sendMessagesResponse = await TicketRepository.sendChatConversation(
          event.ticketKey, event.ticketMsg, event.file);
      emit(SendTicketChatToSupportSuccessState(
          ticketChatResponseEntity: sendMessagesResponse));
    } catch (e) {
      log('Send Chat Messages Bloc Error $e');
      emit(SendTicketChatToSupportFailedErrorState(error: e.toString()));
    }
  }

  FutureOr<void> _loadUserChatConversationMessageEvent(
      LoadUserChatConversationMessageEvent event,
      Emitter<TicketState> emit) async {
    emit(TicketGlobalLoadingState());
    try {
      final loadUserChatMessages =
          await TicketRepository.ticketChatConversation(event.ticketKey);
      emit(LoadUserChatMessagesLoadedSuccessState(
          chatConversationEntity: loadUserChatMessages));
    } catch (e) {
      log('Load User Chat Messages Bloc Error $e');
      emit(LoadUserChatMessagesFailedErrorState(error: e.toString()));
    }
  }
}
