import 'package:mobile_in_out/feature/calendar/data/model/response/response_event_employee.dart';

class ResponseEvents {
  String? eventId;
  String? eventName;
  String? eventDateStart;
  String? eventDateEnd;
  String? locationId;
  String? status;
  String? created;
  String? createdby;
  String? updated;
  String? updatedby;
  List<ResponseEventEmployee>? employeeList;

  ResponseEvents({
    this.eventId,
    this.eventName,
    this.eventDateStart,
    this.eventDateEnd,
    this.locationId,
    this.status,
    this.created,
    this.createdby,
    this.updated,
    this.updatedby,
    this.employeeList,
  });

  ResponseEvents.fromJson(Map<String, dynamic> json) {
    eventId = json['event_id'];
    eventName = json['event_name'];
    eventDateStart = json['event_date_start'];
    eventDateEnd = json['event_date_end'];
    locationId = json['location_id'];
    status = json['status'];
    created = json['created'];
    createdby = json['createdby'];
    updated = json['updated'];
    updatedby = json['updatedby'];
    employeeList = json['employee_list'] != null
        ? ResponseEventEmployee.fromList(json['employee_list'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['event_id'] = eventId;
    data['event_name'] = eventName;
    data['event_date_start'] = eventDateStart;
    data['event_date_end'] = eventDateEnd;
    data['location_id'] = locationId;
    data['status'] = status;
    data['created'] = created;
    data['createdby'] = createdby;
    data['updated'] = updated;
    data['updatedby'] = updatedby;
    data['employee_list'] = employeeList
        ?.map((e) => e.toJson())
        .toList();
    return data;
  }

  static List<ResponseEvents> fromList(List<dynamic> data) {
    return data.map((e) => ResponseEvents.fromJson(e)).toList();
  }
}
