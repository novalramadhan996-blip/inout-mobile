import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:mobile_in_out/core/resources/injector/di.dart';
import 'package:mobile_in_out/core/resources/local/pref_service.dart';
import 'package:mobile_in_out/core/routes/router_import.gr.dart';

class AuthHelper {
  static Future<void> logout() async {
    final prefService = sl<ShardPrefService>();
    bool? isLogin = await prefService.getBool(PrefServiceKey.isLogin);
    if (isLogin == true) {
      final navigatorKey = sl<GlobalKey<NavigatorState>>();
      final context = navigatorKey.currentContext;
      if (context != null) {
        FlutterBackgroundService().invoke('stopService');
        await prefService.clear();
        if (context.mounted) {
          context.router.replace(const SignInRoute());
        }
      }
    }
  }
}
