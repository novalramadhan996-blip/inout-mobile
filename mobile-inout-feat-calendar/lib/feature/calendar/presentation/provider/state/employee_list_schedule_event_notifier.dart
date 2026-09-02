import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile_in_out/core/utils/base_state/base_state.dart';
import 'package:mobile_in_out/core/utils/models/list_data_request.dart';
import 'package:mobile_in_out/feature/calendar/data/model/response/response_event_employee.dart';
import 'package:mobile_in_out/feature/calendar/domain/repositories/calendar_repository.dart';

class EmployeeListScheduleEventsNotifier
    extends StateNotifier<BaseState<List<ResponseEventEmployee>>> {
  final CalendarRepository calendarRepository;

  EmployeeListScheduleEventsNotifier(this.calendarRepository)
    : super(const BaseState<List<ResponseEventEmployee>>());

  bool get isFetching =>
      state.state != ConcreteState.loading &&
      state.state != ConcreteState.fetchingMore;

  Future<void> getEmployeeEventList(ListDataRequest params) async {
    if (!isFetching || !mounted) return;

    state = state.copyWith(
      isLoading: true,
      state: ConcreteState.loading,
      data: null,
    );

    final response = await calendarRepository.getEventEmployee(params);

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
      (data) {
        state = state.copyWith(
          state: ConcreteState.loaded,
          isLoading: false,
          message: 'success',
          data: data,
        );
      },
    );
  }

  void resetState() {
    state = const BaseState();
  }
}
