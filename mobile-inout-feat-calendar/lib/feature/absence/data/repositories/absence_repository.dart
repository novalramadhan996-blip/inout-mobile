import 'package:dartz/dartz.dart';
import 'package:mobile_in_out/core/utils/base_response/http_exception.dart';
import 'package:mobile_in_out/core/utils/models/check_in/check_in_requst_model.dart';
import 'package:mobile_in_out/core/utils/models/check_in/check_in_response_model.dart';
import 'package:mobile_in_out/core/utils/models/check_out/check_out_request_model.dart';
import 'package:mobile_in_out/core/utils/models/check_out/check_out_response_model.dart';
import 'package:mobile_in_out/feature/absence/data/datasource/absence_local_datasource.dart';
import 'package:mobile_in_out/feature/absence/data/datasource/absence_remote_datasource.dart';
import 'package:mobile_in_out/feature/absence/data/model/attendance_file_model.dart';
import 'package:mobile_in_out/feature/absence/domain/repositories/absence_repository.dart';
import 'package:mobile_in_out/feature/home_v2/data/model/profile_model.dart';

class AbsenceRepositoryImpl extends AbsenceRepository {
  final AbsenceDatasource absenceDatasource;
  final AbsenceLocalData absenceLocalData;

  AbsenceRepositoryImpl({
    required this.absenceDatasource,
    required this.absenceLocalData,
  });

  @override
  Future<Either<AppException, ProfileModel>> getProfile() {
    return absenceDatasource.getProfile();
  }

  @override
  Future<String> getProfileLocal() {
    return absenceLocalData.getProfileLocal();
  }

  @override
  Future<String> getEmployeeDetailLocal() {
    return absenceLocalData.getEmployeeDetailLocal();
  }

  @override
  Future<Either<AppException, CheckInResponseModel>> checkIn(
    CheckInRequestModel data,
  ) {
    return absenceDatasource.checkIn(data);
  }

  @override
  Future<Either<AppException, CheckOutResponseModel>> checkOut(
    CheckOutRequestModel data,
  ) {
    return absenceDatasource.checkOut(data);
  }

  @override
  Future saveCheckInLocal(CheckInResponseModel inResponseModel) {
    return absenceLocalData.saveCheckInLocal(inResponseModel);
  }

  @override
  Future deleteCheckInOut() {
    return absenceLocalData.deleteCheckInOut();
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> addAttendanceFile(
    AttendanceFileModel data,
  ) {
    return absenceDatasource.addAttendanceFile(data);
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> insertLocation(
    Map<String, dynamic> data,
  ) {
    return absenceDatasource.insertLocation(data);
  }
}
