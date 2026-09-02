import 'package:mobile_in_out/core/resources/local/local_service.dart';
import 'package:mobile_in_out/core/resources/local/pref_service.dart';
import 'package:mobile_in_out/core/utils/models/check_in/check_in_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class HomeV2LocalData {
  Future<String> getToken();
  Future<bool> getIsReminder();
  Future<String> getGroupShiftSchedule();
  Future updateGroupShiftSchedule(String groupShift);
  Future<bool> getIsOpenUsageApps();
  Future updateOpenUsageApps(bool isOpenUsageApps);
  Future saveCheckInLocal(CheckInResponseModel inResponseModel);
  Future<CheckInResponseModel> fetchCheckInLocal();
  Future saveProfile(String profile);
  Future saveEmployeeDetail(String employeeDetail);
}

class HomeV2LocalDatasource extends HomeV2LocalData {
  HomeV2LocalDatasource();

  @override
  Future<String> getToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final result = sharedPreferences.getString(PrefServiceKey.authToken);
    return result ?? '';
  }

  @override
  Future<bool> getIsReminder() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final result = sharedPreferences.getBool(PrefServiceKey.isReminder);
    return result ?? false;
  }

  @override
  Future<String> getGroupShiftSchedule() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final result = sharedPreferences.getString(
      PrefServiceKey.groupShiftSchedule,
    );
    return result ?? '';
  }

  @override
  Future updateGroupShiftSchedule(String groupShift) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(PrefServiceKey.groupShiftSchedule, groupShift);
  }

  @override
  Future<bool> getIsOpenUsageApps() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final result = sharedPreferences.getBool(PrefServiceKey.isOpenUsageAccess);
    return result ?? false;
  }

  @override
  Future updateOpenUsageApps(bool isOpenUsageApps) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(
      PrefServiceKey.isOpenUsageAccess,
      isOpenUsageApps,
    );
  }

  @override
  Future saveCheckInLocal(CheckInResponseModel inResponseModel) async {
    final DatabaseHelper db = DatabaseHelper.instance;
    await db.insertCheckIn(inResponseModel);
  }

  @override
  Future<CheckInResponseModel> fetchCheckInLocal() async {
    final DatabaseHelper db = DatabaseHelper.instance;
    final List<CheckInResponseModel> checkIn = await db.queryAllCheckIn();
    if (checkIn.isNotEmpty) {
      return checkIn.first;
    } else {
      return CheckInResponseModel();
    }
  }

  @override
  Future saveEmployeeDetail(String employeeDetail) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(PrefServiceKey.employeeDetail, employeeDetail);
  }

  @override
  Future saveProfile(String profile) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(PrefServiceKey.profile, profile);
  }
}
