import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mobile_in_out/core/resources/constants/api_constant.dart';
import 'package:mobile_in_out/core/utils/base_response/http_exception.dart';
import 'package:mobile_in_out/core/resources/network/network_riverpod/network_service.dart';
import 'package:mobile_in_out/feature/report_activity/data/model/activity_model.dart';
import 'package:mobile_in_out/feature/report_activity/data/model/activity_request_model.dart';
import 'package:mobile_in_out/feature/report_activity/data/model/list_activity_request_model.dart';
import 'package:mobile_in_out/feature/task/model/response_upload_file.dart';
import 'package:mobile_in_out/feature/task/model/response_upload_image.dart';

abstract class ReportActivityDatasource {
  Future<Either<AppException, ResponseUploadImage>> uploadImage(File file);
  Future<Either<AppException, ResponseUploadFile>> uploadFile(File file);
  Future<Either<AppException, Map<String, dynamic>>> createActivity(
    ActivityRequestModel data,
  );
  Future<Either<AppException, List<ActivityModel>>> getListActivity(
    ListActivityRequestModel data,
  );
}

class ReportActivityRemoteDatasource extends ReportActivityDatasource {
  final NetworkService networkService;
  ReportActivityRemoteDatasource(this.networkService);

  @override
  Future<Either<AppException, ResponseUploadImage>> uploadImage(
    File file,
  ) async {
    final fileName = file.path.split('/').last;

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });

    final response = await networkService.post(
      APIConstant.apiUploadImage,
      data: formData,
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

      final responseData = ResponseUploadImage.fromJson(jsonData['data']);

      return Right(responseData);
    });
  }

  @override
  Future<Either<AppException, ResponseUploadFile>> uploadFile(File file) async {
    final fileName = file.path.split('/').last;

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });

    final response = await networkService.post(
      APIConstant.apiUploadFile,
      data: formData,
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

      final responseData = ResponseUploadFile.fromJson(jsonData['data']);

      return Right(responseData);
    });
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> createActivity(
    ActivityRequestModel data,
  ) async {
    final response = await networkService.post(
      APIConstant.apiCreateActivity,
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
      final Map<String, dynamic> result =
          jsonData['data'] as Map<String, dynamic>? ?? {};

      return Right(result);
    });
  }

  @override
  Future<Either<AppException, List<ActivityModel>>> getListActivity(
    ListActivityRequestModel data,
  ) async {
    final response = await networkService.post(
      APIConstant.apiListActivity,
      data: data,
    );

    return response.fold((l) => Left(l), (r) {
      final jsonData = r.data;

      if (jsonData == null || jsonData['rows'] == null) {
        return Left(
          AppException(
            identifier: 'fetchData',
            statusCode: 0,
            message: 'The data is not in the valid format.',
          ),
        );
      }

      final List<ActivityModel> activities = (jsonData['rows'] as List)
          .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return Right(activities);
    });
  }
}
