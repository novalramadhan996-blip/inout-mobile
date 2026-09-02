class ProjectTaskMemberModel {
  final ProjectTask? projectTask;
  final Member? member;
  final String? projectTaskMemberId;
  final String? projectTaskId;
  final String? memberId;
  final String? role;
  final String? startDate;
  final String? endDate;
  final bool? active;
  final String? created;
  final String? createdBy;
  final String? updated;
  final String? updatedBy;

  ProjectTaskMemberModel({
    this.projectTask,
    this.member,
    this.projectTaskMemberId,
    this.projectTaskId,
    this.memberId,
    this.role,
    this.startDate,
    this.endDate,
    this.active,
    this.created,
    this.createdBy,
    this.updated,
    this.updatedBy,
  });

  factory ProjectTaskMemberModel.fromJson(Map<String, dynamic> json) {
    return ProjectTaskMemberModel(
      projectTask: json['projectTask'] != null
          ? ProjectTask.fromJson(json['projectTask'])
          : null,
      member: json['member'] != null ? Member.fromJson(json['member']) : null,
      projectTaskMemberId: json['project_task_member_id'],
      projectTaskId: json['project_task_id'],
      memberId: json['member_id'],
      role: json['role'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      active: json['active'],
      created: json['created'],
      createdBy: json['createdby'],
      updated: json['updated'],
      updatedBy: json['updatedby'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectTask': projectTask?.toJson(),
      'member': member?.toJson(),
      'project_task_member_id': projectTaskMemberId,
      'project_task_id': projectTaskId,
      'member_id': memberId,
      'role': role,
      'start_date': startDate,
      'end_date': endDate,
      'active': active,
      'created': created,
      'createdby': createdBy,
      'updated': updated,
      'updatedby': updatedBy,
    };
  }
}

class ProjectTask {
  final String? projectTaskId;
  final String? projectBoardId;
  final String? title;
  final String? descr;
  final String? employeeId;
  final String? dueDate;
  final String? startDate;
  final String? status;
  final int? position;
  final String? created;
  final String? createdBy;
  final String? updated;
  final String? updatedBy;
  final dynamic metadata;
  final dynamic parentTaskId;
  final dynamic checked;
  final dynamic totalItem;
  final dynamic totalChecked;
  final dynamic totalUnchecked;

  ProjectTask({
    this.projectTaskId,
    this.projectBoardId,
    this.title,
    this.descr,
    this.employeeId,
    this.dueDate,
    this.startDate,
    this.status,
    this.position,
    this.created,
    this.createdBy,
    this.updated,
    this.updatedBy,
    this.metadata,
    this.parentTaskId,
    this.checked,
    this.totalItem,
    this.totalChecked,
    this.totalUnchecked,
  });

  factory ProjectTask.fromJson(Map<String, dynamic> json) {
    return ProjectTask(
      projectTaskId: json['project_task_id'],
      projectBoardId: json['project_board_id'],
      title: json['title'],
      descr: json['descr'],
      employeeId: json['employee_id'],
      dueDate: json['due_date'],
      startDate: json['start_date'],
      status: json['status'],
      position: json['position'],
      created: json['created'],
      createdBy: json['createdby'],
      updated: json['updated'],
      updatedBy: json['updatedby'],
      metadata: json['metadata'],
      parentTaskId: json['parent_task_id'],
      checked: json['checked'],
      totalItem: json['total_item'],
      totalChecked: json['total_checked'],
      totalUnchecked: json['total_unchecked'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_task_id': projectTaskId,
      'project_board_id': projectBoardId,
      'title': title,
      'descr': descr,
      'employee_id': employeeId,
      'due_date': dueDate,
      'start_date': startDate,
      'status': status,
      'position': position,
      'created': created,
      'createdby': createdBy,
      'updated': updated,
      'updatedby': updatedBy,
      'metadata': metadata,
      'parent_task_id': parentTaskId,
      'checked': checked,
      'total_item': totalItem,
      'total_checked': totalChecked,
      'total_unchecked': totalUnchecked,
    };
  }
}

class Member {
  final String? employeeId;
  final String? address;
  final String? city;
  final String? country;
  final String? created;
  final String? createdBy;
  final String? dateOfBirth;
  final String? email;
  final String? employeeCode;
  final String? employeeName;
  final String? gender;
  final String? idCard;
  final String? phone;
  final String? placeOfBirth;
  final String? profileUrl;
  final String? province;
  final String? religion;
  final String? updated;
  final String? updatedBy;
  final String? zipCode;

  Member({
    this.employeeId,
    this.address,
    this.city,
    this.country,
    this.created,
    this.createdBy,
    this.dateOfBirth,
    this.email,
    this.employeeCode,
    this.employeeName,
    this.gender,
    this.idCard,
    this.phone,
    this.placeOfBirth,
    this.profileUrl,
    this.province,
    this.religion,
    this.updated,
    this.updatedBy,
    this.zipCode,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      employeeId: json['employee_id'],
      address: json['address'],
      city: json['city'],
      country: json['country'],
      created: json['created'],
      createdBy: json['createdby'],
      dateOfBirth: json['dateofbirth'],
      email: json['email'],
      employeeCode: json['employee_code'],
      employeeName: json['employee_name'],
      gender: json['gender'],
      idCard: json['idcard'],
      phone: json['phone'],
      placeOfBirth: json['placeofbirth'],
      profileUrl: json['profile_url'],
      province: json['province'],
      religion: json['religion'],
      updated: json['updated'],
      updatedBy: json['updatedby'],
      zipCode: json['zipcode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'address': address,
      'city': city,
      'country': country,
      'created': created,
      'createdby': createdBy,
      'dateofbirth': dateOfBirth,
      'email': email,
      'employee_code': employeeCode,
      'employee_name': employeeName,
      'gender': gender,
      'idcard': idCard,
      'phone': phone,
      'placeofbirth': placeOfBirth,
      'profile_url': profileUrl,
      'province': province,
      'religion': religion,
      'updated': updated,
      'updatedby': updatedBy,
      'zipcode': zipCode,
    };
  }
}
