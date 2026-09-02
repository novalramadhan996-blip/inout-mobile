import 'package:dartz/dartz.dart';
import 'package:mobile_in_out/core/resources/constants/api_constant.dart';
import 'package:mobile_in_out/core/utils/base_response/http_exception.dart';
import 'package:mobile_in_out/core/resources/network/network_riverpod/network_service.dart';
import 'package:mobile_in_out/feature/home/data/model/device_info_model.dart';
import 'package:mobile_in_out/feature/home/data/model/profile_model.dart';

abstract class HomeDatasource {
  Future<Either<AppException, Map<String, dynamic>>> insertDeviceInfo(
    DeviceInfoModel payload,
  );
  Future<Either<AppException, ProfileModel>> getProfile();
}

class HomeRemoteDatasource extends HomeDatasource {
  final NetworkService networkService;
  HomeRemoteDatasource(this.networkService);

  @override
  Future<Either<AppException, Map<String, dynamic>>> insertDeviceInfo(
    DeviceInfoModel payload,
  ) async {
    final response = await networkService.post(
      APIConstant.apiDeviceInfo,
      data: payload,
    );

    return response.fold((l) => Left(l), (r) {
      final jsonData = r.data;
      if (jsonData == null || jsonData == '') {
        return Left(
          AppException(
            identifier: 'insertData',
            statusCode: 0,
            message: 'The data is not in the valid format.',
          ),
        );
      }
      final Map<String, dynamic> responseData =
          jsonData['data'] as Map<String, dynamic>? ?? {};

      return Right(responseData);
    });
  }

  @override
  Future<Either<AppException, ProfileModel>> getProfile() async {
    final response = await networkService.get(APIConstant.apiProfile);

    return response.fold((l) => Left(l), (r) {
      final jsonData = r.data;
      if (jsonData == null || jsonData == '') {
        return Left(
          AppException(
            identifier: 'fetchData',
            statusCode: 0,
            message: 'The data is not in the valid format.',
          ),
        );
      }
      final result = jsonData != ''
          ? ProfileModel.fromJson(jsonData ?? {})
          : ProfileModel();
      return Right(result);
    });
  }
}
