import 'package:mobile_in_out/core/resources/local/local_service.dart';
import 'package:mobile_in_out/core/resources/local/pref_service.dart';
import 'package:mobile_in_out/core/utils/models/check_in/check_in_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AbsenceLocalData {
  Future<String> getProfileLocal();
  Future<String> getEmployeeDetailLocal();
  Future saveCheckInLocal(CheckInResponseModel inResponseModel);
  Future deleteCheckInOut();
}

class AbsenceLocalDatasource extends AbsenceLocalData {
  AbsenceLocalDatasource();

  @override
  Future<String> getProfileLocal() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final result = sharedPreferences.getString(PrefServiceKey.profile);
    return result ?? '';
  }

  @override
  Future<String> getEmployeeDetailLocal() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final result = sharedPreferences.getString(PrefServiceKey.employeeDetail);
    return result ?? '';
  }

  @override
  Future saveCheckInLocal(CheckInResponseModel inResponseModel) async {
    final DatabaseHelper db = DatabaseHelper.instance;
    await db.insertCheckIn(inResponseModel);
  }

  @override
  Future deleteCheckInOut() async {
    final DatabaseHelper db = DatabaseHelper.instance;
    await db.deleteCheckInOut();
  }
}
