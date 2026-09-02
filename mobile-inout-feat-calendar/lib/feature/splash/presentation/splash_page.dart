// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_in_out/core/resources/constants/assets.dart';
import 'package:mobile_in_out/core/resources/injector/di.dart';
import 'package:mobile_in_out/core/resources/local/camera_service.dart';
import 'package:mobile_in_out/core/resources/local/face_detector_service.dart';
import 'package:mobile_in_out/core/resources/local/ml_service.dart';
import 'package:mobile_in_out/core/resources/local/pref_service.dart';
import 'package:mobile_in_out/core/resources/network/http_service.dart';
import 'package:mobile_in_out/core/routes/router_import.gr.dart';
import 'package:mobile_in_out/core/utils/base_state/base_state.dart';
import 'package:mobile_in_out/core/utils/extensions/context_extension.dart';
import 'package:mobile_in_out/core/utils/extensions/widget_extension.dart';
import 'package:mobile_in_out/core/utils/helper/location_helper.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';
import 'package:mobile_in_out/core/utils/helper/notification_service.dart';
import 'package:mobile_in_out/feature/auth/provider/auth_provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:mobile_in_out/feature/home_v2/data/model/profile_model.dart';
import 'package:mobile_in_out/feature/home_v2/presentation/provider/home_v2_state_provider.dart';

@RoutePage()
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  late final ShardPrefService _prefService;
  late final AuthProvider authProvider;

  final MLService _mlService = sl<MLService>();
  final FaceDetectorService _mlKitService = sl<FaceDetectorService>();

  @override
  void initState() {
    super.initState();
    _prefService = sl<ShardPrefService>();
    authProvider = sl<AuthProvider>();
    _initialize();
  }

  void _checkRegisterFace(ProfileModel? profileData) async {
    if (profileData?.modelData == null || profileData?.modelData == '') {
      // when user is not ready register, user will be direct to home and on home page will be check again face register
      context.router.replace(HomeRouteV2());
    } else {
      final isReady = await LocationHelper.checkAndEnableLocation();
      if (isReady) {
        context.router.replace(AbsenceRoute(showBackButton: false));
      } else {
        context.router.replace(HomeRouteV2());
      }
    }
    return;
  }

  void _getProfile() async {
    await ref.read(profileNotifierProvider.notifier).getProfile();
    if (!mounted) return;
    final state = ref.read(profileNotifierProvider);

    if (state.state == ConcreteState.loaded) {
      String profileConvert = jsonEncode(state.data);
      await ref
          .read(localDataNotifierProvider.notifier)
          .saveProfile(profileConvert);
      if (!mounted) return;

      _checkRegisterFace(state.data);
    } else if (state.state == ConcreteState.failure) {
      context.router.replace(HomeRouteV2());
      return;
    }
  }

  Future<void> _initialize() async {
    await _initializeServices();
    await _init();
  }

  Future<void> _initializeServices() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _mlService.initialize();
      _mlKitService.initialize();
    });
  }

  Future<void> _init() async {
    final authToken = await _prefService.getString(PrefServiceKey.authToken);
    final email = await _prefService.getString(PrefServiceKey.email);
    bool isLogin = await _prefService.getBool(PrefServiceKey.isLogin) ?? false;

    final details = await NotificationService.notif
        .getNotificationAppLaunchDetails();
    final isFromNotif = details?.didNotificationLaunchApp ?? false;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (authToken == null || authToken.isEmpty) {
        context.router.replace(const SignInRoute());
        return;
      }

      // // Sudah login
      // if (isFromNotif) {
      //   // 1. Ganti screen dengan Home
      //   context.router.replace(const HomeRouteV2());

      //   // 2. Lalu push ke halaman notifikasi
      //   await Future.delayed(Duration(milliseconds: 500));
      //   context.router.push(const CheckInRoute());
      // } else {
      //   // Buka normal → langsung ke Home
      //   context.router.replace(const HomeRouteV2());
      // }

      // context.router.replace(AbsenceRoute(showBackButton: false));

      if (email != null) {
        authProvider.fetchProfileNoSaveToLocal();
      }

      if (isLogin) {
        _startTracking(authToken);
        _getProfile();
      } else {
        context.router.replace(const SignInRoute());
        return;
      }
    });
  }

  Future<void> _startTracking(token) async {
    final service = FlutterBackgroundService();
    bool isRunning = await service.isRunning();

    if (!isRunning) {
      await service.startService();
    }
    LogHelper.logDebug(
      "================= BACKGROUND SERVICE IS ${isRunning ? '' : 'NOT'} 'RUNNING' From SplashScreen =================",
    );
    service.invoke("taskUpdateToken", {"token": token});
    service.invoke("startTaskTrackingLocation", {"token": token});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                child: Image.asset(
                  Assets.logoPng,
                  width: 250,
                ).topPadded(context.screenHeight * .4),
              ),
              const Spacer(),
              Image.asset(Assets.logo2cPng, width: 100).bottomPadded(25),
            ],
          ),
        ),
      ),
    );
  }
}
