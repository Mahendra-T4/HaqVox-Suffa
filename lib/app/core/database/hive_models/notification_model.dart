import 'package:hive/hive.dart';

part 'notification_model.g.dart';

@HiveType(typeId: 5)
class NotificationModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String message;

  @HiveField(3)
  String type; // 'info', 'warning', 'success', 'error'

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  bool isRead;

  @HiveField(6)
  String? actionUrl;

  @HiveField(7)
  String? imageUrl;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.actionUrl,
    this.imageUrl,
  });

  @override
  String toString() =>
      'NotificationModel(id: $id, title: $title, isRead: $isRead)';
}
