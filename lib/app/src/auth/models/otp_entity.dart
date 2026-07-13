class OTPVerificationEntity {
  int? status;
  String? message;

  OTPVerificationEntity({this.status, this.message});

  OTPVerificationEntity.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    return data;
  }
}




class OTPEntity {
  final String num1;
  final String num2;
  final String num3;
  final String num4;

  OTPEntity({
    required this.num1,
    required this.num2,
    required this.num3,
    required this.num4,
  });
}
