class OfflineMusic {
  final String id;
  final String title;
  final String artist;
  final String filePath;
  final String duration;
  final DateTime downloadDate;

  OfflineMusic({
    required this.id,
    required this.title,
    required this.artist,
    required this.filePath,
    required this.duration,
    required this.downloadDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'filePath': filePath,
      'duration': duration,
      'downloadDate': downloadDate.toIso8601String(),
    };
  }

  factory OfflineMusic.fromMap(Map<String, dynamic> map) {
    return OfflineMusic(
      id: map['id'],
      title: map['title'],
      artist: map['artist'],
      filePath: map['filePath'],
      duration: map['duration'],
      downloadDate: DateTime.parse(map['downloadDate']),
    );
  }
}
