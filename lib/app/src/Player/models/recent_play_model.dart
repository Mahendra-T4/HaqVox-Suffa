import 'package:hive_flutter/hive_flutter.dart';
import 'package:audio_service/audio_service.dart';

part 'recent_play_model.g.dart';

@HiveType(typeId: 12)
class RecentPlay extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String? artist;

  @HiveField(2)
  final String? artUri;

  @HiveField(3)
  final String audioUrl;

  @HiveField(4)
  final String? album;

  @HiveField(5)
  final DateTime timestamp;

  @HiveField(6)
  final String? localFilePath;

  @HiveField(7)
  final bool isDownloaded;

  @HiveField(8)
  final String? chapterSlug;

  @HiveField(9)
  final String? ebookSlug;

  @HiveField(10)
  final int? lastPosition;

  RecentPlay({
    required this.title,
    this.artist,
    this.artUri,
    required this.audioUrl,
    this.album,
    required this.timestamp,
    this.localFilePath,
    this.isDownloaded = false,
    this.chapterSlug,
    this.ebookSlug,
    this.lastPosition,
  });

  factory RecentPlay.fromMediaItem(MediaItem mediaItem) {
    return RecentPlay(
      title: mediaItem.title,
      artist: mediaItem.artist,
      audioUrl: mediaItem.extras?['url'] ?? mediaItem.id,
      artUri: mediaItem.artUri?.toString(),
      album: mediaItem.album,
      timestamp: DateTime.now(),
      localFilePath: mediaItem.extras?['localFilePath'],
      isDownloaded: mediaItem.extras?['isDownloaded'] ?? false,
      chapterSlug: mediaItem.extras?['chapterSlug'],
      ebookSlug: mediaItem.extras?['ebookSlug'],
      lastPosition: mediaItem.extras?['lastPosition'],
    );
  }

  MediaItem toMediaItem() {
    final imageUrl =
        artUri?.isNotEmpty == true ? artUri! : 'asset:///assets/icons/book.png';

    return MediaItem(
      id: audioUrl,
      title: title,
      artist: artist,
      album: album,
      artUri: Uri.parse(imageUrl),
      displayTitle: title,
      displaySubtitle: artist ?? album,
      extras: {
        'url': audioUrl,
        'localFilePath': localFilePath,
        'isDownloaded': isDownloaded,
        'chapterSlug': chapterSlug,
        'ebookSlug': ebookSlug,
        'lastPosition': lastPosition,
        'artUri': imageUrl,
        'coverUrl': imageUrl,
        'chapter': artist ?? album, // Include chapter name
        'chapterTitle': artist ?? album, // Include as chapterTitle too
      },
    );
  }

  RecentPlay copyWith({
    String? title,
    String? artist,
    String? artUri,
    String? audioUrl,
    String? album,
    DateTime? timestamp,
    String? localFilePath,
    bool? isDownloaded,
    String? chapterSlug,
    String? ebookSlug,
    int? lastPosition,
  }) {
    return RecentPlay(
      title: title ?? this.title,
      artist: artist ?? this.artist,
      artUri: artUri ?? this.artUri,
      audioUrl: audioUrl ?? this.audioUrl,
      album: album ?? this.album,
      timestamp: timestamp ?? this.timestamp,
      localFilePath: localFilePath ?? this.localFilePath,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      chapterSlug: chapterSlug ?? this.chapterSlug,
      ebookSlug: ebookSlug ?? this.ebookSlug,
      lastPosition: lastPosition ?? this.lastPosition,
    );
  }
}
