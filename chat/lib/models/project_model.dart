class ProjectModel {
  String? projectId;
  String? projectName;
  String? projectCode;
  String? projectOwnerId;
  String? organizationId;
  String? metadata;
  String? startDate;
  String? endDate;
  String? descr;
  String? created;
  String? createdBy;
  String? updated;
  String? updatedBy;
  String? thumbnailUrl;
  int? totalBoard;

  ProjectOwnerModel? projectOwner;
  OrganizationModel? organization;

  ProjectModel({
    this.projectId,
    this.projectName,
    this.projectCode,
    this.projectOwnerId,
    this.organizationId,
    this.metadata,
    this.startDate,
    this.endDate,
    this.descr,
    this.created,
    this.createdBy,
    this.updated,
    this.updatedBy,
    this.thumbnailUrl,
    this.totalBoard,
    this.projectOwner,
    this.organization,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      projectId: json['project_id'],
      projectName: json['project_name'],
      projectCode: json['project_code'],
      projectOwnerId: json['project_owner_id'],
      organizationId: json['organization_id'],
      metadata: json['metadata'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      descr: json['descr'],
      created: json['created'],
      createdBy: json['createdby'],
      updated: json['updated'],
      updatedBy: json['updatedby'],
      thumbnailUrl: json['thumbnail_url'],
      totalBoard: json['total_board'],
      projectOwner: json['projectOwner'] != null
          ? ProjectOwnerModel.fromJson(json['projectOwner'])
          : null,
      organization: json['organization'] != null
          ? OrganizationModel.fromJson(json['organization'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'project_name': projectName,
      'project_code': projectCode,
      'project_owner_id': projectOwnerId,
      'organization_id': organizationId,
      'metadata': metadata,
      'start_date': startDate,
      'end_date': endDate,
      'descr': descr,
      'created': created,
      'createdby': createdBy,
      'updated': updated,
      'updatedby': updatedBy,
      'thumbnail_url': thumbnailUrl,
      'total_board': totalBoard,
      'projectOwner': projectOwner?.toJson(),
      'organization': organization?.toJson(),
    };
  }
}

class ProjectOwnerModel {
  String? employeeId;
  String? employeeName;
  String? email;
  String? phone;
  String? address;
  String? city;
  String? province;
  String? country;
  String? profileUrl;

  ProjectOwnerModel({
    this.employeeId,
    this.employeeName,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.province,
    this.country,
    this.profileUrl,
  });

  factory ProjectOwnerModel.fromJson(Map<String, dynamic> json) {
    return ProjectOwnerModel(
      employeeId: json['employee_id'],
      employeeName: json['employee_name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      city: json['city'],
      province: json['province'],
      country: json['country'],
      profileUrl: json['profile_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'employee_name': employeeName,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'province': province,
      'country': country,
      'profile_url': profileUrl,
    };
  }
}

class OrganizationModel {
  String? organizationId;
  String? organizationName;
  String? descr;

  OrganizationModel({
    this.organizationId,
    this.organizationName,
    this.descr,
  });

  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    return OrganizationModel(
      organizationId: json['organization_id'],
      organizationName: json['organization_name'],
      descr: json['descr'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'organization_id': organizationId,
      'organization_name': organizationName,
      'descr': descr,
    };
  }
}
