class SubscriptionsPlanEntity {
  int? status;
  List<Record>? record;
  String? message;

  SubscriptionsPlanEntity({this.status, this.record, this.message});

  SubscriptionsPlanEntity.fromJson(Map<String, dynamic> json) {
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
  dynamic subscriptionID;
  dynamic subscriptionPrice;
  String? subscriptionFor;

  Record({this.subscriptionID, this.subscriptionPrice, this.subscriptionFor});

  Record.fromJson(Map<String, dynamic> json) {
    subscriptionID = json['subscriptionID'];
    subscriptionPrice = json['subscriptionPrice'];
    subscriptionFor = json['subscriptionFor'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['subscriptionID'] = subscriptionID;
    data['subscriptionPrice'] = subscriptionPrice;
    data['subscriptionFor'] = subscriptionFor;
    return data;
  }
}
