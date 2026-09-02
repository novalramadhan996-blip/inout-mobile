import 'package:chat/core/route_change_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile_in_out/core/global/provider/location_provider.dart';
import 'package:mobile_in_out/core/resources/injector/di.dart';
import 'package:mobile_in_out/core/resources/injector/di.dart' as di;
import 'package:mobile_in_out/core/resources/local/pref_service.dart';
import 'package:mobile_in_out/core/resources/theme/theme.dart';
import 'package:mobile_in_out/core/routes/router_import.dart';
import 'package:mobile_in_out/core/utils/helper/notification_service.dart';
import 'package:mobile_in_out/core/utils/localizations/locale_provider.dart';
import 'package:mobile_in_out/feature/auth/provider/auth_provider.dart';
import 'package:mobile_in_out/feature/auth/provider/register_provider.dart';
import 'package:mobile_in_out/feature/auth/provider/register_provider_old.dart';
import 'package:mobile_in_out/feature/change_password/provider/change_password_provider.dart';
import 'package:mobile_in_out/feature/forgot_password/provider/reset_password_provider.dart';
import 'package:mobile_in_out/feature/history/provider/history_provider.dart';
import 'package:mobile_in_out/feature/home/presentation/provider/home_provider.dart';
import 'package:mobile_in_out/feature/in_and_out/providers/in_out_provider.dart';
import 'package:mobile_in_out/feature/maps/provider/map_provider.dart';
import 'package:mobile_in_out/feature/profile/providers/profile_provider.dart';
import 'package:mobile_in_out/core/routes/router_import.dart' as app_router;
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

class AppWidget extends StatefulWidget {
  const AppWidget({super.key});

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  late final AppRouter _router;
  late final ShardPrefService _prefService;
  late final LocaleProvider _localeProvider;

  @override
  void initState() {
    di.initilizeDi();
    GlobalKey<NavigatorState> navigatorKey = sl<GlobalKey<NavigatorState>>();
    _prefService = sl<ShardPrefService>();
    _localeProvider = sl<LocaleProvider>();
    _router = app_router.AppRouter(navigatorKey: navigatorKey);
    _initializePrefService();
    super.initState();
  }

  _initializePrefService() async {
    await _prefService.init();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.init();
      NotificationService.askNotificationPermission();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => sl<ProfileProvider>(),
        ),
        ChangeNotifierProvider<InOutProvider>(
          create: (_) => sl<InOutProvider>(),
        ),
        ChangeNotifierProvider<AuthProvider>(create: (_) => sl<AuthProvider>()),
        ChangeNotifierProvider<HomeProvider>(create: (_) => sl<HomeProvider>()),
        ChangeNotifierProvider<RegisterProvider>(
          create: (_) => sl<RegisterProvider>(),
        ),
        ChangeNotifierProvider<RegisterProviderOld>(
          create: (_) => sl<RegisterProviderOld>(),
        ),
        ChangeNotifierProvider<MapProvider>(create: (_) => sl<MapProvider>()),
        ChangeNotifierProvider<LocationProvider>(
          create: (_) => sl<LocationProvider>(),
        ),
        ChangeNotifierProvider<HistoryProvider>(
          create: (_) => sl<HistoryProvider>(),
        ),
        ChangeNotifierProvider<ResetPasswordProvider>(
          create: (_) => sl<ResetPasswordProvider>(),
        ),
        ChangeNotifierProvider<ChangePasswordProvider>(
          create: (_) => sl<ChangePasswordProvider>(),
        ),
        ChangeNotifierProvider<LocaleProvider>.value(value: _localeProvider),
        ChangeNotifierProvider<RouteChangeNotifier>(
          create: (_) => sl<RouteChangeNotifier>(),
        ),
      ],
      builder: (context, child) => OverlaySupport.global(
        child: ListenableBuilder(
          listenable: _localeProvider,
          builder: (context, child) => MaterialApp.router(
            key: ValueKey(_localeProvider.languageCode),
            theme: AppTheme.light,
            locale: _localeProvider.locale,
            supportedLocales: const [Locale('id'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerDelegate: _router.delegate(
              navigatorObservers: () => [app_router.RouterObserver(), routeObserver],
            ),
            routeInformationParser: _router.defaultRouteParser(),
          ),
        ),
      ),
    );
  }
}
