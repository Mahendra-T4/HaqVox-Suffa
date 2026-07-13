class LoginEntity {
  int? status;
  String? message;
  Record? record;

  LoginEntity({this.status, this.message, this.record});

  LoginEntity.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    record = json['record'] != null ? Record.fromJson(json['record']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (record != null) {
      data['record'] = record!.toJson();
    }
    return data;
  }
}

class Record {
  String? uCode;
  String? uFirstName;
  String? uLastName;
  String? uEmail;
  String? uMobile;
  String? uAlternateNumber;
  String? uDOB;
  dynamic uGender;
  String? uGenderName;
  dynamic uSubscription;
  String? userKey;

  Record({
    this.uCode,
    this.uFirstName,
    this.uLastName,
    this.uEmail,
    this.uMobile,
    this.uAlternateNumber,
    this.uDOB,
    this.uGender,
    this.uGenderName,
    this.uSubscription,
    this.userKey,
  });

  Record.fromJson(Map<String, dynamic> json) {
    uCode = json['uCode'];
    uFirstName = json['uFirstName'];
    uLastName = json['uLastName'];
    uEmail = json['uEmail'];
    uMobile = json['uMobile'];
    uAlternateNumber = json['uAlternateNumber'];
    uDOB = json['uDOB'];
    uGender = json['uGender'];
    uGenderName = json['uGenderName'];
    uSubscription = json['uSubscription'];
    userKey = json['userKey'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uCode'] = uCode;
    data['uFirstName'] = uFirstName;
    data['uLastName'] = uLastName;
    data['uEmail'] = uEmail;
    data['uMobile'] = uMobile;
    data['uAlternateNumber'] = uAlternateNumber;
    data['uDOB'] = uDOB;
    data['uGender'] = uGender;
    data['uGenderName'] = uGenderName;
    data['uSubscription'] = uSubscription;
    data['userKey'] = userKey;
    return data;
  }
}
