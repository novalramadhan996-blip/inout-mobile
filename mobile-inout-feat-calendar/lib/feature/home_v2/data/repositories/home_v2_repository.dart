import 'package:dartz/dartz.dart';
import 'package:mobile_in_out/core/utils/base_response/http_exception.dart';
import 'package:mobile_in_out/core/utils/models/check_in/check_in_response_model.dart';
import 'package:mobile_in_out/core/utils/models/history/absence_history_model.dart';
import 'package:mobile_in_out/core/utils/models/list_data_request.dart';
import 'package:mobile_in_out/feature/history/model/group_shift_schedule_response.dart';
import 'package:mobile_in_out/feature/home_v2/data/datasource/home_v2_local_datasource.dart';
import 'package:mobile_in_out/feature/home_v2/data/datasource/home_v2_remote_datasource.dart';
import 'package:mobile_in_out/feature/home_v2/data/model/device_info_model.dart';
import 'package:mobile_in_out/feature/home_v2/data/model/employee_detail_model.dart';
import 'package:mobile_in_out/feature/home_v2/data/model/profile_model.dart';
import 'package:mobile_in_out/feature/home_v2/domain/repositories/home_v2_repository.dart';

class HomeV2RepositoryImpl extends HomeV2Repository {
  final HomeV2Datasource homeV2Datasource;
  final HomeV2LocalData homeV2LocalData;

  HomeV2RepositoryImpl({
    required this.homeV2Datasource,
    required this.homeV2LocalData,
  });

  @override
  Future<Either<AppException, Map<String, dynamic>>> insertDeviceInfo(
    DeviceInfoModel data,
  ) {
    return homeV2Datasource.insertDeviceInfo(data);
  }

  @override
  Future<Either<AppException, ProfileModel>> getProfile() {
    return homeV2Datasource.getProfile();
  }

  @override
  Future<Either<AppException, EmployeeDetailModel>> getEmployeeDetail() {
    return homeV2Datasource.getEmployeeDetail();
  }

  @override
  Future<Either<AppException, List<AbsenceHistoryModel>>> getAttendanceList(
    ListDataRequest payload,
  ) {
    return homeV2Datasource.getAttendanceList(payload);
  }

  @override
  Future<String> getToken() {
    return homeV2LocalData.getToken();
  }

  @override
  Future<bool> getIsReminder() {
    return homeV2LocalData.getIsReminder();
  }

  @override
  Future<String> getGroupShiftSchedule() {
    return homeV2LocalData.getGroupShiftSchedule();
  }

  @override
  Future updateGroupShiftSchedule(String groupShift) {
    return homeV2LocalData.updateGroupShiftSchedule(groupShift);
  }

  @override
  Future<bool> getIsOpenUsageApps() {
    return homeV2LocalData.getIsOpenUsageApps();
  }

  @override
  Future updateOpenUsageApps(bool isOpenUsageApps) {
    return homeV2LocalData.updateOpenUsageApps(isOpenUsageApps);
  }

  @override
  Future<Either<AppException, List<GroupShiftScheduleResponse>>>
  getGroupShiftList(ListDataRequest payload) async {
    return homeV2Datasource.getGroupShiftList(payload);
  }

  @override
  Future saveCheckInLocal(CheckInResponseModel inResponseModel) {
    return homeV2LocalData.saveCheckInLocal(inResponseModel);
  }

  @override
  Future<CheckInResponseModel> fetchCheckInLocal() {
    return homeV2LocalData.fetchCheckInLocal();
  }

  @override
  Future saveEmployeeDetail(String employeeDetail) {
    return homeV2LocalData.saveEmployeeDetail(employeeDetail);
  }

  @override
  Future saveProfile(String profile) {
    return homeV2LocalData.saveProfile(profile);
  }

  @override
  Future getDashboardSummary(String employeeId, String month) {
    return homeV2Datasource.getDashboardSummary(employeeId, month);
  }
}
