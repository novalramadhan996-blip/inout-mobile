import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:mobile_in_out/core/utils/base_response/http_exception.dart';
import 'package:mobile_in_out/feature/report_activity/data/model/activity_model.dart';
import 'package:mobile_in_out/feature/report_activity/data/model/activity_request_model.dart';
import 'package:mobile_in_out/feature/report_activity/data/model/list_activity_request_model.dart';
import 'package:mobile_in_out/feature/task/model/response_upload_file.dart';
import 'package:mobile_in_out/feature/task/model/response_upload_image.dart';

abstract class ReportActivityRepository {
  Future<Either<AppException, ResponseUploadImage>> uploadImage(File file);
  Future<Either<AppException, ResponseUploadFile>> uploadFile(File file);
  Future<Either<AppException, Map<String, dynamic>>> createActivity(
    ActivityRequestModel data,
  );
  Future<Either<AppException, List<ActivityModel>>> getListActivity(
    ListActivityRequestModel data,
  );
}
