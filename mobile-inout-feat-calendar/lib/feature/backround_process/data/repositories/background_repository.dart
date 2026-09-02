import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:mobile_in_out/core/resources/local/pref_service.dart';
import 'package:mobile_in_out/core/utils/base_response/http_exception.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';
import 'package:mobile_in_out/core/utils/models/check_in/check_in_requst_model.dart';
import 'package:mobile_in_out/core/utils/models/check_in/check_in_response_model.dart';
import 'package:mobile_in_out/core/utils/models/check_out/check_out_request_model.dart';
import 'package:mobile_in_out/core/utils/models/check_out/check_out_response_model.dart';
import 'package:mobile_in_out/core/utils/models/list_data_request.dart';
import 'package:mobile_in_out/feature/backround_process/data/datasource/background_remote_datasource.dart';
import 'package:mobile_in_out/feature/backround_process/domain/repositories/background_repository.dart';
import 'package:mobile_in_out/feature/history/model/group_shift_schedule_response.dart';
import 'package:mobile_in_out/feature/home/data/model/employee_detail_model.dart';

class BackgroundRepositoryImpl extends BackgroundRepository {
  final BackgroundDatasource backgroundDatasource;
  final ShardPrefService prefService;
  BackgroundRepositoryImpl(this.backgroundDatasource, this.prefService);

  @override
  Future<Either<AppException, EmployeeDetailModel>> getEmployeeDetail() async {
    final cachedData = await prefService.getString(
      PrefServiceKey.employeeDetail,
    );
    if (cachedData != null && cachedData.isNotEmpty) {
      try {
        final jsonMap = json.decode(cachedData) as Map<String, dynamic>;
        return Right(EmployeeDetailModel.fromJson(jsonMap));
      } catch (_) {}
    }

    final result = await backgroundDatasource.getEmployeeDetail();
    return result.fold((l) => Left(l), (r) async {
      await prefService.setString(
        PrefServiceKey.employeeDetail,
        json.encode(r.toJson()),
      );
      return Right(r);
    });
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> insertLocation(
    Map<String, dynamic> data,
  ) {
    return backgroundDatasource.insertLocation(data);
  }

  @override
  Future<Either<AppException, CheckInResponseModel>> checkIn(
    CheckInRequestModel data,
  ) {
    return backgroundDatasource.checkIn(data);
  }

  @override
  Future<Either<AppException, CheckOutResponseModel>> checkOut(
    CheckOutRequestModel data,
  ) {
    return backgroundDatasource.checkOut(data);
  }

  @override
  Future<Either<AppException, List<GroupShiftScheduleResponse>>>
  getGroupShiftList(ListDataRequest payload) async {
    if (payload.filter == null ||
        payload.filter!.isEmpty ||
        !payload.filter!.containsKey('employee_id') ||
        payload.filter!['employee_id'] == null ||
        payload.filter!['employee_id'].toString().isEmpty) {
      LogHelper.logDebug('debug -> getGroupShiftList: employee_id is empty');
      return const Right([]);
    }

    final cachedData = await prefService.getString(
      PrefServiceKey.groupShiftSchedule,
    );
    LogHelper.logDebug('debug -> cachedData $cachedData');
    LogHelper.logDebug('debug -> payload $payload');
    if (cachedData != null && cachedData.isNotEmpty) {
      try {
        final jsonList = json.decode(cachedData) as List;
        final result = jsonList
            .map(
              (e) => GroupShiftScheduleResponse.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList();
        return Right(result);
      } catch (e) {
        LogHelper.logDebug('debug -> error cachedData $e');
      }
    }

    final result = await backgroundDatasource.getGroupShiftList(payload);
    LogHelper.logDebug('debug -> result scheduled 1 ${result}');
    return result.fold((l) => Left(l), (r) async {
      await prefService.setString(
        PrefServiceKey.groupShiftSchedule,
        json.encode(r.map((e) => e.toJson()).toList()),
      );
      LogHelper.logDebug('debug -> result scheduled $r');
      return Right(r);
    });
  }
}
