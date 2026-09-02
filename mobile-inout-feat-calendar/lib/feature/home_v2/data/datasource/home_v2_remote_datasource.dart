import 'package:dartz/dartz.dart';
import 'package:mobile_in_out/core/resources/constants/api_constant.dart';
import 'package:mobile_in_out/core/utils/base_response/http_exception.dart';
import 'package:mobile_in_out/core/resources/network/network_riverpod/network_service.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';
import 'package:mobile_in_out/core/utils/models/history/absence_history_model.dart';
import 'package:mobile_in_out/core/utils/models/list_data_request.dart';
import 'package:mobile_in_out/feature/history/model/group_shift_schedule_response.dart';
import 'package:mobile_in_out/feature/home_v2/data/model/dashboard_summary_model.dart';
import 'package:mobile_in_out/feature/home_v2/data/model/device_info_model.dart';
import 'package:mobile_in_out/feature/home_v2/data/model/employee_detail_model.dart';
import 'package:mobile_in_out/feature/home_v2/data/model/profile_model.dart';

abstract class HomeV2Datasource {
  Future<Either<AppException, Map<String, dynamic>>> insertDeviceInfo(
    DeviceInfoModel payload,
  );
  Future<Either<AppException, ProfileModel>> getProfile();
  Future<Either<AppException, EmployeeDetailModel>> getEmployeeDetail();
  Future<Either<AppException, List<AbsenceHistoryModel>>> getAttendanceList(
    ListDataRequest payload,
  );
  Future<Either<AppException, List<GroupShiftScheduleResponse>>>
  getGroupShiftList(ListDataRequest payload);
  Future<Either<AppException, DashboardSummaryModel>> getDashboardSummary(
    String employeeId,
    String month,
  );
}

class HomeV2RemoteDatasource extends HomeV2Datasource {
  final NetworkService networkService;
  HomeV2RemoteDatasource(this.networkService);

  @override
  Future<Either<AppException, Map<String, dynamic>>> insertDeviceInfo(
    DeviceInfoModel payload,
  ) async {
    final response = await networkService.post(
      APIConstant.apiDeviceInfo,
      data: payload,
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
      final Map<String, dynamic> responseData =
          jsonData['data'] as Map<String, dynamic>? ?? {};

      return Right(responseData);
    });
  }

  @override
  Future<Either<AppException, ProfileModel>> getProfile() async {
    final response = await networkService.get(APIConstant.apiProfile);

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
      final result = jsonData != ''
          ? ProfileModel.fromJson(jsonData ?? {})
          : ProfileModel();
      return Right(result);
    });
  }

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
  Future<Either<AppException, List<AbsenceHistoryModel>>> getAttendanceList(
    ListDataRequest payload,
  ) async {
    final response = await networkService.post(
      APIConstant.apiAttendanceList,
      data: payload,
    );

    return response.fold((l) => Left(l), (r) {
      final jsonData = r.data;
      if (jsonData == null || jsonData == '' || jsonData['rows'] == null) {
        return Left(
          AppException(
            identifier: 'fetchData',
            statusCode: 0,
            message: 'The data is not in the valid format.',
          ),
        );
      }
      final List<AbsenceHistoryModel> result = (jsonData['rows'] as List)
          .map((e) => AbsenceHistoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(result);
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
      if (jsonData == null || jsonData == '' || jsonData['rows'] == null) {
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

  @override
  Future<Either<AppException, DashboardSummaryModel>> getDashboardSummary(
    String employeeId,
    String month,
  ) async {
    final response = await networkService.get(
      APIConstant.apiDashboardSummary,
      queryParameters: {'employee_id': employeeId, 'month': month},
    );

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
      final result = jsonData != ''
          ? DashboardSummaryModel.fromJson(jsonData?['data'] ?? {})
          : DashboardSummaryModel();
      return Right(result);
    });
  }
}
