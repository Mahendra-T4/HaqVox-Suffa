import 'package:haqvox/app/core/database/hive_database.dart';
import 'package:haqvox/app/core/database/hive_models/notification_model.dart';

/// Notification Repository - Handles all notification-related database operations
class NotificationRepository {
  final HiveDatabase _hiveDatabase = HiveDatabase();

  /// Get all notifications
  Future<List<NotificationModel>> getAllNotifications() async {
    try {
      final notifications = _hiveDatabase.notificationBox.values.toList();
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notifications;
    } catch (e) {
      print('Error getting all notifications: $e');
      return [];
    }
  }

  /// Get unread notifications
  Future<List<NotificationModel>> getUnreadNotifications() async {
    try {
      final notifications = _hiveDatabase.notificationBox.values
          .where((notification) => !notification.isRead)
          .toList();
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notifications;
    } catch (e) {
      print('Error getting unread notifications: $e');
      return [];
    }
  }

  /// Get notifications by type
  Future<List<NotificationModel>> getNotificationsByType(String type) async {
    try {
      final notifications = _hiveDatabase.notificationBox.values
          .where((notification) => notification.type == type)
          .toList();
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notifications;
    } catch (e) {
      print('Error getting notifications by type: $e');
      return [];
    }
  }

  /// Get notification by ID
  Future<NotificationModel?> getNotificationById(String id) async {
    try {
      return _hiveDatabase.notificationBox.get(id);
    } catch (e) {
      print('Error getting notification by ID: $e');
      return null;
    }
  }

  /// Add notification
  Future<void> addNotification(NotificationModel notification) async {
    try {
      await _hiveDatabase.notificationBox.put(notification.id, notification);
    } catch (e) {
      print('Error adding notification: $e');
      rethrow;
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String id) async {
    try {
      final notification = await getNotificationById(id);
      if (notification != null) {
        notification.isRead = true;
        await addNotification(notification);
      }
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final notifications = await getAllNotifications();
      for (final notification in notifications) {
        notification.isRead = true;
        await addNotification(notification);
      }
    } catch (e) {
      print('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String id) async {
    try {
      await _hiveDatabase.notificationBox.delete(id);
    } catch (e) {
      print('Error deleting notification: $e');
      rethrow;
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      await _hiveDatabase.notificationBox.clear();
    } catch (e) {
      print('Error clearing all notifications: $e');
      rethrow;
    }
  }

  /// Get unread notifications count
  Future<int> getUnreadCount() async {
    try {
      final notifications = await getUnreadNotifications();
      return notifications.length;
    } catch (e) {
      return 0;
    }
  }

  /// Watch notifications (stream)
  Stream<List<NotificationModel>> watchNotifications() async* {
    try {
      yield await getAllNotifications();
      await for (final _ in _hiveDatabase.notificationBox.watch()) {
        yield await getAllNotifications();
      }
    } catch (e) {
      print('Error watching notifications: $e');
      yield [];
    }
  }
}
