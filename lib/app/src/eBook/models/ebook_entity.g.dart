// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ebook_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EBookRecordAdapter extends TypeAdapter<EBookRecord> {
  @override
  final int typeId = 1;

  @override
  EBookRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EBookRecord(
      ebookName: fields[0] as String?,
      ebookIcon: fields[1] as String?,
      ebookImage: fields[2] as String?,
      ebookTagline: fields[3] as String?,
      ebookDescription: fields[4] as String?,
      ebookSlug: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, EBookRecord obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.ebookName)
      ..writeByte(1)
      ..write(obj.ebookIcon)
      ..writeByte(2)
      ..write(obj.ebookImage)
      ..writeByte(3)
      ..write(obj.ebookTagline)
      ..writeByte(4)
      ..write(obj.ebookDescription)
      ..writeByte(5)
      ..write(obj.ebookSlug);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EBookRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
