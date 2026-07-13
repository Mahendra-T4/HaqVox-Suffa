import 'package:hive/hive.dart';

part 'bookmark_model.g.dart';

@HiveType(typeId: 3)
class BookmarkModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String ebookSlug;

  @HiveField(2)
  String ebookName;

  @HiveField(3)
  String? ebookImage;

  @HiveField(4)
  String? ebookIcon;

  @HiveField(5)
  String? description;

  @HiveField(6)
  DateTime bookmarkedAt;

  @HiveField(7)
  String? authorName;

  BookmarkModel({
    required this.id,
    required this.ebookSlug,
    required this.ebookName,
    this.ebookImage,
    this.ebookIcon,
    this.description,
    required this.bookmarkedAt,
    this.authorName,
  });

  @override
  String toString() =>
      'BookmarkModel(id: $id, ebookSlug: $ebookSlug, ebookName: $ebookName)';
}
