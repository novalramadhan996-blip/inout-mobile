import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile_in_out/core/utils/base_state/base_state.dart';
import 'package:mobile_in_out/feature/home_v2/data/model/dashboard_summary_model.dart';
import 'package:mobile_in_out/feature/home_v2/domain/repositories/home_v2_repository.dart';

class DashboardSummaryNotifier
    extends StateNotifier<BaseState<DashboardSummaryModel>> {
  final HomeV2Repository homeV2Repository;

  DashboardSummaryNotifier(this.homeV2Repository)
    : super(const BaseState<DashboardSummaryModel>());

  bool get isFetching =>
      state.state != ConcreteState.loading &&
      state.state != ConcreteState.fetchingMore;

  Future<void> getDashboardSummary(String employeeId, String month) async {
    if (!isFetching || !mounted) return;

    final response = await homeV2Repository.getDashboardSummary(
      employeeId,
      month,
    );

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

        return response;
      },
    );
  }

  void resetState() {
    state = const BaseState();
  }
}
