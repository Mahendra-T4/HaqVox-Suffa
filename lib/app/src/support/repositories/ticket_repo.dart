import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:haqvox/app/config/environment.dart';
import 'package:haqvox/app/core/database/key.dart';
import 'package:haqvox/app/core/database/shared_prefs_config.dart';
import 'package:haqvox/app/core/database/user/hive_db.dart';
import 'package:haqvox/app/src/support/models/chat_conversation.dart';
import 'package:haqvox/app/src/support/models/generate_ticket_params.dart';
import 'package:haqvox/app/src/support/models/generate_tickets.dart';
import 'package:haqvox/app/src/support/models/ticket_chat_entity.dart';
import 'package:haqvox/app/src/support/models/tickets_history.dart';
import 'package:haqvox/app/src/support/models/tickets_subject_list_entity.dart';
import 'package:haqvox/app/src/support/view/ticket_history_view.dart';
import 'package:http/http.dart' as http;

abstract class TicketRepository {
  static final client = http.Client();
  static final url = Uri.parse(Environment.baseUrl);
  // static final StorageConfig config = StorageConfig();

  static Future<TicketsSubjectEntity> ticketSubject() async {
    try {
      TicketsSubjectEntity ticketsSubjectEntity = TicketsSubjectEntity();

      // final userKey = await config.getUserData(key: DBKeys.userKey);
      final response = await client.post(
        url,
        body: {
          'activity': 'ticket-subject-list',
          'userKey': HiveService.getUserId().toString(),
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        ticketsSubjectEntity = TicketsSubjectEntity.fromJson(jsonResponse);
        log('Ticket Subject List Response => ${ticketsSubjectEntity.message}');
        return TicketsSubjectEntity.fromJson(jsonResponse);
      } else {
        log('Failed To Load Data From Server');
        return TicketsSubjectEntity(
          status: 0,
          message: 'Failed To Load Data From Server',
        );
      }
    } catch (e) {
      log('Ticket Subject Error From Repository : $e');
      return TicketsSubjectEntity(status: 500, message: e.toString());
    }
  }

  static Future<GenerateTicketsEntity> generateTicket(
    GenerateTicketParams params,
    File? file,
    BuildContext context,
  ) async {
    try {
      final userKey = HiveService.getUserId();
      // Create multipart request
      final request = http.MultipartRequest('POST', url);

      // Add text fields
      request.fields.addAll({
        'activity': 'generate-a-ticket',
        'userKey': userKey.toString(),
        'ticketTitle': params.ticketTitle,
        'ticketMessage': params.ticketMsg,
        'ticketSubjectID': params.ticketSubjectID,
      });

      // Add file if provided
      if (file != null) {
        final fileStream = http.ByteStream(file.openRead());
        final length = await file.length();

        final multipartFile = http.MultipartFile(
          'ticketAttachment',
          fileStream,
          length,
          filename: file.path.split('/').last,
        );

        request.files.add(multipartFile);
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        log('Ticket Chat Response => ${response.body}');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TicketHistoryView()),
        );
        return GenerateTicketsEntity.fromJson(jsonResponse);
      } else {
        log('Failed to send message: ${response.statusCode}');
        return GenerateTicketsEntity(
          status: response.statusCode,
          message: 'Failed to send message',
        );
      }
    } catch (e) {
      log('Ticket Chat Repo Error: $e');
      return GenerateTicketsEntity(status: 500, message: e.toString());
    }
  }

  static Future<TicketsHistoryEntity> ticketHistory() async {
    TicketsHistoryEntity ticketsHistoryEntity = TicketsHistoryEntity();
    try {
      final userKey = HiveService.getUserId();
      final response = await client.post(
        url,
        body: {'activity': 'ticket-history', 'userKey': userKey.toString()},
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        log('Ticket History Response => ${response.body}');
        ticketsHistoryEntity = TicketsHistoryEntity.fromJson(jsonResponse);
      } else {
        log('Failed To Load Data From Server');
      }
    } catch (e) {
      log('Ticket History Error From Repository : $e');
    }
    return ticketsHistoryEntity;
  }

  static Future<TicketChatResponseEntity> sendChatConversation(
    String ticketKey,
    String ticketMsg,
    File? file,
  ) async {
    try {
      final userKey = HiveService.getUserId();
      final request = http.MultipartRequest('POST', url);

      request.fields.addAll({
        'activity': 'ticket-chat',
        'userKey': userKey.toString(),
        'ticketKey': ticketKey,
        'ticketMessage': ticketMsg,
      });

      if (file != null) {
        final fileStream = http.ByteStream(file.openRead());
        final length = await file.length();

        final multipartFile = http.MultipartFile(
          'ticketAttachment',
          fileStream,
          length,
          filename: file.path.split('/').last,
        );

        request.files.add(multipartFile);
      }
      final streamResponse = await request.send();
      final response = await http.Response.fromStream(streamResponse);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print(response.body);
        return TicketChatResponseEntity.fromJson(jsonResponse);
      } else {
        return TicketChatResponseEntity(
          status: response.statusCode,
          message: 'Ops! Server not responding',
        );
      }
    } catch (e) {
      log('Ticket Chat Conversation Repo Error $e');
      return TicketChatResponseEntity(status: 500, message: e.toString());
    }
  }

  static Future<ChatConversationEntity> ticketChatConversation(
    String ticketKey,
  ) async {
    try {
      ChatConversationEntity chatConversationEntity = ChatConversationEntity();

      final userKey = HiveService.getUserId();
      final response = await client.post(
        url,
        body: {
          'activity': 'ticket-conversion',
          'userKey': userKey.toString(),
          'ticketKey': ticketKey,
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        chatConversationEntity = ChatConversationEntity.fromJson(jsonResponse);
        log(
          'Ticket Chat Conversation Response => ${chatConversationEntity.message}',
        );
        return ChatConversationEntity.fromJson(jsonResponse);
      } else {
        log('Failed To Load Ticket Chat Conversation From Server');
        return ChatConversationEntity(
          status: 0,
          message: 'Failed To Load Ticket Chat Conversation From Server',
        );
      }
    } catch (e) {
      log('Ticket Chat Conversation Error From Repository : $e');
      return ChatConversationEntity(status: 500, message: e.toString());
    }
  }
}
