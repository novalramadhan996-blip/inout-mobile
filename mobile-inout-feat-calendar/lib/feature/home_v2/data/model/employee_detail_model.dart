import 'package:mobile_in_out/feature/home/data/model/group_shift_schedule.dart';
import 'package:mobile_in_out/feature/home/data/model/head_employee.dart';
import 'package:mobile_in_out/feature/home/data/model/job_title.dart';
import 'package:mobile_in_out/feature/home/data/model/organization.dart';
import 'package:mobile_in_out/feature/home/data/model/working_location.dart';

class EmployeeDetailModel {
  Organization? organization;
  JobTitle? jobTitle;
  WorkingLocation? workingLocation;
  HeadEmployee? headEmployee;
  List<GroupShiftSchedule>? groupShiftSchedules;

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

  EmployeeDetailModel({
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

  factory EmployeeDetailModel.fromJson(Map<String, dynamic> json) {
    return EmployeeDetailModel(
      organization: json["organization"] != null
          ? Organization.fromJson(json["organization"])
          : null,

      jobTitle: json["jobTitle"] != null
          ? JobTitle.fromJson(json["jobTitle"])
          : null,

      workingLocation: json["workingLocation"] != null
          ? WorkingLocation.fromJson(json["workingLocation"])
          : null,

      headEmployee: json["headEmployee"] != null
          ? HeadEmployee.fromJson(json["headEmployee"])
          : null,

      groupShiftSchedules: json["groupShiftSchedules"] != null
          ? (json["groupShiftSchedules"] as List)
                .map((e) => GroupShiftSchedule.fromJson(e))
                .toList()
          : null,

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
      "organization": organization?.toJson(),
      "jobTitle": jobTitle?.toJson(),
      "workingLocation": workingLocation?.toJson(),
      "headEmployee": headEmployee?.toJson(),
      "groupShiftSchedules": groupShiftSchedules
          ?.map((e) => e.toJson())
          .toList(),

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
