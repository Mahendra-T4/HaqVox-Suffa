class FAQEntity {
  int? status;
  List<Record>? record;
  String? message;

  FAQEntity({this.status, this.record, this.message});

  FAQEntity.fromJson(Map<String, dynamic> json) {
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
  String? faqCategory;
  List<FaqRecord>? faqRecord;

  Record({this.faqCategory, this.faqRecord});

  Record.fromJson(Map<String, dynamic> json) {
    faqCategory = json['faqCategory'];
    if (json['faqRecord'] != null) {
      faqRecord = <FaqRecord>[];
      json['faqRecord'].forEach((v) {
        faqRecord!.add(FaqRecord.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['faqCategory'] = faqCategory;
    if (faqRecord != null) {
      data['faqRecord'] = faqRecord!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FaqRecord {
  String? question;
  String? answer;

  FaqRecord({this.question, this.answer});

  FaqRecord.fromJson(Map<String, dynamic> json) {
    question = json['question'];
    answer = json['answer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['question'] = question;
    data['answer'] = answer;
    return data;
  }
}