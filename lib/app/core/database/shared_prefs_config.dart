// import 'package:flutter/material.dart';

// /// DEPRECATED: This class is being replaced by Hive repositories.
// /// See: lib/app/core/database/repositories/
// ///
// /// This stub is kept temporarily for compatibility during migration.
// /// Use repositories instead:
// /// - UserRepository for user data
// /// - AppSettingsRepository for settings
// /// - Other repositories for specific data types

// class StorageConfig with ChangeNotifier {
//   // Singleton pattern
//   static final StorageConfig _instance = StorageConfig._internal();

//   factory StorageConfig() => _instance;

//   StorageConfig._internal();

//   /// DEPRECATED: Use UserRepository.saveUser() instead
//   Future<void> saveUserData({
//     required String key,
//     required dynamic value,
//   }) async {
//     debugPrint(
//       '[DEPRECATED] StorageConfig.saveUserData() is deprecated. '
//       'Use UserRepository.saveUser() instead.',
//     );
//     notifyListeners();
//   }

//   /// DEPRECATED: Use UserRepository.getLoggedInUser() instead
//   Future<dynamic> getUserData({required String key}) async {
//     debugPrint(
//       '[DEPRECATED] StorageConfig.getUserData() is deprecated. '
//       'Use UserRepository methods instead.',
//     );
//     return null;
//   }

//   /// DEPRECATED: Use appropriate repository instead
//   Future<bool> removeUserData({required String key}) async {
//     debugPrint(
//       '[DEPRECATED] StorageConfig.removeUserData() is deprecated. '
//       'Use repository methods instead.',
//     );
//     notifyListeners();
//     return true;
//   }

//   /// DEPRECATED: Use UserRepository.clearAllUsers() instead
//   Future<bool> clearAllData() async {
//     debugPrint(
//       '[DEPRECATED] StorageConfig.clearAllData() is deprecated. '
//       'Use UserRepository.clearAllUsers() instead.',
//     );
//     notifyListeners();
//     return true;
//   }

//   /// DEPRECATED: Use UserRepository methods instead
//   Future<void> clearAllDataWithoutUK() async {
//     debugPrint(
//       '[DEPRECATED] StorageConfig.clearAllDataWithoutUK() is deprecated. '
//       'Use UserRepository methods instead.',
//     );
//     notifyListeners();
//   }

//   /// DEPRECATED: Use repository watch methods instead
//   Stream<Map<String, dynamic>> get preferencesStream async* {
//     debugPrint(
//       '[DEPRECATED] StorageConfig.preferencesStream is deprecated. '
//       'Use repository.watch*() methods instead.',
//     );
//     yield {};
//     notifyListeners();
//   }
// }
