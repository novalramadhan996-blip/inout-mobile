// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';

// import 'package:alarm/alarm.dart';
// import 'package:alarm/utils/alarm_set.dart';
// import 'package:flutter_alice/alice.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mobile_in_out/app.dart';
// import 'package:mobile_in_out/core/resources/env/env.dart';
// import 'package:mobile_in_out/core/resources/injector/di.dart';
// import 'package:mobile_in_out/core/resources/local/pref_service.dart';
// import 'package:mobile_in_out/core/routes/router_import.dart';
// import 'package:mobile_in_out/core/utils/helper/alarm_service.dart';
// import 'package:mobile_in_out/core/utils/helper/notification_service.dart';
// import 'package:mobile_in_out/feature/backround_process/presentation/provider/background_state_provider.dart';
// import 'package:mobile_in_out/feature/home/model/employee_detail_model.dart';
// import 'package:mobile_in_out/feature/home/provider/background_provider.dart';
// import 'package:mobile_in_out/feature/in_and_out/providers/in_out_provider.dart';
// import 'package:mobile_in_out/firebase_options.dart';
// import 'package:dio/dio.dart';
// import 'package:dio/io.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// // import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:intl/date_symbol_data_local.dart';
// import 'package:riverpod/riverpod.dart';
// import 'package:workmanager/workmanager.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'core/global/provider/location_provider.dart';
// import 'core/resources/injector/di.dart' as di;
// import 'core/resources/local/camera_service.dart';
// import 'core/resources/local/face_detector_service.dart';
// import 'core/resources/local/ml_service.dart';
// import 'core/resources/network/http_service.dart';
// import 'core/resources/network/rest_client.dart';
// import 'core/resources/repositories/repository.dart';
// import 'feature/auth/provider/auth_provider.dart';
// import 'feature/auth/provider/register_provider.dart';
// import 'feature/change_password/provider/change_password_provider.dart';
// import 'feature/forgot_password/provider/reset_password_provider.dart';
// import 'feature/history/provider/history_provider.dart';
// import 'feature/home/provider/home_provider.dart';
// import 'feature/maps/provider/map_provider.dart';
// import 'feature/profile/providers/profile_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:mobile_in_out/feature/home/provider/home_provider.dart';

// // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
// //     FlutterLocalNotificationsPlugin();

// Timer? _periodicTimer;
// final _service = FlutterBackgroundService();
// // const _longPeriode = 15;
// const _longPeriode = 1;
// const _schedullerPeriode = 15;
// final _constraints = Constraints(
//   networkType: NetworkType.connected, // Requires network connectivity
//   requiresCharging: false, // Requires the device to be charging
//   requiresBatteryNotLow: true, // Requires battery level to be not low
//   requiresStorageNotLow: false, // Requires sufficient storage space
// );

// Future<void> mainCommon(EnvConfig env) async {
//   WidgetsFlutterBinding.ensureInitialized(); // Ensure binding is initialized

//   // comment firebase because still blank when production mode
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   LogHelper.logDebug("Debug -> main_common : Register DI");

//   di.sl.registerSingleton<EnvConfig>(env);
//   // di.initilizeDi();

//   initializeDateFormatting();

//   //for bypass unsecure certificate, please remove when issue certificate is fixed
//   HttpOverrides.global = MyHttpOverrides();

//   // comment firebase because still blank when production mode
//   // await initFcm();

//   SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//     DeviceOrientation.portraitDown,
//   ]);

//   await Alarm.init();

//   // Initialize the background service
//   await initializeBackgroundService();

//   bool isRunning = await _service.isRunning();

//   LogHelper.logDebug(
//     "Debug -> main_common : IS RUNNING ${isRunning.toString().toUpperCase()}",
//   );

//   // Initialize workmanager
//   Workmanager().initialize(
//     _callbackDispatcher,
//     isInDebugMode: true, // Only in debug mode, useful for testing
//   );

//   runApp(const AppWidget());
// }

// @pragma('vm:entry-point')
// void _callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     LogHelper.logDebug("Debug -> main_common : workManager Start");
//     LogHelper.logDebug('Debug -> main_common : waiting: 15 minutes');

//     final token = inputData?['token'];

//     await initializeDI();
//     LogHelper.logDebug('Debug -> main_common : token $token');

//     if (token != null && token != "") {
//       await sendLocation(token, '');
//     }

//     return Future.value(true);
//   });
// }

// Future<void> initFcm() async {
//   FirebaseMessaging messaging = FirebaseMessaging.instance;

//   //   // Subscribe to a topic
//   messaging.subscribeToTopic('all');

//   //   // Get the token each time the application loads
//   messaging.getToken().then((token) {
//     LogHelper.logDebug('FCM Token: $token');
//   });

//   String? tokenData = await FirebaseMessaging.instance.getToken();
//   LogHelper.logDebug('FCM Instance : $tokenData');

//   // Initialize local notifications
//   // const AndroidInitializationSettings initializationSettingsAndroid =
//   //     AndroidInitializationSettings('@mipmap/ic_launcher');
//   // const InitializationSettings initializationSettings =
//   //     InitializationSettings(android: initializationSettingsAndroid);
//   // await flutterLocalNotificationsPlugin.initialize(initializationSettings);

//   // Handle foreground messages
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     LogHelper.logDebug('Got a message whilst in the foreground!');
//     LogHelper.logDebug('Message data: ${message.data}');

//     if (message.notification != null) {
//       LogHelper.logDebug('Message also contained a notification: ${message.notification}');

//       // get auth token
//       final prefs = sl<ShardPrefService>();
//       prefs.getString(PrefServiceKey.authToken).then((token) {
//         LogHelper.logDebug('Token: $token');
//         if (token != null) {
//           sl<InOutProvider>().insertLocationTracking();
//           // showNotification(message.notification!);
//         }
//       });
//     }
//   });

//   // Handle background messages
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//   // Handle notification clicks
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     LogHelper.logDebug('A new onMessageOpenedApp event was published!');
//   });
// }

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   LogHelper.logDebug('Handling a background message: ${message.messageId}');
//   if (message.notification != null) {
//     LogHelper.logDebug('Message also contained a notification: ${message.notification}');
//   }
// }

// // void showNotification(RemoteNotification notification) async {
// //   const AndroidNotificationDetails androidPlatformChannelSpecifics =
// //       AndroidNotificationDetails(
// //     'your_channel_id',
// //     'your_channel_name',
// //     channelDescription: 'your_channel_description',
// //     importance: Importance.max,
// //     priority: Priority.high,
// //     showWhen: false,
// //   );
// //   const NotificationDetails platformChannelSpecifics =
// //       NotificationDetails(android: androidPlatformChannelSpecifics);
// //   await flutterLocalNotificationsPlugin.show(
// //     0,
// //     notification.title,
// //     notification.body,
// //     platformChannelSpecifics,
// //     payload: 'item x',
// //   );
// // }

// //INFO BACKGROUND SERVICE
// Future<void> initializeBackgroundService() async {
//   final service = FlutterBackgroundService();

//   await service.configure(
//     iosConfiguration: IosConfiguration(
//       autoStart: true,
//       onForeground: onStart,
//       onBackground: onIosBackground,
//     ),
//     androidConfiguration: AndroidConfiguration(
//       autoStart: true,
//       onStart: onStart,
//       isForegroundMode: true,
//       autoStartOnBoot: true,
//     ),
//   );

//   await service.startService();
// }

// Future<void> sendLocation(String token, String location) async {
//   LogHelper.logDebug('Debug -> main_common : sendLocation: ${token}');

//   //check permission
//   bool serviceEnabled;
//   LocationPermission permission;
//   serviceEnabled = await Geolocator.isLocationServiceEnabled();
//   if (!serviceEnabled) {
//     LogHelper.logDebug('Debug -> main_common : Location services are disabled.');
//     return;
//   }
//   permission = await Geolocator.checkPermission();
//   if (permission == LocationPermission.denied) {
//     permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied) {
//       LogHelper.logDebug('Debug -> main_common : Location permissions are denied');
//       return;
//     }
//   }

//   Position position = await Geolocator.getCurrentPosition(
//     desiredAccuracy: LocationAccuracy.high,
//   );
//   LogHelper.logDebug(
//     'Debug -> main_common : Location: ${position.latitude}, ${position.longitude}',
//   );
//   final data = {
//     "latitude": position.latitude,
//     "longitude": position.longitude,
//     "address": '',
//   };

//   LogHelper.logDebug('location distance location $location');
//   if (location != '') {
//     List<String> locationSplit = location.split(',');
//     double latitudeLocationAbsence = double.parse(locationSplit[0]);
//     double longitudeLocationAbsence = double.parse(locationSplit[1]);

//     if (latitudeLocationAbsence != 0.0 &&
//         longitudeLocationAbsence != 0.0 &&
//         position.latitude != 0.0 &&
//         position.longitude != 0.0) {
//       double distance = Geolocator.distanceBetween(
//         latitudeLocationAbsence,
//         longitudeLocationAbsence,
//         position.latitude,
//         position.longitude,
//       );
//       LogHelper.logDebug('Location Distance $distance');
//       if (distance < 500) {
//         LogHelper.logDebug("in distance");
//       } else {
//         LogHelper.logDebug("out of distance");
//       }
//     }
//   }

//   try {
//     fetchEmployeeDetailInBackground(token);
//     // late HomeProvider _homeProvider = Provider.of<HomeProvider>(context, listen: false);
//     Dio dio = Dio();
//     dio.options.headers['Authorization'] = 'Bearer $token';
//     dio.options.headers['Content-Type'] = 'application/json';
//     dio.options.headers['Accept'] = 'application/json';
//     dio.options.headers['Access-Control-Allow-Origin'] = '*';

//     // Disable SSL verification
//     // HttpOverrides.global = MyHttpOverrides();
//     // (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
//     //   client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
//     //   return client;
//     // };

//     final response = await dio.post(
//       'https://143.198.85.75/inout-rest/location_tracking/insert',
//       data: data,
//     );

//     LogHelper.logDebug('Debug -> main_common : Response code : ${response.statusCode}');
//     LogHelper.logDebug('Debug -> main_common : Response message : ${response.statusMessage}');
//     LogHelper.logDebug('Debug -> main_common : Response: ${response.data}');
//   } catch (e) {
//     LogHelper.logDebug('Debug -> main_common : error fetch api $e');
//   }
// }

// // Future<void> fetchEmployeeDetailInBackground(token) async {
// //   // Buat container baru untuk background
// //   final container = ProviderContainer();

// //   try {
// //     // Panggil fungsi dari HomeNotifier
// //     await container.read(homeProvider.notifier).getEmployeeDetail();

// //     // Ambil state terbaru jika perlu
// //     final state = container.read(homeProvider);
// //     LogHelper.logDebug('Employee name: ${state.employeeDetail.address}');
// //   } catch (e) {
// //     LogHelper.logDebug('Error fetching employee detail in background: $e');
// //   } finally {
// //     container.dispose(); // Jangan lupa dispose container setelah selesai
// //   }
// // }

// Future<void> fetchEmployeeDetailInBackground(String token) async {
//   final container = ProviderContainer();

//   try {
//     final notifier = container.read(backgroundNotifierProvider.notifier);

//     await notifier.getEmployeeDetail();

//     final state = container.read(backgroundNotifierProvider);

//     if (state.employeeDetail != null) {
//       LogHelper.logDebug('common Employee : ${state.employeeDetail.address.toString()}');
//       LogHelper.logDebug('common Employee : ${state.employeeDetail.city.toString()}');
//       LogHelper.logDebug('common Employee : ${state.employeeDetail.toString()}');
//       LogHelper.logDebug(
//         'common Employee address: ${state.employeeDetail.workingLocation?.address}',
//       );
//     } else {
//       LogHelper.logDebug('Employee empty');
//     }
//   } catch (e, s) {
//     LogHelper.logDebug('Background error: $e');
//     LogHelper.logDebug('Background error : $s');
//   } finally {
//     container.dispose();
//   }
// }

// Future<void> startTaskTrackingLocation(ServiceInstance service) async {
//   service.on("startTaskTrackingLocation").listen((event) async {
//     LogHelper.logDebug('Debug -> main_common : Start task');

//     String token = event?["token"] ?? '';
//     String location = event?["location"] ?? '';

//     LogHelper.logDebug('Debug -> main_common : location $location');

//     if (token != "") {
//       LogHelper.logDebug('Debug -> main_common : Token: $token');
//       await sendLocation(token, location);
//     }

//     if (_periodicTimer != null) {
//       _periodicTimer?.cancel();
//     }

//     if (token != "") {
//       _periodicTimer = Timer.periodic(const Duration(minutes: _longPeriode), (
//         timer,
//       ) async {
//         LogHelper.logDebug('Debug -> main_common : waiting $_longPeriode minutes');

//         if (token != "") {
//           LogHelper.logDebug('Debug -> main_common : Token timer $token');
//           await sendLocation(token, location);
//         }
//       });

//       LogHelper.logDebug("Debug -> main_common : START TRACKING");
//     }
//   });
// }

// @pragma('vm:entry-point')
// Future<bool> onIosBackground(ServiceInstance service) async {
//   WidgetsFlutterBinding.ensureInitialized();

//   return true;
// }

// Future<void> initializeDI() async {
//   LogHelper.logDebug('Debug -> main_common : init DI');
//   di.sl.registerSingleton<EnvConfig>(
//     EnvConfig(
//       color: Colors.blue,
//       server: 'https://inout-dev.2ndc.app',
//       flavor: EnvType.dev,
//       values: const EnvValues(titleApp: "DEV MODE"),
//       webApiServer: 'https://inout-dev.2ndc.app',
//       webviewServer: 'https://inout-dev.2ndc.app',
//     ),
//   );

//   sl.registerLazySingleton<GlobalKey<NavigatorState>>(
//     () => GlobalKey<NavigatorState>(),
//   );
//   sl.registerLazySingleton<Alice>(
//     () => Alice(
//       showNotification: true,
//       showInspectorOnShake: true,
//       navigatorKey: sl<GlobalKey<NavigatorState>>(),
//     ),
//   );
//   sl.registerLazySingleton<ShardPrefService>(() => ShardPrefService());

//   // Services
//   sl.registerLazySingleton<HttpService>(() => HttpService(alice: sl<Alice>()));
//   sl.registerSingleton<RestClient>(
//     RestClient(sl<HttpService>().dio),
//     instanceName: 'dio',
//   );
//   sl.registerLazySingleton<Repository>(
//     () => Repository(restClient: sl<RestClient>(instanceName: 'dio')),
//   );

//   // Face Services
//   sl.registerLazySingleton<CameraService>(() => CameraService());
//   sl.registerLazySingleton<FaceDetectorService>(() => FaceDetectorService());
//   sl.registerLazySingleton<MLService>(() => MLService());

//   // Providers
//   sl.registerLazySingleton<ProfileProvider>(
//     () => ProfileProvider(sl<Repository>()),
//   );
//   sl.registerLazySingleton<InOutProvider>(
//     () => InOutProvider(sl<Repository>()),
//   );
//   sl.registerLazySingleton<RegisterProvider>(
//     () => RegisterProvider(sl<Repository>()),
//   );
//   sl.registerLazySingleton<HomeProvider>(() => HomeProvider(sl<Repository>()));
//   sl.registerLazySingleton<MapProvider>(() => MapProvider());
//   sl.registerLazySingleton<LocationProvider>(
//     () => LocationProvider(sl<Repository>()),
//   );
//   sl.registerLazySingleton<HistoryProvider>(
//     () => HistoryProvider(sl<Repository>()),
//   );
//   sl.registerLazySingleton<ResetPasswordProvider>(
//     () => ResetPasswordProvider(sl<Repository>()),
//   );
//   sl.registerLazySingleton<ChangePasswordProvider>(
//     () => ChangePasswordProvider(sl<Repository>()),
//   );
// }

// @pragma('vm:entry-point')
// void onStart(ServiceInstance service) async {
//   WidgetsFlutterBinding.ensureInitialized();

//   if (service is AndroidServiceInstance) {
//     await service.setForegroundNotificationInfo(
//       title: "Service berjalan",
//       content: "Tracking lokasi aktif",
//     );
//   }

//   LogHelper.logDebug('Debug -> main_common : start service');
//   await initializeDI();

//   startTaskTrackingLocation(service);
//   taskUpdateToken(service);
// }

// // comment because not use this function, please remove when apps already publish and stable
// // Future<void> taskUpdateToken(ServiceInstance service) async {
// //   service.on("taskUpdateToken").listen((event) async {

// //     Workmanager().cancelAll();

// //     final updatedToken = event!["token"];

// //     LogHelper.logDebug("Debug -> main_common : Token updated in service: $updatedToken");

// //     if (updatedToken != null && updatedToken != "") {

// //       LogHelper.logDebug("Debug -> main_common : startTaskTrackingLocation $updatedToken");

// //       Workmanager().registerPeriodicTask(
// //         "1",
// //         "backgroundTask",
// //         frequency: const Duration(minutes: _schedullerPeriode), // Run every 15 minutes
// //         constraints: _constraints,
// //         inputData: {
// //           "token": updatedToken,
// //         },
// //       );
// //     }

// //   });
// // }

// Future<void> taskUpdateToken(ServiceInstance service) async {
//   service.on("taskUpdateToken").listen((event) async {
//     if (event == null) {
//       LogHelper.logDebug("Debug -> main_common : event null, skip");
//       return;
//     }

//     final updatedToken = event["token"];
//     LogHelper.logDebug("Debug -> main_common : Token received: $updatedToken");

//     // --- VALIDATION TOKEN ---
//     if (updatedToken == null || updatedToken.toString().trim().isEmpty) {
//       LogHelper.logDebug("Debug -> main_common : Token kosong, skip register background task");
//       return;
//     }

//     // --- CANCEL OLD TASKS ---
//     try {
//       LogHelper.logDebug("Debug -> main_common : Cancel all background tasks...");
//       await Workmanager().cancelAll();
//     } catch (e) {
//       LogHelper.logDebug("Debug -> main_common : Error cancelAll -> $e");
//     }

//     // --- REGISTER NEW TASK ---
//     try {
//       LogHelper.logDebug("Debug -> main_common : Register periodic task...");
//       await Workmanager().registerPeriodicTask(
//         "task_location_update",
//         "backgroundTask",
//         frequency: const Duration(minutes: _schedullerPeriode),
//         constraints: _constraints,
//         inputData: {"token": updatedToken},
//       );

//       LogHelper.logDebug(
//         "Debug -> main_common : Background task registered with token: $updatedToken",
//       );
//     } catch (e) {
//       LogHelper.logDebug("Debug -> main_common : Error registerPeriodicTask -> $e");
//     }
//   });
// }

// class MyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     return super.createHttpClient(context)
//       ..badCertificateCallback =
//           (X509Certificate cert, String host, int port) => true;
//   }
// }
