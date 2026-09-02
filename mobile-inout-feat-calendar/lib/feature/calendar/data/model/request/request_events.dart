class RequestEvents {
  String? eventName;
  String? eventDateStart;
  String? eventDateEnd;
  String? locationId;
  String? status;
  String? created;
  String? createdby;
  String? updated;
  String? updatedby;
  List<String>? employeeIds;

  RequestEvents({
    this.eventName,
    this.eventDateStart,
    this.eventDateEnd,
    this.locationId,
    this.status,
    this.created,
    this.createdby,
    this.updated,
    this.updatedby,
    this.employeeIds,
  });

  RequestEvents.fromJson(Map<String, dynamic> json) {
    eventName = json['event_name'];
    eventDateStart = json['event_date_start'];
    eventDateEnd = json['event_date_end'];
    locationId = json['location_id'];
    status = json['status'];
    created = json['created'];
    createdby = json['createdby'];
    updated = json['updated'];
    updatedby = json['updatedby'];
    employeeIds = json['employee_ids'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['event_name'] = eventName;
    data['event_date_start'] = eventDateStart;
    data['event_date_end'] = eventDateEnd;
    data['location_id'] = locationId;
    data['status'] = status;
    data['created'] = created;
    data['createdby'] = createdby;
    data['updated'] = updated;
    data['updatedby'] = updatedby;
    data['employee_ids'] = employeeIds;
    return data;
  }
}
