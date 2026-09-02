import 'dart:developer';
import 'dart:io';

import 'package:chat/core/resources/constants/app_constants.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_alice/alice.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class HttpService {
  late Dio _dio;
  late Dio _dioMapGoogle;
  late Dio _dioMock;

  final Alice _alice;

  Dio get dio => _dio;
  Dio get dioMapGoogle => _dioMapGoogle;
  Dio get dioMock => _dioMock;

  Alice get alice => _alice;

  File? certFile;

  HttpService({required Alice alice}) : _alice = alice {
    _dio = _createDio(AppConstants.baseUrl);
    _dioMapGoogle = _createDioGoogleMap(AppConstants.baseGoogleMapUrl);
    _dioMock = _createDio(AppConstants.baseUrlMock);
  }

  Dio _createDio(String baseUrl) {
    loadCertificate();

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

    // dio.interceptors.add(HttpInterceptor(dio));

    (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      SecurityContext context = SecurityContext(withTrustedRoots: false);
      try {
        context.setTrustedCertificates(certFile?.path ?? '');
        final secureClient = HttpClient(context: context);
        return secureClient;
      } catch (e) {
        log('Error setting up SSL context: $e');
        return client;
      }
    };

    return dio;
  }

  void loadCertificate() {
    rootBundle.load('assets/certificates/tnial_cert.pem').then((bytes) async {
      final buffer = bytes.buffer;
      final tempDir = await Directory.systemTemp.createTemp();
      certFile = File('${tempDir.path}/tnial_cert.pem');
      await certFile?.writeAsBytes(
          buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
    }).catchError((e) {
      log('Error loading cert: $e');
    });
  }

  Dio _createDioGoogleMap(String baseUrl) {
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

    return dio;
  }
}
