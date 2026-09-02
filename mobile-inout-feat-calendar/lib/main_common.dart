import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mobile_in_out/app.dart';
import 'package:mobile_in_out/core/utils/localizations/app_translations.dart';
import 'package:mobile_in_out/feature/backround_process/presentation/background_service.dart';
import 'package:mobile_in_out/feature/backround_process/presentation/workmanager_service.dart';
import 'package:mobile_in_out/firebase_options.dart';

Future<void> mainCommon() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  initializeDateFormatting();

  //for bypass unsecure certificate, please remove when issue certificate is fixed
  HttpOverrides.global = MyHttpOverrides();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Alarm.init();

  await BackgroundService.init();
  await WorkmanagerService.init();
  await AppTranslations.init();

  runApp(const ProviderScope(child: AppWidget()));
}

//for bypass unsecure certificate, please remove when issue certificate is fixed
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
