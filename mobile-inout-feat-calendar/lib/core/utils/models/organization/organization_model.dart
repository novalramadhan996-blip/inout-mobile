class Organization {
  final String? organizationId;
  final int? active;
  final String? appsId;
  final String? descr;
  final String? headOfOrganizationId;
  final String? organizationName;
  final String? parentOrganizationId;

  Organization({
    this.organizationId,
    this.active,
    this.appsId,
    this.descr,
    this.headOfOrganizationId,
    this.organizationName,
    this.parentOrganizationId,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      organizationId: json["organization_id"],
      active: json["active"],
      appsId: json["apps_id"],
      descr: json["descr"],
      headOfOrganizationId: json["head_of_organization_id"],
      organizationName: json["organization_name"],
      parentOrganizationId: json["parent_organization_id"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "organization_id": organizationId,
      "active": active,
      "apps_id": appsId,
      "descr": descr,
      "head_of_organization_id": headOfOrganizationId,
      "organization_name": organizationName,
      "parent_organization_id": parentOrganizationId,
    };
  }
}
