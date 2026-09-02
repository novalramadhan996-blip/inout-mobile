import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile_in_out/core/utils/base_state/base_state.dart';
import 'package:mobile_in_out/feature/report_activity/data/model/activity_model.dart';
import 'package:mobile_in_out/feature/report_activity/domain/provider/report_activity_provider.dart';
import 'package:mobile_in_out/feature/report_activity/presentation/provider/state/list_report_activity_notifier.dart';
import 'package:mobile_in_out/feature/report_activity/presentation/provider/state/report_activity_notifier.dart';

final reportActivityNotifierProvider =
    StateNotifierProvider<
      ReportActivityNotifier,
      BaseState<Map<String, dynamic>>
    >((ref) {
      final repository = ref.watch(reportActivityRepositoryProvider);
      return ReportActivityNotifier(repository);
    });

final listReportActivityNotifierProvider =
    StateNotifierProvider<
      ListReportActivityNotifier,
      BaseState<List<ActivityModel>>
    >((ref) {
      final repository = ref.watch(reportActivityRepositoryProvider);
      return ListReportActivityNotifier(repository);
    });
