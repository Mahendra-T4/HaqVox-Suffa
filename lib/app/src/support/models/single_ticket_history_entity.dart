class SingleTicketHistoryEntity {
  int? status;
  Record? record;
  String? message;

  SingleTicketHistoryEntity({this.status, this.record, this.message});

  SingleTicketHistoryEntity.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    record =
        json['record'] != null ? Record.fromJson(json['record']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (record != null) {
      data['record'] = record!.toJson();
    }
    data['message'] = message;
    return data;
  }
}

class Record {
  String? ticketNumber;
  String? ticketTitle;
  String? ticketSubjectID;
  String? ticketSubjectName;
  String? ticketMessage;
  String? ticketAttachment;
  String? ticketDate;
  int? ticketStatusID;
  String? ticketStatusName;

  Record(
      {this.ticketNumber,
      this.ticketTitle,
      this.ticketSubjectID,
      this.ticketSubjectName,
      this.ticketMessage,
      this.ticketAttachment,
      this.ticketDate,
      this.ticketStatusID,
      this.ticketStatusName});

  Record.fromJson(Map<String, dynamic> json) {
    ticketNumber = json['ticketNumber'];
    ticketTitle = json['ticketTitle'];
    ticketSubjectID = json['ticketSubjectID'];
    ticketSubjectName = json['ticketSubjectName'];
    ticketMessage = json['ticketMessage'];
    ticketAttachment = json['ticketAttachment'];
    ticketDate = json['ticketDate'];
    ticketStatusID = json['ticketStatusID'];
    ticketStatusName = json['ticketStatusName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ticketNumber'] = ticketNumber;
    data['ticketTitle'] = ticketTitle;
    data['ticketSubjectID'] = ticketSubjectID;
    data['ticketSubjectName'] = ticketSubjectName;
    data['ticketMessage'] = ticketMessage;
    data['ticketAttachment'] = ticketAttachment;
    data['ticketDate'] = ticketDate;
    data['ticketStatusID'] = ticketStatusID;
    data['ticketStatusName'] = ticketStatusName;
    return data;
  }
}