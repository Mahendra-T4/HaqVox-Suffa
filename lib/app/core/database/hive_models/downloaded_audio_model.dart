import 'package:hive/hive.dart';

part 'downloaded_audio_model.g.dart';

@HiveType(typeId: 0)
class DownloadedAudioModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String url;

  @HiveField(3)
  String localPath;

  @HiveField(4)
  String artist;

  @HiveField(5)
  String? coverUrl;

  @HiveField(6)
  int fileSize;

  @HiveField(7)
  DateTime downloadDate;

  @HiveField(8)
  String chapterTitle;

  @HiveField(9)
  String chapterSlug;

  @HiveField(10)
  String ebookSlug;

  @HiveField(11)
  String ebookTitle;

  @HiveField(12)
  int? downloadProgress; // 0-100

  @HiveField(13)
  String status; // 'downloading', 'completed', 'failed'

  DownloadedAudioModel({
    required this.id,
    required this.title,
    required this.url,
    required this.localPath,
    required this.artist,
    this.coverUrl,
    required this.fileSize,
    required this.downloadDate,
    required this.chapterTitle,
    required this.chapterSlug,
    required this.ebookSlug,
    required this.ebookTitle,
    this.downloadProgress = 0,
    this.status = 'completed',
  });

  @override
  String toString() =>
      'DownloadedAudioModel(id: $id, title: $title, artist: $artist, status: $status)';
}
