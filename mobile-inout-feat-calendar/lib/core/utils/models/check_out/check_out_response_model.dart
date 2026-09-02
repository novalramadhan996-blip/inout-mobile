class CheckOutResponseModel {
  final String? absensiId;
  final String? nrp;
  final String? accountId;
  final String? deviceId;
  final String? deviceInfo;
  final String? timeOut;
  final String? status;
  final double? latitudeOut;
  final double? longitudeOut;
  final String? addressOut;
  final String? descrOut;
  final String? updated;
  final String? descrTypeOut;
  final String? timezoneOut;

  CheckOutResponseModel({
    this.absensiId,
    this.nrp,
    this.accountId,
    this.deviceId,
    this.deviceInfo,
    this.timeOut,
    this.status,
    this.latitudeOut,
    this.longitudeOut,
    this.addressOut,
    this.descrOut,
    this.updated,
    this.descrTypeOut,
    this.timezoneOut,
  });

  factory CheckOutResponseModel.fromJson(Map<String, dynamic> json) {
    return CheckOutResponseModel(
      absensiId: json['attendance_id'],
      nrp: json['nrp'],
      accountId: json['account_id'],
      deviceId: json['device_id'],
      deviceInfo: json['device_info'],
      timeOut: json['time_out'],
      status: json['status'],
      latitudeOut: json['latitude_out'] ?? 0.0,
      longitudeOut: json['longitude_out'] ?? 0.0, 
      addressOut: json['address_out'],
      descrOut: json['note_out'],
      updated: json['updated'],
      descrTypeOut: json['descr_type_out'],
      timezoneOut: json['timezone_out'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendance_id': absensiId,
      'nrp': nrp,
      'account_id': accountId,
      'device_id': deviceId,
      'device_info': deviceInfo,
      'time_out': timeOut,
      'status': status,
      'latitude_out': latitudeOut,
      'longitude_out': longitudeOut,
      'address_out': addressOut,
      'note_out': descrOut,
      'updated': updated,
      'descr_type_out': descrTypeOut,
      'timezone_out': timezoneOut,
    };
  }
}