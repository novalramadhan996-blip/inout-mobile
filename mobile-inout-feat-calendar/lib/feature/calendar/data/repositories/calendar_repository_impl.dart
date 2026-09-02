import 'package:dartz/dartz.dart';
import 'package:mobile_in_out/core/utils/base_response/http_exception.dart';
import 'package:mobile_in_out/core/utils/models/list_data_request.dart';
import 'package:mobile_in_out/core/utils/models/organization/organization_employee_model.dart';
import 'package:mobile_in_out/feature/calendar/data/datasource/calendar_remote_datasource.dart';
import 'package:mobile_in_out/feature/calendar/data/model/google_calendar_event_model.dart';
import 'package:mobile_in_out/feature/calendar/data/model/location_model.dart';
import 'package:mobile_in_out/feature/calendar/data/model/request/request_event_attachment.dart';
import 'package:mobile_in_out/feature/calendar/data/model/request/request_event_employee.dart';
import 'package:mobile_in_out/feature/calendar/data/model/request/request_events.dart';
import 'package:mobile_in_out/feature/calendar/data/model/request/request_schedule.dart';
import 'package:mobile_in_out/feature/calendar/data/model/response/response_event_attachment.dart';
import 'package:mobile_in_out/feature/calendar/data/model/response/response_event_employee.dart';
import 'package:mobile_in_out/feature/calendar/data/model/response/response_events.dart';
import 'package:mobile_in_out/feature/calendar/domain/repositories/calendar_repository.dart';

class CalendarRepositoryImpl extends CalendarRepository {
  final CalendarDatasource calendarDatasource;

  CalendarRepositoryImpl({required this.calendarDatasource});

  @override
  Future<Either<AppException, GoogleCalendarEventModel>> getCalendarEvents({
    required DateTime timeMin,
    required DateTime timeMax,
  }) {
    return calendarDatasource.getCalendarEvents(
      timeMin: timeMin,
      timeMax: timeMax,
    );
  }

  @override
  Future<Either<AppException, List<LocationModel>>> getLocation(
    ListDataRequest params,
  ) {
    return calendarDatasource.getLocation(params);
  }

  @override
  Future<Either<AppException, List<OrganizationEmployee>>> getEmployeeList(
    ListDataRequest params,
  ) {
    return calendarDatasource.getEmployeeList(params);
  }

  @override
  Future<Either<AppException, List<ResponseEvents>>> getSchedule(
    RequestSchedule params,
  ) {
    return calendarDatasource.getSchedule(params);
  }

  @override
  Future<Either<AppException, ResponseEvents>> insertEvent(
    RequestEvents params,
  ) {
    return calendarDatasource.insertEvent(params);
  }

  @override
  Future<Either<AppException, ResponseEvents>> updateEvent(
    RequestEvents params,
    String eventId,
  ) {
    return calendarDatasource.updateEvent(params, eventId);
  }

  @override
  Future<Either<AppException, ResponseEvents>> deleteEvent(String eventId) {
    return calendarDatasource.deleteEvent(eventId);
  }

  @override
  Future<Either<AppException, ResponseEvents>> getEventById(String eventId) {
    return calendarDatasource.getEventById(eventId);
  }

  @override
  Future<Either<AppException, ResponseEventAttachment>> insertEventAttachment(
    RequestEventAttachment params,
  ) {
    return calendarDatasource.insertEventAttachment(params);
  }

  @override
  Future<Either<AppException, List<ResponseEventAttachment>>>
  getEventAttachment(ListDataRequest params) {
    return calendarDatasource.getEventAttachment(params);
  }

  @override
  Future<Either<AppException, List<ResponseEventEmployee>>> getEventEmployee(
    ListDataRequest params,
  ) {
    return calendarDatasource.getEventEmployee(params);
  }

  @override
  Future<Either<AppException, ResponseEventEmployee>> deleteEmployeeEvent(
    String eventEmployeeId,
  ) {
    return calendarDatasource.deleteEmployeeEvent(eventEmployeeId);
  }

  @override
  Future<Either<AppException, ResponseEventAttachment>> deleteEventAttachment(
    String eventAttachmentId,
  ) {
    return calendarDatasource.deleteEventAttachment(eventAttachmentId);
  }

  @override
  Future<Either<AppException, ResponseEventEmployee>> insertEmployeeEvent(
    RequestEventEmployee params,
  ) {
    return calendarDatasource.insertEmployeeEvent(params);
  }

  @override
  Future<Either<AppException, ResponseEventEmployee>> updateEmployeeEvent(
    RequestEventEmployee params,
    String eventEmployeeId,
  ) {
    return calendarDatasource.updateEmployeeEvent(params, eventEmployeeId);
  }

  @override
  Future<Either<AppException, ResponseEventEmployee>> getEmployeeEventById(
    String eventEmployeeId,
  ) {
    return calendarDatasource.getEmployeeEventById(eventEmployeeId);
  }
}
