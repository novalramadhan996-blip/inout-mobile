import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile_in_out/core/utils/base_state/base_state.dart';
import 'package:mobile_in_out/core/utils/models/history/absence_history_model.dart';
import 'package:mobile_in_out/feature/history/model/group_shift_schedule_response.dart';
import 'package:mobile_in_out/feature/home_v2/data/model/dashboard_summary_model.dart';
import 'package:mobile_in_out/feature/home_v2/data/model/employee_detail_model.dart';
import 'package:mobile_in_out/feature/home_v2/data/model/profile_model.dart';
import 'package:mobile_in_out/feature/home_v2/domain/provider/home_v2_provider.dart';
import 'package:mobile_in_out/feature/home_v2/presentation/provider/state/attendance_list_notifier.dart';
import 'package:mobile_in_out/feature/home_v2/presentation/provider/state/dashboard_summary_notifier.dart';
import 'package:mobile_in_out/feature/home_v2/presentation/provider/state/device_info_notifier.dart';
import 'package:mobile_in_out/feature/home_v2/presentation/provider/state/employee_detail_notifier.dart';
import 'package:mobile_in_out/feature/home_v2/presentation/provider/state/group_shift_schedules_notifer.dart';
import 'package:mobile_in_out/feature/home_v2/presentation/provider/state/local_data_notifier.dart';
import 'package:mobile_in_out/feature/home_v2/presentation/provider/state/profile_notifier.dart';

final deviceInfoNotifierProvider =
    StateNotifierProvider<DeviceInfoNotifier, BaseState<Map<String, dynamic>>>((
      ref,
    ) {
      final repository = ref.watch(homeV2RepositoryProvider);
      return DeviceInfoNotifier(repository);
    });

final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, BaseState<ProfileModel>>((ref) {
      final repository = ref.watch(homeV2RepositoryProvider);
      return ProfileNotifier(repository);
    });

final employeeDetailNotifierProvider =
    StateNotifierProvider<
      EmployeeDetailNotifier,
      BaseState<EmployeeDetailModel>
    >((ref) {
      final repository = ref.watch(homeV2RepositoryProvider);
      return EmployeeDetailNotifier(repository);
    });

final localDataNotifierProvider =
    StateNotifierProvider<LocalDataNotifier, BaseState<dynamic>>((ref) {
      final repository = ref.watch(homeV2RepositoryProvider);
      return LocalDataNotifier(repository);
    });

final attendanceListNotifierProvider =
    StateNotifierProvider<
      AttendanceListNotifier,
      BaseState<List<AbsenceHistoryModel>>
    >((ref) {
      final repository = ref.watch(homeV2RepositoryProvider);
      return AttendanceListNotifier(repository);
    });

final groupShiftListNotifierProvider =
    StateNotifierProvider<
      GroupShiftSchedulesListNotifier,
      BaseState<List<GroupShiftScheduleResponse>>
    >((ref) {
      final repository = ref.watch(homeV2RepositoryProvider);
      return GroupShiftSchedulesListNotifier(repository);
    });

final dashboardSummaryNotifierProvider =
    StateNotifierProvider<
      DashboardSummaryNotifier,
      BaseState<DashboardSummaryModel>
    >((ref) {
      final repository = ref.watch(homeV2RepositoryProvider);
      return DashboardSummaryNotifier(repository);
    });
