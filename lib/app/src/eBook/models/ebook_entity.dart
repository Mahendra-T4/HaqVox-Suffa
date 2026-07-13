import 'package:hive/hive.dart';
part 'ebook_entity.g.dart';

class EBookEntity {
  int? status;
  List<EBookRecord>? record;
  String? message;

  EBookEntity({this.status, this.record, this.message});

  EBookEntity.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['record'] != null) {
      record = <EBookRecord>[];
      json['record'].forEach((v) {
        record!.add(EBookRecord.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (record != null) {
      data['record'] = record!.map((v) => v.toJson()).toList();
    }
    data['message'] = message;
    return data;
  }
}

@HiveType(typeId: 1)
class EBookRecord extends HiveObject {
  @HiveField(0)
  String? ebookName;
  @HiveField(1)
  String? ebookIcon;
  @HiveField(2)
  String? ebookImage;
  @HiveField(3)
  String? ebookTagline;
  @HiveField(4)
  String? ebookDescription;
  @HiveField(5)
  String? ebookSlug;

  EBookRecord({
    this.ebookName,
    this.ebookIcon,
    this.ebookImage,
    this.ebookTagline,
    this.ebookDescription,
    this.ebookSlug,
  });

  EBookRecord.fromJson(Map<String, dynamic> json) {
    ebookName = json['ebookName'];
    ebookIcon = json['ebookIcon'];
    ebookImage = json['ebookImage'];
    ebookTagline = json['ebookTagline'];
    ebookDescription = json['ebookDescription'];
    ebookSlug = json['ebookSlug'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ebookName'] = ebookName;
    data['ebookIcon'] = ebookIcon;
    data['ebookImage'] = ebookImage;
    data['ebookTagline'] = ebookTagline;
    data['ebookDescription'] = ebookDescription;
    data['ebookSlug'] = ebookSlug;
    return data;
  }
}
