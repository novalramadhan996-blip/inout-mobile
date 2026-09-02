import 'package:dartz/dartz.dart';
import 'package:mobile_in_out/core/utils/base_response/http_exception.dart';
import 'package:mobile_in_out/core/utils/models/check_in/check_in_requst_model.dart';
import 'package:mobile_in_out/core/utils/models/check_in/check_in_response_model.dart';
import 'package:mobile_in_out/core/utils/models/check_out/check_out_request_model.dart';
import 'package:mobile_in_out/core/utils/models/check_out/check_out_response_model.dart';
import 'package:mobile_in_out/core/utils/models/list_data_request.dart';
import 'package:mobile_in_out/feature/history/model/group_shift_schedule_response.dart';
import 'package:mobile_in_out/feature/home/data/model/employee_detail_model.dart';

abstract class BackgroundRepository {
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
