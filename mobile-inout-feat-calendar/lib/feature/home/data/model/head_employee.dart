class HeadEmployee {
  dynamic organization;
  dynamic jobTitle;
  dynamic workingLocation;
  dynamic headEmployee;
  dynamic groupShiftSchedules;

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

  HeadEmployee({
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

  factory HeadEmployee.fromJson(Map<String, dynamic> json) {
    return HeadEmployee(
      organization: json["organization"],
      jobTitle: json["jobTitle"],
      workingLocation: json["workingLocation"],
      headEmployee: json["headEmployee"],
      groupShiftSchedules: json["groupShiftSchedules"],
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

  Map<String, dynamic> toJson() {
    return {
      "organization": organization,
      "jobTitle": jobTitle,
      "workingLocation": workingLocation,
      "headEmployee": headEmployee,
      "groupShiftSchedules": groupShiftSchedules,
      "employee_id": employeeId,
      "address": address,
      "city": city,
      "country": country,
      "created": created,
      "createdby": createdby,
      "dateofbirth": dateofbirth,
      "email": email,
      "employee_code": employeeCode,
      "employee_name": employeeName,
      "gender": gender,
      "idcard": idcard,
      "phone": phone,
      "placeofbirth": placeofbirth,
      "profile_url": profileUrl,
      "province": province,
      "religion": religion,
      "updated": updated,
      "updatedby": updatedby,
      "zipcode": zipcode,
    };
  }
}
