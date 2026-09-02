class GroupShiftModel {
    final GroupShift? groupShift;
    final Location? location;
    final String? groupShiftScheduleId;
    final String? groupShiftId;
    final String? day;
    final String? timeIn;
    final String? timeOut;
    final String? locationId;

    GroupShiftModel({
        this.groupShift,
        this.location,
        this.groupShiftScheduleId,
        this.groupShiftId,
        this.day,
        this.timeIn,
        this.timeOut,
        this.locationId,
    });

    factory GroupShiftModel.fromJson(Map<String, dynamic> json) => GroupShiftModel(
        groupShift: json["groupShift"] == null ? null : GroupShift.fromJson(json["groupShift"]),
        location: json["location"] == null ? null : Location.fromJson(json["location"]),
        groupShiftScheduleId: json["group_shift_schedule_id"],
        groupShiftId: json["group_shift_id"],
        day: json["day"],
        timeIn: json["time_in"],
        timeOut: json["time_out"],
        locationId: json["location_id"],
    );

    Map<String, dynamic> toJson() => {
        "groupShift": groupShift?.toJson(),
        "location": location?.toJson(),
        "group_shift_schedule_id": groupShiftScheduleId,
        "group_shift_id": groupShiftId,
        "day": day,
        "time_in": timeIn,
        "time_out": timeOut,
        "location_id": locationId,
    };
}

class GroupShift {
    final String? groupShiftId;
    final String? shiftName;
    final DateTime? startDate;
    final int? active;
    final String? appsId;
    final DateTime? created;
    final String? createdby;

    GroupShift({
        this.groupShiftId,
        this.shiftName,
        this.startDate,
        this.active,
        this.appsId,
        this.created,
        this.createdby,
    });

    factory GroupShift.fromJson(Map<String, dynamic> json) => GroupShift(
        groupShiftId: json["group_shift_id"],
        shiftName: json["shift_name"],
        startDate: json["start_date"] == null ? null : DateTime.parse(json["start_date"]),
        active: json["active"],
        appsId: json["apps_id"],
        created: json["created"] == null ? null : DateTime.parse(json["created"]),
        createdby: json["createdby"],
    );

    Map<String, dynamic> toJson() => {
        "group_shift_id": groupShiftId,
        "shift_name": shiftName,
        "start_date": startDate?.toIso8601String(),
        "active": active,
        "apps_id": appsId,
        "created": created?.toIso8601String(),
        "createdby": createdby,
    };
}

class Location {
    final String? locationId;
    final String? locationName;
    final String? address;
    final String? detailAddress;
    final double? latitude;
    final double? longitude;
    final DateTime? created;
    final DateTime? updated;
    final int? radius;
    final String? appsId;

    Location({
        this.locationId,
        this.locationName,
        this.address,
        this.detailAddress,
        this.latitude,
        this.longitude,
        this.created,
        this.updated,
        this.radius,
        this.appsId,
    });

    factory Location.fromJson(Map<String, dynamic> json) => Location(
        locationId: json["location_id"],
        locationName: json["location_name"],
        address: json["address"],
        detailAddress: json["detail_address"],
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
        created: json["created"] == null ? null : DateTime.parse(json["created"]),
        updated: json["updated"] == null ? null : DateTime.parse(json["updated"]),
        radius: json["radius"],
        appsId: json["apps_id"],
    );

    Map<String, dynamic> toJson() => {
        "location_id": locationId,
        "location_name": locationName,
        "address": address,
        "detail_address": detailAddress,
        "latitude": latitude,
        "longitude": longitude,
        "created": created?.toIso8601String(),
        "updated": updated?.toIso8601String(),
        "radius": radius,
        "apps_id": appsId,
    };
}
