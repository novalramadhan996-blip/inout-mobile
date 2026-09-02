class GroupShiftScheduleResponse {
  final String? groupShiftScheduleId;
  final int? businessDayId;
  final String? created;
  final String? createdBy;
  final String? groupShiftId;
  final String? shiftStartTime;
  final String? shiftEndTime;
  final String? updated;
  final String? updatedBy;
  final String? locationId; // not yet object
  final double? latitude; // not yet object
  final double? longitude; // not yet object
  final int? radius; // not yet object
  final String? locationName; // not yet object
  final BusinessDay? businessDay;
  final GroupShift? groupShift;

  GroupShiftScheduleResponse({
    this.groupShiftScheduleId,
    this.businessDayId,
    this.created,
    this.createdBy,
    this.groupShiftId,
    this.shiftStartTime,
    this.shiftEndTime,
    this.updated,
    this.updatedBy,
    this.locationId,
    this.latitude,
    this.longitude,
    this.radius,
    this.locationName,
    this.businessDay,
    this.groupShift,
  });

  factory GroupShiftScheduleResponse.fromJson(Map<String, dynamic> json) {
    return GroupShiftScheduleResponse(
      groupShiftScheduleId: json['group_shift_schedule_id'],
      businessDayId: json['business_day_id'],
      created: json['created'],
      createdBy: json['createdby'],
      groupShiftId: json['group_shift_id'],
      shiftStartTime: json['shift_start_time'],
      shiftEndTime: json['shift_end_time'],
      updated: json['updated'],
      updatedBy: json['updatedby'],
      businessDay: json['businessDay'] != null
          ? BusinessDay.fromJson(json['businessDay'])
          : null,
      groupShift: json['groupShift'] != null
          ? GroupShift.fromJson(json['groupShift'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group_shift_schedule_id': groupShiftScheduleId,
      'business_day_id': businessDayId,
      'created': created,
      'createdby': createdBy,
      'group_shift_id': groupShiftId,
      'shift_start_time': shiftStartTime,
      'shift_end_time': shiftEndTime,
      'updated': updated,
      'updatedby': updatedBy,
      'businessDay': businessDay?.toJson(),
      'groupShift': groupShift?.toJson(),
    };
  }
}

class BusinessDay {
  final int? businessDayId;
  final String? businessDay;
  final String? created;
  final String? createdBy;
  final String? updated;
  final String? updatedBy;

  BusinessDay({
    this.businessDayId,
    this.businessDay,
    this.created,
    this.createdBy,
    this.updated,
    this.updatedBy,
  });

  factory BusinessDay.fromJson(Map<String, dynamic> json) {
    return BusinessDay(
      businessDayId: json['business_day_id'],
      businessDay: json['business_day'],
      created: json['created'],
      createdBy: json['createdby'],
      updated: json['updated'],
      updatedBy: json['updatedby'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'business_day_id': businessDayId,
      'business_day': businessDay,
      'created': created,
      'createdby': createdBy,
      'updated': updated,
      'updatedby': updatedBy,
    };
  }
}

class GroupShift {
  final String? groupShiftId;
  final int? active;
  final String? appsId;
  final String? created;
  final String? createdBy;
  final String? descr;
  final String? groupShiftName;
  final String? updated;
  final String? updatedBy;

  GroupShift({
    this.groupShiftId,
    this.active,
    this.appsId,
    this.created,
    this.createdBy,
    this.descr,
    this.groupShiftName,
    this.updated,
    this.updatedBy,
  });

  factory GroupShift.fromJson(Map<String, dynamic> json) {
    return GroupShift(
      groupShiftId: json['group_shift_id'],
      active: json['active'],
      appsId: json['apps_id'],
      created: json['created'],
      createdBy: json['createdby'],
      descr: json['descr'],
      groupShiftName: json['group_shift_name'],
      updated: json['updated'],
      updatedBy: json['updatedby'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group_shift_id': groupShiftId,
      'active': active,
      'apps_id': appsId,
      'created': created,
      'createdby': createdBy,
      'descr': descr,
      'group_shift_name': groupShiftName,
      'updated': updated,
      'updatedby': updatedBy,
    };
  }
}