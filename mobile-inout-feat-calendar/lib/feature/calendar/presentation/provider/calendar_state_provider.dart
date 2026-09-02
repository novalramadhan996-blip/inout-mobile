import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile_in_out/core/utils/base_state/base_state.dart';
import 'package:mobile_in_out/core/utils/models/organization/organization_employee_model.dart';
import 'package:mobile_in_out/feature/calendar/data/model/google_calendar_event_model.dart';
import 'package:mobile_in_out/feature/calendar/data/model/location_model.dart';
import 'package:mobile_in_out/feature/calendar/data/model/response/response_event_attachment.dart';
import 'package:mobile_in_out/feature/calendar/data/model/response/response_event_employee.dart';
import 'package:mobile_in_out/feature/calendar/data/model/response/response_events.dart';
import 'package:mobile_in_out/feature/calendar/domain/provider/calendar_provider.dart';
import 'package:mobile_in_out/feature/calendar/presentation/provider/state/attachment_event_notifier.dart';
import 'package:mobile_in_out/feature/calendar/presentation/provider/state/attachment_list_event_notifier.dart';
import 'package:mobile_in_out/feature/calendar/presentation/provider/state/calendar_events_notifier.dart';
import 'package:mobile_in_out/feature/calendar/presentation/provider/state/employee_list_notifier.dart';
import 'package:mobile_in_out/feature/calendar/presentation/provider/state/employee_list_schedule_event_notifier.dart';
import 'package:mobile_in_out/feature/calendar/presentation/provider/state/employee_schedule_event_notifier.dart';
import 'package:mobile_in_out/feature/calendar/presentation/provider/state/location_notifier.dart';
import 'package:mobile_in_out/feature/calendar/presentation/provider/state/schedule_event_notifier.dart';
import 'package:mobile_in_out/feature/calendar/presentation/provider/state/schedule_notifier.dart';

final calendarEventsNotifierProvider =
    StateNotifierProvider<
      CalendarEventsNotifier,
      BaseState<GoogleCalendarEventModel>
    >((ref) {
      final repository = ref.watch(calendarRepositoryProvider);
      return CalendarEventsNotifier(repository);
    });

final locationEventsNotifierProvider =
    StateNotifierProvider<
      LocationEventsNotifier,
      BaseState<List<LocationModel>>
    >((ref) {
      final repository = ref.watch(networkRepositoryProvider);
      return LocationEventsNotifier(repository);
    });

final employeeListEventsNotifierProvider =
    StateNotifierProvider<
      EmployeeListEventsNotifier,
      BaseState<List<OrganizationEmployee>>
    >((ref) {
      final repository = ref.watch(networkRepositoryProvider);
      return EmployeeListEventsNotifier(repository);
    });

final scheduleNotifierProvider =
    StateNotifierProvider<ScheduleNotifier, BaseState<List<ResponseEvents>>>((
      ref,
    ) {
      final repository = ref.watch(networkRepositoryProvider);
      return ScheduleNotifier(repository);
    });

final scheduleEventNotifierProvider =
    StateNotifierProvider<ScheduleEventNotifier, BaseState<ResponseEvents>>((
      ref,
    ) {
      final repository = ref.watch(networkRepositoryProvider);
      return ScheduleEventNotifier(repository);
    });

final eventDetailNotifierProvider =
    StateNotifierProvider<ScheduleEventNotifier, BaseState<ResponseEvents>>((
      ref,
    ) {
      final repository = ref.watch(networkRepositoryProvider);
      return ScheduleEventNotifier(repository);
    });

final attachmentEventNotifierProvider =
    StateNotifierProvider<
      AttachmentEventNotifier,
      BaseState<ResponseEventAttachment>
    >((ref) {
      final repository = ref.watch(networkRepositoryProvider);
      return AttachmentEventNotifier(repository);
    });

final attachmentListEventNotifierProvider =
    StateNotifierProvider<
      AttachmentListEventsNotifier,
      BaseState<List<ResponseEventAttachment>>
    >((ref) {
      final repository = ref.watch(networkRepositoryProvider);
      return AttachmentListEventsNotifier(repository);
    });

final employeeListEventNotifierProvider =
    StateNotifierProvider<
      EmployeeListScheduleEventsNotifier,
      BaseState<List<ResponseEventEmployee>>
    >((ref) {
      final repository = ref.watch(networkRepositoryProvider);
      return EmployeeListScheduleEventsNotifier(repository);
    });

final employeeEventNotifierProvider =
    StateNotifierProvider<
      EmployeeScheduleEventNotifier,
      BaseState<ResponseEventEmployee>
    >((ref) {
      final repository = ref.watch(networkRepositoryProvider);
      return EmployeeScheduleEventNotifier(repository);
    });
