class Employee {
  String? employeeId;
  String? employeeName;
  String? employeeCode;
  String? email;
  String? phone;
  String? gender;
  String? address;
  String? city;
  String? province;
  String? country;
  String? placeOfBirth;
  String? dateOfBirth;
  String? religion;
  String? zipcode;
  String? profileUrl;
  String? idCard;
  String? created;
  String? createdBy;
  String? updated;
  String? updatedBy;
  String? status;

  Employee({
    this.employeeId,
    this.employeeName,
    this.employeeCode,
    this.email,
    this.phone,
    this.gender,
    this.address,
    this.city,
    this.province,
    this.country,
    this.placeOfBirth,
    this.dateOfBirth,
    this.religion,
    this.zipcode,
    this.profileUrl,
    this.idCard,
    this.created,
    this.createdBy,
    this.updated,
    this.updatedBy,
    this.status,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      employeeId: json['employee_id'],
      employeeName: json['employee_name'],
      employeeCode: json['employee_code'],
      email: json['email'],
      phone: json['phone'],
      gender: json['gender'],
      address: json['address'],
      city: json['city'],
      province: json['province'],
      country: json['country'],
      placeOfBirth: json['placeofbirth'],
      dateOfBirth: json['dateofbirth'],
      religion: json['religion'],
      zipcode: json['zipcode'],
      profileUrl: json['profile_url'],
      idCard: json['idcard'],
      created: json['created'],
      createdBy: json['createdby'],
      updated: json['updated'],
      updatedBy: json['updatedby'],
      status: json['status'],
    );
  }
}
