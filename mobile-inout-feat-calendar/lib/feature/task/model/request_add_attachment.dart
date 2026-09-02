class RequestAddAttachment {
  String? taskId;
  String? attachmentUrl;
  String? attachmentType;
  String? attachmentName;
  int? isThumbnail;

  RequestAddAttachment({
    this.taskId,
    this.attachmentUrl,
    this.attachmentType,
    this.attachmentName,
    this.isThumbnail,
  });

  factory RequestAddAttachment.fromJson(Map<String, dynamic> json) { 
    return RequestAddAttachment(
        taskId: json['task_id'],
        attachmentUrl: json['attachment_url'],
        attachmentType: json['attachment_type'],
        attachmentName: json['attachment_name'],
        isThumbnail: json['is_thumbnail'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task_id': taskId,
      'attachment_url': attachmentUrl,
      'attachment_type': attachmentType,
      'attachment_name': attachmentName,
      'is_thumbnail': isThumbnail,
    };
  }
}