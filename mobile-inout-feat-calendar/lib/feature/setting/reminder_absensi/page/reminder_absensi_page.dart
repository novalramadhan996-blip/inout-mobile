import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mobile_in_out/core/resources/injector/di.dart';
import 'package:mobile_in_out/core/resources/local/pref_service.dart';
import 'package:mobile_in_out/core/resources/theme/app_style.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';
import 'package:mobile_in_out/core/utils/helper/notification_service.dart';
import 'package:mobile_in_out/core/utils/localizations/app_translations.dart';
import 'package:mobile_in_out/core/utils/widgets/app_bar_general.dart';
import 'package:mobile_in_out/core/utils/widgets/app_button.dart';
import 'package:mobile_in_out/feature/home/data/model/employee_detail_model.dart';
import 'package:mobile_in_out/feature/home/presentation/provider/home_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

@RoutePage()
class ReminderAbsensiPage extends StatefulWidget {
  const ReminderAbsensiPage({super.key});

  @override
  State<ReminderAbsensiPage> createState() => _ReminderAbsensiPageState();
}

class _ReminderAbsensiPageState extends State<ReminderAbsensiPage> {
  bool isActive = false;
  int? selectedBefore;
  final List<int> labelOptions = [5, 10, 15, 20];

  EmployeeDetailModel? employeeDetail;

  late HomeProvider _homeProvider;
  late final ShardPrefService _prefService;

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
        await _prefService.setString(
          PrefServiceKey.groupShiftSchedule,
          groupShiftScheduleConvert,
        );
        _registerShiftNotifications(employeeDetail ?? EmployeeDetailModel());
      }
    });
  }

  bool isSameJson(String a, String b) {
    return a == b;
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
        delayMinutes: selectedBefore ?? 0,
      );

      await NotificationService.scheduleWeekly(
        weekday: int.tryParse(weekday) ?? 0,
        hour: endHour,
        minute: endMinute,
        title: AppTranslations.translate('waktunya_pulang'),
        body: AppTranslations.translate('jangan_lupa_absen_pulang'),
        channel: "shift_checkout_$weekday",
        descChannel: "Shift Checkout",
        delayMinutes: selectedBefore ?? 0,
      );
    }

    await _prefService.setBool(PrefServiceKey.isReminder, true);
    await _prefService.setInt(PrefServiceKey.delayAbsensi, selectedBefore ?? 0);

    if (mounted) context.router.pop();
  }

  @override
  void initState() {
    _homeProvider = Provider.of<HomeProvider>(context, listen: false);
    _prefService = sl<ShardPrefService>();
    super.initState();
    _getReminder();
  }

  void _getReminder() async {
    bool? selectReminder = await _prefService.getBool(
      PrefServiceKey.isReminder,
    );
    int? getDelayTime = await _prefService.getInt(PrefServiceKey.delayAbsensi);
    setState(() {
      isActive = selectReminder ?? false;
      selectedBefore = getDelayTime != 0 ? getDelayTime : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarGeneral(
        backgroundColor: AppColors.whiteColor,
        colorIcon: AppColors.primaryColor,
        styleTitle: AppStyle(
          color: AppColors.blackColor,
          weight: bold,
        ).headline2,
        colorTitle: AppColors.blackColor,
        title: AppTranslations.translate('reminder_attendance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle aktif
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppTranslations.translate('activate_reminder'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Switch(
                  inactiveTrackColor: Colors.grey.shade300,
                  inactiveThumbColor: Colors.grey.shade600,
                  value: isActive,
                  onChanged: (val) {
                    setState(() {
                      isActive = val;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 25),

            Text(
              AppTranslations.translate('delay_after_attendance_time'),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<int>(
                isExpanded: true,
                underline: const SizedBox(),
                hint: Text(AppTranslations.translate('select_minutes')),
                value: selectedBefore,
                icon: const Icon(Icons.arrow_drop_down),
                items: labelOptions.map((label) {
                  return DropdownMenuItem<int>(
                    value: label,
                    child: Text(
                      "${label} ${AppTranslations.translate('minutes')}",
                    ),
                  );
                }).toList(),
                onChanged: isActive
                    ? (value) {
                        setState(() {
                          selectedBefore = value;
                        });
                      }
                    : null,
              ),
            ),

            const SizedBox(height: 30),

            AppButton(
              buttonName: AppTranslations.translate('save'),
              onPress: () async {
                LogHelper.logDebug("before: $selectedBefore");
                LogHelper.logDebug("isactive: $isActive");
                if (isActive) {
                  _getEmployeeDetail();
                } else {
                  await NotificationService.cancelAll();
                  await _prefService.setBool(PrefServiceKey.isReminder, false);
                  await _prefService.setInt(PrefServiceKey.delayAbsensi, 0);
                  if (context.mounted) context.router.pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
