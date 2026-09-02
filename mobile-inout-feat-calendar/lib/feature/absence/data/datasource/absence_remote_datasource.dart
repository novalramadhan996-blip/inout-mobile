import 'package:dartz/dartz.dart';
import 'package:mobile_in_out/core/resources/constants/api_constant.dart';
import 'package:mobile_in_out/core/utils/base_response/http_exception.dart';
import 'package:mobile_in_out/core/resources/network/network_riverpod/network_service.dart';
import 'package:mobile_in_out/core/utils/models/check_in/check_in_requst_model.dart';
import 'package:mobile_in_out/core/utils/models/check_in/check_in_response_model.dart';
import 'package:mobile_in_out/core/utils/models/check_out/check_out_request_model.dart';
import 'package:mobile_in_out/core/utils/models/check_out/check_out_response_model.dart';
import 'package:mobile_in_out/feature/absence/data/model/attendance_file_model.dart';
import 'package:mobile_in_out/feature/home_v2/data/model/profile_model.dart';

abstract class AbsenceDatasource {
  Future<Either<AppException, ProfileModel>> getProfile();
  Future<Either<AppException, CheckInResponseModel>> checkIn(
    CheckInRequestModel data,
  );
  Future<Either<AppException, CheckOutResponseModel>> checkOut(
    CheckOutRequestModel data,
  );
  Future<Either<AppException, Map<String, dynamic>>> addAttendanceFile(
    AttendanceFileModel data,
  );
  Future<Either<AppException, Map<String, dynamic>>> insertLocation(
    Map<String, dynamic> data,
  );
}

class AbsenceRemoteDatasource extends AbsenceDatasource {
  final NetworkService networkService;
  AbsenceRemoteDatasource(this.networkService);

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

  @override
  Future<Either<AppException, CheckInResponseModel>> checkIn(
    CheckInRequestModel data,
  ) async {
    final response = await networkService.post(
      APIConstant.apiCheckIn,
      data: data,
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
      final CheckInResponseModel responseData =
          jsonData['data']['attendance'] != null
          ? CheckInResponseModel.fromJson(
              jsonData['data']['attendance'] as Map<String, dynamic>,
            )
          : CheckInResponseModel();

      return Right(responseData);
    });
  }

  @override
  Future<Either<AppException, CheckOutResponseModel>> checkOut(
    CheckOutRequestModel data,
  ) async {
    final response = await networkService.post(
      APIConstant.apiCheckOut,
      data: data,
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
      final CheckOutResponseModel responseData = jsonData['data'] != null
          ? CheckOutResponseModel.fromJson(
              jsonData['data'] as Map<String, dynamic>,
            )
          : CheckOutResponseModel();

      return Right(responseData);
    });
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> addAttendanceFile(
    AttendanceFileModel data,
  ) async {
    final response = await networkService.post(
      APIConstant.apiAddAttendanceFiles,
      data: data,
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
      final Map<String, dynamic> response =
          jsonData['data'] as Map<String, dynamic>? ?? {};

      return Right(response);
    });
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> insertLocation(
    Map<String, dynamic> data,
  ) async {
    final response = await networkService.post(
      APIConstant.apiSendLocation + data['userId'].toString(),
      data: data,
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
      final Map<String, dynamic> data =
          jsonData['data'] as Map<String, dynamic>? ?? {};

      return Right(data);
    });
  }
}
