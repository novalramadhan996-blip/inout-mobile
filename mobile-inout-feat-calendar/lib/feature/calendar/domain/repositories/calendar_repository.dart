import 'package:dartz/dartz.dart';
import 'package:mobile_in_out/core/utils/base_response/http_exception.dart';
import 'package:mobile_in_out/core/utils/models/list_data_request.dart';
import 'package:mobile_in_out/core/utils/models/organization/organization_employee_model.dart';
import 'package:mobile_in_out/feature/calendar/data/model/google_calendar_event_model.dart';
import 'package:mobile_in_out/feature/calendar/data/model/location_model.dart';
import 'package:mobile_in_out/feature/calendar/data/model/request/request_event_attachment.dart';
import 'package:mobile_in_out/feature/calendar/data/model/request/request_event_employee.dart';
import 'package:mobile_in_out/feature/calendar/data/model/request/request_events.dart';
import 'package:mobile_in_out/feature/calendar/data/model/request/request_schedule.dart';
import 'package:mobile_in_out/feature/calendar/data/model/response/response_event_attachment.dart';
import 'package:mobile_in_out/feature/calendar/data/model/response/response_event_employee.dart';
import 'package:mobile_in_out/feature/calendar/data/model/response/response_events.dart';

abstract class CalendarRepository {
  Future<Either<AppException, GoogleCalendarEventModel>> getCalendarEvents({
    required DateTime timeMin,
    required DateTime timeMax,
  });
  Future<Either<AppException, List<LocationModel>>> getLocation(
    ListDataRequest params,
  );
  Future<Either<AppException, List<OrganizationEmployee>>> getEmployeeList(
    ListDataRequest params,
  );
  Future<Either<AppException, List<ResponseEvents>>> getSchedule(
    RequestSchedule params,
  );
  Future<Either<AppException, ResponseEvents>> insertEvent(
    RequestEvents params,
  );
  Future<Either<AppException, ResponseEvents>> updateEvent(
    RequestEvents params,
    String eventId,
  );
  Future<Either<AppException, ResponseEvents>> deleteEvent(String eventId);
  Future<Either<AppException, ResponseEvents>> getEventById(String eventId);
  Future<Either<AppException, ResponseEventAttachment>> insertEventAttachment(
    RequestEventAttachment params,
  );
  Future<Either<AppException, ResponseEventAttachment>> deleteEventAttachment(
    String eventAttachmentId,
  );
  Future<Either<AppException, List<ResponseEventAttachment>>>
  getEventAttachment(ListDataRequest params);
  Future<Either<AppException, List<ResponseEventEmployee>>> getEventEmployee(
    ListDataRequest params,
  );
  Future<Either<AppException, ResponseEventEmployee>> insertEmployeeEvent(
    RequestEventEmployee params,
  );
  Future<Either<AppException, ResponseEventEmployee>> updateEmployeeEvent(
    RequestEventEmployee params,
    String eventEmployeeId,
  );
  Future<Either<AppException, ResponseEventEmployee>> deleteEmployeeEvent(
    String eventEmployeeId,
  );
  Future<Either<AppException, ResponseEventEmployee>> getEmployeeEventById(
    String eventEmployeeId,
  );
}
