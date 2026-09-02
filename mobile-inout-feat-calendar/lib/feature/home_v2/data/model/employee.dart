class Employee {
  String? employeeId;
  String? address;
  String? city;
  String? country;
  String? created;
  String? createdby;
  String? dateofbirth;
  String? email;
  String? employeeCode;
  String? employeeName;
  String? gender;
  String? idcard;
  String? phone;
  String? placeofbirth;
  String? profileUrl;
  String? province;
  String? religion;
  String? updated;
  String? updatedby;
  String? zipcode;

  Employee({
    this.employeeId,
    this.address,
    this.city,
    this.country,
    this.created,
    this.createdby,
    this.dateofbirth,
    this.email,
    this.employeeCode,
    this.employeeName,
    this.gender,
    this.idcard,
    this.phone,
    this.placeofbirth,
    this.profileUrl,
    this.province,
    this.religion,
    this.updated,
    this.updatedby,
    this.zipcode,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      employeeId: json["employee_id"],
      address: json["address"],
      city: json["city"],
      country: json["country"],
      created: json["created"],
      createdby: json["createdby"],
      dateofbirth: json["dateofbirth"],
      email: json["email"],
      employeeCode: json["employee_code"],
      employeeName: json["employee_name"],
      gender: json["gender"],
      idcard: json["idcard"],
      phone: json["phone"],
      placeofbirth: json["placeofbirth"],
      profileUrl: json["profile_url"],
      province: json["province"],
      religion: json["religion"],
      updated: json["updated"],
      updatedby: json["updatedby"],
      zipcode: json["zipcode"],
    );
  }
}
