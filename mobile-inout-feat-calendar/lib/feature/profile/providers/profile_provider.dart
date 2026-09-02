// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:developer';
import 'package:mobile_in_out/core/resources/constants/app_const.dart';
import 'package:mobile_in_out/core/resources/injector/di.dart';
import 'package:mobile_in_out/core/resources/local/camera_service.dart';
import 'package:mobile_in_out/core/resources/local/face_detector_service.dart';
import 'package:mobile_in_out/core/resources/local/local_service.dart';
import 'package:mobile_in_out/core/resources/local/ml_service.dart';
import 'package:mobile_in_out/core/resources/repositories/repository.dart';
import 'package:mobile_in_out/core/utils/enum_state.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';
import 'package:mobile_in_out/core/utils/models/profile_model.dart';
import 'package:mobile_in_out/core/utils/helper/date_helper.dart';
import 'package:mobile_in_out/feature/auth/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider extends ChangeNotifier {
  final Repository _repository;
  ProfileProvider(this._repository) {
    getSwitchValue();
  }

  // DatabaseHelper
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // service injection
  final FaceDetectorService faceDetectorService = sl<FaceDetectorService>();
  final CameraService cameraService = sl<CameraService>();
  final MLService mlService = sl<MLService>();

  bool _switchValue = false;
  bool get switchValue => _switchValue;

  void setSwitchValue(bool value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(AppConst.SWITCH_VALUE, value);
    _switchValue = value;
    notifyListeners();
  }

  void getSwitchValue() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _switchValue = sharedPreferences.getBool(AppConst.SWITCH_VALUE) ?? false;
    notifyListeners();
  }

  // Profile Data Controller
  TextEditingController nameCtrl = TextEditingController();
  TextEditingController userIdCtrl = TextEditingController();
  TextEditingController accountIdCtrl = TextEditingController();
  TextEditingController employIdCtrl = TextEditingController();
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController divisionCtrl = TextEditingController();
  TextEditingController positionCtrl = TextEditingController();
  TextEditingController contactCtrl = TextEditingController();

  TextEditingController idCardCtrl = TextEditingController();
  TextEditingController phoneCtrl = TextEditingController();
  TextEditingController dobCtrl = TextEditingController();
  TextEditingController genderCtrl = TextEditingController();
  TextEditingController timeInCtrl = TextEditingController();
  TextEditingController timeOutCtrl = TextEditingController();

  TextEditingController locationCtrl = TextEditingController();
  Location? location;

  bool allowTracking = false;

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

  // Profile
  String? imageProfilePath;
  void setImageProfilePath(String value) {
    imageProfilePath = value;
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

  void clearController() {
    nameCtrl.clear();
    employIdCtrl.clear();
    emailCtrl.clear();
    divisionCtrl.clear();
    positionCtrl.clear();
    contactCtrl.clear();
    userIdCtrl.clear();
    accountIdCtrl.clear();

    idCardCtrl.clear();
    phoneCtrl.clear();
    dobCtrl.clear();
    genderCtrl.clear();
    timeInCtrl.clear();
    timeOutCtrl.clear();
    locationCtrl.clear();
    location = null;
    notifyListeners();
  }

  Future submitProfileToLocalStorage() async {
    setState(RequestState.Loading);
    try {
      await deleteProfile();
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
          userId: userIdCtrl.text,
          accountId: accountIdCtrl.text,
          birthdate: dobCtrl.text.isNotEmpty
              ? DateTime.parse(dobCtrl.text)
              : null,
          gender: genderCtrl.text,
          workingTimeIn: timeInCtrl.text,
          workingTimeOut: timeOutCtrl.text,
          location: location,
        ),
      );

      setState(RequestState.Loaded);
    } catch (e) {
      setState(RequestState.Error);
      setErrorMessage(e.toString());
    }
  }

  // Function for API
  RequestState _stateGetDataFromApi = RequestState.Empty;
  RequestState get stateGetDataFromApi => _stateGetDataFromApi;

  void setStateGetDataFromApi(RequestState value) {
    _stateGetDataFromApi = value;
    notifyListeners();
  }

  Future<void> fetchProfileFromApi({required String userId}) async {
    final response = await _repository.getProfile(userId: userId);
    response.fold(
      (error) {
        setStateGetDataFromApi(RequestState.Error);
        _errorMessage = error.message.toString();
        notifyListeners();
      },
      (data) {
        setStateGetDataFromApi(RequestState.Loaded);
        final ProfileModel profileModel = data.response ?? ProfileModel();
        loadData(profileModel);
        notifyListeners();
      },
    );
  }

  Future<void> updateImageProfile({
    bool isUpdateProfile = true,
    required String userId,
  }) async {
    final String? imageBase64;

    if (isUpdateProfile) {
      imageBase64 = await _processImage(XFile(imageProfilePath ?? ''));
      notifyListeners();
    } else {
      imageBase64 = null;
      notifyListeners();
    }

    final response = await _repository.updateProfile(
      data:
          ProfileModel(
            modelData: mlService.predictedData,
            photo: imageBase64,
          ).toJson()..removeWhere((key, value) {
            return value == null ||
                value == '' ||
                (isUpdateProfile && key == 'model_data');
          }),
    );
    response.fold(
      (error) {
        setState(RequestState.Error);
        _errorMessage = error.message.toString();
        notifyListeners();
      },
      (data) {
        setState(RequestState.Loaded);
        sl<AuthProvider>().fetchProfileNoSaveToLocal();
        reload();
        notifyListeners();
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

  void loadData(ProfileModel model) {
    nameCtrl.text = model.name ?? '';
    // employIdCtrl.text = model.userId ?? '';
    emailCtrl.text = model.email ?? '';
    // divisionCtrl.text = model.unitUsaha ?? '';
    // positionCtrl.text = model.unitKerja ?? '';
    contactCtrl.text = model.phone ?? '';
    allowTracking = model.active == 1;
    userIdCtrl.text = model.userId ?? '';
    accountIdCtrl.text = model.accountId ?? '';
    // genderCtrl.text = model.gender ?? '';
    dobCtrl.text =
        DateHelper.convertStringToDateTime(model.birthdate ?? DateTime.now()) ??
        '';
    phoneCtrl.text = model.phone ?? '';
    // idCardCtrl.text = model.idCard ?? '';
    location = model.location;

    notifyListeners();
  }

  // Function to detect face
  start() async {
    setInitializing(true);
    await cameraService.initialize();
    LogHelper.logDebug('Debug -> imageSize ${cameraService.getImageSize()}');

    setInitializing(false);

    frameFaces();
  }

  frameFaces() {
    if (cameraService.cameraController == null) return; // guard

    imageSize = cameraService.getImageSize();

    cameraService.cameraController?.startImageStream((image) async {
      if (cameraService.cameraController != null) {
        if (detectingFaces) return;

        detectingFaces = true;

        try {
          await faceDetectorService.detectFacesFromImage(image);

          if (faceDetectorService.faces.isNotEmpty) {
            faceDetected = faceDetectorService.faces[0];

            if (saving) {
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
            notifyListeners();
          }

          detectingFaces = false;
          notifyListeners();
        } catch (e) {
          LogHelper.logDebug('Error faceDetectorService face => $e');
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
    imageProfilePath = null;
    notifyListeners();
  }

  void disposeProvider() {
    LogHelper.logDebug('disposeProv👀👀👀👀👀');
    if (cameraService.cameraController?.value.isStreamingImages == true) {
      cameraService.cameraController?.stopImageStream();
    }
    cameraService.dispose();
  }

  Future<void> resetDataBase() async {
    await _databaseHelper.deleteAll();
    notifyListeners();
  }

  Future<void> deleteProfile() async {
    await _databaseHelper.deleteProfile();
    notifyListeners();
  }
}
