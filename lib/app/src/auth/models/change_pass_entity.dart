class ChangePasswordEntity {
  int? status;
  String? message;
  String? redirect;

  ChangePasswordEntity({this.status, this.message, this.redirect});

  ChangePasswordEntity.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    redirect = json['redirect'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['redirect'] = redirect;
    return data;
  }
}
