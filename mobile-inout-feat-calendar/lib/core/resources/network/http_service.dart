import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_alice/alice.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_in_out/core/resources/network/http_interceptor.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class HttpService {
  late Dio _dio;
  late Dio _dioMock;

  final Alice _alice;

  Dio get dio => _dio;
  Dio get dioMock => _dioMock;

  Alice get alice => _alice;

  HttpService({required Alice alice}) : _alice = alice {
    _dio = _createDio(dotenv.get("SERVER"));
    _dioMock = _createDio(dotenv.get("SERVER"));
  }

  Dio _createDio(String baseUrl) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(milliseconds: 10000),
        receiveTimeout: const Duration(milliseconds: 10000),
      ),
    );

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

    dio.interceptors.add(HttpInterceptor(dio, false));

    return dio;
  }
}
