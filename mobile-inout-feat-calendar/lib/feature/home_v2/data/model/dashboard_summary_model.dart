class DashboardSummaryModel {
  final int? late;
  final int? onTime;
  final int? workDayThisMonth;
  final int? totalHoursThisWeek;
  final int? streak;

  DashboardSummaryModel({
    this.late,
    this.onTime,
    this.workDayThisMonth,
    this.totalHoursThisWeek,
    this.streak,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      late: json['late'] ?? 0,
      onTime: json['on_time'] ?? 0,
      workDayThisMonth: json['work_day_this_month'] ?? 0,
      totalHoursThisWeek: json['total_hours_this_week'] ?? 0,
      streak: json['streak'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'late': late,
      'on_time': onTime,
      'work_day_this_month': workDayThisMonth,
      'total_hours_this_week': totalHoursThisWeek,
      'streak': streak,
    };
  }
}
