class OrganizationModel {
  final String? organizationId;
  final int? active;
  final String? appsId;
  final DateTime? created;
  final String? createdBy;
  final String? descr;
  final String? headOfOrganizationId;
  final String? organizationName;
  final String? parentOrganizationId;
  final DateTime? updated;
  final String? updatedBy;

  OrganizationModel({
    this.organizationId,
    this.active,
    this.appsId,
    this.created,
    this.createdBy,
    this.descr,
    this.headOfOrganizationId,
    this.organizationName,
    this.parentOrganizationId,
    this.updated,
    this.updatedBy,
  });

  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    return OrganizationModel(
      organizationId: json['organization_id'],
      active: json['active'],
      appsId: json['apps_id'],
      created:
          json['created'] != null ? DateTime.tryParse(json['created']) : null,
      createdBy: json['createdby'],
      descr: json['descr'],
      headOfOrganizationId: json['head_of_organization_id'],
      organizationName: json['organization_name'],
      parentOrganizationId: json['parent_organization_id'],
      updated:
          json['updated'] != null ? DateTime.tryParse(json['updated']) : null,
      updatedBy: json['updatedby'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'organization_id': organizationId,
      'active': active,
      'apps_id': appsId,
      'created': created?.toIso8601String(),
      'createdby': createdBy,
      'descr': descr,
      'head_of_organization_id': headOfOrganizationId,
      'organization_name': organizationName,
      'parent_organization_id': parentOrganizationId,
      'updated': updated?.toIso8601String(),
      'updatedby': updatedBy,
    };
  }
}
