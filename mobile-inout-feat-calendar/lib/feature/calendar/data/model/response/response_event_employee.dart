class ResponseEventEmployee {
  String? eventEmployeeId;
  String? eventId;
  String? employeeId;
  String? employeeName;
  String? checkIn;
  String? checkOut;
  double? checkInLatitude;
  double? checkInLongitude;
  double? checkOutLatitude;
  double? checkOutLongitude;
  String? photoUrl;
  String? created;
  String? createdby;
  String? updated;
  String? updatedby;

  ResponseEventEmployee({
    this.eventEmployeeId,
    this.eventId,
    this.employeeId,
    this.employeeName,
    this.checkIn,
    this.checkOut,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.photoUrl,
    this.created,
    this.createdby,
    this.updated,
    this.updatedby,
  });

  ResponseEventEmployee.fromJson(Map<String, dynamic> json) {
    eventEmployeeId = json['event_employee_id'];
    eventId = json['event_id'];
    employeeId = json['employee_id'];
    employeeName = json['employee_name'];
    checkIn = json['check_in'];
    checkOut = json['check_out'];
    checkInLatitude = (json['check_in_latitude'] as num?)?.toDouble();
    checkInLongitude = (json['check_in_longitude'] as num?)?.toDouble();
    checkOutLatitude = (json['check_out_latitude'] as num?)?.toDouble();
    checkOutLongitude = (json['check_out_longitude'] as num?)?.toDouble();
    photoUrl = json['photo_url'];
    created = json['created'];
    createdby = json['createdby'];
    updated = json['updated'];
    updatedby = json['updatedby'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['event_employee_id'] = eventEmployeeId;
    data['event_id'] = eventId;
    data['employee_id'] = employeeId;
    data['employee_name'] = employeeName;
    data['check_in'] = checkIn;
    data['check_out'] = checkOut;
    data['check_in_latitude'] = checkInLatitude;
    data['check_in_longitude'] = checkInLongitude;
    data['check_out_latitude'] = checkOutLatitude;
    data['check_out_longitude'] = checkOutLongitude;
    data['photo_url'] = photoUrl;
    data['created'] = created;
    data['createdby'] = createdby;
    data['updated'] = updated;
    data['updatedby'] = updatedby;
    return data;
  }

  static List<ResponseEventEmployee> fromList(List<dynamic> data) {
    return data.map((e) => ResponseEventEmployee.fromJson(e)).toList();
  }
}
