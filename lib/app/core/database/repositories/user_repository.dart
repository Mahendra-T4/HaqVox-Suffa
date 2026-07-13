import 'package:haqvox/app/core/database/hive_database.dart';
import 'package:haqvox/app/core/database/hive_models/user_model.dart';

/// User Repository - Handles all user-related database operations
class UserRepository {
  final HiveDatabase _hiveDatabase = HiveDatabase();

  /// Get current logged-in user
  Future<UserModel?> getLoggedInUser() async {
    try {
      final users = _hiveDatabase.userBox.values
          .where((user) => user.isLoggedIn)
          .toList();
      return users.isNotEmpty ? users.first : null;
    } catch (e) {
      print('Error getting logged-in user: $e');
      return null;
    }
  }

  /// Save user data
  Future<void> saveUser(UserModel user) async {
    try {
      await _hiveDatabase.userBox.put(user.userKey ?? 'default', user);
    } catch (e) {
      print('Error saving user: $e');
      rethrow;
    }
  }

  /// Update user data
  Future<void> updateUser(String userKey, UserModel user) async {
    try {
      await _hiveDatabase.userBox.put(userKey, user);
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  /// Get user by key
  Future<UserModel?> getUserByKey(String userKey) async {
    try {
      return _hiveDatabase.userBox.get(userKey);
    } catch (e) {
      print('Error getting user by key: $e');
      return null;
    }
  }

  /// Delete user
  Future<void> deleteUser(String userKey) async {
    try {
      await _hiveDatabase.userBox.delete(userKey);
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }

  /// Clear all users
  Future<void> clearAllUsers() async {
    try {
      await _hiveDatabase.userBox.clear();
    } catch (e) {
      print('Error clearing users: $e');
      rethrow;
    }
  }

  /// Get all users
  Future<List<UserModel>> getAllUsers() async {
    try {
      return _hiveDatabase.userBox.values.toList();
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }

  /// Check if user is logged in
  Future<bool> isUserLoggedIn() async {
    try {
      final user = await getLoggedInUser();
      return user != null;
    } catch (e) {
      return false;
    }
  }

  /// Logout user
  Future<void> logoutUser() async {
    try {
      final user = await getLoggedInUser();
      if (user != null) {
        user.isLoggedIn = false;
        await saveUser(user);
      }
    } catch (e) {
      print('Error logging out user: $e');
      rethrow;
    }
  }
}
