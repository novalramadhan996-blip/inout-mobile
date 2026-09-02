class ActivityModel {
  final String? activityId;
  final String? activityType;
  final String? descr;
  final DateTime? activityDateStart;
  final DateTime? activityDateEnd;
  final String? employeeId;
  final String? organizationId;
  final String? jobTitleId;
  final String? locationId;
  final double? latitude;
  final double? longitude;
  final String? photoUrl;
  final String? status;
  final DateTime? created;
  final String? createdBy;
  final DateTime? updated;
  final String? updatedBy;

  ActivityModel({
    required this.activityId,
    required this.activityType,
    required this.descr,
    required this.activityDateStart,
    required this.activityDateEnd,
    required this.employeeId,
    required this.organizationId,
    required this.jobTitleId,
    required this.locationId,
    required this.latitude,
    required this.longitude,
    required this.photoUrl,
    required this.status,
    required this.created,
    required this.createdBy,
    required this.updated,
    required this.updatedBy,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      activityId: json['activity_id'] ?? '',
      activityType: json['activity_type'] ?? '',
      descr: json['descr'] ?? '',
      activityDateStart: DateTime.parse(json['activity_date_start']),
      activityDateEnd: json['activity_date_end'] != null
          ? DateTime.parse(json['activity_date_end'])
          : null,
      employeeId: json['employee_id'] ?? '',
      organizationId: json['organization_id'] ?? '',
      jobTitleId: json['job_title_id'] ?? '',
      locationId: json['location_id'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      photoUrl: json['photo_url'] ?? '',
      status: json['status'],
      created: DateTime.parse(json['created']),
      createdBy: json['createdby'] ?? '',
      updated: json['updated'] != null ? DateTime.parse(json['updated']) : null,
      updatedBy: json['updatedby'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activity_id': activityId,
      'activity_type': activityType,
      'descr': descr,
      'activity_date_start': activityDateStart?.toIso8601String(),
      'activity_date_end': activityDateEnd?.toIso8601String(),
      'employee_id': employeeId,
      'organization_id': organizationId,
      'job_title_id': jobTitleId,
      'location_id': locationId,
      'latitude': latitude,
      'longitude': longitude,
      'photo_url': photoUrl,
      'status': status,
      'created': created?.toIso8601String(),
      'createdby': createdBy,
      'updated': updated?.toIso8601String(),
      'updatedby': updatedBy,
    };
  }
}
