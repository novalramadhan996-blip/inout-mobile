import 'dart:io';

import 'package:mobile_in_out/core/utils/errors/error_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

abstract class ResponseHelper {

  static Future<Object> getResponse(Future Function() api, { Object Function(DioException)? onDioError, Object Function(Object)? onError }) async {
    try {
      return await api();

    } on SocketException {
      return const ConnectionFailure('Failed to connect to the network');

    } on DioException catch (e) {
      if (onDioError != null) return onDioError(e);

      final response = e.response;
      String? errorMessage;

      if (response?.data != null) {
        final data = response!.data;
        if (data is String) {
          errorMessage = data;
        } else if (data is Map<String, dynamic>) {
          errorMessage = getErrorMessage(data) ?? e.message;
        } else {
          errorMessage = data.toString();
        }
      } else {
        errorMessage = e.message;
      }

      return ServerFailure(errorMessage ?? 'Unknown server error');

    } on HttpException {
      return const ConnectionFailure('Connection reset by peer');

    } catch (e) {
      if (onError != null) return onError(e);

      return CommonFailure(kReleaseMode ? 'Something went wrong' : e.toString());
    }
  }

  static String? getErrorMessage(Map<String, dynamic> data) {
    if( data.containsKey('message') ) return data['message'];

    if (data.containsKey('rmessage')) return data['rmessage'];

    if( data.containsKey('errors') ) {
      if( data['errors'] is List ) {
        return (data['errors'] as List).first['message'];
      }
    }

    if( data.containsKey('error_message') ) return data['error_message'];

    return null;
  }
}