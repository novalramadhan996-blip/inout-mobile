import 'dart:developer';

import 'package:mobile_in_out/core/resources/local/camera_service.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter/material.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';

import '../injector/di.dart';

class FaceDetectorService {
  final CameraService _cameraService = sl<CameraService>();

  late FaceDetector _faceDetector;
  FaceDetector get faceDetector => _faceDetector;

  List<Face> _faces = [];
  List<Face> get faces => _faces;
  bool get faceDetected => _faces.isNotEmpty;

  /// Notifier that emits when face detection state changes.
  /// Listen to this to react when a face is detected or lost.
  late ValueNotifier<bool> faceDetectedNotifier;
  bool _isDisposed = false;
  bool get disableButton {
    if (faceDetected) {
      return _faces[0].headEulerAngleY! > 10 ||
          _faces[0].headEulerAngleY! < -10;
    }

    return true;
  }

  void initialize() {
    // Recreate notifier if it was disposed
    if (_isDisposed) {
      faceDetectedNotifier = ValueNotifier<bool>(false);
      _isDisposed = false;
    } else {
      // Ensure notifier is initialized on first call
      try {
        faceDetectedNotifier.dispose();
      } catch (_) {}
      faceDetectedNotifier = ValueNotifier<bool>(false);
    }

    // deprecated initialization
    // _faceDetector = GoogleMlKit.vision.faceDetector(
    //   FaceDetectorOptions(
    //     performanceMode: FaceDetectorMode.fast,
    //   ),
    // );

    // new initialization
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
        // enableContours: true,
        // enableLandmarks: true,
      ),
    );
  }

  Future<void> detectFacesFromImage(CameraImage image) async {
    InputImageMetadata firebaseImageMetadata = InputImageMetadata(
      rotation:
          _cameraService.cameraRotation ?? InputImageRotation.rotation0deg,
      format:
          InputImageFormatValue.fromRawValue(image.format.raw) ??
          InputImageFormat.nv21,
      size: Size(image.width.toDouble(), image.height.toDouble()),
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    // InputImageData firebaseImageMetadata = InputImageData(
    //   imageRotation: _cameraService.cameraRotation ?? InputImageRotation.rotation0deg,
    //   inputImageFormat: InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21,
    //   size: Size(image.width.toDouble(), image.height.toDouble()),
    //   planeData: image.planes.map(
    //     (Plane plane) {
    //       return InputImagePlaneMetadata(
    //         bytesPerRow: plane.bytesPerRow,
    //         height: plane.height,
    //         width: plane.width,
    //       );
    //     },
    //   ).toList(),
    // );

    // for mlkit 13
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }

    final bytes = allBytes.done().buffer.asUint8List();

    InputImage firebaseVisionImage = InputImage.fromBytes(
      bytes: bytes,
      metadata: firebaseImageMetadata,
    );
    //  InputImage firebaseVisionImage = InputImage.fromBytes(
    //   bytes: bytes,
    //   inputImageData: firebaseImageMetadata,
    // );

    // for mlkit 13
    _faces = await _faceDetector.processImage(firebaseVisionImage);

    // Notify listeners when face detection state changes (only if not disposed)
    if (!_isDisposed) {
      try {
        final detected = _faces.isNotEmpty;
        if (faceDetectedNotifier.value != detected) {
          faceDetectedNotifier.value = detected;
        }
      } catch (e) {
        // Notifier might be disposed, ignore
        LogHelper.logDebug(
          'error face_detector_service detectFacesFromImage $e',
        );
      }
    }
  }

  // Future<List<Face>> detect(CameraImage image, InputImageRotation rotation) {
  //   final faceDetector = GoogleMlKit.vision.faceDetector(
  //     FaceDetectorOptions(
  //       performanceMode: FaceDetectorMode.fast,
  //       enableLandmarks: true,
  //     ),
  //   );
  //   final WriteBuffer allBytes = WriteBuffer();
  //   for (final Plane plane in image.planes) {
  //     allBytes.putUint8List(plane.bytes);
  //   }
  //   final bytes = allBytes.done().buffer.asUint8List();

  //   final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
  //   final inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21;

  //   final planeData = image.planes.map(
  //     (Plane plane) {
  //       return InputImagePlaneMetadata(
  //         bytesPerRow: plane.bytesPerRow,
  //         height: plane.height,
  //         width: plane.width,
  //       );
  //     },
  //   ).toList();

  //   // final inputImageData = InputImageMetadata(
  //   //   size: imageSize,
  //   //   rotation: rotation,
  //   //   format: inputImageFormat,
  //   //   bytesPerRow: image.planes[0].bytesPerRow,
  //   // );

  //   final inputImageData = InputImageData(
  //     size: imageSize,
  //     imageRotation: rotation,
  //     inputImageFormat: inputImageFormat,
  //     planeData: planeData,
  //   );

  //   // return faceDetector.processImage(
  //   //   InputImage.fromBytes(bytes: bytes, metadata: inputImageData),
  //   // );

  //   return faceDetector.processImage(
  //     InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData),
  //   );
  // }

  /// Reset face detection state to trigger listener on next detection
  void resetFaceDetection() {
    if (_faces.isNotEmpty) {
      _faces = [];
      if (!_isDisposed) {
        try {
          if (faceDetectedNotifier.value != false) {
            faceDetectedNotifier.value = false;
          }
        } catch (e) {
          // Notifier might be disposed, ignore
          LogHelper.logDebug(
            'error face_detector_service : resetFaceDetection $e',
          );
        }
      }
    }
  }

  dispose() {
    _faceDetector.close();
    if (!_isDisposed) {
      try {
        faceDetectedNotifier.dispose();
      } catch (_) {}
      _isDisposed = true;
    }
  }
}
