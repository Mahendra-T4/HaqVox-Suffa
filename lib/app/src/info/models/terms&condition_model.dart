class TermAndConditionEntity {
  int? status;
  Record? record;
  String? message;

  TermAndConditionEntity({this.status, this.record, this.message});

  TermAndConditionEntity.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    record =
        json['record'] != null ? Record.fromJson(json['record']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (record != null) {
      data['record'] = record!.toJson();
    }
    data['message'] = message;
    return data;
  }
}

class Record {
  String? pageHeading;
  String? pageDescription;

  Record({this.pageHeading, this.pageDescription});

  Record.fromJson(Map<String, dynamic> json) {
    pageHeading = json['pageHeading'];
    pageDescription = json['pageDescription'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pageHeading'] = pageHeading;
    data['pageDescription'] = pageDescription;
    return data;
  }
}
