// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';
import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:alarm/model/notification_settings.dart';
import 'package:alarm/model/volume_settings.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:disable_battery_optimizations_latest/disable_battery_optimizations_latest.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_device_apps/flutter_device_apps.dart';
import 'package:flutter_device_imei/flutter_device_imei.dart';
import 'package:flutter_sim_info/flutter_sim_info.dart';
import 'package:mobile_in_out/core/resources/constants/assets.dart';
import 'package:mobile_in_out/core/resources/injector/di.dart';
import 'package:mobile_in_out/core/resources/local/pref_service.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/resources/theme/theme.dart';
import 'package:mobile_in_out/core/routes/router_import.gr.dart';
import 'package:mobile_in_out/core/utils/dialogs.dart';
import 'package:mobile_in_out/core/utils/extensions/context_extension.dart';
import 'package:mobile_in_out/core/utils/extensions/date_extension.dart';
import 'package:mobile_in_out/core/utils/extensions/widget_extension.dart';
import 'package:mobile_in_out/core/utils/helper/alarm_service.dart';
import 'package:mobile_in_out/core/utils/helper/auth_helper.dart';
import 'package:mobile_in_out/core/utils/helper/date_helper.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';
import 'package:mobile_in_out/core/utils/helper/notification_service.dart';
import 'package:mobile_in_out/core/utils/models/check_in/check_in_response_model.dart';
import 'package:mobile_in_out/core/utils/models/list_data_request.dart';
import 'package:mobile_in_out/core/utils/widgets/app_bar_icons_center.dart';
import 'package:mobile_in_out/core/utils/widgets/app_image_profile_rounded.dart';
import 'package:mobile_in_out/core/utils/widgets/info_column_widget.dart';
import 'package:mobile_in_out/feature/app_usage/data/model/app_usage_model.dart';
import 'package:mobile_in_out/feature/app_usage/presentation/app_usage_service.dart';
import 'package:mobile_in_out/feature/auth/provider/auth_provider.dart';
import 'package:mobile_in_out/feature/history/provider/history_provider.dart';
import 'package:mobile_in_out/feature/home/data/model/device_info_model.dart';
import 'package:mobile_in_out/feature/home/data/model/employee_detail_model.dart';
import 'package:mobile_in_out/feature/home/presentation/provider/home_provider.dart';
import 'package:mobile_in_out/feature/home/presentation/provider/home_remote.dart';
import 'package:mobile_in_out/feature/in_and_out/providers/in_out_provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:one_clock/one_clock.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:mobile_in_out/core/routes/router_import.dart';
import 'package:telephony_info_plus/telephony_info_plus.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with WidgetsBindingObserver, RouteAware {
  late final ShardPrefService _prefService;

  // comment this code because not used, please remove when apps already publish and stable 01/12/2025
  // late HistoryProvider _historyProvider;

  late AuthProvider _authProvider;
  late InOutProvider _inOutProvider;
  late HomeProvider _homeProvider;

  List<NavigatorObserver> get observers => [RouterObserver()];

  bool _isPopBack = false;
  bool _isOnResume = false;
  bool _isCheckin = false;
  String? _historyDateIn;
  String? _historyDateOut;
  EmployeeDetailModel? employeeDetail;
  final int _alarmDistance = 5;

  Map<String, dynamic> deviceData = {};
  String? imei;
  String? imsi;
  final _telephonyInfoPlusPlugin = TelephonyInfoPlus();

  @override
  void initState() {
    _inOutProvider = Provider.of<InOutProvider>(context, listen: false);
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _homeProvider = Provider.of<HomeProvider>(context, listen: false);
    _prefService = sl<ShardPrefService>();

    // final homeState = ref.watch(homeProvider);

    Future.microtask(() {
      Future.microtask(() async {
        fetchProfileFromApi();
        _getHistory();
        _getReminder();
      });
    });

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRequestBatteryOptimization();
      _checkPermissionLocation();
      _checkRegisterFace();
      _isPopBack = false;
      _isOnResume = false;
      _getLocationAbsence();
      _updateDeviceInfo();
    });

    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _startTracking(String location) async {
    final token = await _prefService.getString(PrefServiceKey.authToken);

    final service = FlutterBackgroundService();
    bool isRunning = await service.isRunning();

    if (!isRunning) {
      await service.startService();
    }
    log(
      "================= BACKGROUND SERVICE IS ${isRunning ? '' : 'NOT'} 'RUNNING' From home Token:$token =================",
    );
    service.invoke("taskUpdateToken", {"token": token});
    service.invoke("startTaskTrackingLocation", {
      "token": token,
      "location": location,
    });
  }

  void _getReminder() async {
    // set dummy notification
    // NotificationService.showInstantNotification(title: 'tester', body: 'tester body');

    bool? selectReminder = await _prefService.getBool(
      PrefServiceKey.isReminder,
    );
    if (selectReminder == true) {
      _getEmployeeDetail();
    }
  }

  Future<void> _registerShiftNotifications(EmployeeDetailModel employee) async {
    final schedules = employee.groupShiftSchedules ?? [];

    if (schedules.isEmpty) {
      return;
    }

    final status = await Permission.notification.status;
    if (!status.isGranted) return;

    // clear all existing notification
    await NotificationService.cancelAll();
    await Future.delayed(const Duration(milliseconds: 400));
    int? delayAbsensi = await _prefService.getInt(PrefServiceKey.delayAbsensi);

    for (var s in schedules) {
      if (s.businessDayId == null ||
          s.shiftStartTime == null ||
          s.shiftEndTime == null ||
          s.groupShiftId == null)
        continue;

      final String weekday = s.groupShiftId!;

      final partsStart = s.shiftStartTime!.split(':');
      int startHour = int.tryParse(partsStart[0]) ?? 0;
      int startMinute = int.tryParse(partsStart[1]) ?? 0;

      final partsEnd = s.shiftEndTime!.split(':');
      int endHour = int.tryParse(partsEnd[0]) ?? 0;
      int endMinute = int.tryParse(partsEnd[1]) ?? 0;

      await NotificationService.scheduleWeekly(
        weekday: int.tryParse(weekday) ?? 0,
        hour: startHour,
        minute: startMinute,
        title: "Selamat Bekerja!",
        body: "Jangan lupa absen masuk ya!",
        channel: "shift_checkin_$weekday",
        descChannel: "Shift Checkin",
        delayMinutes: delayAbsensi ?? 0,
      );

      await NotificationService.scheduleWeekly(
        weekday: int.tryParse(weekday) ?? 0,
        hour: endHour,
        minute: endMinute,
        title: "Waktunya Pulang!",
        body: "Jangan lupa absen pulang ya!",
        channel: "shift_checkout_$weekday",
        descChannel: "Shift Checkout",
        delayMinutes: delayAbsensi ?? 0,
      );
    }
  }

  void _checkRegisterFace() async {
    final profileData = await HomeRemote.getProfile();
    if (profileData?.modelData == null || profileData?.modelData == '') {
      context.router.push(RegisterFaceRoute());
      return;
    }
  }

  void _updateDeviceInfo() async {
    await _homeProvider.getEmployeeDetail();
    EmployeeDetailModel? employeeDetailData = _homeProvider.employeeDetail;
    _getAllPackages();
    await _getDeviceInfo();
    await _getTelephoneInfo();
    String deviceId = await _getDeviceIMEI();
    await _getSimInfo();
    await _checkPermissionAndLoadApps();
    await HomeRemote.insertDeviceInfo(
      DeviceInfoModel(
        deviceId: deviceId,
        employeeId: employeeDetailData.employeeId,
        imeiImsi: '',
        deviceDetail: deviceData.toString(),
      ),
    );
  }

  Future<void> _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();

    final android = await deviceInfo.androidInfo;

    setState(() {
      deviceData = {
        "Model": android.model,
        "Manufacturer": android.manufacturer,
        "Brand": android.brand,
        "Android Version": android.version.release,
        "SDK": android.version.sdkInt,
        "Hardware": android.hardware,
        "Board": android.board,
        "Device": android.device,
        "Product": android.product,
        "Supported ABIs": android.supportedAbis.join(", "),
      };
    });
  }

  Future<void> _getTelephoneInfo() async {
    var status = await Permission.phone.request();
    if (!status.isGranted) return;

    try {
      final info = await _telephonyInfoPlusPlugin.getSimInfos();
      deviceData = {...deviceData, 'infoSim': info};
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<String> _getDeviceIMEI() async {
    String? imei = await FlutterDeviceImei.instance.getIMEI();
    return imei ?? '';
  }

  Future<void> _getSimInfo() async {
    List<SimInfo>? simNumber = await FlutterSimInfo.getSimInfo();
    deviceData = {...deviceData, 'simNumber': simNumber};
  }

  Future<void> _checkPermissionAndLoadApps() async {
    final isOpenUsageApps = await _prefService.getBool(
      PrefServiceKey.isOpenUsageAccess,
    );

    if (isOpenUsageApps == false) {
      final hasPermission = await AppUsageService.hasUsagePermission();
      if (!hasPermission) {
        await AppUsageService.openUsageSettings();
        _prefService.setBool(PrefServiceKey.isOpenUsageAccess, true);
        return;
      }
    }

    final lastUsed = await AppUsageService.getLastUsedApps();
    List<Map<String, dynamic>> lastUsedApps = lastUsed.map((app) {
      return {
        'app_name': app.appName,
        'package_name': app.packageName,
        'version_name': app.versionName,
        'version_code': app.versionCode,
        'installed_at': app.installedDate,
        'updated_at': app.lastUsedDate,
      };
    }).toList();
    deviceData = {...deviceData, 'last_used_apps': lastUsedApps};

    final mostUsed = await AppUsageService.getMostUsedApps();
    List<Map<String, dynamic>> mostUsedApps = mostUsed.map((app) {
      return {
        'app_name': app.appName,
        'package_name': app.packageName,
        'version_name': app.versionName,
        'version_code': app.versionCode,
        'installed_at': app.installedDate,
        'updated_at': app.lastUsedDate,
      };
    }).toList();
    deviceData = {...deviceData, 'most_used_apps': mostUsedApps};
  }

  void _getAllPackages() async {
    final newestApps = (await _getNewestInstalledApps()).take(10).toList();
    List<Map<String, dynamic>> mappedApps = newestApps.map((app) {
      return {
        'app_name': app.appName,
        'package_name': app.packageName,
        'version_name': app.versionName,
        'version_code': app.versionCode,
        'installed_at': app.firstInstallTime,
        'updated_at': app.lastUpdateTime,
      };
    }).toList();
    deviceData = {...deviceData, 'last_install_apps': mappedApps};
  }

  Future<List<AppInfo>> _getNewestInstalledApps() async {
    final apps = await FlutterDeviceApps.listApps(
      includeSystem: false,
      onlyLaunchable: true,
      includeIcons: false,
    );

    if (apps.isEmpty) {
      return [];
    }

    apps.sort((a, b) => b.firstInstallTime!.compareTo(a.firstInstallTime!));

    return apps;
  }

  void _getLocationAbsence() async {
    await _homeProvider.getEmployeeDetail();
    employeeDetail = _homeProvider.employeeDetail;

    LogHelper.logDebug(
      'location working locaiton ${employeeDetail?.workingLocation?.address}',
    );

    double latitude = employeeDetail?.workingLocation?.latitude ?? 0.0;
    double longitude = employeeDetail?.workingLocation?.longitude ?? 0.0;

    String location = '$latitude,$longitude';

    LogHelper.logDebug('location latitude longitude $location');

    await _prefService.setString(PrefServiceKey.locationAbsence, location);

    _startTracking(location);
  }

  void _getEmployeeDetail() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _homeProvider.getEmployeeDetail();
      employeeDetail = _homeProvider.employeeDetail;

      if (employeeDetail != null) {
        String groupShiftScheduleConvert = jsonEncode(
          (employeeDetail?.groupShiftSchedules ?? [])
              .map((e) => e.toJson())
              .toList(),
        );
        String groupShiftScheduleLocalData =
            await _prefService.getString(PrefServiceKey.groupShiftSchedule) ??
            '';
        if (!isSameJson(
          groupShiftScheduleLocalData,
          groupShiftScheduleConvert,
        )) {
          await _prefService.setString(
            PrefServiceKey.groupShiftSchedule,
            groupShiftScheduleConvert,
          );
          _registerShiftNotifications(employeeDetail ?? EmployeeDetailModel());
        }
      }
    });
  }

  bool isSameJson(String a, String b) {
    return a == b;
  }

  void _getHistory() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _inOutProvider.fetchCheckInLocal();
      await context.read<HistoryProvider>().getHistory(
        ListDataRequest(
          page: 0,
          limit: 5,
          search: "",
          sortBy: "created",
          orderBy: "desc",
          filter: {"employee_id": _authProvider.profileModel.userId},
        ),
      );

      if (context.read<HistoryProvider>().history.isNotEmpty &&
          context.read<HistoryProvider>().history.first.dateOut == null) {
        if (_inOutProvider.checkInResponse == null) {
          final dataCheckin = CheckInResponseModel(
            absensiId: context
                .read<HistoryProvider>()
                .history
                .first
                .attendanceId,
            employeeId: context.read<HistoryProvider>().history.first.employeeId,
            timeIn: context.read<HistoryProvider>().history.first.dateIn,
            latitudeIn: context
                .read<HistoryProvider>()
                .history
                .first
                .latitudeIn,
            longitudeIn: context
                .read<HistoryProvider>()
                .history
                .first
                .longitudeIn,
            addressIn: context.read<HistoryProvider>().history.first.addressIn,
            noteIn: context.read<HistoryProvider>().history.first.noteIn,
            created: context.read<HistoryProvider>().history.first.created,
          );
          await _inOutProvider.saveCheckInLocal(dataCheckin);
          await _inOutProvider.fetchCheckInLocal();
        }
      }

      setState(() {
        context.read<HistoryProvider>().history.isNotEmpty
            ? _historyDateIn = context
                  .read<HistoryProvider>()
                  .history
                  .first
                  .dateIn
            : _historyDateIn = null;
        context.read<HistoryProvider>().history.isNotEmpty
            ? _historyDateOut = context
                  .read<HistoryProvider>()
                  .history
                  .first
                  .dateOut
            : _historyDateOut = null;
      });

      await _getIsCheckedIn();
    });
  }

  void autoLogoutIfProfileNull() async {
    if (_authProvider.profileModel.name == null ||
        _authProvider.profileModel.name == '') {
      await AuthHelper.logout();
    }
  }

  void fetchProfileFromApi() async {
    await _authProvider.fetchProfileNoSaveToLocal();
    autoLogoutIfProfileNull();
  }

  final _channel = const MethodChannel('com.twosee.inandout');

  Future<void> startLocationUpdates() async {
    final jwtToken = await _prefService.getString(PrefServiceKey.authToken);
    try {
      await _channel.invokeMethod('startLocationUpdates', {'jwt': jwtToken});
      // ignore: unused_catch_clause, empty_catches
    } on PlatformException catch (error) {}
  }

  Future<void> stopLocationService() async {
    try {
      await _channel.invokeMethod('stopLocationUpdates');
      // ignore: unused_catch_clause, empty_catches
    } on PlatformException catch (error) {}
  }

  Future<void> _getIsCheckedIn() async {
    if (_inOutProvider.checkInResponse != null) {
      String? timeString = _historyDateIn;
      DateTime dateTime;
      DateTime today = DateTime.now();
      try {
        timeString = timeString?.replaceFirst(
          RegExp(r'\+(\d):(\d)$'),
          r'+0$1:0$2',
        );

        dateTime = DateTime.parse(timeString ?? '');
        dateTime = dateTime.add(Duration(hours: 7));
        bool isTodayGreater = DateTime(today.year, today.month, today.day)
            .isAtSameMomentAs(
              DateTime(dateTime.year, dateTime.month, dateTime.day),
            );
        if (!isTodayGreater) {
          await _inOutProvider.deleteInOutLocal();
          await _inOutProvider.fetchCheckInLocal();
        }
        setState(() {
          _isCheckin = !isTodayGreater;
        });
      } catch (e) {
        setState(() {
          _isCheckin = true;
        });
      }
    } else {
      if (_historyDateOut == null) {
        String? timeString = _historyDateIn;
        DateTime dateTime;
        DateTime today = DateTime.now();
        try {
          timeString = timeString?.replaceFirst(
            RegExp(r'\+(\d):(\d)$'),
            r'+0$1:0$2',
          );

          dateTime = DateTime.parse(timeString ?? '');
          dateTime = dateTime.add(Duration(hours: 7));
          bool isTodayGreater = DateTime(today.year, today.month, today.day)
              .isAtSameMomentAs(
                DateTime(dateTime.year, dateTime.month, dateTime.day),
              );
          setState(() {
            _isCheckin = !isTodayGreater;
          });
        } catch (e) {
          setState(() {
            _isCheckin = true;
          });
        }
      } else {
        setState(() {
          _isCheckin = true;
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to RouterObserver
    final observer = observers.first;
    if (observer is RouterObserver) {
      var contextData = ModalRoute.of(context)!;
      observer.subscribe(this, contextData);
      if (_isPopBack == true) {
        _checkAndRequestBatteryOptimization();
        _checkPermissionLocation();
        WidgetsBinding.instance.addObserver(this);
      }
      if (contextData.isCurrent == false) {
        _isPopBack = true;
        WidgetsBinding.instance.removeObserver(this);
      } else {
        _isPopBack = false;
      }
    }
  }

  @override
  void dispose() {
    // Unsubscribe from RouterObserver
    final observer = observers.first;
    if (observer is RouterObserver) {
      observer.unsubscribe(this);
    }

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // dipanggil ketika kembali ke halaman ini
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (_isOnResume) {
          _checkAndRequestBatteryOptimization();
          _checkPermissionLocation();
          _isOnResume = false;
        }
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        _isOnResume = true;
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        _isOnResume = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarIconCenter(),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: context.screenHeight / 2.5,
              color: AppColors.greyColor.withOpacity(.2),
            ),
          ),
          SingleChildScrollView(
            child: RefreshIndicator(
              onRefresh: () async {
                await _inOutProvider.fetchCheckInLocal();

                // comment this code because not used, please remove when apps already publish and stable 01/12/2025
                // _historyProvider.getHistory(
                //   ListDataRequest(
                //     page: 0,
                //     limit: 1,
                //     search: "",
                //     orderBy: "desc",
                //     sortBy: "created",
                //     filter: {"employee_id": _authProvider.profileModel.userId},
                //   ),
                // );
              },
              child: Column(
                children: [
                  // Header
                  Consumer<AuthProvider>(
                    builder: (context, provider, _) {
                      return Row(
                        children: [
                          Consumer<AuthProvider>(
                            builder: (context, watch, _) {
                              var profileUrl = watch.profileModel.profileUrl;
                              String initialName =
                                  watch.profileModel.name ?? "Unknown";
                              return AppImageProfileRounded(
                                width: 42,
                                height: 42,
                                profileUrl:
                                    profileUrl != null && profileUrl != ""
                                    ? "https://inout-dev.2ndc.app/thumbnail/$profileUrl"
                                    : "",
                                initialName: initialName[0].toUpperCase(),
                              );
                            },
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  // onTap: () async {
                                  //   await BackgroundLocationTrackerManager.startTracking();
                                  // },
                                  child: Consumer<AuthProvider>(
                                    builder: (context, watch, _) {
                                      return Text(
                                        'Hey ${watch.profileModel.name ?? '-'}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const Text(
                                  'Let\'s explore what you can do today!',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ).topPadded(30);
                    },
                  ),

                  // Clock
                  DigitalClock(
                    showSeconds: true,
                    isLive: true,
                    textScaleFactor: 2.5,
                    decoration: const BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                  ).topPadded(40),
                  Text(
                    DateTime.now().toFormattedDate(),
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),

                  // Button Checkin - Checkout
                  Consumer<InOutProvider>(
                    builder: (context, inOutprovider, _) {
                      return Consumer<HomeProvider>(
                        builder: (context, homeProvider, _) {
                          if (homeProvider.needRefresh) {
                            homeProvider.needRefresh = false;
                            fetchProfileFromApi();
                            _getHistory();
                          }
                          return GestureDetector(
                            onTap: () async {
                              Dialogs.showLoadingDialog(context);

                              if (_authProvider.profileModel.modelData !=
                                  null) {
                                Dialogs.dismissDialog(context);
                                context.router.push(const CheckInRoute());
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Please register your face first!",
                                  ),
                                  backgroundColor: AppColors.redColors,
                                ),
                              );

                              Dialogs.dismissDialog(context);
                            },
                            child: Container(
                              width: 230,
                              height: 230,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(1000),
                              ),
                              child: _isCheckin
                                  ? Image.asset(Assets.icInNew)
                                  : Image.asset(Assets.icOutNew),
                            ).topPadded(40),
                          );
                        },
                      );
                    },
                  ),

                  // Data Time in/out
                  Consumer<HistoryProvider>(
                    builder: (context, watch, _) {
                      getCheckIn() {
                        if (watch.history.isEmpty) {
                          return '--:--';
                        }

                        if (watch.history.first.dateIn == null) {
                          return '--:--';
                        }

                        String dateInStr = watch.history.first.dateIn!;

                        // Fix timezone if needed
                        dateInStr = dateInStr.replaceFirst(
                          RegExp(r'\+(\d):(\d)$'),
                          r'+0$1:0$2',
                        );

                        // Parse and convert to GMT+7
                        final timeIn = DateTime.parse(
                          dateInStr,
                        ).add(Duration(hours: 7));

                        final timeInFormatted = DateHelper.getFormattedTime(
                          timeIn,
                        );

                        return timeInFormatted;
                      }

                      getCheckOut() {
                        if (watch.history.isEmpty) {
                          return '--:--';
                        }

                        if (watch.history.first.dateOut == null) {
                          return '--:--';
                        }

                        String dateOutStr = watch.history.first.dateOut!;

                        // Fix timezone if needed
                        dateOutStr = dateOutStr.replaceFirst(
                          RegExp(r'\+(\d):(\d)$'),
                          r'+0$1:0$2',
                        );

                        // Parse and convert to GMT+7
                        final timeOut = DateTime.parse(
                          dateOutStr,
                        ).add(Duration(hours: 7));

                        final timeOutFormatted = DateHelper.getFormattedTime(
                          timeOut,
                        );

                        return timeOutFormatted;
                      }

                      getTotalHours() {
                        if (watch.history.isEmpty) {
                          return '--:--';
                        }

                        if (watch.history.first.dateIn == null ||
                            watch.history.first.dateOut == null) {
                          return '--:--';
                        }

                        String dateInStr = watch.history.first.dateIn!;
                        String dateOutStr = watch.history.first.dateOut!;

                        // Fix timezone if needed
                        dateInStr = dateInStr.replaceFirst(
                          RegExp(r'\+(\d):(\d)$'),
                          r'+0$1:0$2',
                        );
                        dateOutStr = dateOutStr.replaceFirst(
                          RegExp(r'\+(\d):(\d)$'),
                          r'+0$1:0$2',
                        );

                        // Parse and convert to GMT+7
                        final timeIn = DateTime.parse(
                          dateInStr,
                        ).add(Duration(hours: 7));
                        final timeOut = DateTime.parse(
                          dateOutStr,
                        ).add(Duration(hours: 7));

                        Duration diff = timeOut.difference(timeIn);

                        final hours = diff.inHours;
                        final minutes = diff.inMinutes.remainder(60);

                        if (hours == 0 && minutes == 0) return '0 minutes';
                        if (hours == 0) return '$minutes minutes';
                        if (minutes == 0) return '$hours hours';

                        return '$hours h $minutes m';
                      }

                      return Row(
                        children: [
                          Expanded(
                            child: InfoColumn(
                              imagePath: Assets.icMiniIn,
                              time: getCheckIn(),
                              label: 'Check In',
                              margin: const EdgeInsets.only(right: 5),
                            ),
                          ),
                          Expanded(
                            child: InfoColumn(
                              imagePath: Assets.icMiniOut,
                              time: getCheckOut(),
                              label: 'Check Out',
                              margin: const EdgeInsets.only(left: 5, right: 5),
                            ),
                          ),
                          Expanded(
                            child: InfoColumn(
                              imagePath: Assets.icMiniHrs,
                              time: getTotalHours(),
                              label: 'Total HRS',
                              margin: const EdgeInsets.only(left: 5),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  // Location
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(Assets.icMiniLoc, width: 35),
                            const SizedBox(width: 10),
                            Text(
                              "Last check location",
                              style: AppTheme.bodyText.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                        Consumer<InOutProvider>(
                          builder: (context, inOutprovider, _) {
                            return Consumer<HistoryProvider>(
                              builder: (context, watch, _) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xffF1F5F9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    watch.history.isNotEmpty
                                        ? inOutprovider.checkInResponse == null
                                              ? (watch
                                                            .history
                                                            .first
                                                            .addressOut
                                                            ?.isNotEmpty ==
                                                        true
                                                    ? watch
                                                          .history
                                                          .first
                                                          .addressOut!
                                                    : watch
                                                              .history
                                                              .first
                                                              .addressIn ??
                                                          "-")
                                              : watch.history.first.addressIn ??
                                                    "-"
                                        : "-",
                                  ),
                                );
                              },
                            ).topPadded(6);
                          },
                        ),
                      ],
                    ),
                  ).topPadded(8).bottomPadded(8),
                ],
              ).horizontalPadded(),
            ),
          ),
        ],
      ),
    );
  }

  //check battery optimization
  Future<void> _checkAndRequestBatteryOptimization() async {
    bool isBatteryOptimizationDisabled =
        await DisableBatteryOptimizationLatest.isBatteryOptimizationDisabled ??
        false;
    bool isManBatteryOptimizationDisabled =
        await DisableBatteryOptimizationLatest
            .isManufacturerBatteryOptimizationDisabled ??
        false;

    if (!isBatteryOptimizationDisabled) {
      if (isManBatteryOptimizationDisabled) {
        _requestLocationPermission(
          "Battery Optimization",
          'This application requires setup battery no restriction to function properly. Please setup battery "no restrict" in settings.',
          'Aplikasi ini memerlukan pengaturan baterai tanpa batasan agar dapat berfungsi dengan baik. Harap atur baterai "tanpa batasan" di pengaturan.',
        );
      } else {
        await DisableBatteryOptimizationLatest.showDisableBatteryOptimizationSettings();
      }
    }
  }

  Future<void> _checkPermissionLocation() async {
    PermissionStatus status = await Permission.locationAlways.status;
    if (!status.isGranted) {
      _requestLocationPermission(
        "Location Permission Required",
        'This app needs location permission to work properly. Please enable "Allow Always" in settings.',
        'Aplikasi ini memerlukan izin lokasi untuk bekerja dengan baik. Silakan aktifkan "Izinkan Selalu" di pengaturan.',
      );
    }
  }

  Future<void> _requestLocationPermission(title, message_1, message_2) async {
    // Get the current permission status

    Future.delayed(const Duration(microseconds: 3000), () {
      // Show the permission dialog
      showDialog(
        context: context,
        barrierDismissible: true, // Prevent dismissal by tapping outside
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message_1),
                const SizedBox(height: 10),
                Text(message_2, style: const TextStyle(color: Colors.red)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  // Open app settings for user to enable permission manually
                  await openAppSettings();

                  Navigator.pop(context); // This dismisses the dialog
                },
                child: const Text('Go to Settings'),
              ),
            ],
          );
        },
      );
    });
  }

  void _listenerAlarm() {
    Alarm.ringing.listen((AlarmSet alarmSet) async {
      for (final alarm in alarmSet.alarms) {
        LogHelper.logDebug('alarm ${alarm.id}');
        final payload = jsonDecode(alarm.payload ?? '{}');
        if (payload != null && payload.isEmpty) {
          if (payload?.type == 'checkin') {
            LogHelper.logDebug('masuk checkin');
          } else {
            LogHelper.logDebug('masuk checkout');
          }
          if (payload?.alarm_loop == true) {
            await AlarmService.scheduleAlarm(
              weekday: int.tryParse(payload?.weekday) ?? 0,
              hour: payload?.startHour,
              minute: payload?.startMinute,
              title: payload?.title,
              body: payload?.body,
              alarmDistance: _alarmDistance,
              payload: jsonEncode(alarm.payload),
            );
          }
        }
      }
    });
  }

  @Deprecated(
    'Feature alarm using alarm manager not used, please using feature alarm using local notification',
  )
  Future<void> _registerShiftAlarms(EmployeeDetailModel employee) async {
    final schedules = employee.groupShiftSchedules ?? [];

    if (schedules.isEmpty) {
      return;
    }

    final status = await Permission.notification.status;
    if (!status.isGranted) return;

    // clear all existing notification
    await AlarmService.cancelAll();
    await Future.delayed(const Duration(milliseconds: 400));

    for (var s in schedules) {
      if (s.businessDayId == null ||
          s.shiftStartTime == null ||
          s.shiftEndTime == null ||
          s.groupShiftId == null)
        continue;

      final String weekday = s.groupShiftId!;

      final partsStart = s.shiftStartTime!.split(':');
      int startHour = int.tryParse(partsStart[0]) ?? 0;
      int startMinute = int.tryParse(partsStart[1]) ?? 0;

      final partsEnd = s.shiftEndTime!.split(':');
      int endHour = int.tryParse(partsEnd[0]) ?? 0;
      int endMinute = int.tryParse(partsEnd[1]) ?? 0;

      // test dummy alarm
      // final String weekday = '2';
      // int startHour = 8;
      // int startMinute = 18;
      // int endHour = 8;
      // int endMinute = 20;

      final payloadCheckin = {
        'type': 'checkin',
        'alarm_loop': true,
        'startHour': startHour,
        'startMinute': startMinute,
        'weekday': weekday,
        'title': 'Absen Masuk',
        'body': 'Jangan sampai lupa absen ya!',
      };

      final payloadCheckout = {
        'type': 'checkout',
        'alarm_loop': false,
        'startHour': endHour,
        'startMinute': endMinute,
        'weekday': weekday,
        'title': 'Absen Pulang',
        'body': 'Jangan sampai lupa absen ya!',
      };

      await AlarmService.scheduleAlarm(
        weekday: int.tryParse(weekday) ?? 0,
        hour: startHour,
        minute: startMinute,
        title: "Absen Masuk",
        body: "Jangan sampai lupa absen ya!",
        // alarmDistance: _alarmDistance,
        payload: jsonEncode(payloadCheckin),
      );

      await AlarmService.scheduleAlarm(
        weekday: int.tryParse(weekday) ?? 0,
        hour: endHour,
        minute: endMinute,
        title: "Absen Pulang",
        body: "Jangan sampai lupa absen ya!",
        payload: jsonEncode(payloadCheckout),
      );
    }
  }
}
