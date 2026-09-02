import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile_in_out/core/utils/base_state/base_state.dart';
import 'package:mobile_in_out/core/utils/models/check_in/check_in_response_model.dart';
import 'package:mobile_in_out/core/utils/models/check_out/check_out_response_model.dart';
import 'package:mobile_in_out/feature/absence/domain/provider/absence_provider.dart';
import 'package:mobile_in_out/feature/absence/presentation/provider/state/attendance_file_notifier.dart';
import 'package:mobile_in_out/feature/absence/presentation/provider/state/check_in_notifier.dart';
import 'package:mobile_in_out/feature/absence/presentation/provider/state/check_out_notifier.dart';
import 'package:mobile_in_out/feature/absence/presentation/provider/state/insert_location_notifier.dart';
import 'package:mobile_in_out/feature/absence/presentation/provider/state/local_data_notifier.dart';

final localDataNotifierProvider =
    StateNotifierProvider<LocalDataNotifier, BaseState<dynamic>>((ref) {
      final repository = ref.watch(absenceRepositoryProvider);
      return LocalDataNotifier(repository);
    });

final checkInNotifierProvider =
    StateNotifierProvider<CheckInNotifier, BaseState<CheckInResponseModel>>((
      ref,
    ) {
      final repository = ref.watch(absenceRepositoryProvider);
      return CheckInNotifier(repository);
    });

final checkOutNotifierProvider =
    StateNotifierProvider<CheckOutNotifier, BaseState<CheckOutResponseModel>>((
      ref,
    ) {
      final repository = ref.watch(absenceRepositoryProvider);
      return CheckOutNotifier(repository);
    });

final attendanceFileNotifierProvider =
    StateNotifierProvider<
      AttendanceFileNotifier,
      BaseState<Map<String, dynamic>>
    >((ref) {
      final repository = ref.watch(absenceRepositoryProvider);
      return AttendanceFileNotifier(repository);
    });

final insertLocationNotifierProvider =
    StateNotifierProvider<
      InsertLocationNotifier,
      BaseState<Map<String, dynamic>>
    >((ref) {
      final repository = ref.watch(absenceRepositoryProvider);
      return InsertLocationNotifier(repository);
    });
