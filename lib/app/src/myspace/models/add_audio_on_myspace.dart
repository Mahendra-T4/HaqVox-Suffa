class AddOnMySpaceEntity {
  int? status;
  String? message;
  String? rKey;

  AddOnMySpaceEntity({this.status, this.message, this.rKey});

  AddOnMySpaceEntity.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    rKey = json['rKey'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['rKey'] = rKey;
    return data;
  }
}
