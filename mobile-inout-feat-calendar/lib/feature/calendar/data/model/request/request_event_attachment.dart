class RequestEventAttachment {
  String? eventAttachmentId;
  String? eventId;
  String? employeeId;
  String? employeeName;
  String? attachmentUrl;
  String? attachmentName;
  String? attachmentType;
  String? created;
  String? createdby;
  String? updated;
  String? updatedby;

  RequestEventAttachment({
    this.eventAttachmentId,
    this.eventId,
    this.employeeId,
    this.employeeName,
    this.attachmentUrl,
    this.attachmentName,
    this.attachmentType,
    this.created,
    this.createdby,
    this.updated,
    this.updatedby,
  });

  RequestEventAttachment.fromJson(Map<String, dynamic> json) {
    eventAttachmentId = json['event_attachment_id'];
    eventId = json['event_id'];
    employeeId = json['employee_id'];
    employeeName = json['employee_name'];
    attachmentUrl = json['attachment_url'];
    attachmentName = json['attachment_name'];
    attachmentType = json['attachment_type'];
    created = json['created'];
    createdby = json['createdby'];
    updated = json['updated'];
    updatedby = json['updatedby'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['event_attachment_id'] = eventAttachmentId;
    data['event_id'] = eventId;
    data['employee_id'] = employeeId;
    data['employee_name'] = employeeName;
    data['attachment_url'] = attachmentUrl;
    data['attachment_name'] = attachmentName;
    data['attachment_type'] = attachmentType;
    data['created'] = created;
    data['createdby'] = createdby;
    data['updated'] = updated;
    data['updatedby'] = updatedby;
    return data;
  }
}
