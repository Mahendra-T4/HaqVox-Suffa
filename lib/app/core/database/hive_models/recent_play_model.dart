import 'package:hive/hive.dart';

part 'recent_play_model.g.dart';

@HiveType(typeId: 2)
class RecentPlayModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String audioName;

  @HiveField(2)
  String audioPath;

  @HiveField(3)
  String chapterSlug;

  @HiveField(4)
  String ebookSlug;

  @HiveField(5)
  String audioSlug;

  @HiveField(6)
  DateTime playDate;

  @HiveField(7)
  String? thumbnailUrl;

  @HiveField(8)
  int? duration;

  @HiveField(9)
  int? position;

  @HiveField(10)
  String? chapterTitle;

  @HiveField(11)
  String? ebookName;

  RecentPlayModel({
    required this.id,
    required this.audioName,
    required this.audioPath,
    required this.chapterSlug,
    required this.ebookSlug,
    required this.audioSlug,
    required this.playDate,
    this.thumbnailUrl,
    this.duration,
    this.position,
    this.chapterTitle,
    this.ebookName,
  });

  @override
  String toString() =>
      'RecentPlayModel(id: $id, audioName: $audioName, playDate: $playDate)';
}
