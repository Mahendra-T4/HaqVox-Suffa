class NotificationEntity {
  int? status;
  List<Record>? record;
  String? message;

  NotificationEntity({this.status, this.record, this.message});

  NotificationEntity.fromJson(Map<String, dynamic> json) {
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
  String? notMsg;
  String? notDate;

  Record({this.notMsg, this.notDate});

  Record.fromJson(Map<String, dynamic> json) {
    notMsg = json['notMsg'];
    notDate = json['notDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['notMsg'] = notMsg;
    data['notDate'] = notDate;
    return data;
  }
}