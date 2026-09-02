class Employee {
  final String? employeeId;
  final String? address;
  final String? city;
  final String? country;
  final String? created;
  final String? createdBy;
  final String? dateOfBirth;
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
  final String? updated;
  final String? updatedBy;
  final String? zipcode;

  Employee({
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
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      employeeId: json["employee_id"],
      address: json["address"],
      city: json["city"],
      country: json["country"],
      created: json["created"],
      createdBy: json["createdby"],
      dateOfBirth: json["dateofbirth"],
      email: json["email"],
      employeeCode: json["employee_code"],
      employeeName: json["employee_name"],
      gender: json["gender"],
      idCard: json["idcard"],
      phone: json["phone"],
      placeOfBirth: json["placeofbirth"],
      profileUrl: json["profile_url"],
      province: json["province"],
      religion: json["religion"],
      updated: json["updated"],
      updatedBy: json["updatedby"],
      zipcode: json["zipcode"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "employee_id": employeeId,
      "address": address,
      "city": city,
      "country": country,
      "created": created,
      "createdby": createdBy,
      "dateofbirth": dateOfBirth,
      "email": email,
      "employee_code": employeeCode,
      "employee_name": employeeName,
      "gender": gender,
      "idcard": idCard,
      "phone": phone,
      "placeofbirth": placeOfBirth,
      "profile_url": profileUrl,
      "province": province,
      "religion": religion,
      "updated": updated,
      "updatedby": updatedBy,
      "zipcode": zipcode,
    };
  }
}
