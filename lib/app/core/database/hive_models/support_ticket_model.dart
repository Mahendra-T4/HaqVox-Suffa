import 'package:hive/hive.dart';

part 'support_ticket_model.g.dart';

@HiveType(typeId: 4)
class SupportTicketModel extends HiveObject {
  @HiveField(0)
  String ticketId;

  @HiveField(1)
  String subject;

  @HiveField(2)
  String description;

  @HiveField(3)
  String supportType;

  @HiveField(4)
  String status;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime? updatedAt;

  @HiveField(7)
  String? priority;

  @HiveField(8)
  String? assignedTo;

  @HiveField(9)
  List<String> attachmentUrls;

  @HiveField(10)
  String userKey;

  SupportTicketModel({
    required this.ticketId,
    required this.subject,
    required this.description,
    required this.supportType,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.priority,
    this.assignedTo,
    required this.attachmentUrls,
    required this.userKey,
  });

  @override
  String toString() =>
      'SupportTicketModel(ticketId: $ticketId, subject: $subject, status: $status)';
}
