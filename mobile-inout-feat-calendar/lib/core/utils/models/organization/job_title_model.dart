class JobTitle {
  final String? jobTitleId;
  final int? active;
  final String? jobTitleName;
  final String? organizationId;
  final String? created;
  final String? createdby;
  final String? updated;
  final String? updatedby;

  JobTitle({
    this.jobTitleId,
    this.active,
    this.jobTitleName,
    this.organizationId,
    this.created,
    this.createdby,
    this.updated,
    this.updatedby,
  });

  factory JobTitle.fromJson(Map<String, dynamic> json) {
    return JobTitle(
      jobTitleId: json["job_title_id"],
      active: json["active"],
      jobTitleName: json["job_title_name"],
      organizationId: json["organization_id"],
      created: json["created"],
      createdby: json["createdby"],
      updated: json["updated"],
      updatedby: json["updatedby"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "job_title_id": jobTitleId,
      "active": active,
      "job_title_name": jobTitleName,
      "organization_id": organizationId,
      "created": created,
      "createdby": createdby,
      "updated": updated,
      "updatedby": updatedby,
    };
  }
}
