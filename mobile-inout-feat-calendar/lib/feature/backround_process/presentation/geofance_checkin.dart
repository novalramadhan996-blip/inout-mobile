import 'package:geolocator/geolocator.dart';
import 'package:mobile_in_out/core/resources/constants/app_const.dart';
import 'package:mobile_in_out/core/resources/injector/di.dart';
import 'package:mobile_in_out/core/resources/local/local_service.dart';
import 'package:mobile_in_out/core/resources/local/pref_service.dart';
import 'package:mobile_in_out/core/utils/helper/date_helper.dart';
import 'package:mobile_in_out/core/utils/helper/device_info_data.dart';
import 'package:mobile_in_out/core/utils/helper/location_helper.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';
import 'package:mobile_in_out/core/utils/helper/notification_service.dart';
import 'package:mobile_in_out/core/utils/models/check_in/check_in_requst_model.dart';
import 'package:mobile_in_out/core/utils/models/check_in/check_in_response_model.dart';
import 'package:mobile_in_out/core/utils/models/check_out/check_out_request_model.dart';
import 'package:mobile_in_out/core/utils/models/list_data_request.dart';
import 'package:mobile_in_out/feature/backround_process/domain/provider/background_provider.dart';
import 'package:mobile_in_out/feature/backround_process/presentation/location_tracker.dart';
import 'package:mobile_in_out/feature/history/model/group_shift_schedule_response.dart';
import 'package:mobile_in_out/core/utils/base_state/base_state.dart';
import 'package:mobile_in_out/core/utils/models/history/absence_history_model.dart';
import 'package:mobile_in_out/feature/home/data/model/employee_detail_model.dart';
import 'package:mobile_in_out/feature/home_v2/presentation/provider/home_v2_state_provider.dart'
    as home_v2_notifier;
import 'package:riverpod/riverpod.dart';

class GeofanceCheckin {
  static final DatabaseHelper db = DatabaseHelper.instance;
  static final ShardPrefService _prefService = sl<ShardPrefService>();

  static Future<void> fetchEmployeeDetailInBackground() async {
    final container = ProviderContainer();

    try {
      final repository = container.read(backgroundRepositoryProvider);

      final result = await repository.getEmployeeDetail();

      final data = result.getOrElse(() {
        return EmployeeDetailModel();
      });

      LogHelper.logDebug(
        'debug -> BackgroundService common Employee address: ${data.workingLocation?.address}',
      );
      LogHelper.logDebug(
        'debug -> BackgroundService common Employee city: ${data.city}',
      );

      if (!await Geolocator.isLocationServiceEnabled()) {
        LogHelper.logDebug(
          'debug -> BackgroundService Geolocator service disabled',
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      // don't request permission from background, just bail if not granted
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        LogHelper.logDebug(
          'debug -> BackgroundService Geolocator permission denied: $permission',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      final addressFormat = await LocationHelper.getAddressFromLatLng(position);
      LogHelper.logDebug(
        'debug -> BackgroundService addressFormat $addressFormat',
      );

      final double radiusInMeters =
          data.workingLocation?.radius ?? AppConst.radiusAbsence.toDouble();

      double distance = Geolocator.distanceBetween(
        data.workingLocation?.latitude ?? 0.0,
        data.workingLocation?.longitude ?? 0.0,
        position.latitude,
        position.longitude,
      );

      DateTime nowDate = DateTime.now().toUtc();

      String formattedDate =
          '${nowDate.toIso8601String().split('.').first}.${nowDate.millisecond.toString().padLeft(3, '0')}Z';

      Map<String, dynamic> payload = {
        "userId": data.employeeId ?? 0,
        "latitude": position.latitude,
        "longitude": position.longitude,
        "recorded_at": formattedDate,
        "metadata": {
          "locationName": addressFormat['name'],
          "address": addressFormat['street'],
          "province": addressFormat['administrativeArea'],
          "city": addressFormat['locality'],
          "country": addressFormat['country'],
          "zipcode": addressFormat['postalCode'],
        },
        // "radius": distance,
      };

      if (AppConst.isTracking24Hours == true) {
        await LocationTracker.postLocation(payload);
      }

      List<GroupShiftScheduleResponse> schedules =
          data.groupShiftSchedules?.cast<GroupShiftScheduleResponse>() ?? [];
      LogHelper.logDebug('debug -> BackgroundService schedules $schedules');
      LogHelper.logDebug(
        'debug -> BackgroundService schedules data ${data.employeeId}',
      );
      if (schedules.isEmpty &&
          data.employeeId != null &&
          data.employeeId!.isNotEmpty) {
        final result = await repository.getGroupShiftList(
          ListDataRequest(
            page: 0,
            limit: 10,
            search: "",
            sortBy: "created",
            orderBy: "desc",
            filter: {"employee_id": data.employeeId},
          ),
        );

        final dataItem = result.getOrElse(() {
          return <GroupShiftScheduleResponse>[];
        });
        schedules = dataItem;
        LogHelper.logDebug(
          'debug -> BackgroundService schedules after fetch: $result',
        );
      }

      final now = DateTime.now();
      DateTime checkInDate = now;
      DateTime checkOutDate = now;
      bool isAbsenceDay = false;
      final int dayNumber = now.weekday;
      String? workingTimeIn;
      int? diffTimeIn;
      String? workingTimeOut;
      int? diffTimeOut;

      for (var s in schedules) {
        final int weekday = s.businessDayId ?? 0;
        if (weekday == dayNumber) {
          LogHelper.logDebug(
            'debug -> BackgroundService week day $weekday vs dayNumber $dayNumber',
          );
          isAbsenceDay = true;

          final partsStart = s.shiftStartTime!.split(':');
          checkInDate = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(partsStart[0]),
            int.parse(partsStart[1]),
          );

          final remainingCheckIn = DateHelper.getDiffTime(
            s.shiftStartTime ?? '',
            AbsenceType.checkIn,
          );
          workingTimeIn = s.shiftStartTime;
          diffTimeIn = remainingCheckIn.inMinutes;

          final partsEnd = s.shiftEndTime!.split(':');
          checkOutDate = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(partsEnd[0]),
            int.parse(partsEnd[1]),
          );

          final remainingCheckOut = DateHelper.getDiffTime(
            s.shiftEndTime ?? '',
            AbsenceType.checkOut,
          );
          workingTimeOut = s.shiftEndTime;
          diffTimeOut = remainingCheckOut.inMinutes;
          break;
        }
      }

      LogHelper.logDebug(
        'debug -> BackgroundService isAbsenceDay $isAbsenceDay',
      );

      if (!isAbsenceDay) {
        LogHelper.logDebug(
          'debug -> BackgroundService bukan absence day, return',
        );
        return;
      }

      final bool isWithinWorkHours =
          now.isAfter(checkInDate) && now.isBefore(checkOutDate);
      // please uncomment if test already success
      if (!isWithinWorkHours) {
        LogHelper.logDebug(
          'debug -> BackgroundService outside work hours, return',
        );
        return;
      }

      LogHelper.logDebug(
        'debug -> BackgroundService isWithinWorkHours $isWithinWorkHours',
      );

      if (AppConst.isTracking24Hours == false) {
        await LocationTracker.postLocation(payload);
      }

      LogHelper.logDebug(
        'debug -> BackgroundService distance: $distance vs radiusAbsence: ${AppConst.radiusAbsence}',
      );
      if (distance <= radiusInMeters) {
        CheckInRequestModel? checkInRequest;
        CheckOutRequestModel? checkOutRequest;

        String? deviceId = await DeviceInfoData.getId();
        String? deviceInfo = await DeviceInfoData.getInfo();
        String? androidVersion = await DeviceInfoData.getAndroidVersion();

        final attendanceInfo = await _getAttendanceList(
          container,
          data.employeeId ?? '',
        );
        final hasCheckin = attendanceInfo['hasCheckin'] as bool;
        final isSameday = attendanceInfo['isSameday'] as bool;
        final isSamedayDateOut = attendanceInfo['isSamedayDateOut'] as bool;
        final absensiId = attendanceInfo['absensiId'] as String;
        final isError = attendanceInfo['isError'] as bool;
        LogHelper.logDebug(
          'debug -> BackgroundService common isCheckin $hasCheckin (from API)',
        );

        if (isError) {
          LogHelper.logDebug(
            'debug -> BackgroundService failed to fetch attendance data',
          );
          return;
        }

        if (!hasCheckin) {
          if (isSameday) {
            LogHelper.logDebug(
              'debug -> BackgroundService already check-in today, skip check-in',
            );
            return;
          }
          LogHelper.logDebug(
            'debug -> BackgroundService common now $now vs checkinDate $checkInDate',
          );
          if (now.isBefore(checkInDate) || now.isAfter(checkInDate)) {
            checkInRequest = CheckInRequestModel(
              status: "IN",
              deviceId: deviceId,
              deviceInfo: "$deviceInfo - $androidVersion",
              latitudeIn: position.latitude,
              longitudeIn: position.longitude,
              addressIn: addressFormat['street'],
              radiusIn: distance.toInt(),
              diffTimeIn: diffTimeIn,
              workingTimeIn: workingTimeIn,
            );

            checkin(checkInRequest);
          }
        } else {
          if (isSamedayDateOut) {
            LogHelper.logDebug(
              'debug -> BackgroundService already check-out today, skip check-out',
            );
            return;
          }
          LogHelper.logDebug(
            'debug -> BackgroundService common now $now vs checkOutDate $checkOutDate',
          );
          if (now.isAfter(checkOutDate)) {
            checkOutRequest = CheckOutRequestModel(
              attendanceId: absensiId,
              status: "Out",
              deviceId: deviceId,
              deviceInfo: "$deviceInfo - $androidVersion",
              latitudeIn: position.latitude,
              longitudeIn: position.longitude,
              addressOut: addressFormat['street'],
              radiusOut: distance.toInt(),
              diffTimeOut: diffTimeOut,
              workingTimeOut: workingTimeOut,
            );
            checkOut(checkOutRequest);
          }
        }
      }
    } finally {
      container.dispose();
    }
  }

  static Future<Map<String, dynamic>> _getAttendanceList(
    ProviderContainer container,
    String userId,
  ) async {
    bool hasCheckin = false;
    bool isSameday = false;
    bool isSamedayDateOut = false;
    String absensiId = '';

    if (userId.isEmpty) {
      return {
        'hasCheckin': false,
        'isSameday': false,
        'isSamedayDateOut': false,
        'absensiId': '',
        'isError': true,
      };
    }

    final attendanceNotifier = container.read(
      home_v2_notifier.attendanceListNotifierProvider.notifier,
    );

    await attendanceNotifier.getAttendanceList(
      ListDataRequest(
        page: 0,
        limit: 5,
        search: "",
        sortBy: "created",
        orderBy: "desc",
        filter: {"employee_id": userId},
      ),
    );

    final attendanceState = container.read(
      home_v2_notifier.attendanceListNotifierProvider,
    );

    if (attendanceState.state == ConcreteState.loaded) {
      final List<AbsenceHistoryModel> data = attendanceState.data ?? [];

      if (data.isNotEmpty) {
        final latest = data.first;
        final now = DateTime.now();

        if (latest.dateIn != null && latest.dateIn!.isNotEmpty) {
          try {
            final attendanceDate = DateTime.parse(latest.dateIn!).toLocal();
            LogHelper.logDebug(
              'debug -> BackgroundService latest.dateIn! ${latest.dateIn!}',
            );
            isSameday =
                attendanceDate.year == now.year &&
                attendanceDate.month == now.month &&
                attendanceDate.day == now.day;
            hasCheckin = latest.status == 'IN';
          } catch (e) {
            LogHelper.logDebug(
              'debug -> BackgroundService failed to parse dateIn ${latest.dateIn}',
            );
            return {
              'hasCheckin': false,
              'isSameday': false,
              'isSamedayDateOut': false,
              'absensiId': '',
              'isError': true,
            };
          }
        }

        if (latest.dateOut != null && latest.dateOut!.isNotEmpty) {
          try {
            final dateOut = DateTime.parse(latest.dateOut!).toLocal();
            LogHelper.logDebug(
              'debug -> BackgroundService latest.dateOut! ${latest.dateOut!}',
            );
            isSamedayDateOut =
                dateOut.year == now.year &&
                dateOut.month == now.month &&
                dateOut.day == now.day;
          } catch (e) {
            LogHelper.logDebug(
              'debug -> BackgroundService failed to parse dateOut ${latest.dateOut}',
            );
            return {
              'hasCheckin': false,
              'isSameday': false,
              'isSamedayDateOut': false,
              'absensiId': '',
              'isError': true,
            };
          }
        }

        if (hasCheckin) {
          absensiId = latest.attendanceId ?? '';
        }
      }
    }

    return {
      'hasCheckin': hasCheckin,
      'isSameday': isSameday,
      'isSamedayDateOut': isSamedayDateOut,
      'absensiId': absensiId,
      'isError': false,
    };
  }

  static Future<void> checkin(CheckInRequestModel data) async {
    final container = ProviderContainer();

    LogHelper.logDebug(
      'debug -> BackgroundService common payload checkin $data',
    );

    try {
      final repository = container.read(backgroundRepositoryProvider);

      final result = await repository.checkIn(data);

      final response = result.getOrElse(() => CheckInResponseModel());

      saveCheckInLocal(response);

      result.fold(
        (error) {
          LogHelper.logDebug(
            'debug -> BackgroundService Checkin gagal: ${error.message}',
          );
        },
        (response) async {
          _setCheckInDate(DateTime.now().toIso8601String());
          NotificationService.showInstantNotification(
            title: 'Check In',
            body: 'Anda Telah berhasil Check In',
          );
          LogHelper.logDebug(
            'debug -> BackgroundServiceCheckin sukses: ${response}',
          );
        },
      );
    } finally {
      container.dispose();
    }
  }

  static Future<void> checkOut(CheckOutRequestModel data) async {
    final container = ProviderContainer();

    LogHelper.logDebug(
      'debug -> BackgroundServicecommon payload checkout $data',
    );

    try {
      final repository = container.read(backgroundRepositoryProvider);

      final result = await repository.checkOut(data);

      result.fold(
        (error) {
          LogHelper.logDebug(
            'debug -> BackgroundService Checkout gagal: ${error.message}',
          );
        },
        (response) async {
          await deleteInOutLocal();
          _setCheckOutDate(DateTime.now().toIso8601String());
          NotificationService.showInstantNotification(
            title: 'Check Out',
            body: 'Anda Telah berhasil Check Out',
          );
        },
      );
    } finally {
      container.dispose();
    }
  }

  static Future<void> saveCheckInLocal(
    CheckInResponseModel inResponseModel,
  ) async {
    await db.insertCheckIn(inResponseModel);
  }

  static Future<void> deleteInOutLocal() async {
    await db.deleteCheckInOut();
  }

  static Future<void> _setCheckInDate(String checkInDate) async {
    _prefService.init();
    _prefService.setString(PrefServiceKey.checkInDate, checkInDate);
  }

  static Future<void> _setCheckOutDate(String checkOutDate) async {
    _prefService.init();
    _prefService.setString(PrefServiceKey.checkOutDate, checkOutDate);
  }
}
