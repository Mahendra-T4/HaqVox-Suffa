import 'package:audio_service/audio_service.dart';

class Track {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String url;
  final String? artworkUrl;
  final Duration? duration;
  final Map<String, dynamic>? extras;

  const Track({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    required this.url,
    this.artworkUrl,
    this.duration,
    this.extras,
  });

  // Create from API response
  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      album: json['album'] as String?,
      url: json['url'] as String,
      artworkUrl: json['artwork_url'] as String?,
      duration:
          json['duration'] != null
              ? Duration(milliseconds: json['duration'] as int)
              : null,
      extras: json['extras'] as Map<String, dynamic>?,
    );
  }
  // Convert to MediaItem for audio_service
  MediaItem toMediaItem() {
    // Handle artwork URL - convert to Uri if it's a valid URL
    Uri? artUri;
    if (artworkUrl != null && artworkUrl!.isNotEmpty) {
      try {
        artUri = Uri.parse(artworkUrl!);
      } catch (e) {
        print('ERROR parsing artworkUrl: $artworkUrl - $e');
        artUri = null;
      }
    }

    // Create complete extras map - preserve all offline metadata
    Map<String, dynamic> allExtras = {
      'url': url,
      'artUri': artUri?.toString(),
      'isDownloaded': extras?['isDownloaded'] ?? false,
      'localFilePath': extras?['localFilePath'],
      'chapterSlug': extras?['chapterSlug'] ?? artist,
      'ebookSlug': extras?['ebookSlug'] ?? album,
      if (extras != null)
        ...extras!, // Spread all extras to preserve offline metadata
    };

    // Debug: Log offline track info
    if (allExtras['isDownloaded'] == true) {
      print(
        'TRACK TO MEDIAITEM - OFFLINE: title=$title, localPath=${allExtras['localFilePath']}, url=$url, artworkUrl=$artworkUrl, artUri=$artUri',
      );
    }

    // Create media item with all available metadata
    return MediaItem(
      id: id,
      title: title,
      artist: extras?['chapterSlug']?.toString() ?? artist,
      album: extras?['ebookSlug']?.toString() ?? album,
      artUri: artUri,
      duration: duration,
      extras: allExtras,
      displayTitle: title,
      displaySubtitle:
          '${extras?['chapterSlug'] ?? artist} - ${extras?['ebookSlug'] ?? album}',
    );
  }

  // Create Track from MediaItem
  factory Track.fromMediaItem(MediaItem mediaItem) {
    return Track(
      id: mediaItem.id,
      title: mediaItem.title,
      artist: mediaItem.artist ?? '',
      album: mediaItem.album,
      url: mediaItem.extras?['url'] as String,
      artworkUrl: mediaItem.artUri?.toString(),
      duration: mediaItem.duration,
      extras: mediaItem.extras,
    );
  }

  // Copy with method for immutability
  Track copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? url,
    String? artworkUrl,
    Duration? duration,
    Map<String, dynamic>? extras,
  }) {
    return Track(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      url: url ?? this.url,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      duration: duration ?? this.duration,
      extras: extras ?? this.extras,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Track &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          artist == other.artist &&
          album == other.album &&
          url == other.url &&
          artworkUrl == other.artworkUrl &&
          duration == other.duration;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      artist.hashCode ^
      album.hashCode ^
      url.hashCode ^
      artworkUrl.hashCode ^
      duration.hashCode;
}
