import 'package:haqvox/app/core/database/hive_database.dart';
import 'package:haqvox/app/core/database/hive_models/app_settings_model.dart';

/// App Settings Repository - Handles all app settings-related database operations
class AppSettingsRepository {
  final HiveDatabase _hiveDatabase = HiveDatabase();

  /// Get all settings
  Future<List<AppSettingsModel>> getAllSettings() async {
    try {
      return _hiveDatabase.appSettingsBox.values.toList();
    } catch (e) {
      print('Error getting all settings: $e');
      return [];
    }
  }

  /// Get setting by key
  Future<AppSettingsModel?> getSettingByKey(String key) async {
    try {
      return _hiveDatabase.appSettingsBox.get(key);
    } catch (e) {
      print('Error getting setting by key: $e');
      return null;
    }
  }

  /// Save setting
  Future<void> saveSetting(AppSettingsModel setting) async {
    try {
      setting.updatedAt = DateTime.now();
      await _hiveDatabase.appSettingsBox.put(setting.key, setting);
    } catch (e) {
      print('Error saving setting: $e');
      rethrow;
    }
  }

  /// Save setting by key and value
  Future<void> saveSettingByKeyValue(String key, dynamic value) async {
    try {
      final setting = AppSettingsModel(
        key: key,
        value: value,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await saveSetting(setting);
    } catch (e) {
      print('Error saving setting by key-value: $e');
      rethrow;
    }
  }

  /// Get setting value
  Future<dynamic> getSettingValue(String key, {dynamic defaultValue}) async {
    try {
      final setting = await getSettingByKey(key);
      return setting?.value ?? defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  /// Delete setting
  Future<void> deleteSetting(String key) async {
    try {
      await _hiveDatabase.appSettingsBox.delete(key);
    } catch (e) {
      print('Error deleting setting: $e');
      rethrow;
    }
  }

  /// Clear all settings
  Future<void> clearAllSettings() async {
    try {
      await _hiveDatabase.appSettingsBox.clear();
    } catch (e) {
      print('Error clearing all settings: $e');
      rethrow;
    }
  }

  /// Get settings count
  Future<int> getSettingsCount() async {
    try {
      return _hiveDatabase.appSettingsBox.length;
    } catch (e) {
      return 0;
    }
  }

  /// Watch settings (stream)
  Stream<List<AppSettingsModel>> watchSettings() async* {
    try {
      yield await getAllSettings();
      await for (final _ in _hiveDatabase.appSettingsBox.watch()) {
        yield await getAllSettings();
      }
    } catch (e) {
      print('Error watching settings: $e');
      yield [];
    }
  }
}
