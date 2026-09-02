import 'dart:io';
import 'dart:ui';
import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  CameraController? _cameraController;
  CameraController? get cameraController => _cameraController;

  /// Safely check whether the underlying controller is initialized.
  /// Accesses `value` inside a try/catch to avoid assertions when the
  /// controller has been disposed concurrently.
  bool get controllerIsInitialized {
    try {
      return _cameraController?.value.isInitialized ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Check if controller is disposed by trying to access its value.
  /// Returns true if disposed (error on access), false if still valid.
  bool get isDisposed {
    try {
      final _ = _cameraController?.value;
      return false;
    } catch (_) {
      return true;
    }
  }

  InputImageRotation? _cameraRotation;
  InputImageRotation? get cameraRotation => _cameraRotation;

  String? _imagePath;
  String? get imagePath => _imagePath;

  bool _isRequesting = false;

  Future<void> initialize() async {
    if (_isRequesting) return;
    _isRequesting = true;

    var status = await Permission.camera.request();

    if (!status.isGranted) {
      _isRequesting = false;
      return;
    }

    if (_cameraController != null) {
      await dispose();
    }

    // beri delay kecil agar device siap
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      CameraDescription description = await _getCameraDescription();

      await _setupCameraController(description: description);

      _cameraRotation = rotationIntToImageRotation(
        description.sensorOrientation,
      );
    } catch (e) {
      LogHelper.logDebug("Camera init error: $e");
    }

    _isRequesting = false;
  }

  Future<CameraDescription> _getCameraDescription() async {
    List<CameraDescription> cameras = await availableCameras();
    return cameras.firstWhere(
      (CameraDescription camera) =>
          camera.lensDirection == CameraLensDirection.front,
    );
  }

  Future _setupCameraController({
    required CameraDescription description,
  }) async {
    _cameraController = CameraController(
      description,
      // Set to ResolutionPreset.high. Do NOT set it to ResolutionPreset.max because for some phones does NOT work.
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
      // ResolutionPreset.high,
      // enableAudio: false,
      // imageFormatGroup: ImageFormatGroup.yuv420,
    );
    await _cameraController?.initialize();
  }

  InputImageRotation rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  Future<XFile?> takePicture() async {
    try {
      LogHelper.logDebug("Debug : CameraService => takePicture");
      assert(_cameraController != null, 'Camera controller not initialized');
      if (_cameraController != null) {
        LogHelper.logDebug("Debug : _cameraController => notnull");
        XFile? file = await _cameraController?.takePicture();
        _imagePath = file?.path;
        LogHelper.logDebug(
          "Debug : _cameraController => _imagePath $_imagePath",
        );
        return file;
      } else {
        return null;
      }
    } catch (e) {
      LogHelper.logDebug('Error initializing camera: $e');
      return null;
    }
  }

  Size getImageSize() {
    if (_cameraController != null) {
      // assert(_cameraController != null, 'Camera controller not initialized');
      // assert(_cameraController!.value.previewSize != null, 'Preview size is null');
      return Size(
        _cameraController != null
            ? _cameraController!.value.isInitialized
                  ? _cameraController!.value.previewSize!.height
                  : 0
            : 0,
        _cameraController != null
            ? _cameraController!.value.isInitialized
                  ? _cameraController!.value.previewSize!.width
                  : 0
            : 0,
      );
    } else {
      return Size(0, 0);
    }
  }

  //Properly dispose of the camera controller
  Future<void> dispose() async {
    final controller = _cameraController;
    if (controller != null) {
      _cameraController = null; // Null out immediately to prevent new listeners
      try {
        await controller.dispose();
      } catch (e) {
        // ignore dispose errors
      }
    }
  }
}
