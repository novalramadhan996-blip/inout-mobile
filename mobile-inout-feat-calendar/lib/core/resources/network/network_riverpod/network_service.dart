import 'package:dartz/dartz.dart';
import 'package:mobile_in_out/core/utils/base_response/http_exception.dart';
import 'package:mobile_in_out/core/utils/base_response/response.dart';

abstract class NetworkService {
  String get baseUrl;

  Map<String, Object> get headers;

  void updateHeader(Map<String, dynamic> data);

  Future<Either<AppException, Response>> get(
    String endpoint, {
    dynamic queryParameters,
  });

  Future<Either<AppException, Response>> post(String endpoint, {dynamic data});

  Future<Either<AppException, Response>> put(String endpoint, {dynamic data});

  Future<Either<AppException, Response>> delete(
    String endpoint, {
    dynamic data,
  });
}
