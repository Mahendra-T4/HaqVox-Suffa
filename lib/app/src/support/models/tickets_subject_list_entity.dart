class TicketsSubjectEntity {
  int? status;
  List<Record>? record;
  String? message;

  TicketsSubjectEntity({this.status, this.record, this.message});

  TicketsSubjectEntity.fromJson(Map<String, dynamic> json) {
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
  int? subjectID;
  String? subjectName;

  Record({this.subjectID, this.subjectName});

  Record.fromJson(Map<String, dynamic> json) {
    subjectID = json['subjectID'];
    subjectName = json['subjectName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['subjectID'] = subjectID;
    data['subjectName'] = subjectName;
    return data;
  }
}