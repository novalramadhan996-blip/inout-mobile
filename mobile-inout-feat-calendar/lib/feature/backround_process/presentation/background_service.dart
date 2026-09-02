import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:chat/core/resources/storage/shared_preference_service.dart';
import 'package:chat/core/route_change_notifier.dart';
import 'package:chat/viewmodel/chat_view_model.dart';
import 'package:chat/viewmodel/group_list_view_model.dart';
import 'package:chat/viewmodel/user_list_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alice/alice.dart';
import 'package:mobile_in_out/core/global/provider/location_provider.dart';
import 'package:mobile_in_out/core/resources/injector/di.dart' as di;
import 'package:mobile_in_out/core/resources/local/pref_service.dart';
import 'package:mobile_in_out/core/resources/network/http_service.dart';
import 'package:mobile_in_out/core/resources/network/rest_client.dart';
import 'package:mobile_in_out/core/resources/repositories/repository.dart';
import 'package:mobile_in_out/core/utils/localizations/locale_provider.dart';
import 'package:mobile_in_out/feature/auth/provider/register_provider.dart';
import 'package:mobile_in_out/feature/auth/provider/auth_provider.dart';
import 'package:mobile_in_out/feature/auth/provider/register_provider_old.dart';
import 'package:mobile_in_out/feature/backround_process/presentation/background_entry.dart';
import 'package:mobile_in_out/feature/change_password/provider/change_password_provider.dart';
import 'package:mobile_in_out/feature/forgot_password/provider/reset_password_provider.dart';
import 'package:mobile_in_out/feature/history/provider/history_provider.dart';
import 'package:mobile_in_out/feature/home/presentation/provider/home_provider.dart';
import 'package:mobile_in_out/feature/in_and_out/providers/in_out_provider.dart';
import 'package:mobile_in_out/feature/maps/provider/map_provider.dart';
import 'package:mobile_in_out/feature/profile/providers/profile_provider.dart';
import 'package:chat/core/resources/network/http_service.dart' as HttpServ;
import 'package:chat/core/resources/network/rest_client.dart' as RestCl;
import 'package:chat/repositories/repository.dart' as Repo;

class BackgroundService {
  static final FlutterBackgroundService _service = FlutterBackgroundService();

  static Future<void> init() async {
    await _service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
      androidConfiguration: AndroidConfiguration(
        autoStart: true,
        onStart: onStart,
        isForegroundMode: true,
        autoStartOnBoot: true,
      ),
    );

    // when error background services please comment this code, but check how long background process still running
    await _service.startService();
  }

  static Future<bool> isRunning() async {
    return await _service.isRunning();
  }

  static Future<void> startService() async {
    try {
      bool running = await _service.isRunning();
      if (!running) {
        await _service.startService();
      }
    } catch (e) {
      // Android 14+ may restrict foreground service start
    }
  }

  static Future<void> initializeDI() async {
    di.sl.registerLazySingleton<GlobalKey<NavigatorState>>(
      () => GlobalKey<NavigatorState>(),
    );
    di.sl.registerLazySingleton<SharedPreferenceService>(
      () => SharedPreferenceService(),
    );
    di.sl.registerLazySingleton<Alice>(
      () => Alice(
        showNotification: true,
        showInspectorOnShake: true,
        navigatorKey: di.sl<GlobalKey<NavigatorState>>(),
      ),
    );
    di.sl.registerLazySingleton<ShardPrefService>(() => ShardPrefService());
    di.sl.registerLazySingleton<LocaleProvider>(
      () => LocaleProvider(di.sl<ShardPrefService>()),
    );

    // Services
    di.sl.registerLazySingleton<HttpService>(
      () => HttpService(alice: di.sl<Alice>()),
    );
    di.sl.registerLazySingleton<RestClient>(
      () => RestClient(di.sl<HttpService>().dio),
      instanceName: 'dio',
    );
    di.sl.registerLazySingleton<Repository>(
      () => Repository(restClient: di.sl<RestClient>(instanceName: 'dio')),
    );

    // Providers
    di.sl.registerLazySingleton<AuthProvider>(
      () => AuthProvider(di.sl<Repository>()),
    );
    di.sl.registerLazySingleton<ProfileProvider>(
      () => ProfileProvider(di.sl<Repository>()),
    );
    di.sl.registerLazySingleton<InOutProvider>(
      () => InOutProvider(di.sl<Repository>()),
    );
    di.sl.registerLazySingleton<RegisterProvider>(
      () => RegisterProvider(di.sl<Repository>()),
    );
    di.sl.registerLazySingleton<RegisterProviderOld>(
      () => RegisterProviderOld(di.sl<Repository>()),
    );
    di.sl.registerLazySingleton<HomeProvider>(
      () => HomeProvider(di.sl<Repository>()),
    );
    di.sl.registerLazySingleton<MapProvider>(() => MapProvider());
    di.sl.registerLazySingleton<LocationProvider>(
      () => LocationProvider(di.sl<Repository>()),
    );
    di.sl.registerLazySingleton<HistoryProvider>(
      () => HistoryProvider(di.sl<Repository>()),
    );
    di.sl.registerLazySingleton<ResetPasswordProvider>(
      () => ResetPasswordProvider(di.sl<Repository>()),
    );
    di.sl.registerLazySingleton<ChangePasswordProvider>(
      () => ChangePasswordProvider(di.sl<Repository>()),
    );

    di.sl.registerLazySingleton<HttpServ.HttpService>(
      () => HttpServ.HttpService(alice: di.sl<Alice>()),
    );
    di.sl.registerSingleton<RestCl.RestClient>(
      RestCl.RestClient(di.sl<HttpServ.HttpService>().dio),
      instanceName: 'dio',
    );
    di.sl.registerLazySingleton<Repo.Repository>(
      () => Repo.Repository(
        restClient: di.sl<RestCl.RestClient>(instanceName: 'dio'),
      ),
    );
    di.sl.registerLazySingleton<UserListViewModel>(
      () => UserListViewModel(di.sl<Repo.Repository>()),
    );
    di.sl.registerLazySingleton<GroupListViewModel>(
      () => GroupListViewModel(di.sl<Repo.Repository>()),
    );
    di.sl.registerLazySingleton<ChatViewModel>(
      () => ChatViewModel(di.sl<Repo.Repository>()),
    );
    di.sl.registerLazySingleton<RouteChangeNotifier>(
      () => RouteChangeNotifier(),
    );
  }
}
