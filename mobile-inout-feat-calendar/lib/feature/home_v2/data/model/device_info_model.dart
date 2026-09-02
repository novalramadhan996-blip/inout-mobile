class DeviceInfoModel {
  final String? deviceInfoId;
  final String? deviceId;
  final String? employeeId;
  final String? imeiImsi;
  // final String? model;
  // final String? os;
  final String? deviceDetail;
  // final DateTime? created;
  // final String? createdBy;

  DeviceInfoModel({
    this.deviceInfoId,
    this.deviceId,
    this.employeeId,
    this.imeiImsi,
    // this.model,
    // this.os,
    this.deviceDetail,
    // this.created,
    // this.createdBy,
  });

  factory DeviceInfoModel.fromJson(Map<String, dynamic> json) {
    return DeviceInfoModel(
      deviceInfoId: json['device_info_id'] ?? '',
      deviceId: json['device_id'] ?? '',
      employeeId: json['employee_id'] ?? '',
      imeiImsi: json['imei_imsi'] ?? '',
      // model: json['model'] ?? '',
      // os: json['os'] ?? '',
      deviceDetail: json['device_detail'] ?? '',
      // created: DateTime.parse(json['created']),
      // createdBy: json['createdby'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_info_id': deviceInfoId,
      'device_id': deviceId,
      'employee_id': employeeId,
      'imei_imsi': imeiImsi,
      // 'model': model,
      // 'os': os,
      'device_detail': deviceDetail,
      // 'created': created.toIso8601String(),
      // 'createdby': createdBy,
    };
  }
}
