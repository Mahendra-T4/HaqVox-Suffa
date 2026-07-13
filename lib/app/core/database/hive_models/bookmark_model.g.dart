// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookmarkModelAdapter extends TypeAdapter<BookmarkModel> {
  @override
  final int typeId = 3;

  @override
  BookmarkModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BookmarkModel(
      id: fields[0] as String,
      ebookSlug: fields[1] as String,
      ebookName: fields[2] as String,
      ebookImage: fields[3] as String?,
      ebookIcon: fields[4] as String?,
      description: fields[5] as String?,
      bookmarkedAt: fields[6] as DateTime,
      authorName: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BookmarkModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.ebookSlug)
      ..writeByte(2)
      ..write(obj.ebookName)
      ..writeByte(3)
      ..write(obj.ebookImage)
      ..writeByte(4)
      ..write(obj.ebookIcon)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.bookmarkedAt)
      ..writeByte(7)
      ..write(obj.authorName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookmarkModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
