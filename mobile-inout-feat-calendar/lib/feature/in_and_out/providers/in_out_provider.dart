// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'dart:developer';

import 'package:mobile_in_out/core/resources/injector/di.dart';
import 'package:mobile_in_out/core/resources/local/camera_service.dart';
import 'package:mobile_in_out/core/resources/local/face_detector_service.dart';
import 'package:mobile_in_out/core/resources/local/local_service.dart';
import 'package:mobile_in_out/core/resources/local/ml_service.dart';
import 'package:mobile_in_out/core/resources/local/pref_service.dart';
import 'package:mobile_in_out/core/resources/repositories/repository.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/utils/enum_state.dart';
import 'package:mobile_in_out/core/utils/helper/device_info_data.dart';
import 'package:mobile_in_out/core/utils/helper/location_helper.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';
import 'package:mobile_in_out/core/utils/models/check_in/check_in_requst_model.dart';
import 'package:mobile_in_out/core/utils/models/check_in/check_in_response_model.dart';
import 'package:mobile_in_out/core/utils/models/check_out/check_out_request_model.dart';
import 'package:mobile_in_out/core/utils/models/list_data_request.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_watermark/image_watermark.dart';
import 'package:image/image.dart' as img;
import 'package:mobile_in_out/feature/history/model/group_shift_schedule_response.dart';

class InOutProvider extends ChangeNotifier {
  // Repository
  final Repository _repo;
  final DatabaseHelper _db = DatabaseHelper.instance;
  static final ShardPrefService _prefService = sl<ShardPrefService>();
  InOutProvider(this._repo);

  // service injection
  final FaceDetectorService faceDetectorService = sl<FaceDetectorService>();
  final CameraService cameraService = sl<CameraService>();
  final MLService mlService = sl<MLService>();
  bool isDispose = false;

  CameraImage? _lastCameraImage;
  Face? _lastDetectedFace;

  // Key
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // Face Registration
  String? imagePath;
  String? urlFace;
  Face? faceDetected;
  Size? imageSize;

  String? urlImagePath;
  double? distanceWorkLocation;

  bool detectingFaces = false;
  bool isPictureTaken = false;
  void setPictureTaken(bool value) {
    isPictureTaken = value;
    notifyListeners();
  }

  bool initializing = false;
  bool get isInitializing => initializing;
  void setInitializing(bool value) {
    initializing = value;
    notifyListeners();
  }

  bool saving = false;
  bool bottomSheetVisible = false;
  bool isCaptureImage = false;
  bool _isDisposing = false;
  bool get isDisposing => _isDisposing;

  // Other Function For Face Detection
  Future start() async {
    LogHelper.logDebug("Debug : in_out_provider => start init");
    initializing = true;
    await cameraService.initialize();
    initializing = false;
    isPictureTaken = false;
    frameFaces();
  }

  frameFaces() async {
    bool processing = false;
    cameraService.cameraController?.startImageStream((CameraImage image) async {
      if (processing) return;
      LogHelper.logDebug(
        "TRACE:STREAM frame arrived isCaptureImage=$isCaptureImage width=${image.width} height=${image.height} format=${image.format.group}",
      );
      processing = true;
      await _predictFacesFromImage(image: image);
      processing = false;
    });
  }

  Future<void> _predictFacesFromImage({@required CameraImage? image}) async {
    try {
      assert(image != null, 'Image is null');
      await faceDetectorService.detectFacesFromImage(image!);
      LogHelper.logDebug(
        "TRACE:PREDICT faceDetected=${faceDetectorService.faceDetected} isCaptureImage=$isCaptureImage",
      );
      if (faceDetectorService.faceDetected) {
        _lastCameraImage = image;
        _lastDetectedFace = faceDetectorService.faces[0];
        LogHelper.logDebug(
          "TRACE:PREDICT storing _lastCameraImage & _lastDetectedFace -> calling setCurrentPrediction isCaptureImage=$isCaptureImage",
        );
        mlService.setCurrentPrediction(
          image,
          faceDetectorService.faces[0],
          isDispose: isDispose,
          isCaptureImage: isCaptureImage,
        );
      }
      notifyListeners();
    } catch (e) {
      LogHelper.logDebug('error in_out_provider _predictFacesFromImage :  $e');
    }
  }

  Future<void> takePicture(BuildContext context) async {
    if (isDispose) {
      LogHelper.logDebug('Provider is being disposed, skipping takePicture');
      return;
    }

    LogHelper.logDebug(
      "TRACE:TAKEPIC isCaptureImage=$isCaptureImage _lastCameraImage=${_lastCameraImage != null} _lastDetectedFace=${_lastDetectedFace != null} streaming=${cameraService.cameraController?.value.isStreamingImages}",
    );
    if (cameraService.cameraController != null) {
      if (cameraService.cameraController!.value.isStreamingImages) {
        if (isCaptureImage &&
            _lastCameraImage != null &&
            _lastDetectedFace != null) {
          LogHelper.logDebug(
            "TRACE:TAKEPIC calling setCurrentPrediction before stopImageStream (safety net)",
          );
          mlService.setCurrentPrediction(
            _lastCameraImage!,
            _lastDetectedFace,
            isDispose: isDispose,
            isCaptureImage: isCaptureImage,
          );
        }
        try {
          await cameraService.cameraController?.stopImageStream();
          LogHelper.logDebug("TRACE:TAKEPIC imageStream stopped");
        } catch (e) {
          LogHelper.logDebug('Error stopping image stream: $e');
        }
      }
    }
    LogHelper.logDebug(
      "TRACE:TAKEPIC AFTER stop -> _predictedData.length=${mlService.predictedData.length} _hasPredictedData=${mlService.hasPredictedData}",
    );

    await Future.delayed(const Duration(milliseconds: 500));
    LogHelper.logDebug(
      "TRACE:TAKEPIC after 500ms delay -> _predictedData.length=${mlService.predictedData.length}",
    );

    if (cameraService.cameraController == null ||
        !cameraService.controllerIsInitialized) {
      if (isDispose) {
        LogHelper.logDebug(
          'Provider is being disposed, skipping camera reinit',
        );
        return;
      }
      LogHelper.logDebug('Camera not initialized, reinitializing...');
      await cameraService.initialize();
      await Future.delayed(const Duration(milliseconds: 300));
    }

    if (faceDetectorService.faceDetected) {
      if (isDispose) {
        LogHelper.logDebug(
          'Provider is being disposed, skipping takePicture action',
        );
        return;
      }
      try {
        await cameraService.takePicture();
        isPictureTaken = true;
      } catch (e) {
        LogHelper.logDebug('Error taking picture: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error taking picture: $e'),
              backgroundColor: AppColors.redColors,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Face not recognized'),
          backgroundColor: AppColors.redColors,
          duration: Duration(seconds: 1),
        ),
      );
      await Future.delayed(const Duration(seconds: 3));
      faceDetectorService.resetFaceDetection();
      if (!isDispose &&
          cameraService.cameraController != null &&
          !cameraService.cameraController!.value.isStreamingImages) {
        frameFaces();
      }
    }
  }

  // Checkin to Server
  CheckInRequestModel? checkInRequest;
  CheckOutRequestModel? checkOutRequest;

  // Response
  CheckInResponseModel? checkInResponse;

  String? currentAddress;
  Position? currentPosition;

  Future<bool> handleLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      LogHelper.logDebug(
        'Location services are disabled. Please enable the services ❌❌❌❌',
      );
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      LogHelper.logDebug('Location permissions are denied ❌❌❌❌');
      return false;
    }

    return true;
  }

  Future<void> getCurrentPosition() async {
    if (!await handleLocationPermission()) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      currentPosition = position;
      notifyListeners();
      if (currentPosition != null) {
        final addressFormat = await LocationHelper.getAddressFromLatLng(
          currentPosition!,
        );
        if (addressFormat.isNotEmpty) {
          currentAddress =
              '${addressFormat['street']}, '
              '${addressFormat['subLocality']}, '
              '${addressFormat['subAdministrativeArea']}, '
              '${addressFormat['postalCode']}';
          notifyListeners();
        }
      }
    } catch (e) {
      LogHelper.logDebug("${e.toString()}❌❌❌❌");
    }
  }

  // State Submit
  RequestState _state = RequestState.Empty;
  RequestState get state => _state;

  void setState(RequestState state) {
    _state = state;
    notifyListeners();
  }

  String? _errMsg;
  String? get errMsg => _errMsg;

  void setErrMsg(String errMsg) {
    _errMsg = errMsg;
    notifyListeners();
  }

  // VARIABLE CONTROLLER
  TextEditingController noteCtrl = TextEditingController();
  String? imageBase64;
  XFile? imageFile;

  void setImageFile(XFile? file) {
    imageFile = file;
    notifyListeners();
  }

  void setImageBase64(String base64) {
    imageBase64 = base64;
    notifyListeners();
  }

  void setUrlImagePath(String url) {
    urlImagePath = url;
    notifyListeners();
  }

  void deleteImage() {
    imageBase64 = null;
    imageFile = null;
    notifyListeners();
  }

  void setDistanceWorkLocation(double distance) {
    distanceWorkLocation = distance;
    notifyListeners();
  }

  Future<void> checkIn() async {
    try {
      setState(RequestState.Loading);

      final results = await Future.wait([
        DeviceInfoData.getId(),
        DeviceInfoData.getInfo(),
        DeviceInfoData.getAndroidVersion(),
      ]);

      final deviceId = results[0];
      final deviceInfo = results[1];
      final androidVersion = results[2];

      checkInRequest = CheckInRequestModel(
        status: "IN",
        deviceId: deviceId,
        deviceInfo: "$deviceInfo - $androidVersion",
        latitudeIn: currentPosition!.latitude,
        longitudeIn: currentPosition!.longitude,
        addressIn: currentAddress,
        noteIn: noteCtrl.text,
        photoInUrl: urlImagePath,
        faceInUrl: urlFace,
        radiusIn: distanceWorkLocation?.toInt(),
      );
      notifyListeners();

      final result = await _repo.checkIn(data: checkInRequest!.toJson());
      result.fold(
        (l) {
          setErrMsg(l.toString());
          setState(RequestState.Error);
        },
        (r) {
          saveCheckInLocal(r.response ?? CheckInResponseModel());
          _prefService.setString(
            PrefServiceKey.checkInDate,
            DateTime.now().toIso8601String(),
          );
          noteCtrl.clear();
          deleteImage();
          setState(RequestState.Loaded);
        },
      );
    } catch (e) {
      setErrMsg(e.toString());
      setState(RequestState.Error);
    }
  }

  Future<void> checkOut() async {
    try {
      setState(RequestState.Loading);

      final results = await Future.wait([
        DeviceInfoData.getId(),
        DeviceInfoData.getInfo(),
        DeviceInfoData.getAndroidVersion(),
        fetchCheckInLocal(),
      ]);

      final deviceId = results[0] as String?;
      final deviceInfo = results[1] as String?;
      final androidVersion = results[2] as String?;
      final checkInLocal = checkInResponse;

      checkOutRequest = CheckOutRequestModel(
        attendanceId: checkInLocal?.absensiId,
        status: "Out",
        deviceId: deviceId,
        deviceInfo: "$deviceInfo - $androidVersion",
        latitudeOut: currentPosition?.latitude,
        longitudeOut: currentPosition?.longitude,
        addressOut: currentAddress,
        noteOut: noteCtrl.text,
        photoOutUrl: urlImagePath,
        faceOutUrl: urlFace,
        radiusOut: distanceWorkLocation?.toInt(),
      );
      notifyListeners();

      final result = await _repo.checkOut(data: checkOutRequest!.toJson());
      result.fold(
        (l) {
          setErrMsg(l.toString());
          setState(RequestState.Error);
        },
        (r) {
          noteCtrl.clear();
          deleteImage();
          _prefService.setString(
            PrefServiceKey.checkOutDate,
            DateTime.now().toIso8601String(),
          );
          setState(RequestState.Loaded);
        },
      );
    } catch (e) {
      setErrMsg(e.toString());
      setState(RequestState.Error);
    }
  }

  // Local Data
  Future<void> saveCheckInLocal(CheckInResponseModel inResponseModel) async {
    await _db.insertCheckIn(inResponseModel);
  }

  Future<CheckInResponseModel?> fetchCheckInLocal() async {
    final List<CheckInResponseModel> checkIn = await _db.queryAllCheckIn();
    if (checkIn.isEmpty) {
      checkInResponse = null;
      notifyListeners();
      return null;
    }

    checkInResponse = checkIn.first;

    notifyListeners();

    return checkIn.first;
  }

  Future<void> deleteInOutLocal() async {
    await _db.deleteCheckInOut();
  }

  Future<void> checkIflocationOutOfOffice() async {}

  //initialize
  Future<void> initialize() async {
    await mlService.initialize();
    faceDetectorService.initialize();
  }

  // Dispose
  Future<void> disposeProvider() async {
    _isDisposing = true;
    // Don't call notifyListeners() during disposal - widget tree is being destroyed
    // and the framework may be locked during navigation

    mlService.dispose();
    faceDetectorService.dispose();

    // Stop image stream before disposing controller
    if (cameraService.cameraController != null) {
      try {
        if (cameraService.cameraController!.value.isStreamingImages) {
          await cameraService.cameraController!.stopImageStream();
        }
      } catch (e) {
        // ignore errors stopping stream
      }
    }

    // Dispose camera after stopping stream
    await cameraService.dispose();

    _isDisposing = false;
  }

  void clearDataProvider() {
    imagePath = null;
    faceDetected = null;
    imageSize = null;
  }

  @Deprecated(
    "Don't use this function, since update v2 upload image using url. When still using this function please move to global function",
  )
  Future<String?> _processImage(XFile? pickedFile, String timeInOut) async {
    if (pickedFile != null) {
      final filePath = pickedFile.path;
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        filePath,
        '$filePath.jpg',
        quality: 88,
      );

      final bytes = await compressedFile?.readAsBytes();

      // Decode the image to get its dimensions
      final image = img.decodeImage(bytes!);

      if (image == null) {
        return null; // Return if the image could not be decoded
      }

      // Get the width and height of the image
      final imageWidth = image.width;
      final imageHeight = image.height;

      // Calculate position for the bottom-right corner
      final dstX = imageWidth - 700; // Adjust for the text's width
      final dstY = imageHeight - 300; // Adjust for the text's height

      final watermarkedImg = await ImageWatermark.addTextWatermark(
        imgBytes: bytes,
        watermarkText:
            "Time: $timeInOut\nLatitude: ${currentPosition!.latitude}\nLongitude: ${currentPosition!.longitude}",
        dstX: dstX,
        dstY: dstY,
        color: Colors.white, // Set text color to white
        // font: img.arial14, // Set font to arial_24
        font: img.arial_14, // Set font to arial_24
      );

      final base64Image = base64Encode(watermarkedImg);

      return base64Image;
    }

    return null;
  }

  // Comment because deprecated, when already stable please removed
  // ScheduleModel? _mySchedule;
  // ScheduleModel? get mySchedule => _mySchedule;
  // RequestState _groupShiftState = RequestState.Empty;
  // RequestState get groupShiftState => _groupShiftState;
  // Future getWorkSschedule() async {
  //   final day = DateTime.now().weekday;
  //   LogHelper.logDebug("DAY $day");

  //   final result = await _repo.getMySchedule(day);

  //   result.fold((l) {
  //     setErrMsg(l.toString());
  //     _groupShiftState = RequestState.Error;
  //   }, (r) {
  //     LogHelper.logDebug("DATA ${r.response}");
  //     _mySchedule = r.response;
  //     _groupShiftState = RequestState.Loaded;
  //   });
  // }

  GroupShiftScheduleResponse? _mySchedule;
  GroupShiftScheduleResponse? get mySchedule => _mySchedule;

  RequestState _groupShiftState = RequestState.Empty;
  RequestState get groupShiftState => _groupShiftState;

  Future getWorkSschedule({ListDataRequest? request}) async {
    _groupShiftState = RequestState.Loading;
    notifyListeners();

    ListDataRequest listDataRequest = ListDataRequest();
    if (request == null) {
      listDataRequest = ListDataRequest(
        page: 0,
        limit: 100,
        search: "",
        sortBy: "created",
        orderBy: "desc",
      );
    } else {
      listDataRequest = request;
    }

    final response = await _repo.getMySchedule(listDataRequest);

    response.fold(
      (error) {
        LogHelper.logDebug('error ${error.message.toString()}');
        _groupShiftState = RequestState.Error;
        notifyListeners();
      },
      (data) async {
        GroupShiftScheduleResponse responseData =
            data.response ?? GroupShiftScheduleResponse();
        LogHelper.logDebug('work schedule ${responseData.locationName}');
        _mySchedule = responseData;

        _groupShiftState = RequestState.Loaded;
        notifyListeners();
      },
    );
  }

  // Comment because deprecated, when already stable please removed
  // List<GroupShiftModel> _groupShiftList = [];
  // List<GroupShiftModel> get groupShiftList => _groupShiftList;
  // Future getGroupShiftList() async {
  //   _groupShiftListState = RequestState.Loading;
  //   notifyListeners();
  //   final day = DateTime.now().weekday;
  //   LogHelper.logDebug("DAY $day");

  //   final result = await _repo.getMyGroupShift(day);

  //   result.fold((l) {
  //     setErrMsg(l.toString());
  //     _groupShiftListState = RequestState.Error;
  //     notifyListeners();
  //   }, (r) {
  //     _groupShiftList = r.response ?? [];
  //     _groupShiftListState = RequestState.Loaded;
  //     notifyListeners();
  //   });
  // }

  List<GroupShiftScheduleResponse> _groupShiftList = [];
  List<GroupShiftScheduleResponse> get groupShiftList => _groupShiftList;

  RequestState _groupShiftListState = RequestState.Empty;
  RequestState get groupShiftListState => _groupShiftListState;

  Future getGroupShiftList({ListDataRequest? request}) async {
    _groupShiftListState = RequestState.Loading;
    notifyListeners();

    // please using param day when api already provide this param
    final day = DateTime.now().weekday;
    LogHelper.logDebug("DAY $day");

    ListDataRequest listDataRequest = ListDataRequest();
    if (request == null) {
      listDataRequest = ListDataRequest(
        page: 0,
        limit: 100,
        search: "",
        sortBy: "created",
        orderBy: "desc",
      );
    } else {
      listDataRequest = request;
    }

    final result = await _repo.getMyGroupShift(listDataRequest);

    result.fold(
      (l) {
        setErrMsg(l.toString());
        _groupShiftListState = RequestState.Error;
        notifyListeners();
      },
      (r) {
        _groupShiftList = r.response ?? [];
        _groupShiftListState = RequestState.Loaded;
        notifyListeners();
      },
    );
  }

  // Insert Location Tracking
  Future<void> insertLocationTracking() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    final data = {
      "latitude": position.latitude,
      "longitude": position.longitude,
      "address": '',
    };

    final result = await _repo.locationTracking(data: data);
    result.fold((l) {
      setErrMsg(l.toString());
    }, (r) {});
  }
}
