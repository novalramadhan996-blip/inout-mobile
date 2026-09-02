class ActivityRequestModel {
  final String activityType;
  final String descr;
  final double latitude;
  final double longitude;
  final String photoUrl;

  ActivityRequestModel({
    required this.activityType,
    required this.descr,
    required this.latitude,
    required this.longitude,
    required this.photoUrl,
  });

  factory ActivityRequestModel.fromJson(Map<String, dynamic> json) {
    return ActivityRequestModel(
      activityType: json['activity_type'] as String,
      descr: json['descr'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      photoUrl: json['photo_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activity_type': activityType,
      'descr': descr,
      'latitude': latitude,
      'longitude': longitude,
      'photo_url': photoUrl,
    };
  }
}
