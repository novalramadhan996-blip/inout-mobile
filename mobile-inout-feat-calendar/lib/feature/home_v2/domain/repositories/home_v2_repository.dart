import 'package:dartz/dartz.dart';
import 'package:mobile_in_out/core/utils/base_response/http_exception.dart';
import 'package:mobile_in_out/core/utils/models/check_in/check_in_response_model.dart';
import 'package:mobile_in_out/core/utils/models/history/absence_history_model.dart';
import 'package:mobile_in_out/core/utils/models/list_data_request.dart';
import 'package:mobile_in_out/feature/history/model/group_shift_schedule_response.dart';
import 'package:mobile_in_out/feature/home_v2/data/model/device_info_model.dart';
import 'package:mobile_in_out/feature/home_v2/data/model/employee_detail_model.dart';
import 'package:mobile_in_out/feature/home_v2/data/model/profile_model.dart';

abstract class HomeV2Repository {
  Future<Either<AppException, Map<String, dynamic>>> insertDeviceInfo(
    DeviceInfoModel data,
  );
  Future<Either<AppException, ProfileModel>> getProfile();
  Future<Either<AppException, EmployeeDetailModel>> getEmployeeDetail();
  Future<Either<AppException, List<AbsenceHistoryModel>>> getAttendanceList(
    ListDataRequest payload,
  );
  Future<Either<AppException, List<GroupShiftScheduleResponse>>>
  getGroupShiftList(ListDataRequest payload);
  Future<String> getToken();
  Future<bool> getIsReminder();
  Future<String> getGroupShiftSchedule();
  Future updateGroupShiftSchedule(String groupShift);
  Future<bool> getIsOpenUsageApps();
  Future updateOpenUsageApps(bool isOpenUsageApps);
  Future saveCheckInLocal(CheckInResponseModel inResponseModel);
  Future<CheckInResponseModel> fetchCheckInLocal();
  Future saveEmployeeDetail(String employeeDetail);
  Future saveProfile(String profile);
  Future getDashboardSummary(String employeeId, String month);
}
