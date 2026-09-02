import 'package:dartz/dartz.dart';
import 'package:mobile_in_out/core/utils/base_response/http_exception.dart';
import 'package:mobile_in_out/feature/home/data/model/device_info_model.dart';
import 'package:mobile_in_out/feature/home/data/model/profile_model.dart';

abstract class HomeRepository {
  Future<Either<AppException, Map<String, dynamic>>> insertDeviceInfo(
    DeviceInfoModel data,
  );
  Future<Either<AppException, ProfileModel>> getProfile();
}
