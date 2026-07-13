import 'package:audio_service/audio_service.dart';

/// Utility class for MediaItem serialization
class MediaItemConverter {
  /// Convert MediaItem to JSON Map
  static Map<String, dynamic> toJson(MediaItem item) {
    return {
      'id': item.id,
      'title': item.title,
      'album': item.album,
      'artist': item.artist,
      'genre': item.genre,
      'duration': item.duration?.inMilliseconds,
      'artUri': item.artUri?.toString(),
      'extras': item.extras,
    };
  }

  /// Create MediaItem from JSON Map
  static MediaItem fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'] as String,
      title: json['title'] as String,
      album: json['album'] as String?,
      artist: json['artist'] as String?,
      genre: json['genre'] as String?,
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'] as int)
          : null,
      artUri:
          json['artUri'] != null ? Uri.parse(json['artUri'] as String) : null,
      extras: json['extras'] as Map<String, dynamic>?,
    );
  }
}
