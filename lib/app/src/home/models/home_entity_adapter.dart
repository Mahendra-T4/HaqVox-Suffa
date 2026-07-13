import 'package:hive/hive.dart';
import 'package:haqvox/app/src/home/models/home_entity.dart';

class CategoryAdapter extends TypeAdapter<Category> {
  @override
  final int typeId = 1;

  @override
  Category read(BinaryReader reader) {
    return Category(
      categoryName: reader.readString(),
      categoryIcon: reader.readString(),
      categorySlug: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Category obj) {
    writer.writeString(obj.categoryName);
    writer.writeString(obj.categoryIcon);
    writer.writeString(obj.categorySlug);
  }
}

class BookAdapter extends TypeAdapter<Book> {
  @override
  final int typeId = 2;

  @override
  Book read(BinaryReader reader) {
    return Book(
      ebookName: reader.readString(),
      ebookIcon: reader.readString(),
      ebookImage: reader.readString(),
      ebookTagline: reader.readString(),
      ebookDescription: reader.readString(),
      ebookSlug: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Book obj) {
    writer.writeString(obj.ebookName);
    writer.writeString(obj.ebookIcon);
    writer.writeString(obj.ebookImage);
    writer.writeString(obj.ebookTagline);
    writer.writeString(obj.ebookDescription);
    writer.writeString(obj.ebookSlug);
  }
}
