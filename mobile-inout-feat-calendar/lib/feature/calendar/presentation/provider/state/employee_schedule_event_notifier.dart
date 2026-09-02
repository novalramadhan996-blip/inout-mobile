import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile_in_out/core/utils/base_state/base_state.dart';
import 'package:mobile_in_out/feature/calendar/data/model/request/request_event_attachment.dart';
import 'package:mobile_in_out/feature/calendar/data/model/request/request_event_employee.dart';
import 'package:mobile_in_out/feature/calendar/data/model/response/response_event_attachment.dart';
import 'package:mobile_in_out/feature/calendar/data/model/response/response_event_employee.dart';
import 'package:mobile_in_out/feature/calendar/domain/repositories/calendar_repository.dart';

class EmployeeScheduleEventNotifier
    extends StateNotifier<BaseState<ResponseEventEmployee>> {
  final CalendarRepository calendarRepository;

  EmployeeScheduleEventNotifier(this.calendarRepository)
    : super(const BaseState<ResponseEventEmployee>());

  bool get isFetching =>
      state.state != ConcreteState.loading &&
      state.state != ConcreteState.fetchingMore;

  Future<void> insertEmployeeEvent(RequestEventEmployee params) async {
    if (!isFetching || !mounted) return;

    state = state.copyWith(
      isLoading: true,
      state: ConcreteState.loading,
      data: null,
    );

    final response = await calendarRepository.insertEmployeeEvent(params);

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

  Future<void> getEmployeeEventById(String eventEmployeeId) async {
    if (!isFetching || !mounted) return;

    state = state.copyWith(
      isLoading: true,
      state: ConcreteState.loading,
      data: null,
    );

    final response = await calendarRepository.getEmployeeEventById(
      eventEmployeeId,
    );

    if (!mounted) return;

    response.fold(
      (failure) {
        state = state.copyWith(
          state: ConcreteState.failure,
          message: failure.message,
          isLoading: false,
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

  Future<void> updateEvent(
    RequestEventEmployee params,
    String eventEmployeeId,
  ) async {
    if (!isFetching || !mounted) return;

    state = state.copyWith(
      isLoading: true,
      state: ConcreteState.loading,
      data: null,
    );

    final response = await calendarRepository.updateEmployeeEvent(
      params,
      eventEmployeeId,
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

  Future<void> deleteEvent(String eventEmployeeId) async {
    if (!isFetching || !mounted) return;

    state = state.copyWith(
      isLoading: true,
      state: ConcreteState.loading,
      data: null,
    );

    final response = await calendarRepository.deleteEmployeeEvent(
      eventEmployeeId,
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
          message: 'delete',
          data: data,
        );
      },
    );
  }
}
