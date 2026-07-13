import 'package:haqvox/app/core/database/hive_database.dart';
import 'package:haqvox/app/core/database/hive_models/support_ticket_model.dart';

/// Support Ticket Repository - Handles all support ticket-related database operations
class SupportTicketRepository {
  final HiveDatabase _hiveDatabase = HiveDatabase();

  /// Get all support tickets
  Future<List<SupportTicketModel>> getAllTickets() async {
    try {
      final tickets = _hiveDatabase.supportTicketBox.values.toList();
      tickets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return tickets;
    } catch (e) {
      print('Error getting all tickets: $e');
      return [];
    }
  }

  /// Get support tickets by user key
  Future<List<SupportTicketModel>> getTicketsByUserKey(String userKey) async {
    try {
      final tickets = _hiveDatabase.supportTicketBox.values
          .where((ticket) => ticket.userKey == userKey)
          .toList();
      tickets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return tickets;
    } catch (e) {
      print('Error getting tickets by user key: $e');
      return [];
    }
  }

  /// Get support tickets by status
  Future<List<SupportTicketModel>> getTicketsByStatus(String status) async {
    try {
      final tickets = _hiveDatabase.supportTicketBox.values
          .where((ticket) => ticket.status == status)
          .toList();
      tickets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return tickets;
    } catch (e) {
      print('Error getting tickets by status: $e');
      return [];
    }
  }

  /// Get support ticket by ID
  Future<SupportTicketModel?> getTicketById(String ticketId) async {
    try {
      return _hiveDatabase.supportTicketBox.get(ticketId);
    } catch (e) {
      print('Error getting ticket by ID: $e');
      return null;
    }
  }

  /// Create support ticket
  Future<void> createTicket(SupportTicketModel ticket) async {
    try {
      await _hiveDatabase.supportTicketBox.put(ticket.ticketId, ticket);
    } catch (e) {
      print('Error creating ticket: $e');
      rethrow;
    }
  }

  /// Update support ticket
  Future<void> updateTicket(SupportTicketModel ticket) async {
    try {
      await _hiveDatabase.supportTicketBox.put(ticket.ticketId, ticket);
    } catch (e) {
      print('Error updating ticket: $e');
      rethrow;
    }
  }

  /// Delete support ticket
  Future<void> deleteTicket(String ticketId) async {
    try {
      await _hiveDatabase.supportTicketBox.delete(ticketId);
    } catch (e) {
      print('Error deleting ticket: $e');
      rethrow;
    }
  }

  /// Clear all support tickets
  Future<void> clearAllTickets() async {
    try {
      await _hiveDatabase.supportTicketBox.clear();
    } catch (e) {
      print('Error clearing all tickets: $e');
      rethrow;
    }
  }

  /// Get support tickets count
  Future<int> getTicketsCount() async {
    try {
      return _hiveDatabase.supportTicketBox.length;
    } catch (e) {
      return 0;
    }
  }

  /// Watch support tickets (stream)
  Stream<List<SupportTicketModel>> watchTickets() async* {
    try {
      yield await getAllTickets();
      await for (final _ in _hiveDatabase.supportTicketBox.watch()) {
        yield await getAllTickets();
      }
    } catch (e) {
      print('Error watching tickets: $e');
      yield [];
    }
  }
}
