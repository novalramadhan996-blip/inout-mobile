class CheckInRequestModel {
  final String? employeeId;
  final String? jobTitle;
  final String? organizationId;
  final String? workingLocationId;
  final String? deviceId;
  final String? deviceInfo;
  final String? dateIn;
  final String? timeIn;
  final String? status;
  final double? latitudeIn;
  final double? longitudeIn;
  final String? addressIn;
  final String? noteIn;
  final String? photoInUrl;
  final String? faceInUrl;
  final int? radiusIn;
  final int? diffTimeIn;
  final String? appsId;
  final String? created;
  final String? createdBy;
  final String? workingTimeIn;

  CheckInRequestModel({
    this.employeeId,
    this.jobTitle,
    this.organizationId,
    this.workingLocationId,
    this.deviceId,
    this.deviceInfo,
    this.dateIn,
    this.timeIn,
    this.status,
    this.latitudeIn,
    this.longitudeIn,
    this.addressIn,
    this.noteIn,
    this.photoInUrl,
    this.faceInUrl,
    this.radiusIn,
    this.diffTimeIn,
    this.appsId,
    this.created,
    this.createdBy,
    this.workingTimeIn,
  });

  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'job_title': jobTitle,
      'organization_id': organizationId,
      'working_location_id': workingLocationId,
      'device_id': deviceId,
      'device_info': deviceInfo,
      'date_in': dateIn,
      'time_in': timeIn,
      'status': status,
      'latitude_in': latitudeIn,
      'longitude_in': longitudeIn,
      'address_in': addressIn,
      'note_in': noteIn,
      'photo_in_url': photoInUrl,
      'face_in_url': faceInUrl,
      'radius_in': radiusIn,
      'diff_time_in': diffTimeIn,
      'apps_id': appsId,
      'created': created,
      'createdby': createdBy,
      'working_time_in': workingTimeIn,
    };
  }

  factory CheckInRequestModel.fromJson(Map<String, dynamic> json) {
    return CheckInRequestModel(
      employeeId: json['employee_id'],
      jobTitle: json['job_title'],
      organizationId: json['organization_id'],
      workingLocationId: json['working_location_id'],
      deviceId: json['device_id'],
      deviceInfo: json['device_info'],
      dateIn: json['date_in'],
      timeIn: json['time_in'],
      status: json['status'],
      latitudeIn: (json['latitude_in'] as num?)?.toDouble(),
      longitudeIn: (json['longitude_in'] as num?)?.toDouble(),
      addressIn: json['address_in'],
      noteIn: json['note_in'],
      photoInUrl: json['photo_in_url'],
      faceInUrl: json['face_in_url'],
      radiusIn: json['radius_in'],
      diffTimeIn: json['diff_time_in'],
      appsId: json['apps_id'],
      created: json['created'],
      createdBy: json['createdby'],
      workingTimeIn: json['working_time_in'],
    );
  }
}
