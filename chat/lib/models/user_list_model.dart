class UserListModel {
  final String? organization;
  final String? jobTitle;
  final String? workingLocation;
  final String? headEmployee;
  final String? groupShiftSchedules;

  final String? employeeId;
  final String? address;
  final String? city;
  final String? country;

  final DateTime? created;
  final String? createdBy;
  final DateTime? dateOfBirth;

  final String? email;
  final String? employeeCode;
  final String? employeeName;
  final String? gender;
  final String? idCard;
  final String? phone;
  final String? placeOfBirth;

  final String? profileUrl;
  final String? province;
  final String? religion;

  final DateTime? updated;
  final String? updatedBy;
  final String? zipcode;
  final String? status;

  UserListModel({
    this.organization,
    this.jobTitle,
    this.workingLocation,
    this.headEmployee,
    this.groupShiftSchedules,
    this.employeeId,
    this.address,
    this.city,
    this.country,
    this.created,
    this.createdBy,
    this.dateOfBirth,
    this.email,
    this.employeeCode,
    this.employeeName,
    this.gender,
    this.idCard,
    this.phone,
    this.placeOfBirth,
    this.profileUrl,
    this.province,
    this.religion,
    this.updated,
    this.updatedBy,
    this.zipcode,
    this.status,
  });

  factory UserListModel.fromJson(Map<String, dynamic> json) {
    return UserListModel(
      organization: json['organization'],
      jobTitle: json['jobTitle'],
      workingLocation: json['workingLocation'],
      headEmployee: json['headEmployee'],
      groupShiftSchedules: json['groupShiftSchedules'],
      employeeId: json['employee_id'],
      address: json['address'],
      city: json['city'],
      country: json['country'],
      created: json['created'] != null ? DateTime.parse(json['created']) : null,
      createdBy: json['createdby'],
      dateOfBirth: json['dateofbirth'] != null
          ? DateTime.parse(json['dateofbirth'])
          : null,
      email: json['email'],
      employeeCode: json['employee_code'],
      employeeName: json['employee_name'],
      gender: json['gender'],
      idCard: json['idcard'],
      phone: json['phone'],
      placeOfBirth: json['placeofbirth'],
      profileUrl: json['profile_url'],
      province: json['province'],
      religion: json['religion'],
      updated: json['updated'] != null ? DateTime.parse(json['updated']) : null,
      updatedBy: json['updatedby'],
      zipcode: json['zipcode'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'organization': organization,
      'jobTitle': jobTitle,
      'workingLocation': workingLocation,
      'headEmployee': headEmployee,
      'groupShiftSchedules': groupShiftSchedules,
      'employee_id': employeeId,
      'address': address,
      'city': city,
      'country': country,
      'created': created?.toIso8601String(),
      'createdby': createdBy,
      'dateofbirth': dateOfBirth?.toIso8601String(),
      'email': email,
      'employee_code': employeeCode,
      'employee_name': employeeName,
      'gender': gender,
      'idcard': idCard,
      'phone': phone,
      'placeofbirth': placeOfBirth,
      'profile_url': profileUrl,
      'province': province,
      'religion': religion,
      'updated': updated?.toIso8601String(),
      'updatedby': updatedBy,
      'zipcode': zipcode,
      'status': status,
    };
  }
}
