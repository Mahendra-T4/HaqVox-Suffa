// Model classes for home layout data
// Generated from JSON structure with null safety

class HomeEntity {
  final int? status;
  final Record? record;
  final String? message;

  HomeEntity({this.status, this.record, this.message});

  factory HomeEntity.fromJson(Map<String, dynamic> json) {
    return HomeEntity(
      status: json['status'] as int,
      record: Record.fromJson(json['record'] as Map<String, dynamic>),
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'record': record!.toJson(),
    'message': message,
  };
}

class Record {
  final List<Category> categoryList;
  final List<Book> recommendedBook;
  final List<Book> trendingBook;
  final List<Book> latestBook;

  Record({
    required this.categoryList,
    required this.recommendedBook,
    required this.trendingBook,
    required this.latestBook,
  });

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      categoryList:
          (json['categoryList'] as List<dynamic>)
              .map((e) => Category.fromJson(e as Map<String, dynamic>))
              .toList(),
      recommendedBook:
          (json['recommendedBook'] as List<dynamic>)
              .map((e) => Book.fromJson(e as Map<String, dynamic>))
              .toList(),
      trendingBook:
          (json['trendingBook'] as List<dynamic>)
              .map((e) => Book.fromJson(e as Map<String, dynamic>))
              .toList(),
      latestBook:
          (json['latestBook'] as List<dynamic>)
              .map((e) => Book.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'categoryList': categoryList.map((e) => e.toJson()).toList(),
    'recommendedBook': recommendedBook.map((e) => e.toJson()).toList(),
    'trendingBook': trendingBook.map((e) => e.toJson()).toList(),
    'latestBook': latestBook.map((e) => e.toJson()).toList(),
  };
}

class Category {
  final String categoryName;
  final String categoryIcon;
  final String categorySlug;

  Category({
    required this.categoryName,
    required this.categoryIcon,
    required this.categorySlug,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryName: json['categoryName'] as String,
      categoryIcon: json['categoryIcon'] as String,
      categorySlug: json['categorySlug'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'categoryName': categoryName,
    'categoryIcon': categoryIcon,
    'categorySlug': categorySlug,
  };
}

class Book {
  final String ebookName;
  final String ebookIcon;
  final String ebookImage;
  final String ebookTagline;
  final String ebookDescription;
  final String ebookSlug;

  Book({
    required this.ebookName,
    required this.ebookIcon,
    required this.ebookImage,
    required this.ebookTagline,
    required this.ebookDescription,
    required this.ebookSlug,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      ebookName: json['ebookName'] as String,
      ebookIcon: json['ebookIcon'] as String,
      ebookImage: json['ebookImage'] as String,
      ebookTagline: json['ebookTagline'] as String,
      ebookDescription: json['ebookDescription'] as String,
      ebookSlug: json['ebookSlug'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'ebookName': ebookName,
    'ebookIcon': ebookIcon,
    'ebookImage': ebookImage,
    'ebookTagline': ebookTagline,
    'ebookDescription': ebookDescription,
    'ebookSlug': ebookSlug,
  };
}
