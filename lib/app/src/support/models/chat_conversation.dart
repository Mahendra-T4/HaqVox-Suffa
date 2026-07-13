class ChatConversationEntity {
  int? status;
  List<Record>? record;
  String? message;
  final bool isUser = true;

  ChatConversationEntity({this.status, this.record, this.message,});

  ChatConversationEntity.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['record'] != null) {
      record = <Record>[];
      json['record'].forEach((v) {
        record!.add(Record.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (record != null) {
      data['record'] = record!.map((v) => v.toJson()).toList();
    }
    data['message'] = message;
    return data;
  }
}

class Record {
  String? ticketMessage;
  String? ticketAttachment;
  String? ticketDate;
  String? ticketUser;
  String? chatByName;

  Record(
      {this.ticketMessage,
      this.ticketAttachment,
      this.ticketDate,
      this.ticketUser,
      this.chatByName});

  Record.fromJson(Map<String, dynamic> json) {
    ticketMessage = json['ticketMessage'];
    ticketAttachment = json['ticketAttachment'];
    ticketDate = json['ticketDate'];
    ticketUser = json['ticketUser'];
    chatByName = json['chatByName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ticketMessage'] = ticketMessage;
    data['ticketAttachment'] = ticketAttachment;
    data['ticketDate'] = ticketDate;
    data['ticketUser'] = ticketUser;
    data['chatByName'] = chatByName;
    return data;
  }
}