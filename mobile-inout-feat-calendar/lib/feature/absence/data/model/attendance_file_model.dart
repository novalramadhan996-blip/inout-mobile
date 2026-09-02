class AttendanceFileModel {
  final String? attendanceId;
  final String? title;
  final String? fileUrl;

  AttendanceFileModel({
    this.attendanceId,
    this.title,
    this.fileUrl,
  });

  factory AttendanceFileModel.fromJson(Map<String, dynamic> json) {
    return AttendanceFileModel(
      attendanceId: json['attendance_id'] as String?,
      title: json['title'] as String?,
      fileUrl: json['file_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendance_id': attendanceId,
      'title': title,
      'file_url': fileUrl,
    };
  }
}
