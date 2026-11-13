class TermAndConditionEntity {
  int? status;
  String? pageURL;
  String? message;

  TermAndConditionEntity({this.status, this.pageURL, this.message});

  TermAndConditionEntity.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    String? rawUrl = json['pageURL'];
    if (rawUrl != null && !rawUrl.contains('index.php') && rawUrl.contains('/haqvox/')) {
      rawUrl = rawUrl.replaceFirst('/haqvox/', '/haqvox/index.php/');
    }
    pageURL = rawUrl;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['pageURL'] = this.pageURL;
    data['message'] = this.message;
    return data;
  }
}
