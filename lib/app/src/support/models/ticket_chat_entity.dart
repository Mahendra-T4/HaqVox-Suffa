class TicketChatResponseEntity {
  int? status;
  String? message;
  bool? isUser;

  TicketChatResponseEntity({this.status, this.message,this.isUser});

  TicketChatResponseEntity.fromJson(Map<String, dynamic> json) {
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
