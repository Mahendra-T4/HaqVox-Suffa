class UserModel {
  String? uCode;
  String? uFirstName;
  String? uLastName;
  String? uEmail;
  String? uMobile;
  String? uAlternateNumber;
  String? uDOB;
  int? uGender;
  String? uGenderName;
  String? userKey;

  UserModel(
      {this.uCode,
      this.uFirstName,
      this.uLastName,
      this.uEmail,
      this.uMobile,
      this.uAlternateNumber,
      this.uDOB,
      this.uGender,
      this.uGenderName,
      this.userKey});

  UserModel.fromJson(Map<String, dynamic> json) {
    uCode = json['uCode'];
    uFirstName = json['uFirstName'];
    uLastName = json['uLastName'];
    uEmail = json['uEmail'];
    uMobile = json['uMobile'];
    uAlternateNumber = json['uAlternateNumber'];
    uDOB = json['uDOB'];
    uGender = json['uGender'];
    uGenderName = json['uGenderName'];
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
    data['userKey'] = userKey;
    return data;
  }
}