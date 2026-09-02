import 'package:dartz/dartz.dart';
import 'package:mobile_in_out/core/resources/constants/api_constant.dart';
import 'package:mobile_in_out/core/utils/base_response/http_exception.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';
import 'package:mobile_in_out/core/resources/network/network_riverpod/network_service.dart';
import 'package:mobile_in_out/core/utils/models/check_in/check_in_requst_model.dart';
import 'package:mobile_in_out/core/utils/models/check_in/check_in_response_model.dart';
import 'package:mobile_in_out/core/utils/models/check_out/check_out_request_model.dart';
import 'package:mobile_in_out/core/utils/models/check_out/check_out_response_model.dart';
import 'package:mobile_in_out/core/utils/models/list_data_request.dart';
import 'package:mobile_in_out/feature/history/model/group_shift_schedule_response.dart';
import 'package:mobile_in_out/feature/home/data/model/employee_detail_model.dart';

abstract class BackgroundDatasource {
  Future<Either<AppException, EmployeeDetailModel>> getEmployeeDetail();
  Future<Either<AppException, Map<String, dynamic>>> insertLocation(
    Map<String, dynamic> data,
  );
  Future<Either<AppException, CheckInResponseModel>> checkIn(
    CheckInRequestModel data,
  );
  Future<Either<AppException, CheckOutResponseModel>> checkOut(
    CheckOutRequestModel data,
  );
  Future<Either<AppException, List<GroupShiftScheduleResponse>>>
  getGroupShiftList(ListDataRequest payload);
}

class BackgroundRemoteDatasource extends BackgroundDatasource {
  final NetworkService networkService;
  BackgroundRemoteDatasource(this.networkService);

  @override
  Future<Either<AppException, EmployeeDetailModel>> getEmployeeDetail() async {
    final response = await networkService.get(APIConstant.apiEmployeesMe);

    return response.fold((l) => Left(l), (r) {
      final jsonData = r.data;
      if (jsonData == null || jsonData == '') {
        return Left(
          AppException(
            identifier: 'fetchData',
            statusCode: 0,
            message: 'The data is not in the valid format.',
          ),
        );
      }
      final employeeResponse = jsonData != ''
          ? EmployeeDetailModel.fromJson(jsonData?['data'] ?? {})
          : EmployeeDetailModel();
      return Right(employeeResponse);
    });
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> insertLocation(
    Map<String, dynamic> data,
  ) async {
    final response = await networkService.post(
      APIConstant.apiSendLocation + data['userId'].toString(),
      data: data,
    );

    return response.fold((l) => Left(l), (r) {
      final jsonData = r.data;
      if (jsonData == null || jsonData == '') {
        return Left(
          AppException(
            identifier: 'insertData',
            statusCode: 0,
            message: 'The data is not in the valid format.',
          ),
        );
      }
      final Map<String, dynamic> insertLocationResponse =
          jsonData['data'] as Map<String, dynamic>? ?? {};

      return Right(insertLocationResponse);
    });
  }

  @override
  Future<Either<AppException, CheckInResponseModel>> checkIn(
    CheckInRequestModel data,
  ) async {
    final response = await networkService.post(
      APIConstant.apiCheckIn,
      data: data,
    );

    return response.fold((l) => Left(l), (r) {
      final jsonData = r.data;
      if (jsonData == null || jsonData == '') {
        return Left(
          AppException(
            identifier: 'insertData',
            statusCode: 0,
            message: 'The data is not in the valid format.',
          ),
        );
      }
      final CheckInResponseModel responseData = jsonData['data'] != null
          ? CheckInResponseModel.fromJson(
              jsonData['data'] as Map<String, dynamic>,
            )
          : CheckInResponseModel();

      return Right(responseData);
    });
  }

  @override
  Future<Either<AppException, CheckOutResponseModel>> checkOut(
    CheckOutRequestModel data,
  ) async {
    final response = await networkService.post(
      APIConstant.apiCheckOut,
      data: data,
    );

    return response.fold((l) => Left(l), (r) {
      final jsonData = r.data;
      if (jsonData == null || jsonData == '') {
        return Left(
          AppException(
            identifier: 'insertData',
            statusCode: 0,
            message: 'The data is not in the valid format.',
          ),
        );
      }
      final CheckOutResponseModel responseData = jsonData['data'] != null
          ? CheckOutResponseModel.fromJson(
              jsonData['data'] as Map<String, dynamic>,
            )
          : CheckOutResponseModel();

      return Right(responseData);
    });
  }

  @override
  Future<Either<AppException, List<GroupShiftScheduleResponse>>>
  getGroupShiftList(ListDataRequest payload) async {
    final response = await networkService.post(
      APIConstant.apiGroupShiftSchedule,
      data: payload,
    );
    return response.fold((l) => Left(l), (r) {
      final jsonData = r.data;
      LogHelper.logDebug('debug -> getGroupShiftList response: $jsonData');
      if (jsonData == null || jsonData == '' || jsonData['rows'] == null) {
        LogHelper.logDebug('debug -> getGroupShiftList: rows is null or empty');
        return Left(
          AppException(
            identifier: 'fetchData',
            statusCode: 0,
            message: 'The data is not in the valid format.',
          ),
        );
      }
      final List<GroupShiftScheduleResponse> result = (jsonData['rows'] as List)
          .map(
            (e) =>
                GroupShiftScheduleResponse.fromJson(e as Map<String, dynamic>),
          )
          .toList();
      return Right(result);
    });
  }
}
