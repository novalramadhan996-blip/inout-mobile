class AbsenceHistoryModel {
  final String? attendanceId;
  final String? employeeId;
  final String? employeeName;
  final String? jobTitle;
  final String? organizationId;
  final String? organizationName;
  final String? workingLocationId;
  final String? workingLocationName;
  final String? workingLocationAddress;
  final double? workingLatitude;
  final double? workingLongitude;
  final String? workingTimeIn;
  final String? workingTimeOut;
  final String? deviceId;
  final String? deviceInfo;
  final String? dateIn;
  final String? dateOut;
  final String? timeIn;
  final String? timeOut;
  final String? status;
  final double? latitudeIn;
  final double? longitudeIn;
  final String? addressIn;
  final double? latitudeOut;
  final double? longitudeOut;
  final String? addressOut;
  final String? noteIn;
  final String? noteOut;
  final String? photoInUrl;
  final String? photoOutUrl;
  final String? faceInUrl;
  final String? faceOutUrl;
  final double? radiusIn;
  final double? radiusOut;
  final int? diffTimeIn;
  final int? diffTimeOut;
  final String? appsId;
  final String? created;
  final String? createdBy;

  AbsenceHistoryModel({
    this.attendanceId,
    this.employeeId,
    this.employeeName,
    this.jobTitle,
    this.organizationId,
    this.organizationName,
    this.workingLocationId,
    this.workingLocationName,
    this.workingLocationAddress,
    this.workingLatitude,
    this.workingLongitude,
    this.workingTimeIn,
    this.workingTimeOut,
    this.deviceId,
    this.deviceInfo,
    this.dateIn,
    this.dateOut,
    this.timeIn,
    this.timeOut,
    this.status,
    this.latitudeIn,
    this.longitudeIn,
    this.addressIn,
    this.latitudeOut,
    this.longitudeOut,
    this.addressOut,
    this.noteIn,
    this.noteOut,
    this.photoInUrl,
    this.photoOutUrl,
    this.faceInUrl,
    this.faceOutUrl,
    this.radiusIn,
    this.radiusOut,
    this.diffTimeIn,
    this.diffTimeOut,
    this.appsId,
    this.created,
    this.createdBy,
  });

  factory AbsenceHistoryModel.fromJson(Map<String, dynamic> json) {
    return AbsenceHistoryModel(
      attendanceId: json["attendance_id"],
      employeeId: json["employee_id"],
      employeeName: json["employee_name"],
      jobTitle: json["job_title"],
      organizationId: json["organization_id"],
      organizationName: json["organization_name"],
      workingLocationId: json["working_location_id"],
      workingLocationName: json["working_location_name"],
      workingLocationAddress: json["working_location_address"],
      workingLatitude: json["working_latitude"]?.toDouble(),
      workingLongitude: json["working_longitude"]?.toDouble(),
      workingTimeIn: json["working_time_in"],
      workingTimeOut: json["working_time_out"],
      deviceId: json["device_id"],
      deviceInfo: json["device_info"],
      dateIn: json["date_in"],
      dateOut: json["date_out"],
      timeIn: json["time_in"],
      timeOut: json["time_out"],
      status: json["status"],
      latitudeIn: json["latitude_in"]?.toDouble(),
      longitudeIn: json["longitude_in"]?.toDouble(),
      addressIn: json["address_in"],
      latitudeOut: json["latitude_out"]?.toDouble(),
      longitudeOut: json["longitude_out"]?.toDouble(),
      addressOut: json["address_out"],
      noteIn: json["note_in"],
      noteOut: json["note_out"],
      photoInUrl: json["photo_in_url"],
      photoOutUrl: json["photo_out_url"],
      faceInUrl: json["face_in_url"],
      faceOutUrl: json["face_out_url"],
      radiusIn: json["radius_in"]?.toDouble(),
      radiusOut: json["radius_out"]?.toDouble(),
      diffTimeIn: json["diff_time_in"],
      diffTimeOut: json["diff_time_out"],
      appsId: json["apps_id"],
      created: json["created"],
      createdBy: json["createdby"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "attendance_id": attendanceId,
      "employee_id": employeeId,
      "employee_name": employeeName,
      "job_title": jobTitle,
      "organization_id": organizationId,
      "organization_name": organizationName,
      "working_location_id": workingLocationId,
      "working_location_name": workingLocationName,
      "working_location_address": workingLocationAddress,
      "working_latitude": workingLatitude,
      "working_longitude": workingLongitude,
      "working_time_in": workingTimeIn,
      "working_time_out": workingTimeOut,
      "device_id": deviceId,
      "device_info": deviceInfo,
      "date_in": dateIn,
      "date_out": dateOut,
      "time_in": timeIn,
      "time_out": timeOut,
      "status": status,
      "latitude_in": latitudeIn,
      "longitude_in": longitudeIn,
      "address_in": addressIn,
      "latitude_out": latitudeOut,
      "longitude_out": longitudeOut,
      "address_out": addressOut,
      "note_in": noteIn,
      "note_out": noteOut,
      "photo_in_url": photoInUrl,
      "photo_out_url": photoOutUrl,
      "face_in_url": faceInUrl,
      "face_out_url": faceOutUrl,
      "radius_in": radiusIn,
      "radius_out": radiusOut,
      "diff_time_in": diffTimeIn,
      "diff_time_out": diffTimeOut,
      "apps_id": appsId,
      "created": created,
      "createdby": createdBy,
    };
  }
}
