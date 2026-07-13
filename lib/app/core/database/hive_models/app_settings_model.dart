import 'package:hive/hive.dart';

part 'app_settings_model.g.dart';

@HiveType(typeId: 6)
class AppSettingsModel extends HiveObject {
  @HiveField(0)
  String key;

  @HiveField(1)
  dynamic value;

  @HiveField(2)
  DateTime? createdAt;

  @HiveField(3)
  DateTime? updatedAt;

  AppSettingsModel({
    required this.key,
    required this.value,
    this.createdAt,
    this.updatedAt,
  });

  @override
  String toString() => 'AppSettingsModel(key: $key, value: $value)';
}
