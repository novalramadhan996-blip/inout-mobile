import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile_in_out/core/utils/base_state/base_state.dart';
import 'package:mobile_in_out/feature/report_activity/data/model/activity_model.dart';
import 'package:mobile_in_out/feature/report_activity/data/model/list_activity_request_model.dart';
import 'package:mobile_in_out/feature/report_activity/domain/repositories/report_activity_repository.dart';

class ListReportActivityNotifier
    extends StateNotifier<BaseState<List<ActivityModel>>> {
  final ReportActivityRepository reportActivityRepository;

  ListReportActivityNotifier(this.reportActivityRepository)
    : super(const BaseState<List<ActivityModel>>());

  bool get isFetching =>
      state.state != ConcreteState.loading &&
      state.state != ConcreteState.fetchingMore;

  Future<void> getListActivity(ListActivityRequestModel data) async {
    if (!isFetching || !mounted) return;

    final response = await reportActivityRepository.getListActivity(data);

    if (!mounted) return;

    response.fold(
      (failure) {
        state = state.copyWith(
          state: ConcreteState.failure,
          message: failure.message,
          isLoading: false,
          data: null,
        );
      },
      (response) {
        state = state.copyWith(
          state: ConcreteState.loaded,
          isLoading: false,
          message: 'success',
          data: response,
        );
      },
    );
  }

  void resetState() {
    state = const BaseState();
  }
}
