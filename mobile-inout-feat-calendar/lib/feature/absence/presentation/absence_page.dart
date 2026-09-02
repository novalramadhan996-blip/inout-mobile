import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:camera/camera.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_in_out/core/resources/constants/app_const.dart';
import 'package:mobile_in_out/core/resources/theme/app_style.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/routes/router_import.gr.dart';
import 'package:mobile_in_out/core/utils/base_state/base_state.dart';
import 'package:mobile_in_out/core/utils/extensions/date_extension.dart';
import 'package:mobile_in_out/core/utils/helper/device_info_data.dart';
import 'package:mobile_in_out/core/utils/helper/location_helper.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';
import 'package:mobile_in_out/core/utils/localizations/app_translations.dart';
import 'package:mobile_in_out/core/utils/models/check_in/check_in_requst_model.dart';
import 'package:mobile_in_out/core/utils/models/check_in/check_in_response_model.dart';
import 'package:mobile_in_out/core/utils/models/check_out/check_out_request_model.dart';
import 'package:mobile_in_out/core/utils/models/history/absence_history_model.dart';
import 'package:mobile_in_out/core/utils/models/list_data_request.dart';
import 'package:mobile_in_out/core/utils/widgets/app_bar_general.dart';
import 'package:mobile_in_out/core/utils/widgets/app_button.dart';
import 'package:mobile_in_out/core/utils/widgets/app_input.dart';
import 'package:mobile_in_out/core/utils/widgets/faces/camera_detection_preview.dart';
import 'package:mobile_in_out/feature/absence/data/model/attendance_file_model.dart';
import 'package:mobile_in_out/feature/absence/data/model/image_data_model.dart';
import 'package:mobile_in_out/feature/absence/presentation/provider/absence_state_provider.dart';
import 'package:mobile_in_out/feature/history/model/group_shift_schedule_response.dart';
import 'package:mobile_in_out/feature/home/data/model/working_location.dart';
import 'package:mobile_in_out/feature/home_v2/data/model/employee_detail_model.dart';
import 'package:mobile_in_out/feature/home_v2/presentation/provider/home_v2_state_provider.dart'
    as home_v2_notifier;
import 'package:mobile_in_out/feature/home_v2/data/model/profile_model.dart'
    as profile_model_home_v2;
import 'package:mobile_in_out/feature/in_and_out/providers/in_out_provider.dart';
import 'package:mobile_in_out/feature/report_activity/presentation/provider/report_activity_state_provider.dart';
import 'package:mobile_in_out/feature/task/model/response_upload_image.dart';
import 'package:provider/provider.dart' hide Consumer;
import 'package:mobile_in_out/core/utils/models/profile_model.dart';

@RoutePage()
class AbsencePage extends ConsumerStatefulWidget {
  final bool showBackButton;
  const AbsencePage({super.key, required this.showBackButton});

  @override
  ConsumerState<AbsencePage> createState() => _AbsencePageState();
}

class _AbsencePageState extends ConsumerState<AbsencePage> {
  GoogleMapController? _controller;
  final TextEditingController _noteCtrl = TextEditingController();
  Position? _getCurrentPosition;
  final DateTime _today = DateTime.now();
  InOutProvider? _provider;

  String? _currentAddress;
  String? _name;
  String? _capturedImagePath;
  String _urlFaceRecognation = '';
  String _checkInId = '';
  String _scheduleCheckIn = '08:00';
  String _scheduleCheckOut = '17:00';
  bool _isExpandLocation = false;
  bool _isExpandPhotos = false;
  bool _isLoadingUploadImage = false;
  bool _isloadingSubmit = false;
  bool _isWorkLocation = false;
  bool _isFaceDetection = true;
  bool _isCheckin = false;
  double? _distanceWorkLocation;
  List<ImageDataModel> _imagesUpload = [];
  ProfileModel? _userProfile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _provider = context.read<InOutProvider>();

      LogHelper.logDebug('TRACE:INIT start -> await mlService.initialize()');
      await _provider?.initialize();
      LogHelper.logDebug('TRACE:INIT mlService ready -> starting camera');
      _provider?.isDispose = false;
      _provider?.isCaptureImage = true;
      await _provider?.start();
      LogHelper.logDebug('TRACE:INIT camera stream started');

      // register face detected listener
      try {
        _provider?.faceDetectorService.faceDetectedNotifier.addListener(
          _onFaceDetected,
        );
      } catch (_) {}
    });

    _getProfile();
  }

  @override
  void dispose() {
    // remove listener with error handling
    try {
      _provider?.faceDetectorService.faceDetectedNotifier.removeListener(
        _onFaceDetected,
      );
    } catch (_) {}

    _provider?.isDispose = true;
    // Stop image stream first before disposing
    try {
      final controller = _provider?.cameraService.cameraController;
      if (controller != null && controller.value.isStreamingImages) {
        controller.stopImageStream();
      }
    } catch (_) {}

    // ensure camera and related services are disposed when widget is destroyed
    try {
      _provider?.isDispose = true;
      _provider?.disposeProvider();
    } catch (e) {
      LogHelper.logDebug('Error disposing provider in dispose(): $e');
    }
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _disposeCameraResources() async {
    try {
      _provider?.isDispose = true;

      // Stop image stream first before disposing
      final controller = _provider?.cameraService.cameraController;
      if (controller != null && controller.value.isStreamingImages) {
        try {
          await controller.stopImageStream();
        } catch (e) {
          LogHelper.logDebug('Error stopping image stream: $e');
        }
      }

      await _provider?.disposeProvider();
    } catch (e) {
      LogHelper.logDebug('Error disposing camera resources: $e');
    }
  }

  Future<void> _handleBackNavigation({bool replaceHome = false}) async {
    await _disposeCameraResources();
    if (!mounted) return;
    if (replaceHome) {
      context.router.replace(HomeRouteV2());
    } else {
      context.pop(true);
    }
  }

  void _onFaceDetected() async {
    // fire-and-forget async handler to avoid blocking notifier
    await Future.delayed(Duration(seconds: 2));
    if (!mounted) return;
    _handleFaceDetected();
  }

  Future<void> _handleFaceDetected() async {
    if (_provider == null) {
      return;
    }
    if (!_provider!.faceDetectorService.faceDetected) {
      return;
    }

    _provider?.isCaptureImage = true;
    if (!mounted) return;
    await _provider?.takePicture(context);
    if (!mounted) return;
    final imagePath = _provider?.cameraService.imagePath;

    // perform face prediction against registered profile
    try {
      if (imagePath != null && imagePath.isNotEmpty) {
        // ask ML service to predict using current profile (fallback to AuthProvider)

        // disable because model data only one, next create register for multiple model data with capture photo left, right, and straight position
        // final ProfileModel? user = await _provider?.mlService.predict(
        //   users: [_userProfile ?? ProfileModel()],
        // );

        final ProfileModel? user = await _provider?.mlService.predict(
          user: _userProfile ?? ProfileModel(),
        );

        if (user != null) {
          // matched: stop streaming and show captured photo only
          try {
            if (_provider?.cameraService.cameraController != null &&
                _provider!
                    .cameraService
                    .cameraController!
                    .value
                    .isStreamingImages) {
              await _provider?.cameraService.cameraController
                  ?.stopImageStream();
            }
          } catch (e) {
            LogHelper.logDebug('error absence_page handleFacedetected $e');
          }

          if (!mounted) return;
          setState(() {
            _capturedImagePath = imagePath;
            _isFaceDetection = false;
          });

          _provider?.isCaptureImage = false;

          await ref
              .read(reportActivityNotifierProvider.notifier)
              .uploadImage(File(_capturedImagePath ?? ''));
          if (!mounted) return;

          if (!mounted) return;
          final state = ref.read(reportActivityNotifierProvider);

          if (state.state == ConcreteState.loaded) {
            final json = state.data as Map<String, dynamic>;
            final ResponseUploadImage resultUploadFile =
                ResponseUploadImage.fromJson(json);
            final url = resultUploadFile.imageUrl;
            if (url != null && url.isNotEmpty) {
              if (!mounted) return;
              setState(() {
                _urlFaceRecognation = url;
              });
            }
          }
          return;
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppTranslations.translate('face_not_recognized')),
                backgroundColor: AppColors.redColors,
                duration: const Duration(seconds: 1),
              ),
            );
          }

          // Reset face detection to allow re-triggering listener on next detection
          await Future.delayed(Duration(seconds: 5));
          _provider?.faceDetectorService.resetFaceDetection();

          // Restart image stream for next face detection
          if (!mounted) return;
          if (_provider?.cameraService.cameraController != null &&
              !_provider!
                  .cameraService
                  .cameraController!
                  .value
                  .isStreamingImages) {
            _provider?.frameFaces();
          }
        }
      }
    } catch (e) {
      // ignore prediction errors and continue with normal flow
      LogHelper.logDebug(
        'error absence_page : _handleFaceDetected -> parent $e',
      );
    }
  }

  Future<void> processImage(XFile? pickedFile) async {
    if (pickedFile != null) {
      if (!mounted) return;
      setState(() {
        _isLoadingUploadImage = true;
      });
      final filePath = pickedFile.path;
      XFile? compressedFile;
      int quality = 100;
      int targetSize = 200 * 1024; // 200KB in bytes

      // Loop until the file is less than or equal to 200KB
      do {
        compressedFile = await FlutterImageCompress.compressAndGetFile(
          filePath,
          '$filePath.jpg',
          quality: quality,
        );

        final fileSize = await compressedFile?.length();
        if (fileSize != null && fileSize <= targetSize) {
          break; // Stop if file size is less than or equal to 200KB
        }

        quality -= 5; // Reduce quality to compress further
      } while (quality > 0);

      if (!mounted) return;
      if (compressedFile != null) {
        await ref
            .read(reportActivityNotifierProvider.notifier)
            .uploadImage(File(compressedFile.path));
        if (!mounted) return;

        final state = ref.read(reportActivityNotifierProvider);

        if (state.state == ConcreteState.loaded) {
          final bytes = await compressedFile.readAsBytes();
          final base64Image = base64Encode(bytes);

          final json = state.data as Map<String, dynamic>;
          final ResponseUploadImage resultUploadFile =
              ResponseUploadImage.fromJson(json);
          final url = resultUploadFile.imageUrl;
          if (url != null && url.isNotEmpty) {
            if (!mounted) return;
            setState(() {
              _imagesUpload.add(
                ImageDataModel(
                  base64: base64Image,
                  file: pickedFile,
                  urlPath: url,
                ),
              );
            });
          }
        }
        if (!mounted) return;
        setState(() {
          _isLoadingUploadImage = false;
        });
      }
    }
  }

  Future<bool> handleLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      //Location services are disabled. Please enable the services
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // Location permissions are denied
      return false;
    }

    return true;
  }

  Future<void> _getCurrentPositionData() async {
    if (!await handleLocationPermission()) return;
    if (!mounted) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;
      setState(() {
        _getCurrentPosition = position;
      });

      LogHelper.logDebug('debug -> getCurrentPosition: $_getCurrentPosition');

      if (_getCurrentPosition != null) {
        await _controller?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude),
            16,
          ),
        );

        final addressFormat = await LocationHelper.getAddressFromLatLng(
          _getCurrentPosition ??
              Position(
                longitude: 0.0,
                latitude: 0.0,
                timestamp: DateTime.now(),
                accuracy: 0.0,
                altitude: 0.0,
                altitudeAccuracy: 0.0,
                heading: 0.0,
                headingAccuracy: 0.0,
                speed: 0.0,
                speedAccuracy: 0.0,
              ),
        );
        if (addressFormat.isNotEmpty) {
          if (!mounted) return;
          setState(() {
            _currentAddress =
                '${addressFormat['street']}, '
                '${addressFormat['subLocality']}, '
                '${addressFormat['subAdministrativeArea']}, '
                '${addressFormat['postalCode']}';
          });
        }
      }
    } catch (e, s) {
      await FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'AbsencePage : getCurrentPosition',
        fatal: false,
      );
    }
  }

  Future<void> _getProfileLocal() async {
    Future.microtask(() async {
      if (!mounted) return;
      await ref.read(localDataNotifierProvider.notifier).getProfileLocal();
      if (!mounted) return;
      final state = ref.read(localDataNotifierProvider);

      if (state.state == ConcreteState.loaded) {
        if (state.data != null && state.data != '') {
          final Map<String, dynamic> json = jsonDecode(state.data);
          final ProfileModel profile = ProfileModel.fromJson(json);
          if (!mounted) return;
          setState(() {
            _name = profile.name;
            _userProfile = profile;
          });
          _getEmployeeDetailLocal();
        } else {
          _getProfile();
        }
      }
    });
  }

  void _getEmployeeDetailLocal() async {
    Future.microtask(() async {
      if (!mounted) return;
      await ref
          .read(localDataNotifierProvider.notifier)
          .getEmployeeDetailLocal();
      if (!mounted) return;
      final state = ref.read(localDataNotifierProvider);

      if (state.state == ConcreteState.loaded) {
        if (state.data != null && state.data != '') {
          final Map<String, dynamic> json = jsonDecode(state.data);
          final EmployeeDetailModel employeeDetail =
              EmployeeDetailModel.fromJson(json);
          await _getCurrentPositionData();
          if (!mounted) return;
          setState(() {
            _isWorkLocation = _getInOrUnknown(employeeDetail.workingLocation);
          });
        } else {
          _getProfile();
        }
      }
    });
  }

  bool _getInOrUnknown(WorkingLocation? workingLocation) {
    bool inWorkLocation = false;

    if (workingLocation != null) {
      // final double radiusInKm = (workingLocation.radius ?? 0) / 1000.0;
      final double radiusInMeters =
          workingLocation.radius ?? AppConst.radiusAbsence.toDouble();

      final double workLatitude = workingLocation.latitude ?? 0;
      final double workLongitude = workingLocation.longitude ?? 0;

      LogHelper.logDebug(
        'debug -> getcurrentPosition check -> $_getCurrentPosition',
      );

      final double currentLatitude = _getCurrentPosition?.latitude ?? 0;
      final double currentLongitude = _getCurrentPosition?.longitude ?? 0;

      LogHelper.logDebug(
        'debug -> workLatitude: $workLatitude, workLongitude: $workLongitude',
      );
      LogHelper.logDebug(
        'debug -> currentLatitude: $currentLatitude, currentLongitude: $currentLongitude',
      );
      LogHelper.logDebug(
        'debug -> workingRadiusInKm: ${workingLocation.radius}',
      );

      if ((workLatitude == 0.0 ||
              workLatitude == 0 && workLongitude == 0.0 ||
              workLongitude == 0.0) ||
          (currentLatitude == 0.0 ||
              currentLatitude == 0 && currentLongitude == 0.0 ||
              currentLongitude == 0.0)) {
        LogHelper.logDebug(
          'debug -> invalid coordinate detected, skip distance calculation',
        );
        return false;
      }

      final distanceInMeters = Geolocator.distanceBetween(
        workLatitude,
        workLongitude,
        currentLatitude,
        currentLongitude,
      );

      // final distanceInKm = distanceInMeters / 1000;
      LogHelper.logDebug('debug -> distanceInMeter: $distanceInMeters');
      // LogHelper.logDebug('debug -> distanceInKm: $distanceInKm, radiusInKm: $radiusInKm');

      inWorkLocation = distanceInMeters <= radiusInMeters;

      if (inWorkLocation) {
        setState(() {
          _distanceWorkLocation = distanceInMeters;
        });
      }
    }

    return inWorkLocation;
  }

  void _submitAbsence() async {
    setState(() {
      _isloadingSubmit = true;
    });
    final results = await Future.wait([
      DeviceInfoData.getId(),
      DeviceInfoData.getInfo(),
      DeviceInfoData.getAndroidVersion(),
    ]);
    if (!mounted) return;

    final deviceId = results[0];
    final deviceInfo = results[1];
    final androidVersion = results[2];

    DateTime nowDate = DateTime.now().toUtc();

    String formattedDate =
        '${nowDate.toIso8601String().split('.').first}.${nowDate.millisecond.toString().padLeft(3, '0')}Z';

    final addressFormat = await LocationHelper.getAddressFromLatLng(
      _getCurrentPosition ??
          Position(
            longitude: 0.0,
            latitude: 0.0,
            timestamp: nowDate,
            accuracy: 0.0,
            altitude: 0.0,
            altitudeAccuracy: 0.0,
            heading: 0.0,
            headingAccuracy: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
          ),
    );

    Map<String, dynamic> payload = {
      "userId": _userProfile?.userId,
      "latitude": _getCurrentPosition?.latitude,
      "longitude": _getCurrentPosition?.longitude,
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

    await ref
        .read(insertLocationNotifierProvider.notifier)
        .insertLocation(payload);
    if (!mounted) return;

    if (!_isCheckin) {
      final remaining = _getDiffTime(_scheduleCheckIn);
      final minutes = remaining.inMinutes;

      await ref
          .read(checkInNotifierProvider.notifier)
          .checkIn(
            CheckInRequestModel(
              status: "IN",
              deviceId: deviceId,
              deviceInfo: "$deviceInfo - $androidVersion",
              latitudeIn: _getCurrentPosition?.latitude,
              longitudeIn: _getCurrentPosition?.longitude,
              addressIn: _currentAddress,
              noteIn: _noteCtrl.text,
              faceInUrl: _urlFaceRecognation,
              radiusIn: _distanceWorkLocation?.toInt(),
              diffTimeIn: minutes,
              workingTimeIn: _scheduleCheckIn,
            ),
          );
      if (!mounted) return;
      final state = ref.read(checkInNotifierProvider);
      if (state.state == ConcreteState.loaded) {
        await ref
            .read(localDataNotifierProvider.notifier)
            .saveCheckInLocal(state.data ?? CheckInResponseModel());
        if (!mounted) return;
        await _sendAttendanceFile(state.data?.absensiId ?? '');
        setState(() {
          _isloadingSubmit = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.greenColor,
            ),
          );
          if (widget.showBackButton) {
            await _handleBackNavigation();
          } else {
            await _handleBackNavigation(replaceHome: true);
          }
        }
      } else if (state.state == ConcreteState.failure) {
        setState(() {
          _isloadingSubmit = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.redColors,
            ),
          );
        }
      }
    } else {
      final remaining = _getDiffTime(_scheduleCheckOut);
      final minutes = remaining.inMinutes;
      await ref
          .read(checkOutNotifierProvider.notifier)
          .checkIn(
            CheckOutRequestModel(
              attendanceId: _checkInId,
              status: "Out",
              deviceId: deviceId,
              deviceInfo: "$deviceInfo - $androidVersion",
              latitudeOut: _getCurrentPosition?.latitude,
              longitudeOut: _getCurrentPosition?.longitude,
              addressOut: _currentAddress,
              noteOut: _noteCtrl.text,
              faceOutUrl: _urlFaceRecognation,
              radiusOut: _distanceWorkLocation?.toInt(),
              diffTimeOut: minutes,
              workingTimeOut: _scheduleCheckOut,
            ),
          );
      if (!mounted) return;
      final state = ref.read(checkOutNotifierProvider);
      if (state.state == ConcreteState.loaded) {
        await ref.read(localDataNotifierProvider.notifier).deleteInOutLocal();
        if (!mounted) return;
        await _sendAttendanceFile(state.data?.absensiId ?? '');
        setState(() {
          _isloadingSubmit = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.greenColor,
            ),
          );
          if (widget.showBackButton) {
            await _handleBackNavigation();
          } else {
            await _handleBackNavigation(replaceHome: true);
          }
        }
      } else if (state.state == ConcreteState.failure) {
        setState(() {
          _isloadingSubmit = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.redColors,
            ),
          );
        }
      }
    }
  }

  Duration _getDiffTime(String time) {
    final now = DateTime.now();

    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;

    var dateTime = DateTime(now.year, now.month, now.day, hour, minute);

    if (_isCheckin) {
      return now.difference(dateTime);
    } else {
      return dateTime.difference(now);
    }
  }

  void _getProfile() async {
    await ref
        .read(home_v2_notifier.profileNotifierProvider.notifier)
        .getProfile();
    if (!mounted) return;
    final state = ref.read(home_v2_notifier.profileNotifierProvider);

    if (state.state == ConcreteState.loaded) {
      String profileConvert = jsonEncode(state.data);
      await ref
          .read(home_v2_notifier.localDataNotifierProvider.notifier)
          .saveProfile(profileConvert);
      if (!mounted) return;

      await _getAttendanceList(state.data?.userId ?? '');
      await _getGroupShiftSchedule(state.data?.userId ?? '');
      _getEmployeeDetail();
    }
  }

  void _getEmployeeDetail() async {
    await ref
        .read(home_v2_notifier.employeeDetailNotifierProvider.notifier)
        .getEmployeeDetail();
    if (!mounted) return;
    final state = ref.read(home_v2_notifier.employeeDetailNotifierProvider);

    if (state.state == ConcreteState.loaded) {
      String employeeDetailConvert = jsonEncode(state.data?.toJson());
      await ref
          .read(home_v2_notifier.localDataNotifierProvider.notifier)
          .saveEmployeeDetail(employeeDetailConvert);
      if (!mounted) return;
      _getProfileLocal();
    }
  }

  Future<void> _getGroupShiftSchedule(String userId) async {
    await ref
        .read(home_v2_notifier.groupShiftListNotifierProvider.notifier)
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
    if (!mounted) return;
    final state = ref.read(home_v2_notifier.groupShiftListNotifierProvider);

    if (state.state == ConcreteState.loaded) {
      List<GroupShiftScheduleResponse> data = state.data ?? [];
      DateTime today = DateTime.now();
      final dayId = today.weekday % 7;
      bool isFill = false;

      if (data.isNotEmpty) {
        for (var item in data) {
          if (isFill == false) {
            if (item.businessDay?.businessDayId == dayId) {
              isFill = true;
              if (!mounted) return;
              LogHelper.logDebug('shift start time $item.shiftStartTime');
              LogHelper.logDebug('shift end time $item.shiftEndTime');
              setState(() {
                _scheduleCheckIn = item.shiftStartTime ?? '';
                _scheduleCheckOut = item.shiftEndTime ?? '';
              });
            }
          }
        }
      }
    }
  }

  Future<void> _getAttendanceList(String userId) async {
    await ref
        .read(home_v2_notifier.attendanceListNotifierProvider.notifier)
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
    final state = ref.read(home_v2_notifier.attendanceListNotifierProvider);

    if (state.state == ConcreteState.loaded) {
      List<AbsenceHistoryModel> data = state.data ?? [];

      await ref
          .read(home_v2_notifier.localDataNotifierProvider.notifier)
          .fetchCheckInLocal();
      if (!mounted) return;
      final stateFetchLocal = ref.read(
        home_v2_notifier.localDataNotifierProvider,
      );

      if (stateFetchLocal.state == ConcreteState.loaded) {
        CheckInResponseModel dataCheckin = stateFetchLocal.data;
        if (!mounted) return;
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
                if (!mounted) return;

                setState(() {
                  _checkInId = data.first.attendanceId ?? '';
                });
              }
            }
          } else {
            setState(() {
              _checkInId = dataCheckin.absensiId ?? '';
            });
          }
        }
      }
      if (data.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _isCheckin = data.first.status == 'IN' ? true : false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _isCheckin = false;
        });
      }
    }
  }

  Future<void> _sendAttendanceFile(String idAbsence) async {
    if (_imagesUpload.isEmpty) return;

    for (final image in _imagesUpload) {
      final payload = AttendanceFileModel(
        attendanceId: idAbsence,
        title: _noteCtrl.text.isNotEmpty ? _noteCtrl.text : null,
        fileUrl: image.urlPath,
      );

      await ref
          .read(attendanceFileNotifierProvider.notifier)
          .addAttendanceFile(payload);
      if (!mounted) return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cameraController = context
        .watch<InOutProvider>()
        .cameraService
        .cameraController;
    return WillPopScope(
      onWillPop: () async {
        await _disposeCameraResources();
        return true;
      },
      child: Scaffold(
        appBar: AppBarGeneral(
          backgroundColor: AppColors.whiteColor,
          colorIcon: AppColors.primaryColor,
          styleTitle: AppStyle(
            color: AppColors.blackColor,
            weight: bold,
          ).headline2,
          colorTitle: AppColors.blackColor,
          title: '',
          showBackButton: widget.showBackButton,
          onBackPressed: () => _handleBackNavigation(),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                SizedBox(
                  width: 140,
                  child: AppButton(
                    icon: Icons.home_outlined,
                    buttonName: AppTranslations.translate('home'),
                    onPress: () async {
                      if (widget.showBackButton) {
                        await _handleBackNavigation();
                      } else {
                        await _handleBackNavigation(replaceHome: true);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    isDisabled:
                        _urlFaceRecognation.isEmpty || _isLoadingUploadImage,
                    isLoading: _isloadingSubmit,
                    buttonName: _isCheckin
                        ? AppTranslations.translate('check_out')
                        : AppTranslations.translate('check_in'),
                    color: _isCheckin
                        ? AppColors.redColors
                        : AppColors.greenColor,
                    onPress: () => _submitAbsence(),
                  ),
                ),
              ],
            ),
          ),
        ),

        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _isFaceDetection
                    ? Text(
                        AppTranslations.translate('scanning_face'),
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: AppColors.black,
                          fontSize: 14,
                        ),
                      )
                    : SizedBox.shrink(),
                SizedBox(height: 5),
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    // color: AppColors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child:
                        (cameraController == null ||
                            !cameraController.value.isInitialized)
                        ? const Center(child: CircularProgressIndicator())
                        : Transform.scale(
                            scale: 0.55,
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: SizedBox(
                                width:
                                    cameraController.value.previewSize!.height,
                                height:
                                    cameraController.value.previewSize!.width,
                                child: _isFaceDetection
                                    ? CameraDetectionPreview()
                                    : Image.file(
                                        File(_capturedImagePath ?? ''),
                                      ),
                              ),
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 5),
                !_isFaceDetection
                    ? Text(
                        AppTranslations.translate('confirmed'),
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: AppColors.black,
                          fontSize: 12,
                        ),
                      )
                    : SizedBox.shrink(),
                SizedBox(height: 10),
                SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _name ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 5),
                      SizedBox(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 100,
                              child: Text(
                                AppTranslations.translate('time'),
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Text(
                              _today.formatTimeDefaut(),
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: AppColors.black,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      SizedBox(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 100,
                              child: Text(
                                AppTranslations.translate('date'),
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Text(
                              _today.toFormattedDate(),
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: AppColors.black,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isExpandLocation = !_isExpandLocation;
                          });
                        },
                        child: SizedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 100,
                                child: Text(
                                  AppTranslations.translate('location'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _currentAddress ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.black,
                                        fontSize: 14,
                                      ),
                                      maxLines: !_isExpandLocation ? 1 : null,
                                      overflow: !_isExpandLocation
                                          ? TextOverflow.ellipsis
                                          : null,
                                    ),
                                    _isExpandLocation
                                        ? SizedBox(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${_getCurrentPosition?.latitude},\n${_getCurrentPosition?.longitude}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    color: AppColors.black,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                    SizedBox(height: 5),
                                    SizedBox(
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            color: _isWorkLocation
                                                ? AppColors.blackColor
                                                : AppColors.redColors,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            _isWorkLocation
                                                ? AppTranslations.translate(
                                                    'in_work_location',
                                                  )
                                                : AppTranslations.translate(
                                                    'not_in_work_location',
                                                  ),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: _isWorkLocation
                                                  ? AppColors.blackColor
                                                  : AppColors.redColors,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 50,
                                child: Icon(
                                  !_isExpandLocation
                                      ? Icons.keyboard_arrow_down
                                      : Icons.keyboard_arrow_up,
                                  color: AppColors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16), // <-- radius
                        child: SizedBox(
                          width: double.infinity,
                          height: 180,
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                _getCurrentPosition?.latitude ?? 0.0,
                                _getCurrentPosition?.longitude ?? 0.0,
                              ),
                              zoom: 16,
                            ),
                            onMapCreated: (c) => _controller = c,
                            scrollGesturesEnabled: false,
                            zoomControlsEnabled: false,
                            zoomGesturesEnabled: false,
                            rotateGesturesEnabled: false,
                            tiltGesturesEnabled: false,
                            compassEnabled: false,
                            myLocationButtonEnabled: false,
                            markers: {
                              Marker(
                                markerId: const MarkerId("location"),
                                position: LatLng(
                                  _getCurrentPosition?.latitude ?? 0.0,
                                  _getCurrentPosition?.longitude ?? 0.0,
                                ),
                              ),
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isExpandPhotos = !_isExpandPhotos;
                          });
                        },
                        child: SizedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  AppTranslations.translate('photos'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 50,
                                child: Icon(
                                  !_isExpandPhotos
                                      ? Icons.keyboard_arrow_down
                                      : Icons.keyboard_arrow_up,
                                  color: AppColors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      if (_isExpandPhotos) ...[
                        SizedBox(
                          height: 80,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount:
                                _imagesUpload.length + 1, // +1 untuk tombol add
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              // tombol add
                              if (index == _imagesUpload.length) {
                                return InkWell(
                                  onTap: () async {
                                    if (_isLoadingUploadImage) return;
                                    final pickedFile = await ImagePicker()
                                        .pickImage(source: ImageSource.camera);
                                    await processImage(pickedFile);
                                  },
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: AppColors.greyColor.withOpacity(
                                        0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.greyColor,
                                      ),
                                    ),
                                    child: Center(
                                      child: _isLoadingUploadImage
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(Icons.add, size: 30),
                                    ),
                                  ),
                                );
                              }

                              // thumbnail image
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Stack(
                                  children: [
                                    Image.network(
                                      _imagesUpload[index].urlPath ?? '',
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),

                                    // optional delete icon
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _imagesUpload.removeAt(index);
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(
                                              0.5,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      AppInput(
                        controller: _noteCtrl,
                        hintText: AppTranslations.translate('write_note_here'),
                        onChanged: (value) {},
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
