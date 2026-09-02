import 'package:chat/core/resources/injector/di.dart';
import 'package:chat/ui/chat_detail_screen.dart';
import 'package:chat/core/route_change_notifier.dart';
import 'package:chat/core/routes/router_import.dart';
import 'package:chat/ui/home_screen.dart';
import 'package:chat/ui/loading_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:chat/chat.dart';
import 'package:overlay_support/overlay_support.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final RouteChangeNotifier _routeChangeNotifier = RouteChangeNotifier();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final appRouter = AppRouter(navigatorKey: navigatorKey);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  initilizeDi(navigatorKey);

  runApp(
    ChangeNotifierProvider(
      create: (_) => RouteChangeNotifier(),
      child: OverlaySupport.global(child: MyApp(appRouter: appRouter)),
    ),
  );
}

class MyApp extends StatefulWidget {
  final AppRouter appRouter;

  const MyApp({super.key, required this.appRouter});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _chatPlugin = Chat();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _chatPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: widget.appRouter.config(),
    );
  }
}
