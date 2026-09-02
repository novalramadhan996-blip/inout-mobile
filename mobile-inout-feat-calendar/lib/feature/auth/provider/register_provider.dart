import 'dart:convert';
import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:mobile_in_out/core/resources/injector/di.dart';
import 'package:mobile_in_out/core/resources/local/camera_service.dart';
import 'package:mobile_in_out/core/resources/local/face_detector_service.dart';
import 'package:mobile_in_out/core/resources/local/local_service.dart';
import 'package:mobile_in_out/core/resources/local/ml_service.dart';
import 'package:mobile_in_out/core/resources/repositories/repository.dart';
import 'package:mobile_in_out/core/utils/enum_state.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';
import 'package:mobile_in_out/core/utils/models/validate_account_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class RegisterProvider extends ChangeNotifier {
  final Repository _repository;

  // service injection
  final FaceDetectorService faceDetectorService = sl<FaceDetectorService>();
  final CameraService cameraService = sl<CameraService>();
  final MLService mlService = sl<MLService>();

  // DatabaseHelper
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  RegisterProvider(this._repository);

  TextEditingController nameCtrl = TextEditingController();
  TextEditingController otpCtrl = TextEditingController();
  TextEditingController pwdCtrl = TextEditingController();
  TextEditingController reTypePwdCtrl = TextEditingController();

  // State
  RequestState _state = RequestState.Empty;
  RequestState get state => _state;

  void setState(RequestState value) {
    _state = value;
    notifyListeners();
  }

  // Error Message
  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  void setErrorMessage(String value) {
    _errorMessage = value;
    notifyListeners();
  }

  // Other Function
  void disposeCtrl() {
    nameCtrl.dispose();
  }

  ValidateAccountResponse? _validateAccountResponse;
  ValidateAccountResponse? get validateAccountResponse =>
      _validateAccountResponse;

  Future<void> validateAccount() async {
    setState(RequestState.Loading);
    final result = await _repository.validateAccount(username: nameCtrl.text);

    result.fold(
      (failure) {
        setErrorMessage("Employee Unknown, contact your administrator");
        setState(RequestState.Error);
      },
      (data) {
        _validateAccountResponse = data.response;
        setState(RequestState.Loaded);
      },
    );
  }

  bool _isOtpValid = false;
  bool get isOtpValid => _isOtpValid;

  RequestState _stateOtp = RequestState.Empty;
  RequestState get stateOtp => _stateOtp;

  void setStateOtp(RequestState value) {
    _stateOtp = value;
    notifyListeners();
  }

  Future<void> validateOtp(String email) async {
    setStateOtp(RequestState.Loading);
    final result = await _repository.validateRegisterCode(
      data: {"code": otpCtrl.text, "email": email},
    );

    result.fold(
      (failure) {
        _isOtpValid = false;
        setErrorMessage(failure.message.toString());
        setStateOtp(RequestState.Error);
      },
      (data) {
        _isOtpValid = true;
        setStateOtp(RequestState.Loaded);
      },
    );
  }

  bool _isFacevalid = false;
  bool get isFacevalid => _isFacevalid;

  RequestState _stateFace = RequestState.Empty;
  RequestState get stateFace => _stateFace;

  void setStateFace(RequestState value) {
    _stateFace = value;
    notifyListeners();
  }

  Future<void> regsiterFace() async {
    setStateFace(RequestState.Loading);
    final imageBase64 = await _processImage(XFile(imagePath ?? ''));
    LogHelper.logDebug('debug -> register_provider code ${otpCtrl.text}');
    LogHelper.logDebug(
      'debug -> register_provider modelData ${mlService.predictedData.toString()}',
    );
    LogHelper.logDebug(
      'debug -> register_provider modelData ${jsonEncode(mlService.predictedData)}',
    );

    // Comment because deprecated, when already stable please removed
    // final result = await _repository.registerFaceId(data: {
    //   "username": nameCtrl.text,
    //   "model_data": jsonEncode(mlService.predictedData),
    //   "password": pwdCtrl.text,
    //   "code": otpCtrl.text,
    //   "photo": imageBase64,
    // });

    final result = await _repository.registerFaceId(
      data: {
        "photo": jsonEncode(mlService.predictedData),
        "password": pwdCtrl.text,
        "username": nameCtrl.text,
      },
    );

    result.fold(
      (failure) {
        _isFacevalid = false;
        setErrorMessage(failure.message.toString());
        setStateFace(RequestState.Error);
      },
      (data) {
        _isFacevalid = true;
        setStateFace(RequestState.Loaded);
      },
    );
  }

  Future<String?> _processImage(XFile? pickedFile) async {
    if (pickedFile != null) {
      final filePath = pickedFile.path;
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        filePath,
        '$filePath.jpg',
        quality: 88,
      );

      final bytes = await compressedFile?.readAsBytes();
      final base64Image = base64Encode(bytes!);

      return base64Image;
    }

    return null;
  }

  void disposeCtrlFace() {
    nameCtrl.clear();
    otpCtrl.clear();
    pwdCtrl.clear();
    reTypePwdCtrl.clear();
    faceDetected = null;
    imagePath = null;
    _state = RequestState.Empty;
    _stateOtp = RequestState.Empty;
    _stateFace = RequestState.Empty;
    reload();
    notifyListeners();
  }

  // Face Registration
  String? imagePath;
  Face? faceDetected;
  Size? imageSize;

  bool detectingFaces = false;
  bool pictureTaken = false;

  bool initializing = false;
  bool get isInitializing => initializing;
  void setInitializing(bool value) {
    initializing = value;
    notifyListeners();
  }

  bool saving = false;
  bool bottomSheetVisible = false;
  bool _isDisposed = false;

  // Function to detect face
  start() async {
    _isDisposed = false;
    pictureTaken = false;
    faceDetected = null;
    imagePath = null;
    setInitializing(true);
    faceDetectorService.initialize();
    await cameraService.initialize();
    await mlService.initialize();
    setInitializing(false);

    frameFaces();
  }

  frameFaces() {
    imageSize = cameraService.getImageSize();

    cameraService.cameraController?.startImageStream((image) async {
      if (cameraService.cameraController != null) {
        if (detectingFaces) return;

        detectingFaces = true;

        try {
          await faceDetectorService.detectFacesFromImage(image);

          LogHelper.logDebug('Debug : streaming face detection');

          if (faceDetectorService.faces.isNotEmpty) {
            faceDetected = faceDetectorService.faces[0];

            if (saving) {
              LogHelper.logDebug('Debug : is saving streaming face detection');
              mlService.setCurrentPrediction(
                image,
                faceDetected,
                isDispose: false,
                isCaptureImage: true,
              );
              saving = false;
            }
          } else {
            faceDetected = null;
          }

          detectingFaces = false;

          Future.microtask(() {
            if (!_isDisposed) {
              notifyListeners();
            }
          });
        } catch (e) {
          LogHelper.logDebug('Error in frameFaces: $e');
          detectingFaces = false;
        }
      }
    });
  }

  Future<bool> onShot(BuildContext context) async {
    if (faceDetected == null) {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(content: Text('No face detected!'));
        },
      );

      return false;
    } else {
      LogHelper.logDebug("onShot FACE DETECED");
      saving = true;
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 500));

      XFile? file = await cameraService.takePicture();
      imagePath = file?.path;
      LogHelper.logDebug('imagePath___ => $imagePath');
      notifyListeners();

      bottomSheetVisible = true;
      pictureTaken = true;
      if (cameraService.cameraController?.value.isStreamingImages == true) {
        cameraService.cameraController?.stopImageStream();
      }
      notifyListeners();

      return true;
    }
  }

  void reload() {
    pictureTaken = false;
    bottomSheetVisible = false;
    faceDetected = null;
    imagePath = null;
    if (cameraService.cameraController != null &&
        cameraService.cameraController!.value.isStreamingImages == false) {
      frameFaces();
    }
    notifyListeners();
  }

  void disposeProvider() {
    LogHelper.logDebug('disposeProv👀👀👀👀👀');
    _isDisposed = true;
    if (cameraService.cameraController?.value.isStreamingImages == true) {
      cameraService.cameraController?.stopImageStream();
    }
    cameraService.dispose();
  }

  // save local storage
  Future<void> resetDataBase() async {
    await _databaseHelper.deleteAll();
    notifyListeners();
  }

  Future submitProfileToLocalStorage() async {
    setState(RequestState.Loading);
    try {
      await resetDataBase();
      setState(RequestState.Loaded);
    } catch (e) {
      setState(RequestState.Error);
      setErrorMessage(e.toString());
    }
  }
}
