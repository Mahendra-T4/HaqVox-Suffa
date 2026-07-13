// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_play_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecentPlayModelAdapter extends TypeAdapter<RecentPlayModel> {
  @override
  final int typeId = 2;

  @override
  RecentPlayModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecentPlayModel(
      id: fields[0] as String,
      audioName: fields[1] as String,
      audioPath: fields[2] as String,
      chapterSlug: fields[3] as String,
      ebookSlug: fields[4] as String,
      audioSlug: fields[5] as String,
      playDate: fields[6] as DateTime,
      thumbnailUrl: fields[7] as String?,
      duration: fields[8] as int?,
      position: fields[9] as int?,
      chapterTitle: fields[10] as String?,
      ebookName: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RecentPlayModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.audioName)
      ..writeByte(2)
      ..write(obj.audioPath)
      ..writeByte(3)
      ..write(obj.chapterSlug)
      ..writeByte(4)
      ..write(obj.ebookSlug)
      ..writeByte(5)
      ..write(obj.audioSlug)
      ..writeByte(6)
      ..write(obj.playDate)
      ..writeByte(7)
      ..write(obj.thumbnailUrl)
      ..writeByte(8)
      ..write(obj.duration)
      ..writeByte(9)
      ..write(obj.position)
      ..writeByte(10)
      ..write(obj.chapterTitle)
      ..writeByte(11)
      ..write(obj.ebookName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecentPlayModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
