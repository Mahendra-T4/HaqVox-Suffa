class GenderEntity {
  int? status;
  List<Record>? record;
  String? message;

  GenderEntity({this.status, this.record, this.message});

  GenderEntity.fromJson(Map<String, dynamic> json) {
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
  int? genderID;
  String? genderName;

  Record({this.genderID, this.genderName});

  Record.fromJson(Map<String, dynamic> json) {
    genderID = json['genderID']; // Convert to string
    genderName = json['genderName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['genderID'] = genderID;
    data['genderName'] = genderName;
    return data;
  }
}
