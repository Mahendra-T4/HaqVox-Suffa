class EditProfileEntity {
  int? status;
  String? message;
  dynamic uOTP;

  EditProfileEntity({this.status, this.message, this.uOTP});

  EditProfileEntity.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    uOTP = json['uOTP'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['uOTP'] = uOTP;
    return data;
  }
}
