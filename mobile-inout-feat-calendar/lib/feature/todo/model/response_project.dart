class ResponseProject {
  String? projectId;
  String? projectName;
  String? projectCode;
  String? projectOwnerId;
  String? organizationId;
  String? startDate;
  String? endDate;
  String? descr;
  String? thumbnailUrl;
  int? totalBoard;

  ResponseProject({
    this.projectId,
    this.projectName,
    this.projectCode,
    this.projectOwnerId,
    this.organizationId,
    this.startDate,
    this.endDate,
    this.descr,
    this.thumbnailUrl,
    this.totalBoard,
  });

  factory ResponseProject.fromJson(Map<String, dynamic> json) { 
    return ResponseProject(
        projectId: json['project_id'],
        projectName: json['project_name'],
        projectCode: json['project_code'],
        projectOwnerId: json['project_owner_id'],
        organizationId: json['organization_id'],
        startDate: json['start_date'],
        endDate: json['end_date'],
        descr: json['descr'],
        thumbnailUrl: json['thumbnail_url'],
        totalBoard: json['total_board'],
      );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'project_name': projectName,
      'project_code': projectCode,
      'project_owner_id': projectOwnerId,
      'organization_id': organizationId,
      'start_date': startDate,
      'end_date': endDate,
      'descr': descr,
      'thumbnail_url': thumbnailUrl,
      'total_board': totalBoard,
    };
  }
}