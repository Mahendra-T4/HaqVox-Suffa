class RegisterEntity {
  int? status;
  String? message;
  String? uOTP;
  String? rKey;

  RegisterEntity({this.status, this.message, this.uOTP, this.rKey});
  RegisterEntity.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    // Handle case where uOTP might be an integer in the response
    uOTP = json['uOTP']?.toString();
    rKey = json['rKey']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['uOTP'] = uOTP;
    data['rKey'] = rKey;
    return data;
  }
}
