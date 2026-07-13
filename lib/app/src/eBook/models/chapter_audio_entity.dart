class ChapterAudioEntity {
  int? status;
  List<Record>? record;
  String? message;

  ChapterAudioEntity({this.status, this.record, this.message});

  ChapterAudioEntity.fromJson(Map<String, dynamic> json) {
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
  String? audioName;
  String? audioPath;
  String? audioSlug;

  Record({this.audioName, this.audioPath, this.audioSlug});

  Record.fromJson(Map<String, dynamic> json) {
    audioName = json['audioName'];
    audioPath = json['audioPath'];
    audioSlug = json['audioSlug'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['audioName'] = audioName;
    data['audioPath'] = audioPath;
    data['audioSlug'] = audioSlug;
    return data;
  }
}