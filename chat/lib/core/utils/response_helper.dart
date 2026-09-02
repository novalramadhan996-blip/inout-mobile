import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:chat/core/utils/failure.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

abstract class ResponseHelper {
  static Future<Object> getResponse(
    Future Function() api, {
    Object Function(DioException)? onDioError,
    Object Function(Object)? onError,
  }) async {
    try {
      return await api();
    } on SocketException {
      return const ConnectionFailure('Failed to connect to the network');
    } on DioException catch (e) {
      /// Handle error response dari API
      if (e.type == DioExceptionType.badResponse && e.response != null) {
        final description = _extractErrorMessage(e.response?.data);
        return ServerFailure(description);
      }

      /// Custom handler kalau ada
      if (onDioError != null) return onDioError(e);

      /// Fallback message
      Response? response = e.response;
      String errorMessage = response?.data != null
          ? _extractErrorMessage(response?.data)
          : (e.message ?? 'Unknown error');

      return ServerFailure(errorMessage);
    } on HttpException {
      return const ConnectionFailure('Connection reset by peer');
    } catch (e) {
      if (onError != null) return onError(e);

      return CommonFailure(
        kReleaseMode ? 'Something went wrong' : e.toString(),
      );
    }
  }

  /// ✅ SAFE PARSER (anti crash)
  static String _extractErrorMessage(dynamic data) {
    try {
      /// Kalau String → coba decode
      if (data is String) {
        final decoded = jsonDecode(data);

        if (decoded is Map<String, dynamic>) {
          return decoded['description']?.toString() ??
              decoded['message']?.toString() ??
              data;
        }

        /// Kalau bukan Map (misal List / String biasa)
        return data;
      }

      /// Kalau sudah Map
      if (data is Map<String, dynamic>) {
        return data['description']?.toString() ??
            data['message']?.toString() ??
            'Unknown error';
      }

      /// Kalau List atau lainnya
      if (data is List) {
        return data.isNotEmpty ? data.first.toString() : 'Unknown error';
      }

      return 'Unknown error';
    } catch (_) {
      return 'Unknown error';
    }
  }

  static String? getErrorMessage(Map<String, dynamic> data) {
    if (data.containsKey('message')) return data['message'];

    if (data.containsKey('rmessage')) return data['rmessage'];

    if (data.containsKey('errors')) {
      if (data['errors'] is List) {
        return (data['errors'] as List).first['message'];
      }
    }

    if (data.containsKey('error_message')) return data['error_message'];

    return null;
  }
}
