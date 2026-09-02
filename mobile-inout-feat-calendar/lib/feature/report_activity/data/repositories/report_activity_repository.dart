import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:mobile_in_out/core/utils/base_response/http_exception.dart';
import 'package:mobile_in_out/feature/report_activity/data/datasource/report_activity_datasource.dart';
import 'package:mobile_in_out/feature/report_activity/data/model/activity_model.dart';
import 'package:mobile_in_out/feature/report_activity/data/model/activity_request_model.dart';
import 'package:mobile_in_out/feature/report_activity/data/model/list_activity_request_model.dart';
import 'package:mobile_in_out/feature/report_activity/domain/repositories/report_activity_repository.dart';
import 'package:mobile_in_out/feature/task/model/response_upload_file.dart';
import 'package:mobile_in_out/feature/task/model/response_upload_image.dart';

class ReportActivityRepositoryImpl extends ReportActivityRepository {
  final ReportActivityDatasource reportActivityDatasource;
  ReportActivityRepositoryImpl(this.reportActivityDatasource);

  @override
  Future<Either<AppException, ResponseUploadImage>> uploadImage(File file) {
    return reportActivityDatasource.uploadImage(file);
  }

  @override
  Future<Either<AppException, ResponseUploadFile>> uploadFile(File file) {
    return reportActivityDatasource.uploadFile(file);
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> createActivity(
    ActivityRequestModel data,
  ) {
    return reportActivityDatasource.createActivity(data);
  }

  @override
  Future<Either<AppException, List<ActivityModel>>> getListActivity(
    ListActivityRequestModel data,
  ) {
    return reportActivityDatasource.getListActivity(data);
  }
}
