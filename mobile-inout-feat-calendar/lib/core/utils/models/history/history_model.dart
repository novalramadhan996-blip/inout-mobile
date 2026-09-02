class AbsenceRecord {
  final String? absensiId;
  final String? nrp;
  final String? accountId;
  final String? deviceId;
  final String? deviceInfo;
  final String? timeIn;
  final String? timeOut;
  final String? status;
  final double? latitudeIn;
  final double? longitudeIn;
  final String? addressIn;
  final double? latitudeOut;
  final double? longitudeOut;
  final String? addressOut;
  final String? descrIn;
  final String? descrOut;
  final String? created;
  final String? updated;
  final String? descrTypeIn;
  final String? descrTypeOut;
  final String? timezoneIn;
  final String? timezoneOut;

  AbsenceRecord({
    this.absensiId,
    this.nrp,
    this.accountId,
    this.deviceId,
    this.deviceInfo,
    this.timeIn,
    this.timeOut,
    this.status,
    this.latitudeIn,
    this.longitudeIn,
    this.addressIn,
    this.latitudeOut,
    this.longitudeOut,
    this.addressOut,
    this.descrIn,
    this.descrOut,
    this.created,
    this.updated,
    this.descrTypeIn,
    this.descrTypeOut,
    this.timezoneIn,
    this.timezoneOut,
  });

  factory AbsenceRecord.fromJson(Map<String, dynamic> json) {
    return AbsenceRecord(
      absensiId: json['absensi_id'],
      nrp: json['nrp'],
      accountId: json['account_id'],
      deviceId: json['device_id'],
      deviceInfo: json['device_info'],
      timeIn: json['time_in'],
      timeOut: json['time_out'],
      status: json['status'],
      latitudeIn: json['latitude_in'],
      longitudeIn: json['longitude_in'],
      addressIn: json['address_in'],
      latitudeOut: json['latitude_out'],
      longitudeOut: json['longitude_out'],
      addressOut: json['address_out'],
      descrIn: json['descr_in'],
      descrOut: json['descr_out'],
      created: json['created'],
      updated: json['updated'],
      descrTypeIn: json['descr_type_in'],
      descrTypeOut: json['descr_type_out'],
      timezoneIn: json['timezone_in'],
      timezoneOut: json['timezone_out'],
    );
  }
}