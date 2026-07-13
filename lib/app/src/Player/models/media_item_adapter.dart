import 'package:audio_service/audio_service.dart';
import 'package:hive/hive.dart';

class MediaItemAdapter extends TypeAdapter<MediaItem> {
  @override
  final typeId = 0; // Unique identifier for this adapter

  @override
  MediaItem read(BinaryReader reader) {
    return MediaItem(
      id: reader.readString(),
      title: reader.readString(),
      album: reader.readString(),
      artist: reader.readString(),
      genre: reader.readString(),
      duration: Duration(milliseconds: reader.readInt()),
      artUri: Uri.parse(reader.readString()),
      extras: Map<String, dynamic>.from(reader.readMap()),
    );
  }

  @override
  void write(BinaryWriter writer, MediaItem obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.album ?? '');
    writer.writeString(obj.artist ?? '');
    writer.writeString(obj.genre ?? '');
    writer.writeInt(obj.duration?.inMilliseconds ?? 0);
    writer.writeString(obj.artUri?.toString() ?? '');
    writer.writeMap(obj.extras ?? {});
  }
}
