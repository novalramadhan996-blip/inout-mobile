import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_in_out/core/resources/constants/assets.dart';
import 'package:mobile_in_out/core/resources/theme/app_style.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/utils/base_state/base_state.dart';
import 'package:mobile_in_out/core/utils/extensions/date_extension.dart';
import 'package:mobile_in_out/core/utils/helper/device_info_data.dart';
import 'package:mobile_in_out/core/utils/helper/location_helper.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';
import 'package:mobile_in_out/core/utils/localizations/app_translations.dart';
import 'package:mobile_in_out/core/utils/models/check_in/check_in_requst_model.dart';
import 'package:mobile_in_out/core/utils/models/check_in/check_in_response_model.dart';
import 'package:mobile_in_out/core/utils/models/check_out/check_out_request_model.dart';
import 'package:mobile_in_out/core/utils/widgets/app_bar_general.dart';
import 'package:mobile_in_out/core/utils/widgets/app_button.dart';
import 'package:mobile_in_out/core/utils/widgets/faces/camera_detection_preview.dart';
import 'package:mobile_in_out/feature/calendar/data/model/request/request_event_employee.dart';
import 'package:mobile_in_out/feature/calendar/presentation/provider/calendar_state_provider.dart';
import 'package:mobile_in_out/feature/home/data/model/employee_detail_model.dart';
import 'package:mobile_in_out/feature/home_v2/presentation/provider/home_v2_state_provider.dart'
    as home_v2_notifier;
import 'package:mobile_in_out/feature/in_and_out/providers/in_out_provider.dart';
import 'package:mobile_in_out/feature/report_activity/presentation/provider/report_activity_state_provider.dart';
import 'package:mobile_in_out/feature/task/model/response_upload_image.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/utils/models/profile_model.dart';
import '../../absence/presentation/provider/absence_state_provider.dart';

@RoutePage()
class CheckinMeetingPage extends ConsumerStatefulWidget {
  final bool isCheckin;
  final String? checkInId;
  final String? eventId;
  final String? eventEmployeeId;
  const CheckinMeetingPage({
    super.key,
    this.isCheckin = false,
    this.checkInId,
    this.eventId,
    this.eventEmployeeId,
  });

  @override
  ConsumerState<CheckinMeetingPage> createState() => _CheckinMeetingPageState();
}

class _CheckinMeetingPageState extends ConsumerState<CheckinMeetingPage> {
  Position? _getCurrentPosition;
  final DateTime _today = DateTime.now();
  InOutProvider? _provider;

  String? _currentAddress;
  String? _name;
  String? _capturedImagePath;
  String _urlFaceRecognation = '';
  String _employeeId = '';
  String _employeeName = '';
  bool _isloadingSubmit = false;
  bool _isFaceDetection = true;
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
          if (!mounted) return;
          setState(() {
            _employeeId = employeeDetail.employeeId ?? '';
            _employeeName = employeeDetail.employeeName ?? '';
          });
          await _getCurrentPositionData();
        } else {
          _getProfile();
        }
      }
    });
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

  Future<void> _handleBackNavigation() async {
    await _disposeCameraResources();
    if (!mounted) return;
    context.pop(true);
  }

  Duration _getDiffTime(String time) {
    final now = DateTime.now();

    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;

    var dateTime = DateTime(now.year, now.month, now.day, hour, minute);

    if (widget.isCheckin) {
      return now.difference(dateTime);
    } else {
      return dateTime.difference(now);
    }
  }

  Future<void> _submitEventEmployee({required bool isCheckIn}) async {
    final eventId = widget.eventId;
    if (eventId == null || eventId.isEmpty) return;

    DateTime nowDate = DateTime.now().toUtc();

    String formattedDate =
        '${nowDate.toIso8601String().split('.').first}.${nowDate.millisecond.toString().padLeft(3, '0')}Z';

    final request = RequestEventEmployee(
      eventId: eventId,
      employeeId: _employeeId,
      employeeName: _employeeName,
      photoUrl: _urlFaceRecognation,
      checkIn: isCheckIn ? formattedDate : null,
      checkInLatitude: isCheckIn ? _getCurrentPosition?.latitude : null,
      checkInLongitude: isCheckIn ? _getCurrentPosition?.longitude : null,
      checkOut: !isCheckIn ? formattedDate : null,
      checkOutLatitude: !isCheckIn ? _getCurrentPosition?.latitude : null,
      checkOutLongitude: !isCheckIn ? _getCurrentPosition?.longitude : null,
    );

    final notifier = ref.read(employeeEventNotifierProvider.notifier);
    if ((widget.eventEmployeeId ?? '').isEmpty) {
      // no record yet -> create new event employee
      await notifier.insertEmployeeEvent(request);
    } else {
      // record exists -> update it
      await notifier.updateEvent(request, widget.eventEmployeeId!);
    }
    if (!mounted) return;

    final state = ref.read(employeeEventNotifierProvider);
    LogHelper.logDebug(
      'event employee ${isCheckIn ? 'check_in' : 'check_out'} state: ${state.state}',
    );
    if (state.state == ConcreteState.failure && state.message.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.redColors,
        ),
      );
    }
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

    if (!widget.isCheckin) {
      // final remaining = _getDiffTime(_scheduleCheckIn);
      // final minutes = remaining.inMinutes;

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
              noteIn: '',
              faceInUrl: _urlFaceRecognation,
              radiusIn: 0,
              diffTimeIn: 0,
              workingTimeIn: '00:00',
            ),
          );
      if (!mounted) return;
      final state = ref.read(checkInNotifierProvider);
      if (state.state == ConcreteState.loaded) {
        await ref
            .read(localDataNotifierProvider.notifier)
            .saveCheckInLocal(state.data ?? CheckInResponseModel());
        if (!mounted) return;
        await _submitEventEmployee(isCheckIn: true);
        if (!mounted) return;
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
          await _handleBackNavigation();
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
      // final remaining = _getDiffTime(_scheduleCheckOut);
      // final minutes = remaining.inMinutes;
      await ref
          .read(checkOutNotifierProvider.notifier)
          .checkIn(
            CheckOutRequestModel(
              attendanceId: widget.checkInId,
              status: "Out",
              deviceId: deviceId,
              deviceInfo: "$deviceInfo - $androidVersion",
              latitudeOut: _getCurrentPosition?.latitude,
              longitudeOut: _getCurrentPosition?.longitude,
              addressOut: _currentAddress,
              noteOut: '',
              faceOutUrl: _urlFaceRecognation,
              radiusOut: 0,
              diffTimeOut: 0,
              workingTimeOut: '00:00',
            ),
          );
      if (!mounted) return;
      final state = ref.read(checkOutNotifierProvider);
      if (state.state == ConcreteState.loaded) {
        await ref.read(localDataNotifierProvider.notifier).deleteInOutLocal();
        if (!mounted) return;
        await _submitEventEmployee(isCheckIn: false);
        if (!mounted) return;
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
          await _handleBackNavigation();
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

  Future<void> _openGoogleMaps({
    required double latitude,
    required double longitude,
  }) async {
    final Uri googleMaps = Uri.parse(
      'google.navigation:q=$latitude,$longitude',
    );

    if (await canLaunchUrl(googleMaps)) {
      await launchUrl(googleMaps, mode: LaunchMode.externalApplication);
      return;
    }

    // Fallback ke browser
    final Uri web = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    await launchUrl(web, mode: LaunchMode.externalApplication);
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
          title: widget.isCheckin == true
              ? AppTranslations.translate('check_out_meeting')
              : AppTranslations.translate('check_in_meeting'),
          showBackButton: true,
          onBackPressed: () => _handleBackNavigation(),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: AppButton(
              isDisabled: _urlFaceRecognation.isEmpty,
              isLoading: _isloadingSubmit,
              buttonName: widget.isCheckin
                  ? AppTranslations.translate('check_out')
                  : AppTranslations.translate('check_in'),
              color: widget.isCheckin
                  ? AppColors.redColors
                  : AppColors.greenColor,
              onPress: () => _submitAbsence(),
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
                      SizedBox(
                        child: Row(
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
                              child: Text(
                                _currentAddress ?? '-',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Center(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () => {
                                    _openGoogleMaps(
                                      latitude:
                                          _getCurrentPosition?.latitude ?? 0.0,
                                      longitude:
                                          _getCurrentPosition?.longitude ?? 0.0,
                                    ),
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Image.asset(
                                      Assets.icShortCut,
                                      width: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
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
