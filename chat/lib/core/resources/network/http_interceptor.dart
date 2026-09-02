// import 'dart:developer';

// import 'package:auth/core/resources/constants/app_constants.dart';
// import 'package:auth/core/resources/injector/di.dart';
// import 'package:auth/core/resources/storage/shared_preference_service.dart';
// import 'package:auth/core/utils/request_state.dart';
// import 'package:auth/viewmodel/auth_view_model.dart';
// import 'package:chat/core/resources/storage/shared_preference_service.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:go_router/go_router.dart';

// class HttpInterceptor extends Interceptor {
//   final SharedPreferenceService _prefService = sl<SharedPreferenceService>();
//   final GlobalKey<NavigatorState> navigatorKey =
//       sl<GlobalKey<NavigatorState>>();
//   AuthViewModel get authViewModel => sl<AuthViewModel>(); // Lazy initialization
//   final Dio dio;

//   HttpInterceptor(this.dio);

//   @override
//   Future<void> onRequest(
//       RequestOptions options, RequestInterceptorHandler handler) async {
//     // super.onRequest(options, handler);

//     log("REQUEST[${options.method}] => PATH: ${options.path}");
//     String? token = await _prefService.getString(PrefServiceKey.authToken);
//     log('Request Token $token');

//     if (isUrlWithoutToken(options.path)) {
//       options.headers["Authorization"] = 'Bearer $token';
//       // options.headers["Authorization"] = 'Bearer 1231232';
//     }

//     return handler.next(options);
//   }

//   @override
//   void onResponse(Response response, ResponseInterceptorHandler handler) {
//     // super.onResponse(response, handler);

//     log("RESPONSE[${response.statusCode}] => DATA: ${response.data}");
//     return handler.next(response);
//   }

//   @override
//   void onError(DioException err, ErrorInterceptorHandler handler) async {
//     log("ERROR Message [${err.response?.statusCode}] => MESSAGE: ${err.message}");

//     int errorCode = err.response?.statusCode ?? 404;
//     if (errorCode == 401) {
//       // check the second retry refresh token, when failed the user sould be logout
//       if (err.requestOptions.extra["retry"] == true) {
//         _logout();
//         return handler.next(err);
//       }
//       err.requestOptions.extra["retry"] = true;

//       await authViewModel.refreshToken();

//       if (authViewModel.stateAuth == RequestState.Error) {
//         _logout();
//         return handler.next(err);
//       }

//       // Retry latest api after refresh token
//       final RequestOptions requestOptions = err.requestOptions;
//       String? token = await _prefService.getString(PrefServiceKey.authToken);
//       requestOptions.headers["Authorization"] = "Bearer $token";
//       final response = await dio.fetch(requestOptions);
//       return handler.resolve(response);
//     }

//     return handler.next(err);
//   }

//   void _logout() async {
//     bool? isLogin = await _prefService.getBool(PrefServiceKey.isLogin);
//     if (isLogin == true) {
//       final context = navigatorKey.currentContext;
//       if (context != null) {
//         FlutterBackgroundService().invoke('stopService');
//         _prefService.clear();
//         if (context.mounted) {
//           context.go('/login_screen');
//         }
//       }
//     }
//   }

//   static bool isUrlWithoutToken(String url) {
//     return !AppConstants.listUrlWithoutToken.contains(url);
//   }
// }
