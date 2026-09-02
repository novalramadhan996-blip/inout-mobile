// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'dart:developer';
import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:disable_battery_optimizations_latest/disable_battery_optimizations_latest.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_device_apps/flutter_device_apps.dart';
import 'package:flutter_device_imei/flutter_device_imei.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sim_info/flutter_sim_info.dart';
import 'package:mobile_in_out/core/resources/constants/app_font.dart';
import 'package:mobile_in_out/core/resources/constants/assets.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/routes/router_import.gr.dart';
import 'package:mobile_in_out/core/utils/base_state/base_state.dart';
import 'package:mobile_in_out/core/utils/extensions/date_extension.dart';
import 'package:mobile_in_out/core/utils/helper/alarm_service.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';
import 'package:mobile_in_out/core/utils/helper/notification_service.dart';
import 'package:mobile_in_out/core/utils/models/history/absence_history_model.dart';
import 'package:mobile_in_out/core/utils/models/list_data_request.dart';
import 'package:mobile_in_out/core/utils/widgets/app_bar_icons_center.dart';
import 'package:mobile_in_out/core/utils/widgets/app_button.dart';
import 'package:mobile_in_out/core/utils/widgets/app_image_profile_rounded.dart';
import 'package:mobile_in_out/feature/app_usage/presentation/app_usage_service.dart';
import 'package:mobile_in_out/feature/history/model/group_shift_schedule_response.dart';
import 'package:mobile_in_out/feature/home_v2/data/model/device_info_model.dart';
import 'package:mobile_in_out/feature/home_v2/data/model/employee_detail_model.dart';
import 'package:mobile_in_out/feature/home_v2/data/model/profile_model.dart';
import 'package:mobile_in_out/feature/home_v2/presentation/provider/home_v2_state_provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_in_out/core/routes/router_import.dart';
import 'package:telephony_info_plus/telephony_info_plus.dart';

@RoutePage()
class HomePageScrollV2 extends ConsumerStatefulWidget {
  const HomePageScrollV2({super.key});

  @override
  ConsumerState<HomePageScrollV2> createState() => _HomePageScrollV2State();
}

class _HomePageScrollV2State extends ConsumerState<HomePageScrollV2>
    with WidgetsBindingObserver, RouteAware {
  List<NavigatorObserver> get observers => [RouterObserver()];

  bool _isPopBack = false;
  bool _isOnResume = false;
  bool _isCheckin = false;
  String? _profileUrl;
  String? _initialName;
  String? _fullName;
  String _timeCheckIn = '';
  String _timeElapsed = '';
  String _remaining = '';
  final int _alarmDistance = 5;

  Map<String, dynamic> deviceData = {};
  String? imei;
  String? imsi;
  final _telephonyInfoPlusPlugin = TelephonyInfoPlus();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isPopBack = false;
      _isOnResume = false;
      _checkAndRequestBatteryOptimization();
      _checkPermissionLocation();
      _getEmployeeDetail();
      _geProfile();
    });

    WidgetsBinding.instance.addObserver(this);
  }

  void _onRefresh() {
    _getEmployeeDetail();
    _geProfile();
  }

  Future<void> _startTracking() async {
    await ref.read(localDataNotifierProvider.notifier).getToken();
    final state = ref.read(localDataNotifierProvider);

    if (state.state == ConcreteState.loaded) {
      final token = state.data;
      final service = FlutterBackgroundService();
      bool isRunning = await service.isRunning();

      if (!isRunning) {
        await service.startService();
      }
      LogHelper.logDebug(
        "================= BACKGROUND SERVICE IS ${isRunning ? '' : 'NOT'} 'RUNNING' From home Token:$token =================",
      );
      service.invoke("taskUpdateToken", {"token": token});
      service.invoke("startTaskTrackingLocation", {"token": token});
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
    // int? delayAbsensi = await _prefService.getInt(PrefServiceKey.delayAbsensi);

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
        // delayMinutes: delayAbsensi ?? 0,
      );

      await NotificationService.scheduleWeekly(
        weekday: int.tryParse(weekday) ?? 0,
        hour: endHour,
        minute: endMinute,
        title: "Waktunya Pulang!",
        body: "Jangan lupa absen pulang ya!",
        channel: "shift_checkout_$weekday",
        descChannel: "Shift Checkout",
        // delayMinutes: delayAbsensi ?? 0,
      );
    }
  }

  void _checkRegisterFace(ProfileModel? profileData) async {
    if (profileData?.modelData == null || profileData?.modelData == '') {
      context.router.push(RegisterFaceRoute());
      return;
    }
  }

  void _getEmployeeDetail() async {
    await ref.read(employeeDetailNotifierProvider.notifier).getEmployeeDetail();
    final state = ref.read(employeeDetailNotifierProvider);

    if (state.state == ConcreteState.loaded) {
      _updateDeviceInfo(state.data?.employeeId ?? '');
      _startTracking();
      _getReminder(state.data);
    }
  }

  void _getReminder(EmployeeDetailModel? employeeDetail) async {
    await ref.read(localDataNotifierProvider.notifier).getIsReminder();
    final state = ref.read(localDataNotifierProvider);

    if (state.state == ConcreteState.loaded) {
      if (state.data == true) {
        String groupShiftScheduleConvert = jsonEncode(
          (employeeDetail?.groupShiftSchedules ?? [])
              .map((e) => e.toJson())
              .toList(),
        );
        await ref
            .read(localDataNotifierProvider.notifier)
            .getGroupShiftSchedule();
        final stateGroupShift = ref.read(localDataNotifierProvider);

        if (stateGroupShift.state == ConcreteState.loaded) {
          String groupShiftScheduleLocalData = stateGroupShift.data ?? '';
          if (!isSameJson(
            groupShiftScheduleLocalData,
            groupShiftScheduleConvert,
          )) {
            await ref
                .read(localDataNotifierProvider.notifier)
                .updateGroupShiftSchedule(groupShiftScheduleConvert);
            _registerShiftNotifications(
              employeeDetail ?? EmployeeDetailModel(),
            );
          }
        }
      }
    }
  }

  void _geProfile() async {
    await ref.read(profileNotifierProvider.notifier).getProfile();
    final state = ref.read(profileNotifierProvider);

    if (state.state == ConcreteState.loaded) {
      _checkRegisterFace(state.data);
      _getAttendanceList(state.data?.userId ?? '');
      _getGroupShiftSchedule(state.data?.userId ?? '');
      setState(() {
        _profileUrl = state.data?.profileUrl;
        final fullName = state.data?.name ?? 'Unknown';
        _fullName = fullName;
        _initialName = fullName[0].toUpperCase();
      });
    }
  }

  void _updateDeviceInfo(String employeeId) async {
    _getAllPackages();
    await _getDeviceInfo();
    await _getTelephoneInfo();
    String deviceId = await _getDeviceIMEI();
    await _getSimInfo();
    await _checkPermissionAndLoadApps();
    await ref
        .read(deviceInfoNotifierProvider.notifier)
        .insertDeviceInfo(
          DeviceInfoModel(
            deviceId: deviceId,
            employeeId: employeeId,
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
    await ref.read(localDataNotifierProvider.notifier).getIsOpenUsageApps();
    final state = ref.read(localDataNotifierProvider);

    if (state.state == ConcreteState.loaded) {
      if (state.data == false) {
        final hasPermission = await AppUsageService.hasUsagePermission();
        if (!hasPermission) {
          await AppUsageService.openUsageSettings();
          await ref
              .read(localDataNotifierProvider.notifier)
              .updateOpenUsageApps(true);
          return;
        }
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

  bool isSameJson(String a, String b) {
    return a == b;
  }

  void _getAttendanceList(String userId) async {
    await ref
        .read(attendanceListNotifierProvider.notifier)
        .getAttendanceList(
          ListDataRequest(
            page: 0,
            limit: 5,
            search: "",
            sortBy: "created",
            orderBy: "desc",
            filter: {"employee_id": userId},
          ),
        );
    final state = ref.read(attendanceListNotifierProvider);

    if (state.state == ConcreteState.loaded) {
      List<AbsenceHistoryModel> data = state.data ?? [];
      LogHelper.logDebug('data Attendance $data');
      if (data.isNotEmpty) {
        LogHelper.logDebug('data ${data[0]}');
        String timeIn = data[0].timeIn ?? '';
        String timeOut = data[0].timeOut ?? '';
        setState(() {
          _isCheckin = timeOut != '' ? false : true;
        });
        //         await _inOutProvider.deleteInOutLocal();
        //         await _inOutProvider.fetchCheckInLocal();
        // bool isTodayGreater = DateTime(today.year, today.month, today.day)
        //             .isAtSameMomentAs(
        //               DateTime(dateTime.year, dateTime.month, dateTime.day),
        //             );
        //         setState(() {
        //           _isCheckin = !isTodayGreater;
        //         });
        DateTime dateTimeIn;
        DateTime today = DateTime.now();
        try {
          dateTimeIn = DateTime.parse(timeIn);

          final diff = today.difference(dateTimeIn);
          final diffHours = diff.inHours;
          final diffMinutes = diff.inMinutes.remainder(60);

          setState(() {
            _timeCheckIn = dateTimeIn.formatTime();
            _timeElapsed = '${diffHours}h ${diffMinutes}m';
          });
        } catch (e) {
          setState(() {
            _isCheckin = false;
          });
        }
      } else {
        setState(() {
          _isCheckin = false;
        });
      }
    }
  }

  void _getGroupShiftSchedule(String userId) async {
    await ref
        .read(groupShiftListNotifierProvider.notifier)
        .getGroupShiftSchedule(
          ListDataRequest(
            page: 0,
            limit: 10,
            search: "",
            sortBy: "created",
            orderBy: "desc",
            filter: {"employee_id": userId},
          ),
        );
    final state = ref.read(groupShiftListNotifierProvider);

    if (state.state == ConcreteState.loaded) {
      List<GroupShiftScheduleResponse> data = state.data ?? [];
      LogHelper.logDebug('data groupShift schedule $data');
      DateTime today = DateTime.now();
      final dayId = today.weekday % 7;
      String endTime = '';
      LogHelper.logDebug('dayId $dayId');
      if (data.isNotEmpty) {
        for (var item in data) {
          LogHelper.logDebug(
            'busines_day_id: ${item.businessDay?.businessDayId}',
          );
          if (endTime == '') {
            if (item.businessDay?.businessDayId == dayId) {
              endTime = item.shiftEndTime ?? '';
            }
          }
        }
      }

      final remaining = getRemainingToEndTime(endTime);

      final hours = remaining.inHours;
      final minutes = remaining.inMinutes % 60;

      setState(() {
        _remaining = '${hours}h ${minutes}m';
      });
    }
  }

  Duration getRemainingToEndTime(String endTime) {
    final now = DateTime.now();

    final endParts = endTime.split(':');
    final endHour = int.parse(endParts[0]);
    final endMinute = int.parse(endParts[1]);

    var endDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      endHour,
      endMinute,
    );

    if (endDateTime.isBefore(now)) {
      endDateTime = endDateTime.add(const Duration(days: 1));
    }

    return endDateTime.difference(now);
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
      body: RefreshIndicator(
        onRefresh: () async => _onRefresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.only(top: 40, bottom: 20, left: 20, right: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    AppImageProfileRounded(
                      width: 42,
                      height: 42,
                      profileUrl: _profileUrl != null && _profileUrl != ""
                          ? "https://inout-dev.2ndc.app/thumbnail/$_profileUrl"
                          : "",
                      initialName: _initialName ?? '',
                    ),
                    SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Hey ${_fullName ?? '-'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppFont.fontMontserrat,
                          ),
                        ),
                        Text(
                          'Let\'s explore what you can do today!',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            fontFamily: AppFont.fontMontserrat,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.greyCardHome,
                    border: Border.all(color: AppColors.greyBorder, width: 1),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Padding(
                    padding: EdgeInsetsGeometry.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(Assets.icChecklistCircle, width: 40),
                        Text(
                          'Current Status',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.greyDarkTextHome,
                            fontWeight: FontWeight.w500,
                            fontFamily: AppFont.fontMontserrat,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: _isCheckin
                                ? AppColors.greenColors
                                : AppColors.redColors,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            child: Text(
                              _isCheckin ? 'Checked In' : 'Checked Out',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.whiteColor,
                                fontWeight: FontWeight.w600,
                                fontFamily: AppFont.fontMontserrat,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.greyCardHome,
                    border: Border.all(color: AppColors.greyBorder, width: 1),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Padding(
                    padding: EdgeInsetsGeometry.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(Assets.icCheckinHistory, width: 40),
                        Text(
                          'Time Checkin',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.greyDarkTextHome,
                            fontWeight: FontWeight.w500,
                            fontFamily: AppFont.fontMontserrat,
                          ),
                        ),
                        Text(
                          _timeCheckIn,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.greyDarkTextHome,
                            fontWeight: FontWeight.w500,
                            fontFamily: AppFont.fontMontserrat,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.greyCardHome,
                    border: Border.all(color: AppColors.greyBorder, width: 1),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Padding(
                    padding: EdgeInsetsGeometry.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(Assets.icTimeElapsed, width: 40),
                        Text(
                          'Time Elapsed',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.greyDarkTextHome,
                            fontWeight: FontWeight.w500,
                            fontFamily: AppFont.fontMontserrat,
                          ),
                        ),
                        Text(
                          _timeElapsed,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.greyDarkTextHome,
                            fontWeight: FontWeight.w500,
                            fontFamily: AppFont.fontMontserrat,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.greyCardHome,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Padding(
                          padding: EdgeInsetsGeometry.only(
                            left: 20,
                            right: 10,
                            top: 15,
                            bottom: 15,
                          ),
                          child: Row(
                            children: [
                              Image.asset(Assets.icTimeStamp, width: 60),
                              SizedBox(width: 15),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Remaining',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.greyDarkTextHome,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: AppFont.fontMontserrat,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    _remaining,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.black,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: AppFont.fontMontserrat,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.greyCardHome,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Padding(
                          padding: EdgeInsetsGeometry.only(
                            left: 20,
                            right: 10,
                            top: 15,
                            bottom: 15,
                          ),
                          child: Row(
                            children: [
                              Image.asset(Assets.icStreak, width: 60),
                              SizedBox(width: 15),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Streak',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.greyDarkTextHome,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: AppFont.fontMontserrat,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    '12 days',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.black,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: AppFont.fontMontserrat,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.greyCardHome,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Padding(
                          padding: EdgeInsetsGeometry.only(
                            left: 20,
                            right: 10,
                            top: 15,
                            bottom: 15,
                          ),
                          child: Row(
                            children: [
                              Image.asset(Assets.icGraph, width: 60),
                              SizedBox(width: 15),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'This Week',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.greyDarkTextHome,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: AppFont.fontMontserrat,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    '38 h',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.black,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: AppFont.fontMontserrat,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.greyCardHome,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Padding(
                          padding: EdgeInsetsGeometry.only(
                            left: 20,
                            right: 10,
                            top: 15,
                            bottom: 15,
                          ),
                          child: Row(
                            children: [
                              Image.asset(Assets.icChart, width: 60),
                              SizedBox(width: 15),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'This Month',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.greyDarkTextHome,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: AppFont.fontMontserrat,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    '12 days',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.black,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: AppFont.fontMontserrat,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.greyCardHome,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Padding(
                          padding: EdgeInsetsGeometry.only(
                            left: 20,
                            right: 10,
                            top: 15,
                            bottom: 15,
                          ),
                          child: Row(
                            children: [
                              Image.asset(Assets.icHistory, width: 60),
                              SizedBox(width: 15),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'On Time',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.greyDarkTextHome,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: AppFont.fontMontserrat,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    '5 Days',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.black,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: AppFont.fontMontserrat,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.greyCardHome,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Padding(
                          padding: EdgeInsetsGeometry.only(
                            left: 20,
                            right: 10,
                            top: 15,
                            bottom: 15,
                          ),
                          child: Row(
                            children: [
                              Image.asset(Assets.icReport, width: 60),
                              SizedBox(width: 15),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Late',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.greyDarkTextHome,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: AppFont.fontMontserrat,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    '12 days',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.black,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: AppFont.fontMontserrat,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: AppButton(
                        buttonName: "Check In",
                        isDisabled: _isCheckin,
                        color: AppColors.greenColors,
                        onPress: () async {
                          final onResume = await context.router.push(
                            AbsenceRoute(showBackButton: true),
                          );

                          if (onResume == true) {
                            _onRefresh();
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      flex: 1,
                      child: AppButton(
                        buttonName: "Check Out",
                        isDisabled: !_isCheckin,
                        color: AppColors.redColors,
                        onPress: () async {
                          final onResume = await context.router.push(
                            AbsenceRoute(showBackButton: true),
                          );

                          if (onResume == true) {
                            _onRefresh();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
