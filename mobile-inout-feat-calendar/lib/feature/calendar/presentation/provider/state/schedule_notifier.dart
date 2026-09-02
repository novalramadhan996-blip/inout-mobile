import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile_in_out/core/utils/base_state/base_state.dart';
import 'package:mobile_in_out/feature/calendar/data/model/request/request_schedule.dart';
import 'package:mobile_in_out/feature/calendar/data/model/response/response_events.dart';
import 'package:mobile_in_out/feature/calendar/domain/repositories/calendar_repository.dart';

class ScheduleNotifier extends StateNotifier<BaseState<List<ResponseEvents>>> {
  final CalendarRepository calendarRepository;

  ScheduleNotifier(this.calendarRepository)
    : super(const BaseState<List<ResponseEvents>>());

  bool get isFetching =>
      state.state != ConcreteState.loading &&
      state.state != ConcreteState.fetchingMore;

  Future<void> getSchedule(RequestSchedule params) async {
    if (!isFetching || !mounted) return;

    state = state.copyWith(
      isLoading: true,
      state: ConcreteState.loading,
      data: null,
    );

    final response = await calendarRepository.getSchedule(params);

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
