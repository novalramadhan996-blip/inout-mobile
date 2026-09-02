class ResponseTask {
  String? projectTaskId;
  String? projectTaskTitle;
  String? projectTaskDueDate;
  String? projectTaskStartDate;
  String? projectTaskStatus;
  String? projectTaskDescription;
  int? totalItem;
  int? totalChecked;
  int? totalUnChecked; 

  ResponseTask({
    this.projectTaskId,
    this.projectTaskTitle,
    this.projectTaskDueDate,
    this.projectTaskStartDate,
    this.projectTaskStatus,
    this.projectTaskDescription,
    this.totalItem,
    this.totalChecked,
    this.totalUnChecked,
  });

  factory ResponseTask.fromJson(Map<String, dynamic> json) { 
    return ResponseTask(
        projectTaskId: json['project_task_id'],
        projectTaskTitle: json['title'],
        projectTaskDueDate: json['due_date'],
        projectTaskStartDate: json['start_date'],
        projectTaskStatus: json['status'],
        projectTaskDescription: json['descr'],
        totalItem: json['total_item'],
        totalChecked: json['total_checked'],
        totalUnChecked: json['total_unchecked'],
      );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_task_id': projectTaskId,
      'title': projectTaskTitle,
      'due_date': projectTaskDueDate,
      'start_date': projectTaskStartDate,
      'status': projectTaskStatus,
      'descr': projectTaskDescription,
      'total_item': totalItem,
      'total_checked': totalChecked,
      'total_unchecked': totalUnChecked,
    };
  }
}