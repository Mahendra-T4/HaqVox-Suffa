class MySpaceListEntity {
  int? status;
  List<RecordSpace>? record;
  String? message;

  MySpaceListEntity({this.status, this.record, this.message});

  MySpaceListEntity.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['record'] != null) {
      record = <RecordSpace>[];
      json['record'].forEach((v) {
        record!.add(RecordSpace.fromJson(v));
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

class RecordSpace {
  String? audioName;
  String? audioPath;
  String? chapterSlug;
  String? ebookSlug;
  String? audioSlug;
  String? mySpaceDate;
  String? mySpaceKey;
  String? imageUrl; // Added field for image URL
  String? coverImageUrl; // Added field for cover image URL

  RecordSpace({
    this.audioName,
    this.audioPath,
    this.chapterSlug,
    this.ebookSlug,
    this.audioSlug,
    this.mySpaceDate,
    this.mySpaceKey,
    this.imageUrl,
    this.coverImageUrl,
  });

  RecordSpace.fromJson(Map<String, dynamic> json) {
    audioName = json['audioName'];
    audioPath = json['audioPath'];
    chapterSlug = json['chapterSlug'];
    ebookSlug = json['ebookSlug'];
    audioSlug = json['audioSlug'];
    mySpaceDate = json['mySpaceDate'];
    mySpaceKey = json['mySpaceKey'];
    imageUrl = json['imageUrl'] ?? json['image']; // Support both field names
    coverImageUrl =
        json['coverImageUrl'] ?? json['coverImage']; // Support both field names
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['audioName'] = audioName;
    data['audioPath'] = audioPath;
    data['chapterSlug'] = chapterSlug;
    data['ebookSlug'] = ebookSlug;
    data['audioSlug'] = audioSlug;
    data['mySpaceDate'] = mySpaceDate;
    data['mySpaceKey'] = mySpaceKey;
    data['imageUrl'] = imageUrl;
    data['coverImageUrl'] = coverImageUrl;
    return data;
  }
}
