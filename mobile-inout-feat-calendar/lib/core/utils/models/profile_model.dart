import 'dart:convert';

class ProfileModel {
  final Location? location;
  final String? accountId;
  final String? userId;
  final String? idCard;
  final String? email;
  final String? phone;
  final DateTime? birthdate;
  final String? gender;
  final int? active;
  final String? accountTypeId;
  final DateTime? created;
  final DateTime? updated;
  final String? locationId;
  final String? unitUsaha;
  final String? workingTimeIn;
  final String? workingTimeOut;
  final String? unitKerja;
  final List? modelData;
  final Absensi? absensi;
  final String? profileUrl;
  final String? photo;
  final String? status;
  final String? name;

  ProfileModel({
    this.location,
    this.accountId,
    this.userId,
    this.idCard,
    this.email,
    this.phone,
    this.birthdate,
    this.gender,
    this.active,
    this.accountTypeId,
    this.created,
    this.updated,
    this.locationId,
    this.unitUsaha,
    this.workingTimeIn,
    this.workingTimeOut,
    this.unitKerja,
    this.modelData,
    this.absensi,
    this.profileUrl,
    this.photo,
    this.status,
    this.name,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      location: json["location"] == null
          ? null
          : Location.fromJson(json["location"]),
      accountId: json["account_id"],
      userId: json["user_id"],
      idCard: json["id_card"],
      email: json["email"],
      phone: json["phone"],
      birthdate: json["birthdate"] == null
          ? null
          : DateTime.parse(json["birthdate"]),
      gender: json["gender"],
      active: json["active"],
      accountTypeId: json["account_type_id"],
      created: json["created"] == null ? null : DateTime.parse(json["created"]),
      updated: json["updated"] == null ? null : DateTime.parse(json["updated"]),
      locationId: json["location_id"],
      unitUsaha: json["unit_usaha"],
      workingTimeIn: json["working_time_in"],
      workingTimeOut: json["working_time_out"],
      unitKerja: json["unit_kerja"],
      // modelData: json["model_data"] != null
      //     ? jsonDecode(json["model_data"])
      //     : null,
      modelData: _parseModelData(json["model_data"]),
      absensi: json["absensi"].runtimeType == String
          ? Absensi.fromJson(jsonDecode(json['absensi']))
          : json["absensi"] == null
          ? null
          : Absensi.fromJson(json["absensi"]),
      profileUrl: json['profile_url'],
      photo: json['photo'],
      status: json['status'],
      name: json['name'],
    );
  }

  static dynamic _parseModelData(dynamic data) {
    if (data == null) return null;

    if (data is String) {
      try {
        final decoded = jsonDecode(data);

        // kalau hasil decode bukan Map/List, return null atau original
        if (decoded is Map || decoded is List) {
          return decoded;
        }

        return null;
      } catch (e) {
        // kalau bukan JSON valid (misal "test")
        return null; // atau return data kalau mau keep stringnya
      }
    }

    return data;
  }

  Map<String, dynamic> toJson({bool saveLocation = true}) =>
      {
        "location": location?.toJson(),
        "account_id": accountId,
        "user_id": userId,
        "id_card": idCard,
        "email": email,
        "phone": phone,
        "birthdate": birthdate?.toIso8601String(),
        "gender": gender,
        "active": active,
        "account_type_id": accountTypeId,
        "created": created?.toIso8601String(),
        "updated": updated?.toIso8601String(),
        "location_id": locationId,
        "unit_usaha": unitUsaha,
        "working_time_in": workingTimeIn,
        "working_time_out": workingTimeOut,
        "unit_kerja": unitKerja,
        "model_data": modelData != null ? jsonEncode(modelData) : null,
        "absensi": absensi != null ? jsonEncode(absensi) : null,
        "profile_url": profileUrl,
        "photo": photo,
        "name": name,
      }..removeWhere((key, value) {
        return saveLocation ? false : key == "location";
      });
}

class Location {
  final String? locationId;
  final String? locationName;
  final String? address;
  final double? latitude;
  final double? longitude;
  final int? radius;

  Location({
    this.locationId,
    this.locationName,
    this.address,
    this.latitude,
    this.longitude,
    this.radius,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    locationId: json["location_id"],
    locationName: json["location_name"],
    address: json["address"],
    latitude: json["latitude"]?.toDouble(),
    longitude: json["longitude"]?.toDouble(),
    radius: json["radius"],
  );

  Map<String, dynamic> toJson() => {
    "location_id": locationId,
    "location_name": locationName,
    "address": address,
    "latitude": latitude,
    "longitude": longitude,
    "radius": radius,
  };
}

class Absensi {
  String? absensiId;
  String? nrp;
  String? accountId;
  String? deviceId;
  String? deviceInfo;
  String? timeIn;
  String? timeOut;
  String? status;
  double? latitudeIn;
  double? longitudeIn;
  String? addressIn;
  double? latitudeOut;
  double? longitudeOut;
  String? addressOut;
  String? descrIn;
  String? descrOut;
  String? created;
  String? updated;
  String? descrTypeIn;
  String? descrTypeOut;
  String? timezoneIn;
  String? timezoneOut;
  int? totalHours;
  String? timeInDateTime;
  String? timeOutDateTime;

  Absensi({
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
    this.totalHours,
    this.timeInDateTime,
    this.timeOutDateTime,
  });

  factory Absensi.fromJson(Map<String, dynamic> json) => Absensi(
    absensiId: json["absensi_id"],
    nrp: json["nrp"],
    accountId: json["account_id"],
    deviceId: json["device_id"],
    deviceInfo: json["device_info"],
    timeIn: json["time_in"],
    timeOut: json["time_out"],
    status: json["status"],
    latitudeIn: json["latitude_in"]?.toDouble(),
    longitudeIn: json["longitude_in"]?.toDouble(),
    addressIn: json["address_in"],
    latitudeOut: json["latitude_out"]?.toDouble(),
    longitudeOut: json["longitude_out"]?.toDouble(),
    addressOut: json["address_out"],
    descrIn: json["descr_in"],
    descrOut: json["descr_out"],
    created: json["created"],
    updated: json["updated"],
    descrTypeIn: json["descr_type_in"],
    descrTypeOut: json["descr_type_out"],
    timezoneIn: json["timezone_in"],
    timezoneOut: json["timezone_out"],
    totalHours: json["total_hours"],
    timeInDateTime: json["time_in_date_time"],
    timeOutDateTime: json["time_out_date_time"],
  );

  Map<String, dynamic> toJson() => {
    "absensi_id": absensiId,
    "nrp": nrp,
    "account_id": accountId,
    "device_id": deviceId,
    "device_info": deviceInfo,
    "time_in": timeIn,
    "time_out": timeOut,
    "status": status,
    "latitude_in": latitudeIn,
    "longitude_in": longitudeIn,
    "address_in": addressIn,
    "latitude_out": latitudeOut,
    "longitude_out": longitudeOut,
    "address_out": addressOut,
    "descr_in": descrIn,
    "descr_out": descrOut,
    "created": created,
    "updated": updated,
    "descr_type_in": descrTypeIn,
    "descr_type_out": descrTypeOut,
    "timezone_in": timezoneIn,
    "timezone_out": timezoneOut,
    "total_hours": totalHours,
    "time_in_date_time": timeInDateTime,
    "time_out_date_time": timeOutDateTime,
  };
}
