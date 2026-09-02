class ResponseAttachment {
  String? attachmentId;
  String? taskId;
  String? attachmentUrl;
  String? attachmentName;
  String? attachmentType;
  int? isThumbnail;

  ResponseAttachment({
    this.attachmentId,
    this.taskId,
    this.attachmentUrl,
    this.attachmentName,
    this.attachmentType,
    this.isThumbnail,
  });

  factory ResponseAttachment.fromJson(Map<String, dynamic> json) {
    return ResponseAttachment(
      attachmentId: json['attachment_id'],
      taskId: json['task_id'],
      attachmentUrl: json['attachment_url'],
      attachmentName: json['attachment_name'],
      attachmentType: json['attachment_type'],
      isThumbnail: json['is_thumbnail'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attachment_id': attachmentId,
      'task_id': taskId,
      'attachment_url': attachmentUrl,
      'attachment_name': attachmentName,
      'attachment_type': attachmentType,
      'is_thumbnail': isThumbnail
    };
  }
}