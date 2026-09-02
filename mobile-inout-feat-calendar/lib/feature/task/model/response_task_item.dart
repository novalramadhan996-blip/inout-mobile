class ResponseTaskItem {
  String? projectTaskItemId;
  String? title;
  String? description;
  String? status;
  bool? checked;
  int? totalItem;
  int? totalChecked;
  int? totalUnChecked; 

  ResponseTaskItem({
    this.projectTaskItemId,
    this.title,
    this.description,
    this.status,
    this.checked,
    this.totalItem,
    this.totalChecked,
    this.totalUnChecked,
  });

  factory ResponseTaskItem.fromJson(Map<String, dynamic> json) { 
    return ResponseTaskItem(
        projectTaskItemId: json['project_task_id'],
        title: json['title'],
        description: json['descr'],
        status: json['status'],
        checked: json['checked'],
        totalItem: json['total_item'],
        totalChecked: json['total_checked'],
        totalUnChecked: json['total_unchecked'],
      );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_task_id': projectTaskItemId,
      'title': title,
      'descr': description,
      'status': status,
      'checked': checked,
      'total_item': totalItem,
      'total_checked': totalChecked,
      'total_unchecked': totalUnChecked,
    };
  }
}