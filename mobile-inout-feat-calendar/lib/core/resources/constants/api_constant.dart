class APIConstant {
  static const String prefix = "/inout-rest";
  static const String apiEmployeesMe = '$prefix/employees/me';
  static const String apiProfile = '$prefix/auth/myprofile';
  static const String apiSendLocation = '$prefix/location-tracking/';
  static const String apiCheckIn = '$prefix/attendances/in';
  static const String apiCheckOut = '$prefix/attendances/out';
  static const String apiDeviceInfo = '$prefix/device_infos';
  static const String apiUploadImage = '$prefix/upload/image';
  static const String apiCreateActivity = '$prefix/activities/in';
  static const String apiListActivity = '$prefix/activities/list';
  static const String apiAttendanceList = '$prefix/attendances/list';
  static const String apiGroupShiftSchedule =
      '$prefix/group_shift_schedule/list';
  static const String apiAddAttendanceFiles = '$prefix/attendance_files';
  static const String apiDashboardSummary =
      '$prefix/dashboard/attendance-summary';
  static const String apiCalendarEvents = '';
  static const String apiLocation = '$prefix/locations/list';
  static const String apiEmployeeList = '$prefix/employees/list';
  static const String apiUploadFile = '$prefix/upload/file';

  // feature calendar
  static const String apiGetScheduleByDate = '$prefix/events/list/bydate';
  static const String apiEvents = '$prefix/events';
  static const String apiEventAttachment = '$prefix/event_attachments';
  static const String apiEventAttachmentList = '$prefix/event_attachments/list';
  static const String apiEventEmployee = '$prefix/events_employees';
  static const String apiEventEmployeeList = '$prefix/events_employees/list';
}
