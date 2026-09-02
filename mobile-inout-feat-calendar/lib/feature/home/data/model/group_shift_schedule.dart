class GroupShiftSchedule {
  String? businessDay;
  String? groupShift;
  String? groupShiftScheduleId;
  int? businessDayId;
  String? created;
  String? createdby;
  String? groupShiftId;
  String? shiftEndTime;
  String? shiftStartTime;
  String? updated;
  String? updatedby;

  GroupShiftSchedule({
    this.businessDay,
    this.groupShift,
    this.groupShiftScheduleId,
    this.businessDayId,
    this.created,
    this.createdby,
    this.groupShiftId,
    this.shiftEndTime,
    this.shiftStartTime,
    this.updated,
    this.updatedby,
  });

  factory GroupShiftSchedule.fromJson(Map<String, dynamic> json) {
    return GroupShiftSchedule(
      businessDay: json["businessDay"],
      groupShift: json["groupShift"],
      groupShiftScheduleId: json["group_shift_schedule_id"],
      businessDayId: json["business_day_id"],
      created: json["created"],
      createdby: json["createdby"],
      groupShiftId: json["group_shift_id"],
      shiftEndTime: json["shift_end_time"],
      shiftStartTime: json["shift_start_time"],
      updated: json["updated"],
      updatedby: json["updatedby"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "businessDay": businessDay,
      "groupShift": groupShift,
      "group_shift_schedule_id": groupShiftScheduleId,
      "business_day_id": businessDayId,
      "created": created,
      "createdby": createdby,
      "group_shift_id": groupShiftId,
      "shift_end_time": shiftEndTime,
      "shift_start_time": shiftStartTime,
      "updated": updated,
      "updatedby": updatedby,
    };
  }
}
