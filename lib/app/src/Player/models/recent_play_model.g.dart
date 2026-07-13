// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_play_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecentPlayAdapter extends TypeAdapter<RecentPlay> {
  @override
  final int typeId = 12;

  @override
  RecentPlay read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecentPlay(
      title: fields[0] as String,
      artist: fields[1] as String?,
      artUri: fields[2] as String?,
      audioUrl: fields[3] as String,
      album: fields[4] as String?,
      timestamp: fields[5] as DateTime,
      localFilePath: fields[6] as String?,
      isDownloaded: fields[7] as bool,
      chapterSlug: fields[8] as String?,
      ebookSlug: fields[9] as String?,
      lastPosition: fields[10] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, RecentPlay obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.artist)
      ..writeByte(2)
      ..write(obj.artUri)
      ..writeByte(3)
      ..write(obj.audioUrl)
      ..writeByte(4)
      ..write(obj.album)
      ..writeByte(5)
      ..write(obj.timestamp)
      ..writeByte(6)
      ..write(obj.localFilePath)
      ..writeByte(7)
      ..write(obj.isDownloaded)
      ..writeByte(8)
      ..write(obj.chapterSlug)
      ..writeByte(9)
      ..write(obj.ebookSlug)
      ..writeByte(10)
      ..write(obj.lastPosition);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecentPlayAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
