class AbsenceRecordDetail {
  final String? absensiId;
  final String? nrp;
  final String? accountId;
  final String? deviceId;
  final String? deviceInfo;
  final DateTime? timeIn;
  final DateTime? timeOut;
  final String? status;
  final double? latitudeIn;
  final double? longitudeIn;
  final String? addressIn;
  final double? latitudeOut;
  final double? longitudeOut;
  final String? addressOut;
  final String? descrIn;
  final String? descrOut;
  final DateTime? created;
  final DateTime? updated;
  final String? descrTypeIn;
  final String? descrTypeOut;
  final String? timezoneIn;
  final String? timezoneOut;
  final String? displayName;
  final String? email;
  final String? photoInUrl;
  final String? photoOutUrl;

  AbsenceRecordDetail({
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
    this.displayName,
    this.email,
    this.photoInUrl,
    this.photoOutUrl,
  });

  factory AbsenceRecordDetail.fromJson(Map<String, dynamic> json) {
    return AbsenceRecordDetail(
      absensiId: json["absensi_id"],
      nrp: json["nrp"],
      accountId: json["account_id"],
      deviceId: json["device_id"],
      deviceInfo: json["device_info"],
      timeIn: json["time_in"] == null ? null : DateTime.parse(json["time_in"]),
      timeOut:
          json["time_out"] == null ? null : DateTime.parse(json["time_out"]),
      status: json["status"],
      latitudeIn: json["latitude_in"]?.toDouble(),
      longitudeIn: json["longitude_in"]?.toDouble(),
      addressIn: json["address_in"],
      latitudeOut: json["latitude_out"]?.toDouble(),
      longitudeOut: json["longitude_out"]?.toDouble(),
      addressOut: json["address_out"],
      descrIn: json["descr_in"],
      descrOut: json["descr_out"],
      created: json["created"] == null ? null : DateTime.parse(json["created"]),
      updated: json["updated"] == null ? null : DateTime.parse(json["updated"]),
      descrTypeIn: json["descr_type_in"],
      descrTypeOut: json["descr_type_out"],
      timezoneIn: json["timezone_in"],
      timezoneOut: json["timezone_out"],
      displayName: json["display_name"],
      email: json["email"],
      photoInUrl: json["photo_in_url"],
      photoOutUrl: json["photo_out_url"],
    );
  }
}
