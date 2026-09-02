class Organization {
  String? organizationId;
  int? active;
  String? appsId;
  String? created;
  String? createdby;
  String? descr;
  String? headOfOrganizationId;
  String? organizationName;
  String? parentOrganizationId;
  String? updated;
  String? updatedby;

  Organization({
    this.organizationId,
    this.active,
    this.appsId,
    this.created,
    this.createdby,
    this.descr,
    this.headOfOrganizationId,
    this.organizationName,
    this.parentOrganizationId,
    this.updated,
    this.updatedby,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      organizationId: json["organization_id"],
      active: json["active"],
      appsId: json["apps_id"],
      created: json["created"],
      createdby: json["createdby"],
      descr: json["descr"],
      headOfOrganizationId: json["head_of_organization_id"],
      organizationName: json["organization_name"],
      parentOrganizationId: json["parent_organization_id"],
      updated: json["updated"],
      updatedby: json["updatedby"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "organization_id": organizationId,
      "active": active,
      "apps_id": appsId,
      "created": created,
      "createdby": createdby,
      "descr": descr,
      "head_of_organization_id": headOfOrganizationId,
      "organization_name": organizationName,
      "parent_organization_id": parentOrganizationId,
      "updated": updated,
      "updatedby": updatedby,
    };
  }
}
