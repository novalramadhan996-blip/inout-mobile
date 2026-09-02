import 'package:mobile_in_out/core/utils/models/organization/employee_model.dart';
import 'package:mobile_in_out/core/utils/models/organization/job_title_model.dart';
import 'package:mobile_in_out/core/utils/models/organization/location_model.dart';
import 'package:mobile_in_out/core/utils/models/organization/organization_model.dart';

class OrganizationEmployee {
  final Employee? employee;
  final Employee? headEmployee;
  final JobTitle? jobTitle;
  final Location? location;
  final Organization? organization;

  final String? organizationEmployeeId;
  final double? baseSalary;
  final String? created;
  final String? createdBy;
  final String? employeeId;
  final String? employeeIdCard;
  final String? employeeType;
  final String? endDate;
  final String? headEmployeeId;
  final String? jobTitleId;
  final String? locationId;
  final String? organizationId;
  final String? startDate;
  final String? status;
  final String? updated;
  final String? updatedBy;
  final String? workingScheduleId;
  final String? employeeCode;
  final String? employeeName;

  OrganizationEmployee({
    this.employee,
    this.headEmployee,
    this.jobTitle,
    this.location,
    this.organization,
    this.organizationEmployeeId,
    this.baseSalary,
    this.created,
    this.createdBy,
    this.employeeId,
    this.employeeIdCard,
    this.employeeType,
    this.endDate,
    this.headEmployeeId,
    this.jobTitleId,
    this.locationId,
    this.organizationId,
    this.startDate,
    this.status,
    this.updated,
    this.updatedBy,
    this.workingScheduleId,
    this.employeeCode,
    this.employeeName,
  });

  factory OrganizationEmployee.fromJson(Map<String, dynamic> json) {
    return OrganizationEmployee(
      employee: json["employee"] != null
          ? Employee.fromJson(json["employee"])
          : null,
      headEmployee: json["headEmployee"] != null
          ? Employee.fromJson(json["headEmployee"])
          : null,
      jobTitle: json["jobTitle"] != null
          ? JobTitle.fromJson(json["jobTitle"])
          : null,
      location: json["location"] != null
          ? Location.fromJson(json["location"])
          : null,
      organization: json["organization"] != null
          ? Organization.fromJson(json["organization"])
          : null,
      organizationEmployeeId: json["organization_employee_id"],
      baseSalary: (json["base_salary"] as num?)?.toDouble(),
      created: json["created"],
      createdBy: json["createdby"],
      employeeId: json["employee_id"],
      employeeIdCard: json["employee_idcard"],
      employeeType: json["employee_type"],
      endDate: json["end_date"],
      headEmployeeId: json["head_employee_id"],
      jobTitleId: json["job_title_id"],
      locationId: json["location_id"],
      organizationId: json["organization_id"],
      startDate: json["start_date"],
      status: json["status"],
      updated: json["updated"],
      updatedBy: json["updatedby"],
      workingScheduleId: json["working_schedule_id"],
      employeeCode: json['employee_code'],
      employeeName: json['employee_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "employee": employee?.toJson(),
      "headEmployee": headEmployee?.toJson(),
      "jobTitle": jobTitle?.toJson(),
      "location": location?.toJson(),
      "organization": organization?.toJson(),
      "organization_employee_id": organizationEmployeeId,
      "base_salary": baseSalary,
      "created": created,
      "createdby": createdBy,
      "employee_id": employeeId,
      "employee_idcard": employeeIdCard,
      "employee_type": employeeType,
      "end_date": endDate,
      "head_employee_id": headEmployeeId,
      "job_title_id": jobTitleId,
      "location_id": locationId,
      "organization_id": organizationId,
      "start_date": startDate,
      "status": status,
      "updated": updated,
      "updatedby": updatedBy,
      "working_schedule_id": workingScheduleId,
      "employee_code": employeeCode,
      "employee_name": employeeName,
    };
  }

  static List<OrganizationEmployee> fromList(List<dynamic> data) {
    return data.map((e) => OrganizationEmployee.fromJson(e)).toList();
  }
}
