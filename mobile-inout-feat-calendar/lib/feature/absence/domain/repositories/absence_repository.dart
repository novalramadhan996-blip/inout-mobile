import 'package:dartz/dartz.dart';
import 'package:mobile_in_out/core/utils/base_response/http_exception.dart';
import 'package:mobile_in_out/core/utils/models/check_in/check_in_requst_model.dart';
import 'package:mobile_in_out/core/utils/models/check_in/check_in_response_model.dart';
import 'package:mobile_in_out/core/utils/models/check_out/check_out_request_model.dart';
import 'package:mobile_in_out/core/utils/models/check_out/check_out_response_model.dart';
import 'package:mobile_in_out/feature/absence/data/model/attendance_file_model.dart';
import 'package:mobile_in_out/feature/home_v2/data/model/profile_model.dart';

abstract class AbsenceRepository {
  Future<Either<AppException, ProfileModel>> getProfile();
  Future<String> getProfileLocal();
  Future<String> getEmployeeDetailLocal();
  Future<Either<AppException, CheckInResponseModel>> checkIn(
    CheckInRequestModel data,
  );
  Future<Either<AppException, CheckOutResponseModel>> checkOut(
    CheckOutRequestModel data,
  );
  Future saveCheckInLocal(CheckInResponseModel inResponseModel);
  Future deleteCheckInOut();
  Future<Either<AppException, Map<String, dynamic>>> addAttendanceFile(
    AttendanceFileModel data,
  );
  Future<Either<AppException, Map<String, dynamic>>> insertLocation(
    Map<String, dynamic> data,
  );
}
