class EBooks {
  int? status;
  List<Record>? record;
  String? message;

  EBooks({this.status, this.record, this.message});

  EBooks.fromJson(Map<String, dynamic> json) {
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
  String? ebookName;
  String? description;
  String? slug;
  String? searchkeyword;
  String? ebookrkey;

  Record(
      {this.ebookName,
      this.description,
      this.slug,
      this.searchkeyword,
      this.ebookrkey});

  Record.fromJson(Map<String, dynamic> json) {
    ebookName = json['ebookName'];
    description = json['description'];
    slug = json['slug'];
    searchkeyword = json['searchkeyword'];
    ebookrkey = json['ebookrkey'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ebookName'] = ebookName;
    data['description'] = description;
    data['slug'] = slug;
    data['searchkeyword'] = searchkeyword;
    data['ebookrkey'] = ebookrkey;
    return data;
  }
}