class ChepterEntity {
  int? status;
  List<Record>? record;
  String? message;

  ChepterEntity({this.status, this.record, this.message});

  ChepterEntity.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['record'] != null) {
      record = <Record>[];
      json['record'].forEach((v) {
        record!.add(Record.fromJson(v));
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

class Record {
  String? ebookSlug;
  String? chapterName;
  Null chapterSlug;
  String? chapterrkey;

  Record(
      {this.ebookSlug, this.chapterName, this.chapterSlug, this.chapterrkey});

  Record.fromJson(Map<String, dynamic> json) {
    ebookSlug = json['ebookSlug'];
    chapterName = json['chapterName'];
    chapterSlug = json['chapterSlug'];
    chapterrkey = json['chapterrkey'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ebookSlug'] = ebookSlug;
    data['chapterName'] = chapterName;
    data['chapterSlug'] = chapterSlug;
    data['chapterrkey'] = chapterrkey;
    return data;
  }
}