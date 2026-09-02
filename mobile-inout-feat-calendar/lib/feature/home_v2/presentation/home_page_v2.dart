// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'dart:developer';
import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'package:auto_route/auto_route.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:disable_battery_optimizations_latest/disable_battery_optimizations_latest.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_device_apps/flutter_device_apps.dart';
import 'package:flutter_device_imei/flutter_device_imei.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sim_info/flutter_sim_info.dart';
import 'package:intl/intl.dart';
import 'package:mobile_in_out/core/resources/constants/app_font.dart';
import 'package:mobile_in_out/core/resources/constants/assets.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/routes/router_import.dart';
import 'package:mobile_in_out/core/routes/router_import.gr.dart';
import 'package:mobile_in_out/core/utils/base_state/base_state.dart';
import 'package:mobile_in_out/core/utils/extensions/date_extension.dart';
import 'package:mobile_in_out/core/utils/helper/alarm_service.dart';
import 'package:mobile_in_out/core/utils/helper/location_helper.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';
import 'package:mobile_in_out/core/utils/helper/notification_service.dart';
import 'package:mobile_in_out/core/utils/localizations/app_translations.dart';
import 'package:mobile_in_out/core/utils/models/check_in/check_in_response_model.dart';
import 'package:mobile_in_out/core/utils/models/history/absence_history_model.dart';
import 'package:mobile_in_out/core/utils/models/list_data_request.dart';
import 'package:mobile_in_out/core/utils/widgets/app_bar_icons_center.dart';
import 'package:mobile_in_out/core/utils/widgets/app_button.dart';
import 'package:mobile_in_out/core/utils/widgets/app_image_profile_rounded.dart';
import 'package:mobile_in_out/feature/app_usage/presentation/app_usage_service.dart';
import 'package:mobile_in_out/feature/backround_process/presentation/background_service.dart'
    as bs;
import 'package:mobile_in_out/feature/history/model/group_shift_schedule_response.dart';
import 'package:mobile_in_out/feature/home_v2/data/model/device_info_model.dart';
import 'package:mobile_in_out/feature/home_v2/data/model/employee_detail_model.dart';
import 'package:mobile_in_out/feature/home_v2/data/model/profile_model.dart';
import 'package:mobile_in_out/feature/home_v2/presentation/provider/home_v2_state_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telephony_info_plus/telephony_info_plus.dart';

@RoutePage()
class HomePageV2 extends ConsumerStatefulWidget {
  final bool? isFromSignIn;
  const HomePageV2({super.key, this.isFromSignIn = false});

  @override
  ConsumerState<HomePageV2> createState() => _HomePageV2State();
}

class _HomePageV2State extends ConsumerState<HomePageV2>
    with WidgetsBindingObserver, RouteAware {
  late final RouterObserver _routerObserver;
  bool isFaceRegister = false;
  bool _isFromSignInPage = false;

  bool _isPopBack = false;
  bool _isOnResume = false;
  bool _isCheckin = false;
  bool _isLoadingCheckin = false;
  bool _isRefresh = false;
  String? _profileUrl;
  String? _initialName;
  String? _fullName;
  String _timeCheckIn = '';
  String _timeCheckOut = '';
  String _timeElapsed = '';
  String _remaining = '';
  String _checkInId = '';
  String _scheduleCheckIn = '';
  String _scheduleCheckOut = '';
  String _late = '-';
  String _onTime = '-';
  String _workDayThisMonth = '-';
  String _totalHoursThisWeek = '-';
  String _streak = '-';
  final int _alarmDistance = 5;
  bool _isBatteryOptimDisabled = false;

  Map<String, dynamic> deviceData = {};
  String? imei;
  String? imsi;
  final _telephonyInfoPlusPlugin = TelephonyInfoPlus();

  @override
  void initState() {
    super.initState();

    _isFromSignInPage = widget.isFromSignIn ?? false;
    _routerObserver = RouterObserver();
    WidgetsBinding.instance.addObserver(this);

    init();
  }

  void init() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _isPopBack = false;
      _isOnResume = false;
      if (_isFromSignInPage == false) {
        await _checkAndRequestBatteryOptimization();
        await _checkPermissionLocation();
      }
      await _getEmployeeDetail();
      await _getProfile();
    });
  }

  Future<void> _onRefresh() async {
    if (_isFromSignInPage == false) {
      await _checkAndRequestBatteryOptimization();
      await _checkPermissionLocation();
    }
    setState(() {
      _isLoadingCheckin = false;
    });
    await _getEmployeeDetail();
    await _getProfile();
    setState(() {
      _isRefresh = true;
    });
  }

  Future<void> _startTracking() async {
    if (!mounted) return;

    await ref.read(localDataNotifierProvider.notifier).getToken();
    final state = ref.read(localDataNotifierProvider);

    if (!mounted) return;

    if (state.state == ConcreteState.loaded) {
      final token = state.data;
      final service = FlutterBackgroundService();
      bool isRunning = await service.isRunning();

      if (!isRunning) {
        await service.startService();
      }
      log(
        "================= BACKGROUND SERVICE IS ${isRunning ? '' : 'NOT'} 'RUNNING' From home Token:$token =================",
      );
      service.invoke("taskUpdateToken", {"token": token});
      service.invoke("startTaskTrackingLocation", {"token": token});
    }
  }

  Future<void> _registerShiftNotifications(EmployeeDetailModel employee) async {
    if (!mounted) return;

    final schedules = employee.groupShiftSchedules ?? [];

    if (schedules.isEmpty) {
      return;
    }

    final status = await Permission.notification.status;
    if (!status.isGranted) return;

    if (!mounted) return;

    await NotificationService.cancelAll();
    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

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
        title: AppTranslations.translate('selamat_berkerja'),
        body: AppTranslations.translate('jangan_lupa_absen_masuk'),
        channel: "shift_checkin_$weekday",
        descChannel: "Shift Checkin",
      );

      await NotificationService.scheduleWeekly(
        weekday: int.tryParse(weekday) ?? 0,
        hour: endHour,
        minute: endMinute,
        title: AppTranslations.translate('waktunya_pulang'),
        body: AppTranslations.translate('jangan_lupa_absen_pulang'),
        channel: "shift_checkout_$weekday",
        descChannel: "Shift Checkout",
      );
    }
  }

  Future<void> _checkRegisterFace(ProfileModel? profileData) async {
    if (!mounted) return;

    if (profileData?.modelData == null || profileData?.modelData == '') {
      // disable check register face, because before sign in user must be register face
      // if (!mounted) return;
      // context.router.replace(RegisterFaceRoute());
      // return;

      setState(() {
        isFaceRegister = false;
      });
    } else {
      LogHelper.logDebug(
        'debug -> check Log faceregister profile model data ${profileData?.modelData}',
      );
      LogHelper.logDebug('debug -> _isFromSignInPage $_isFromSignInPage');
      setState(() {
        isFaceRegister = true;
      });
      if (_isFromSignInPage == true) {
        _isFromSignInPage = false;
        await Future.delayed(Duration.zero);
        if (!context.mounted) return;
        final isReady = await LocationHelper.checkAndEnableLocation();
        if (isReady) {
          final onResume = await context.router.push(
            AbsenceRoute(showBackButton: true),
          );
          if (onResume == true) _onRefresh();
        }
      }
    }
  }

  Future<void> _getEmployeeDetail() async {
    if (!mounted) return;

    await ref.read(employeeDetailNotifierProvider.notifier).getEmployeeDetail();
    if (!mounted) return;

    final state = ref.read(employeeDetailNotifierProvider);

    if (state.state == ConcreteState.loaded) {
      String employeeDetailConvert = jsonEncode(state.data?.toJson());
      await ref
          .read(localDataNotifierProvider.notifier)
          .saveEmployeeDetail(employeeDetailConvert);

      if (!mounted) return;
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await _getDashboardSummary(state.data?.employeeId ?? '', today);
      if (_isFromSignInPage == false) {
        await _updateDeviceInfo(state.data?.employeeId ?? '');
        await _startTracking();
        await _getReminder(state.data);
      }
    }
  }

  Future<void> _getReminder(EmployeeDetailModel? employeeDetail) async {
    if (!mounted) return;

    await ref.read(localDataNotifierProvider.notifier).getIsReminder();
    if (!mounted) return;

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
        if (!mounted) return;

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

  Future<void> _getProfile() async {
    if (!mounted) return;

    await ref.read(profileNotifierProvider.notifier).getProfile();

    if (!mounted) return;

    final state = ref.read(profileNotifierProvider);

    if (!mounted) return;

    if (state.state == ConcreteState.loaded) {
      String profileConvert = jsonEncode(state.data);
      await ref
          .read(localDataNotifierProvider.notifier)
          .saveProfile(profileConvert);

      LogHelper.logDebug(
        'debug -> check Log profile model data ${state.data?.modelData}',
      );
      if (!mounted) return;
      await _checkRegisterFace(state.data);

      if (!mounted) return;

      if (_isFromSignInPage == false) {
        await _getAttendanceList(state.data?.userId ?? '');
        _getGroupShiftSchedule(state.data?.userId ?? '');
      }

      if (mounted) {
        setState(() {
          _profileUrl = state.data?.profileUrl;
          final fullName = state.data?.name ?? 'Unknown';
          _fullName = fullName;
          _initialName = fullName[0].toUpperCase();
        });
      }
    }
  }

  Future<void> _getDashboardSummary(String employeeId, String month) async {
    if (!mounted) return;

    await ref
        .read(dashboardSummaryNotifierProvider.notifier)
        .getDashboardSummary(employeeId, month);

    if (!mounted) return;

    final state = ref.read(dashboardSummaryNotifierProvider);

    if (!mounted) return;

    if (state.state == ConcreteState.loaded) {
      if (mounted) {
        setState(() {
          _late =
              '${(state.data?.late ?? 0).toString()} ${AppTranslations.translate('days').toLowerCase()}';
          _onTime =
              '${(state.data?.onTime ?? 0).toString()} ${AppTranslations.translate('days').toLowerCase()}';
          _workDayThisMonth =
              '${(state.data?.workDayThisMonth ?? 0).toString()} ${AppTranslations.translate('days').toLowerCase()}';
          _totalHoursThisWeek =
              '${(state.data?.totalHoursThisWeek ?? 0).toString()} h';
          _streak =
              '${(state.data?.streak ?? 0).toString()} ${AppTranslations.translate('days').toLowerCase()}';
        });
      }
    }
  }

  Future<void> _updateDeviceInfo(String employeeId) async {
    if (!mounted) return;

    _getAllPackages();
    await _getDeviceInfo();
    if (!mounted) return;

    await _getTelephoneInfo();
    if (!mounted) return;

    String deviceId = await _getDeviceIMEI();
    if (!mounted) return;

    await _getSimInfo();
    if (!mounted) return;

    await _checkPermissionAndLoadApps();
    if (!mounted) return;

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

    if (!mounted) return;

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
    if (!mounted) return;

    var status = await Permission.phone.request();
    if (!status.isGranted) return;

    try {
      final info = await _telephonyInfoPlusPlugin.getSimInfos();
      if (!mounted) return;
      deviceData = {...deviceData, 'infoSim': info};
    } catch (e) {}
  }

  Future<String> _getDeviceIMEI() async {
    String? imei = await FlutterDeviceImei.instance.getIMEI();
    return imei ?? '';
  }

  Future<void> _getSimInfo() async {
    if (!mounted) return;

    List<SimInfo>? simNumber = await FlutterSimInfo.getSimInfo();
    if (!mounted) return;
    deviceData = {...deviceData, 'simNumber': simNumber};
  }

  Future<void> _checkPermissionAndLoadApps() async {
    if (!mounted) return;

    await ref.read(localDataNotifierProvider.notifier).getIsOpenUsageApps();
    final state = ref.read(localDataNotifierProvider);

    if (!mounted) return;

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
    if (!mounted) return;

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
    if (!mounted) return;

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
    if (!mounted) return;

    final newestApps = (await _getNewestInstalledApps()).take(10).toList();
    if (!mounted) return;

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

    if (apps.isEmpty) return [];

    apps.sort((a, b) => b.firstInstallTime!.compareTo(a.firstInstallTime!));
    return apps;
  }

  bool isSameJson(String a, String b) => a == b;

  Future<void> _getAttendanceList(String userId) async {
    if (!mounted) return;

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

    if (!mounted) return;

    final state = ref.read(attendanceListNotifierProvider);

    if (!mounted) return;

    if (state.state == ConcreteState.loaded) {
      List<AbsenceHistoryModel> data = state.data ?? [];

      await ref.read(localDataNotifierProvider.notifier).fetchCheckInLocal();

      if (!mounted) return;

      final stateFetchLocal = ref.read(localDataNotifierProvider);

      if (stateFetchLocal.state == ConcreteState.loaded) {
        CheckInResponseModel dataCheckin = stateFetchLocal.data;
        if (mounted) {
          setState(() {
            _checkInId = dataCheckin.absensiId ?? '';
          });
        }

        if (data.isNotEmpty) {
          if (dataCheckin.absensiId != data.first.attendanceId) {
            if (data.isNotEmpty) {
              if (data.first.status == 'IN') {
                final dataCheckin = CheckInResponseModel(
                  absensiId: data.first.attendanceId,
                  employeeId: data.first.employeeId,
                  timeIn: data.first.dateIn,
                  latitudeIn: data.first.latitudeIn,
                  longitudeIn: data.first.longitudeIn,
                  addressIn: data.first.addressIn,
                  noteIn: data.first.noteIn,
                  created: data.first.created,
                );
                await ref
                    .read(localDataNotifierProvider.notifier)
                    .saveCheckInLocal(dataCheckin);
              }
            }
          }
        }
      }
      if (data.isNotEmpty) {
        String timeIn = data.first.dateIn ?? '';
        String timeOut = data.first.dateOut ?? '';
        if (mounted) {
          setState(() {
            _isCheckin = data.first.status == 'IN' ? true : false;
            _isLoadingCheckin = true;
          });
        }

        DateTime dateTimeIn;
        DateTime dateTimeOut;
        DateTime today = DateTime.now();
        try {
          if (timeIn != '') {
            dateTimeIn = DateTime.parse(timeIn);
            final diff = today.difference(dateTimeIn);
            final diffHours = diff.inHours;
            final diffMinutes = diff.inMinutes.remainder(60);
            if (mounted) {
              setState(() {
                _timeCheckIn = dateTimeIn.formatTime();
                _timeElapsed = '${diffHours}h ${diffMinutes}m';
              });
            }
          }

          if (timeOut != '') {
            dateTimeOut = DateTime.parse(timeOut);
            if (mounted) {
              setState(() {
                _timeCheckOut = dateTimeOut.formatTime();
              });
            }
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _isCheckin = false;
              _isLoadingCheckin = true;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isCheckin = false;
            _isLoadingCheckin = true;
          });
        }
      }
    }
  }

  Future<void> _getGroupShiftSchedule(String userId) async {
    if (!mounted) return;

    final notifier = ref.read(groupShiftListNotifierProvider.notifier);

    await notifier.getGroupShiftSchedule(
      ListDataRequest(
        page: 0,
        limit: 10,
        search: "",
        sortBy: "created",
        orderBy: "desc",
        filter: {"employee_id": userId},
      ),
    );

    if (!mounted) return;

    // ambil state dari notifier langsung (lebih aman)
    final state = notifier.state;

    if (state.state != ConcreteState.loaded) return;

    final data = state.data ?? [];
    final today = DateTime.now();
    final dayId = today.weekday % 7;

    final matched = data.firstWhere(
      (item) => item.businessDay?.businessDayId == dayId,
      orElse: () => GroupShiftScheduleResponse(),
    );

    final endTime = matched.shiftEndTime ?? '';

    if (endTime.isEmpty || !_isCheckin) {
      setState(() => _remaining = '-');
      return;
    }

    final remaining = _getRemainingToEndTime(endTime);
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;

    setState(() {
      _scheduleCheckIn = matched.shiftStartTime ?? '';
      _scheduleCheckOut = matched.shiftEndTime ?? '';
      _remaining = '${hours}h ${minutes}m';
    });
  }

  Duration _getRemainingToEndTime(String endTime) {
    final now = DateTime.now();

    final endParts = endTime.split(':');
    final endHour = int.tryParse(endParts[0]) ?? 0;
    final endMinute = int.tryParse(endParts[1]) ?? 0;

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
    final route = ModalRoute.of(context);
    if (route != null) {
      _routerObserver.subscribe(this, route);
    }
    if (route != null) {
      var contextData = ModalRoute.of(context)!;
      _routerObserver.subscribe(this, contextData);
      if (_isPopBack == true) {
        // _checkAndRequestBatteryOptimization();
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
    _routerObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (_isOnResume) {
          _checkAndRequestBatteryOptimization();
          _checkPermissionLocation();
          _ensureBackgroundServiceRunning();
          _isOnResume = false;
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _isOnResume = true;
        break;
      default:
        break;
    }
  }

  Widget _buildLayout() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 40, bottom: 20, left: 20, right: 20),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 20),

          _buildStatusCard(),
          const SizedBox(height: 12),

          _buildTimeCard(
            icon: Assets.icCheckinHistory,
            title: _isCheckin
                ? AppTranslations.translate('time_checkin')
                : AppTranslations.translate('time_checkout'),
            value: _isCheckin ? _timeCheckIn : _timeCheckOut,
          ),
          const SizedBox(height: 12),

          _buildTimeCard(
            icon: Assets.icTimeElapsed,
            title: AppTranslations.translate('time_elapsed'),
            value: _timeElapsed,
          ),
          const SizedBox(height: 12),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.3,
            children: [
              _buildMiniCard(
                icon: Assets.icTimeStamp,
                title: AppTranslations.translate('remaining'),
                value: _remaining,
              ),
              _buildMiniCard(
                icon: Assets.icStreak,
                title: AppTranslations.translate('streak'),
                value: _streak,
              ),
              _buildMiniCard(
                icon: Assets.icGraph,
                title: AppTranslations.translate('this_week'),
                value: _totalHoursThisWeek,
              ),
              _buildMiniCard(
                icon: Assets.icChart,
                title: AppTranslations.translate('this_month'),
                value: _workDayThisMonth,
              ),
              _buildMiniCard(
                icon: Assets.icHistory,
                title: AppTranslations.translate('on_time'),
                value: _onTime,
              ),
              _buildMiniCard(
                icon: Assets.icReport,
                title: AppTranslations.translate('late'),
                value: _late,
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsetsGeometry.only(left: 20, right: 20, bottom: 20),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              buttonName: AppTranslations.translate('check_in'),
              isDisabled: _isCheckin || !_isLoadingCheckin,
              color: AppColors.greenColors,
              onPress: () async {
                if (isFaceRegister == false) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppTranslations.translate(
                            'please_register_face_first',
                          ),
                        ),
                        backgroundColor: AppColors.redColors,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                } else {
                  final isReady = await LocationHelper.checkAndEnableLocation();
                  if (isReady) {
                    final onResume = await context.router.push(
                      AbsenceRoute(showBackButton: true),
                    );
                    if (onResume == true) _onRefresh();
                  }
                }
              },
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: AppButton(
              buttonName: AppTranslations.translate('check_out'),
              isDisabled: !_isCheckin || !_isLoadingCheckin,
              color: AppColors.redColors,
              onPress: () async {
                if (isFaceRegister == false) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppTranslations.translate(
                            'please_register_face_first',
                          ),
                        ),
                        backgroundColor: AppColors.redColors,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                } else {
                  final isReady = await LocationHelper.checkAndEnableLocation();
                  if (isReady) {
                    final onResume = await context.router.push(
                      AbsenceRoute(showBackButton: true),
                    );
                    if (onResume == true) _onRefresh();
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarIconCenter(),
      body: SafeArea(
        child: RefreshIndicator(onRefresh: _onRefresh, child: _buildLayout()),
      ),
      bottomNavigationBar: _buildActionButtons(),
    );
  }

  Future<void> _ensureBackgroundServiceRunning() async {
    await bs.BackgroundService.startService();
  }

  // ===========================
  // UI HELPERS
  // ===========================

  Widget _buildHeader() {
    return Row(
      children: [
        AppImageProfileRounded(
          width: 42,
          height: 42,
          profileUrl: _profileUrl != null && _profileUrl != ""
              ? "https://inout-dev.2ndc.app/thumbnail/$_profileUrl"
              : "",
          initialName: _initialName ?? '',
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppTranslations.translate('hey')} ${_fullName ?? '-'}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFont.fontMontserrat,
                ),
              ),
              Text(
                AppTranslations.translate('lets_explore'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  fontFamily: AppFont.fontMontserrat,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.greyCardHome,
        border: Border.all(color: AppColors.greyBorder, width: 1),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(Assets.icChecklistCircle, width: 40),
          Text(
            AppTranslations.translate('current_status'),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.greyDarkTextHome,
              fontWeight: FontWeight.w500,
              fontFamily: AppFont.fontMontserrat,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: _isCheckin ? AppColors.greenColors : AppColors.redColors,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            child: Text(
              _isCheckin
                  ? AppTranslations.translate('checked_in')
                  : AppTranslations.translate('checked_out'),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.whiteColor,
                fontWeight: FontWeight.w600,
                fontFamily: AppFont.fontMontserrat,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard({
    required String icon,
    required String title,
    required String value,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.greyCardHome,
        border: Border.all(color: AppColors.greyBorder, width: 1),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(icon, width: 40),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.greyDarkTextHome,
              fontWeight: FontWeight.w500,
              fontFamily: AppFont.fontMontserrat,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.greyDarkTextHome,
              fontWeight: FontWeight.w500,
              fontFamily: AppFont.fontMontserrat,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCard({
    required String icon,
    required String title,
    required String value,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.greyCardHome,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Image.asset(icon, width: 42),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.greyDarkTextHome,
                    fontWeight: FontWeight.w500,
                    fontFamily: AppFont.fontMontserrat,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.black,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFont.fontMontserrat,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================
  // PERMISSIONS
  // ===========================

  Future<void> _checkAndRequestBatteryOptimization() async {
    bool isBatteryOptimizationDisabled =
        await DisableBatteryOptimizationLatest.isBatteryOptimizationDisabled ??
        false;
    bool isManBatteryOptimizationDisabled =
        await DisableBatteryOptimizationLatest
            .isManufacturerBatteryOptimizationDisabled ??
        false;

    if (mounted) {
      setState(() {
        _isBatteryOptimDisabled = isBatteryOptimizationDisabled;
      });
    }

    if (!isBatteryOptimizationDisabled) {
      if (isManBatteryOptimizationDisabled) {
        _showBatteryOptimizationDialog();
      }
    }
  }

  void _showBatteryOptimizationDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppTranslations.translate('battery_optimization')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppTranslations.translate('battery_optimization_desc')),
              const SizedBox(height: 12),
              Text(
                AppTranslations.translate('battery_warning_desc'),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppTranslations.translate('cancel')),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _openBatteryOptimizationSettings();
              },
              child: Text(AppTranslations.translate('go_to_settings')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openBatteryOptimizationSettings() async {
    await DisableBatteryOptimizationLatest.showDisableBatteryOptimizationSettings();
  }

  Future<void> _checkPermissionLocation() async {
    PermissionStatus status = await Permission.locationAlways.status;
    if (!status.isGranted) {
      _requestLocationPermission(
        AppTranslations.translate('location_permission_required'),
        AppTranslations.translate('location_permission_desc'),
        '',
      );
    }
  }

  Future<void> _requestLocationPermission(title, message_1, message_2) async {
    Future.delayed(const Duration(microseconds: 3000), () {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message_1),
                if (message_2.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(message_2, style: const TextStyle(color: Colors.red)),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await openAppSettings();
                  Navigator.pop(context);
                },
                child: Text(AppTranslations.translate('go_to_settings')),
              ),
            ],
          );
        },
      );
    });
  }

  // ===========================
  // ALARM (as-is)
  // ===========================

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

    if (schedules.isEmpty) return;

    final status = await Permission.notification.status;
    if (!status.isGranted) return;

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
