import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_in_out/core/resources/injector/di.dart';
import 'package:mobile_in_out/core/resources/local/camera_service.dart';
import 'package:mobile_in_out/core/resources/local/face_detector_service.dart';
import 'package:mobile_in_out/core/resources/local/local_service.dart';
import 'package:mobile_in_out/core/resources/local/ml_service.dart';
import 'package:mobile_in_out/core/resources/repositories/repository.dart';
import 'package:mobile_in_out/core/utils/enum_state.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';
import 'package:mobile_in_out/core/utils/models/profile_model.dart';
import 'package:mobile_in_out/core/utils/models/register_model.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class RegisterProviderOld extends ChangeNotifier {
  final Repository _repository;

  // service injection
  final FaceDetectorService _faceDetectorService = sl<FaceDetectorService>();
  final CameraService cameraService = sl<CameraService>();
  final MLService mlService = sl<MLService>();

  // DatabaseHelper
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  RegisterProviderOld(this._repository);

  TextEditingController nameCtrl = TextEditingController();
  TextEditingController usernameCtrl = TextEditingController();
  TextEditingController employIdCtrl = TextEditingController();
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController divisionCtrl = TextEditingController();
  TextEditingController positionCtrl = TextEditingController();
  TextEditingController contactCtrl = TextEditingController();
  bool allowTracking = false;

  // New
  TextEditingController birthdateCtrl = TextEditingController();
  TextEditingController genderCtrl = TextEditingController();
  TextEditingController workLocationCtrl = TextEditingController();
  TextEditingController passwordCtrl = TextEditingController();

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
  void setAllowTracking(bool value) {
    allowTracking = value;
    notifyListeners();
  }

  void disposeCtrl() {
    nameCtrl.dispose();
    employIdCtrl.dispose();
    emailCtrl.dispose();
    divisionCtrl.dispose();
    positionCtrl.dispose();
    contactCtrl.dispose();
  }

  RegisterModel get registerModel => RegisterModel(
    // deprecated since update new end point
    // domain: dotenv.get("DOMAIN", fallback: ""),
    username: usernameCtrl.text,
    email: emailCtrl.text,
    name: nameCtrl.text,
    password: passwordCtrl.text,
  );

  String accountId = '';

  Future<void> register() async {
    setState(RequestState.Loading);
    final result = await _repository.register(registerModel.toJson());

    result.fold(
      (failure) {
        setErrorMessage(failure.message.toString());
        setState(RequestState.Error);
      },
      (data) {
        // accountId = data.response?.accountId ?? '';
        // if (accountId.isNotEmpty) {
        //   log("Account ID: $accountId");
        //   log("ALREADY REGISTERED! $accountId 😈😈😈😈😈");
        //   submitProfileToLocalStorage();
        // }
        setState(RequestState.Loaded);
      },
    );
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

  // Function to detect face
  start() async {
    setInitializing(true);
    await cameraService.initialize();
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
          await _faceDetectorService.detectFacesFromImage(image);

          if (_faceDetectorService.faces.isNotEmpty) {
            faceDetected = _faceDetectorService.faces[0];

            if (saving) {
              mlService.setCurrentPrediction(image, faceDetected);
              saving = false;
            }
          } else {
            faceDetected = null;
            notifyListeners();
          }

          detectingFaces = false;
          notifyListeners();
        } catch (e) {
          LogHelper.logDebug('Error _faceDetectorService face => $e');
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
      saving = true;
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 500));

      XFile? file = await cameraService.takePicture();
      imagePath = file?.path;
      notifyListeners();

      bottomSheetVisible = true;
      pictureTaken = true;
      notifyListeners();

      return true;
    }
  }

  void reload() {
    pictureTaken = false;
    bottomSheetVisible = false;
    faceDetected = null;
    imagePath = null;
    notifyListeners();
  }

  void disposeProvider() {
    cameraService.dispose();
  }

  Future<void> resetDataBase() async {
    await _databaseHelper.deleteAll();
    notifyListeners();
  }

  // save local storage
  Future submitProfileToLocalStorage() async {
    setState(RequestState.Loading);
    try {
      await resetDataBase();
      await _databaseHelper.insert(
        ProfileModel(
          name: nameCtrl.text,
          idCard: employIdCtrl.text,
          email: emailCtrl.text,
          phone: contactCtrl.text,
          unitUsaha: divisionCtrl.text,
          unitKerja: positionCtrl.text,
          active: allowTracking ? 1 : 0,
          modelData: mlService.predictedData,
          accountId: accountId,
        ),
      );

      setState(RequestState.Loaded);
    } catch (e) {
      setState(RequestState.Error);
      setErrorMessage(e.toString());
    }
  }
}
