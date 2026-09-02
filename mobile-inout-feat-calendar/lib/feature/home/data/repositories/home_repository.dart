import 'package:dartz/dartz.dart';
import 'package:mobile_in_out/core/utils/base_response/http_exception.dart';
import 'package:mobile_in_out/feature/home/data/datasource/home_remote_datasource.dart';
import 'package:mobile_in_out/feature/home/data/model/device_info_model.dart';
import 'package:mobile_in_out/feature/home/data/model/profile_model.dart';
import 'package:mobile_in_out/feature/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl extends HomeRepository {
  final HomeDatasource homeDatasource;
  HomeRepositoryImpl(this.homeDatasource);

  @override
  Future<Either<AppException, Map<String, dynamic>>> insertDeviceInfo(
    DeviceInfoModel data,
  ) {
    return homeDatasource.insertDeviceInfo(data);
  }

  @override
  Future<Either<AppException, ProfileModel>> getProfile() {
    return homeDatasource.getProfile();
  }
}
