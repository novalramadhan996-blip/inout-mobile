import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile_in_out/core/utils/base_state/base_state.dart';
import 'package:mobile_in_out/feature/calendar/data/model/google_calendar_event_model.dart';
import 'package:mobile_in_out/feature/calendar/domain/repositories/calendar_repository.dart';

class CalendarEventsNotifier
    extends StateNotifier<BaseState<GoogleCalendarEventModel>> {
  final CalendarRepository calendarRepository;

  CalendarEventsNotifier(this.calendarRepository)
    : super(const BaseState<GoogleCalendarEventModel>());

  bool get isFetching =>
      state.state != ConcreteState.loading &&
      state.state != ConcreteState.fetchingMore;

  Future<void> fetchEvents({
    required DateTime timeMin,
    required DateTime timeMax,
  }) async {
    if (!isFetching || !mounted) return;

    state = state.copyWith(
      isLoading: true,
      state: ConcreteState.loading,
      data: null,
    );

    final response = await calendarRepository.getCalendarEvents(
      timeMin: timeMin,
      timeMax: timeMax,
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
