class JobTitle {
  String? jobTitleId;
  int? active;
  String? jobTitleName;
  String? organizationId;
  String? created;
  String? createdBy;
  String? updated;
  String? updatedBy;

  JobTitle({
    this.jobTitleId,
    this.active,
    this.jobTitleName,
    this.organizationId,
    this.created,
    this.createdBy,
    this.updated,
    this.updatedBy,
  });

  factory JobTitle.fromJson(Map<String, dynamic> json) {
    return JobTitle(
      jobTitleId: json['job_title_id'],
      active: json['active'],
      jobTitleName: json['job_title_name'],
      organizationId: json['organization_id'],
      created: json['created'],
      createdBy: json['createdby'],
      updated: json['updated'],
      updatedBy: json['updatedby'],
    );
  }
}
