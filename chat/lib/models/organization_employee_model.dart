import 'package:chat/models/employee_model.dart';
import 'package:chat/models/job_title_model.dart';
import 'package:chat/models/organization_model.dart';

class OrganizationEmployeeModel {
  Employee? employee;
  Employee? headEmployee;
  JobTitle? jobTitle;
  dynamic location;
  OrganizationModel? organization;

  String? organizationEmployeeId;
  double? baseSalary;
  String? created;
  String? createdBy;
  String? employeeId;
  String? employeeIdCard;
  String? employeeType;
  String? endDate;
  String? headEmployeeId;
  String? jobTitleId;
  String? locationId;
  String? organizationId;
  String? startDate;
  String? status;
  String? updated;
  String? updatedBy;
  String? workingScheduleId;

  OrganizationEmployeeModel({
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
  });

  factory OrganizationEmployeeModel.fromJson(Map<String, dynamic> json) {
    return OrganizationEmployeeModel(
      employee:
          json['employee'] != null ? Employee.fromJson(json['employee']) : null,
      headEmployee: json['headEmployee'] != null
          ? Employee.fromJson(json['headEmployee'])
          : null,
      jobTitle:
          json['jobTitle'] != null ? JobTitle.fromJson(json['jobTitle']) : null,
      location: json['location'],
      organization: json['organization'] != null
          ? OrganizationModel.fromJson(json['organization'])
          : null,
      organizationEmployeeId: json['organization_employee_id'],
      baseSalary: (json['base_salary'] as num?)?.toDouble(),
      created: json['created'],
      createdBy: json['createdby'],
      employeeId: json['employee_id'],
      employeeIdCard: json['employee_idcard'],
      employeeType: json['employee_type'],
      endDate: json['end_date'],
      headEmployeeId: json['head_employee_id'],
      jobTitleId: json['job_title_id'],
      locationId: json['location_id'],
      organizationId: json['organization_id'],
      startDate: json['start_date'],
      status: json['status'],
      updated: json['updated'],
      updatedBy: json['updatedby'],
      workingScheduleId: json['working_schedule_id'],
    );
  }
}
