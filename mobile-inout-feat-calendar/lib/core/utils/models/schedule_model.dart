class ScheduleModel {
  final String? locationName;
  final double? latitude;
  final String? timeIn;
  final String? day;
  final String? locationId;
  final String? timeOut;
  final double? longitude;
  final int? radius;

  ScheduleModel({
    this.locationName,
    this.latitude,
    this.timeIn,
    this.day,
    this.locationId,
    this.timeOut,
    this.longitude,
    this.radius,
  });

  // Factory method to create an instance from JSON
  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    if (json['day'] != null) {
      json['day'] = json['day'].toString();
    }

    return ScheduleModel(
      locationName: json['location_name'],
      latitude: json['latitude'],
      timeIn: json['time_in'],
      day: json['day'],
      locationId: json['location_id'],
      timeOut: json['time_out'],
      longitude: json['longitude'],
      radius: json['radius'],
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'location_name': locationName,
      'latitude': latitude,
      'time_in': timeIn,
      'day': day,
      'location_id': locationId,
      'time_out': timeOut,
      'longitude': longitude,
      'radius': radius,
    };
  }
}
