import 'dart:async';
import 'package:dio/dio.dart';
import 'package:mobile_in_out/core/resources/constants/app_const.dart';
import 'package:mobile_in_out/core/resources/injector/di.dart';
import 'package:mobile_in_out/core/resources/local/pref_service.dart';
import 'package:mobile_in_out/core/utils/enum_state.dart';
import 'package:mobile_in_out/core/utils/helper/auth_helper.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';
import 'package:mobile_in_out/feature/auth/provider/auth_provider.dart';

class HttpInterceptor extends Interceptor {
  static Completer<void>? _refreshCompleter;

  final ShardPrefService _prefService = sl<ShardPrefService>();
  AuthProvider get authViewModel => sl<AuthProvider>();
  final Dio dio;
  bool isBackgroundProcess = false;

  HttpInterceptor(this.dio, this.isBackgroundProcess);

  Future<String?> _backgroundGetToken() async {
    _prefService.init();
    return _prefService.getString(PrefServiceKey.authToken);
  }

  Future<String?> _backgroundGetAppsId() async {
    _prefService.init();
    return _prefService.getString(PrefServiceKey.appsId);
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // super.onRequest(options, handler);

    String? token = isBackgroundProcess
        ? await _backgroundGetToken()
        : await _prefService.getString(PrefServiceKey.authToken);
    String? appsId = isBackgroundProcess
        ? await _backgroundGetAppsId()
        : await _prefService.getString(PrefServiceKey.appsId);

    LogHelper.logDebug('token interceptor $token');
    LogHelper.logDebug('appsid interceptor $appsId');

    if (_isUrlRequiringAuth(options.path)) {
      options.headers["Authorization"] = 'Bearer $token';
    }
    options.headers["appsId"] = appsId ?? "";

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // super.onResponse(response, handler);

    LogHelper.logDebug(
      "RESPONSE[${response.statusCode}] => DATA: ${response.data}",
    );
    return handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    LogHelper.logDebug(
      "ERROR Message [${err.response?.statusCode}] => MESSAGE: ${err.message}",
    );

    int errorCode = err.response?.statusCode ?? 404;
    LogHelper.logDebug('debug -> refreshtoken errorCode $errorCode');
    if (errorCode == 401) {
      // If the refresh endpoint itself fails with 401, logout immediately
      // to prevent deadlock with _refreshCompleter
      if (err.requestOptions.path.contains('/inout-rest/auth/refreshtoken')) {
        LogHelper.logDebug(
          'debug -> refreshtoken endpoint returned 401, logout',
        );
        await _logout();
        return handler.next(err);
      }

      if (err.requestOptions.extra["retry"] == true) {
        LogHelper.logDebug('debug -> refreshtoken already retried, logout');
        await _logout();
        return handler.next(err);
      }
      err.requestOptions.extra["retry"] = true;

      // Only one request triggers the refresh; others wait for it
      if (_refreshCompleter == null) {
        _refreshCompleter = Completer<void>();
        await authViewModel.refreshToken();
        _refreshCompleter!.complete();
        _refreshCompleter = null;
      } else {
        await _refreshCompleter!.future;
      }

      if (authViewModel.stateAuth == RequestState.Error) {
        LogHelper.logDebug('debug -> authViewModel.stateAuth error');
        await _logout();
        return handler.next(err);
      }

      try {
        final RequestOptions requestOptions = err.requestOptions;
        String? token = await _prefService.getString(PrefServiceKey.authToken);
        requestOptions.headers["Authorization"] = "Bearer $token";
        final response = await dio.fetch(requestOptions);
        return handler.resolve(response);
      } catch (e) {
        LogHelper.logDebug("Retry failed after 401: $e");
        await _logout();
        return handler.next(err);
      }
    }

    return handler.next(err);
  }

  Future<void> _logout() async {
    await AuthHelper.logout();
  }

  static bool _isUrlRequiringAuth(String url) {
    return !AppConst.listUrlWithoutToken.contains(url);
  }
}
