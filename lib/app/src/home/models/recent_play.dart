class RecentPlay {
  final String title;
  final String? artist;
  final String audioPath;
  final String? coverUrl;
  final String? localPath;
  final bool isDownloaded;
  final int? position;
  final int? duration;

  RecentPlay({
    required this.title,
    this.artist,
    required this.audioPath,
    this.coverUrl,
    this.localPath,
    this.isDownloaded = false,
    this.position,
    this.duration,
  });

  factory RecentPlay.fromJson(Map<String, dynamic> json) {
    return RecentPlay(
      title: json['title'] as String? ?? 'Unknown Title',
      artist: json['artist'] as String?,
      audioPath: json['audioPath'] as String,
      coverUrl: json['coverUrl'] as String?,
      localPath: json['localPath'] as String?,
      isDownloaded: json['isDownloaded'] as bool? ?? false,
      position: json['position'] as int?,
      duration: json['duration'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'artist': artist,
      'audioPath': audioPath,
      'coverUrl': coverUrl,
      'localPath': localPath,
      'isDownloaded': isDownloaded,
      'position': position,
      'duration': duration,
    };
  }
}
