import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_alice/alice.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_in_out/core/utils/base_response/response.dart'
    as response;
import 'package:mobile_in_out/core/resources/network/network_riverpod/network_service.dart';
import 'package:mobile_in_out/core/utils/base_response/http_exception.dart';
import 'package:mobile_in_out/core/utils/base_response/exception_handler_mixin.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioCalendarService extends NetworkService with ExceptionHandlerMixin {
  final Dio dio;
  final Alice alice;

  DioCalendarService(this.dio, this.alice) {
    dio.options = dioBaseOptions;
    if (!kReleaseMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          error: true,
          compact: true,
          maxWidth: 150,
        ),
      );
      dio.interceptors.add(alice.getDioInterceptor());
    }
  }

  BaseOptions get dioBaseOptions => BaseOptions(
    baseUrl: baseUrl,
    headers: headers,
    queryParameters: {'key': dotenv.get("API_KEY_GOOGLE_CALENDAR")},
    connectTimeout: const Duration(milliseconds: 10000),
    receiveTimeout: const Duration(milliseconds: 10000),
  );

  @override
  String get baseUrl => dotenv.get("URL_CALENDAR");

  @override
  Map<String, Object> get headers => {
    'accept': 'application/json',
    'content-type': 'application/json',
  };

  @override
  Map<String, dynamic>? updateHeader(Map<String, dynamic> data) {
    final header = {...data, ...headers};
    if (!kReleaseMode) {
      dio.options.headers = header;
    }
    return header;
  }

  @override
  Future<Either<AppException, response.Response>> post(
    String endpoint, {
    dynamic data,
  }) {
    final res = handleException(
      () => dio.post(endpoint, data: data),
      endpoint: endpoint,
    );
    return res;
  }

  @override
  Future<Either<AppException, response.Response>> put(
    String endpoint, {
    dynamic data,
  }) {
    final res = handleException(
      () => dio.put(endpoint, data: data),
      endpoint: endpoint,
    );
    return res;
  }

  @override
  Future<Either<AppException, response.Response>> delete(
    String endpoint, {
    dynamic data,
  }) {
    final res = handleException(
      () => dio.delete(endpoint, data: data),
      endpoint: endpoint,
    );
    return res;
  }

  @override
  Future<Either<AppException, response.Response>> get(
    String endpoint, {
    dynamic queryParameters,
  }) {
    final res = handleException(
      () => dio.get(endpoint, queryParameters: queryParameters),
      endpoint: endpoint,
    );
    return res;
  }
}
