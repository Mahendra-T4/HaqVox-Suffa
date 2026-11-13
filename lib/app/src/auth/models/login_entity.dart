class LoginEntity {
  Record? record;

  LoginEntity({this.record});

  LoginEntity.fromJson(Map<String, dynamic> json) {
    record =
        json['record'] != null ? new Record.fromJson(json['record']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.record != null) {
      data['record'] = this.record!.toJson();
    }
    return data;
  }
}

class Record {
  int? status;
  String? message;
  String? uCode;
  String? uFirstName;
  String? uLastName;
  String? uEmail;
  String? uMobile;
  String? uAlternateNumber;
  String? uDOB;
  String? uDOBText;
  String? uGender;
  String? uGenderName;
  int? uSubscription;
  String? subscriberStatus;
  String? userKey;

  Record({
    this.status,
    this.message,
    this.uCode,
    this.uFirstName,
    this.uLastName,
    this.uEmail,
    this.uMobile,
    this.uAlternateNumber,
    this.uDOB,
    this.uDOBText,
    this.uGender,
    this.uGenderName,
    this.uSubscription,
    this.subscriberStatus,
    this.userKey,
  });

  Record.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    uCode = json['uCode'];
    uFirstName = json['uFirstName'];
    uLastName = json['uLastName'];
    uEmail = json['uEmail'];
    uMobile = json['uMobile'];
    uAlternateNumber = json['uAlternateNumber'];
    uDOB = json['uDOB'];
    uDOBText = json['uDOBText'];
    uGender = json['uGender'];
    uGenderName = json['uGenderName'];
    uSubscription = json['uSubscription'];
    subscriberStatus = json['subscriberStatus'];
    userKey = json['userKey'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['uCode'] = this.uCode;
    data['uFirstName'] = this.uFirstName;
    data['uLastName'] = this.uLastName;
    data['uEmail'] = this.uEmail;
    data['uMobile'] = this.uMobile;
    data['uAlternateNumber'] = this.uAlternateNumber;
    data['uDOB'] = this.uDOB;
    data['uDOBText'] = this.uDOBText;
    data['uGender'] = this.uGender;
    data['uGenderName'] = this.uGenderName;
    data['uSubscription'] = this.uSubscription;
    data['subscriberStatus'] = this.subscriberStatus;
    data['userKey'] = this.userKey;
    return data;
  }
}
