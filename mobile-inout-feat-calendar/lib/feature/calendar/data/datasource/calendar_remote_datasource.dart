import 'package:dartz/dartz.dart';
import 'package:mobile_in_out/core/resources/constants/api_constant.dart';
import 'package:mobile_in_out/core/resources/network/network_riverpod/network_service.dart';
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

abstract class CalendarDatasource {
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

class CalendarRemoteDatasource extends CalendarDatasource {
  final NetworkService networkService;

  CalendarRemoteDatasource(this.networkService);

  @override
  Future<Either<AppException, GoogleCalendarEventModel>> getCalendarEvents({
    required DateTime timeMin,
    required DateTime timeMax,
  }) async {
    final response = await networkService.get(
      APIConstant.apiCalendarEvents,
      queryParameters: {
        'timeMin': timeMin.toUtc().toIso8601String(),
        'timeMax': timeMax.toUtc().toIso8601String(),
        'singleEvents': true,
        'orderBy': 'startTime',
      },
    );

    return response.fold((l) => Left(l), (r) {
      final jsonData = r.data;
      if (jsonData == null || jsonData == '') {
        return Left(
          AppException(
            identifier: 'fetchCalendarEvents',
            statusCode: 0,
            message: 'The data is not in the valid format.',
          ),
        );
      }
      final result = GoogleCalendarEventModel.fromJson(
        jsonData as Map<String, dynamic>,
      );
      return Right(result);
    });
  }

  @override
  Future<Either<AppException, List<LocationModel>>> getLocation(
    ListDataRequest params,
  ) async {
    final response = await networkService.post(
      APIConstant.apiLocation,
      data: params.toJson(),
    );

    return response.fold((l) => Left(l), (r) {
      final jsonData = r.data;
      if (jsonData == null || jsonData == '') {
        return Left(
          AppException(
            identifier: 'getLocation',
            statusCode: 0,
            message: 'The data is not in the valid format.',
          ),
        );
      }
      final mapData = jsonData as Map<String, dynamic>;
      final rows = mapData['rows'] as List<dynamic>;
      final result = LocationModel.fromList(rows);
      return Right(result);
    });
  }

  @override
  Future<Either<AppException, List<OrganizationEmployee>>> getEmployeeList(
    ListDataRequest params,
  ) async {
    final response = await networkService.post(
      APIConstant.apiEmployeeList,
      data: params.toJson(),
    );

    return response.fold((l) => Left(l), (r) {
      final jsonData = r.data;
      if (jsonData == null || jsonData == '') {
        return Left(
          AppException(
            identifier: 'getLocation',
            statusCode: 0,
            message: 'The data is not in the valid format.',
          ),
        );
      }
      final mapData = jsonData as Map<String, dynamic>;
      final rows = mapData['rows'] as List<dynamic>;
      final result = OrganizationEmployee.fromList(rows);
      return Right(result);
    });
  }

  @override
  Future<Either<AppException, List<ResponseEvents>>> getSchedule(
    RequestSchedule params,
  ) async {
    final response = await networkService.post(
      APIConstant.apiGetScheduleByDate,
      data: params.toJson(),
    );

    return response.fold((l) => Left(l), (r) {
      final jsonData = r.data;
      if (jsonData == null || jsonData == '') {
        return Left(
          AppException(
            identifier: 'getSchedule',
            statusCode: 0,
            message: 'The data is not in the valid format.',
          ),
        );
      }
      final mapData = jsonData as Map<String, dynamic>;
      final rows = mapData['rows'] as List<dynamic>;
      final result = ResponseEvents.fromList(rows);
      return Right(result);
    });
  }

  @override
  Future<Either<AppException, ResponseEvents>> insertEvent(
    RequestEvents params,
  ) async {
    final response = await networkService.post(
      APIConstant.apiEvents,
      data: params.toJson(),
    );

    return response.fold((l) => Left(l), (r) {
      final jsonData = r.data;
      if (jsonData == null || jsonData == '') {
        return Left(
          AppException(
            identifier: 'fetchCalendarEvents',
            statusCode: 0,
            message: 'The data is not in the valid format.',
          ),
        );
      }
      final result = ResponseEvents.fromJson(jsonData as Map<String, dynamic>);
      return Right(result);
    });
  }

  @override
  Future<Either<AppException, ResponseEvents>> updateEvent(
    RequestEvents params,
    String eventId,
  ) async {
    final response = await networkService.put(
      '${APIConstant.apiEvents}/$eventId',
      data: params.toJson(),
    );

    return response.fold((l) => Left(l), (r) {
      final jsonData = r.data;
      if (jsonData == null || jsonData == '') {
        return Left(
          AppException(
            identifier: 'fetchCalendarEvents',
            statusCode: 0,
            message: 'The data is not in the valid format.',
          ),
        );
      }
      final result = ResponseEvents.fromJson(jsonData as Map<String, dynamic>);
      return Right(result);
    });
  }

  @override
  Future<Either<AppException, ResponseEvents>> deleteEvent(
    String eventId,
  ) async {
    final response = await networkService.delete(
      '${APIConstant.apiEvents}/$eventId',
    );

    return response.fold((l) => Left(l), (r) {
      final jsonData = r.data;
      if (jsonData == null || jsonData == '') {
        return Left(
          AppException(
            identifier: 'deleteEvent',
            statusCode: 0,
            message: 'The data is not in the valid format.',
          ),
        );
      }
      final result = ResponseEvents.fromJson(jsonData as Map<String, dynamic>);
      return Right(result);
    });
  }

  @override
  Future<Either<AppException, ResponseEvents>> getEventById(
    String eventId,
  ) async {
    final response = await networkService.get(
      '${APIConstant.apiEvents}/$eventId',
    );

    return response.fold((l) => Left(l), (r) {
      final jsonData = r.data;
      if (jsonData == null || jsonData == '' || jsonData['data'] == null) {
        return Left(
          AppException(
            identifier: 'getEventById',
            statusCode: 0,
            message: 'The data is not in the valid format.',
          ),
        );
      }
      final result = ResponseEvents.fromJson(
        jsonData['data'] as Map<String, dynamic>,
      );
      return Right(result);
    });
  }

  @override
  Future<Either<AppException, ResponseEventAttachment>> insertEventAttachment(
    RequestEventAttachment params,
  ) async {
    final response = await networkService.post(
      APIConstant.apiEventAttachment,
      data: params.toJson(),
    );

    return response.fold((l) => Left(l), (r) {
      final jsonData = r.data;
      if (jsonData == null || jsonData == '') {
        return Left(
          AppException(
            identifier: 'insertEventAttachment',
            statusCode: 0,
            message: 'The data is not in the valid format.',
          ),
        );
      }
      final mapData =
          jsonData['data'] as Map<String, dynamic>? ??
          jsonData as Map<String, dynamic>;
      final result = ResponseEventAttachment.fromJson(mapData);
      return Right(result);
    });
  }

  @override
  Future<Either<AppException, List<ResponseEventAttachment>>>
  getEventAttachment(ListDataRequest params) async {
    final response = await networkService.post(
      APIConstant.apiEventAttachmentList,
      data: params.toJson(),
    );

    return response.fold((l) => Left(l), (r) {
      final jsonData = r.data;
      if (jsonData == null || jsonData == '') {
        return Left(
          AppException(
            identifier: 'getLocation',
            statusCode: 0,
            message: 'The data is not in the valid format.',
          ),
        );
      }
      final mapData = jsonData as Map<String, dynamic>;
      final rows = mapData['rows'] as List<dynamic>;
      final result = ResponseEventAttachment.fromList(rows);
      return Right(result);
    });
  }

  @override
  Future<Either<AppException, List<ResponseEventEmployee>>> getEventEmployee(
    ListDataRequest params,
  ) async {
    final response = await networkService.post(
      APIConstant.apiEventEmployeeList,
      data: params.toJson(),
    );

    return response.fold((l) => Left(l), (r) {
      final jsonData = r.data;
      if (jsonData == null || jsonData == '') {
        return Left(
          AppException(
            identifier: 'getLocation',
            statusCode: 0,
            message: 'The data is not in the valid format.',
          ),
        );
      }
      final mapData = jsonData as Map<String, dynamic>;
      final rows = mapData['rows'] as List<dynamic>;
      final result = ResponseEventEmployee.fromList(rows);
      return Right(result);
    });
  }

  @override
  Future<Either<AppException, ResponseEventEmployee>> deleteEmployeeEvent(
    String eventEmployeeId,
  ) async {
    final response = await networkService.delete(
      '${APIConstant.apiEventEmployee}/$eventEmployeeId',
    );

    return response.fold((l) => Left(l), (r) {
      final jsonData = r.data;
      if (jsonData == null || jsonData == '') {
        return Left(
          AppException(
            identifier: 'deleteEvent',
            statusCode: 0,
            message: 'The data is not in the valid format.',
          ),
        );
      }
      final result = ResponseEventEmployee.fromJson(
        jsonData as Map<String, dynamic>,
      );
      return Right(result);
    });
  }

  @override
  Future<Either<AppException, ResponseEventAttachment>> deleteEventAttachment(
    String eventAttachmentId,
  ) async {
    final response = await networkService.delete(
      '${APIConstant.apiEventAttachment}/$eventAttachmentId',
    );

    return response.fold((l) => Left(l), (r) {
      final jsonData = r.data;
      if (jsonData == null || jsonData == '') {
        return Left(
          AppException(
            identifier: 'deleteEvent',
            statusCode: 0,
            message: 'The data is not in the valid format.',
          ),
        );
      }
      final result = ResponseEventAttachment.fromJson(
        jsonData as Map<String, dynamic>,
      );
      return Right(result);
    });
  }

  @override
  Future<Either<AppException, ResponseEventEmployee>> insertEmployeeEvent(
    RequestEventEmployee params,
  ) async {
    final response = await networkService.post(
      APIConstant.apiEventEmployee,
      data: params.toJson(),
    );

    return response.fold((l) => Left(l), (r) {
      final jsonData = r.data;
      if (jsonData == null || jsonData == '') {
        return Left(
          AppException(
            identifier: 'insertEventAttachment',
            statusCode: 0,
            message: 'The data is not in the valid format.',
          ),
        );
      }
      final mapData =
          jsonData['data'] as Map<String, dynamic>? ??
          jsonData as Map<String, dynamic>;
      final result = ResponseEventEmployee.fromJson(mapData);
      return Right(result);
    });
  }

  @override
  Future<Either<AppException, ResponseEventEmployee>> updateEmployeeEvent(
    RequestEventEmployee params,
    String eventEmployeeId,
  ) async {
    final response = await networkService.put(
      '${APIConstant.apiEventEmployee}/$eventEmployeeId',
      data: params.toJson(),
    );

    return response.fold((l) => Left(l), (r) {
      final jsonData = r.data;
      if (jsonData == null || jsonData == '') {
        return Left(
          AppException(
            identifier: 'fetchCalendarEvents',
            statusCode: 0,
            message: 'The data is not in the valid format.',
          ),
        );
      }
      final result = ResponseEventEmployee.fromJson(
        jsonData as Map<String, dynamic>,
      );
      return Right(result);
    });
  }

  @override
  Future<Either<AppException, ResponseEventEmployee>> getEmployeeEventById(
    String eventEmployeeId,
  ) async {
    final response = await networkService.get(
      '${APIConstant.apiEventEmployee}/$eventEmployeeId',
    );

    return response.fold((l) => Left(l), (r) {
      final jsonData = r.data;
      if (jsonData == null || jsonData == '' || jsonData['data'] == null) {
        return Left(
          AppException(
            identifier: 'getEventById',
            statusCode: 0,
            message: 'The data is not in the valid format.',
          ),
        );
      }
      final result = ResponseEventEmployee.fromJson(
        jsonData['data'] as Map<String, dynamic>,
      );
      return Right(result);
    });
  }
}
