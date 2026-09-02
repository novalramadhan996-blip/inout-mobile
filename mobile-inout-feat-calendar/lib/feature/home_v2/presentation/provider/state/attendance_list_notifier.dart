import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile_in_out/core/utils/base_state/base_state.dart';
import 'package:mobile_in_out/core/utils/models/history/absence_history_model.dart';
import 'package:mobile_in_out/core/utils/models/list_data_request.dart';
import 'package:mobile_in_out/feature/home_v2/domain/repositories/home_v2_repository.dart';

class AttendanceListNotifier
    extends StateNotifier<BaseState<List<AbsenceHistoryModel>>> {
  final HomeV2Repository homeV2Repository;

  AttendanceListNotifier(this.homeV2Repository)
    : super(const BaseState<List<AbsenceHistoryModel>>());

  bool get isFetching =>
      state.state != ConcreteState.loading &&
      state.state != ConcreteState.fetchingMore;

  Future<void> getAttendanceList(ListDataRequest data) async {
    if (!isFetching || !mounted) return;

    final response = await homeV2Repository.getAttendanceList(data);

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
