// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'downloaded_audio_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DownloadedAudioModelAdapter extends TypeAdapter<DownloadedAudioModel> {
  @override
  final int typeId = 0;

  @override
  DownloadedAudioModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DownloadedAudioModel(
      id: fields[0] as String,
      title: fields[1] as String,
      url: fields[2] as String,
      localPath: fields[3] as String,
      artist: fields[4] as String,
      coverUrl: fields[5] as String?,
      fileSize: fields[6] as int,
      downloadDate: fields[7] as DateTime,
      chapterTitle: fields[8] as String,
      chapterSlug: fields[9] as String,
      ebookSlug: fields[10] as String,
      ebookTitle: fields[11] as String,
      downloadProgress: fields[12] as int?,
      status: fields[13] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DownloadedAudioModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.url)
      ..writeByte(3)
      ..write(obj.localPath)
      ..writeByte(4)
      ..write(obj.artist)
      ..writeByte(5)
      ..write(obj.coverUrl)
      ..writeByte(6)
      ..write(obj.fileSize)
      ..writeByte(7)
      ..write(obj.downloadDate)
      ..writeByte(8)
      ..write(obj.chapterTitle)
      ..writeByte(9)
      ..write(obj.chapterSlug)
      ..writeByte(10)
      ..write(obj.ebookSlug)
      ..writeByte(11)
      ..write(obj.ebookTitle)
      ..writeByte(12)
      ..write(obj.downloadProgress)
      ..writeByte(13)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadedAudioModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
