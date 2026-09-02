// ignore_for_file: depend_on_referenced_packages, implementation_imports

import 'dart:io';
import 'dart:math';
import 'dart:developer' as log;
import 'dart:typed_data';
import 'package:mobile_in_out/core/resources/constants/app_const.dart';
import 'package:mobile_in_out/core/utils/helper/image_converter.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';
import 'package:mobile_in_out/core/utils/models/profile_model.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tflite_flutter/src/bindings/tensorflow_lite_bindings_generated.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as imglib;

class MLService {
  Interpreter? _interpreter;
  double threshold = AppConst.FACE_ID_MEDIUM_THRESHOLD;
  bool _isDisposed = false;

  List _predictedData = [];
  List get predictedData => _predictedData;
  bool _hasPredictedData = false;
  bool get hasPredictedData => _hasPredictedData;

  Future initialize() async {
    _isDisposed = false;
    _hasPredictedData = false;
    _predictedData = [];
    late Delegate delegate;
    try {
      if (Platform.isAndroid) {
        delegate = GpuDelegateV2(
          options: GpuDelegateOptionsV2(
            isPrecisionLossAllowed: false,
            inferencePriority1: TfLiteGpuInferencePriority
                .TFLITE_GPU_INFERENCE_PRIORITY_MIN_LATENCY,
          ),
        );
      } else if (Platform.isIOS) {
        delegate = GpuDelegate(
          options: GpuDelegateOptions(
            allowPrecisionLoss: true,
            waitType: TFLGpuDelegateWaitType.TFLGpuDelegateWaitTypeActive,
          ),
        );
      }
      var interpreterOptions = InterpreterOptions()..addDelegate(delegate);

      _interpreter = await Interpreter.fromAsset(
        'assets/mobilefacenet.tflite',
        options: interpreterOptions,
      );
    } catch (e) {
      LogHelper.logDebug('Failed to load model.✅✅✅✅');
      LogHelper.logDebug("$e. 🔥🔥🔥🔥");
    }
  }

  void setCurrentPrediction(
    CameraImage cameraImage,
    Face? face, {
    bool? isDispose,
    bool? isCaptureImage,
  }) {
    if (_isDisposed) {
      LogHelper.logDebug('TRACE:ML setCurrentPrediction -> DISPOSED');
      return;
    }
    if (_interpreter == null) {
      LogHelper.logDebug('TRACE:ML setCurrentPrediction -> INTERPRETER NULL');
      return;
    }
    if (face == null) {
      LogHelper.logDebug('TRACE:ML setCurrentPrediction -> FACE NULL');
      return;
    }
    try {
      LogHelper.logDebug(
        'TRACE:ML setCurrentPrediction START image=${cameraImage.width}x${cameraImage.height} format=${cameraImage.format.group}',
      );
      List input = _preProcess(cameraImage, face, isDispose);

      if (input.isEmpty) {
        LogHelper.logDebug('TRACE:ML setCurrentPrediction -> INPUT EMPTY');
        return;
      }

      LogHelper.logDebug(
        'TRACE:ML setCurrentPrediction preProcess OK input.length=${input.length}',
      );
      input = input.reshape([1, 112, 112, 3]);
      List output = List.generate(1, (index) => List.filled(192, 0));

      _interpreter?.run(input, output);
      output = output.reshape([192]);

      _predictedData = List.from(output);
      _hasPredictedData = true;

      LogHelper.logDebug(
        'TRACE:ML setCurrentPrediction SUCCESS _predictedData.length=${_predictedData.length} first3=${_predictedData.take(3).toList()}',
      );
    } catch (e) {
      LogHelper.logDebug('TRACE:ML setCurrentPrediction ERROR: $e');
    }
  }

  // disable because model data only one, next create register for multiple model data with capture photo left, right, and straight position
  // Future<ProfileModel?> predict({required List<ProfileModel> users}) async {
  //   return _searchResult(_predictedData, users: users);
  // }

  Future<ProfileModel?> predict({required ProfileModel user}) async {
    LogHelper.logDebug(
      'TRACE:ML predict _predictedData.length=${_predictedData.length} _hasPredictedData=$_hasPredictedData user.modelData=${user.modelData?.length}',
    );
    return _searchResult(_predictedData, user: user);
  }

  Future<ProfileModel?> _searchResult(
    List predictedData, {
    required ProfileModel user,
  }) async {
    double minDist = 999;
    double currDist = 0.0;
    ProfileModel? predictedResult;

    LogHelper.logDebug(
      'TRACE:ML _searchResult predictedData.length=${predictedData.length} user.modelData.length=${user.modelData?.length}',
    );
    currDist = _euclideanDistance(user.modelData, predictedData);

    // For testing purpose, use fixed model data
    // currDist = _euclideanDistance(AppConst.modelDataDummy, predictedData);

    LogHelper.logDebug(
      'debug -> currDist $currDist treshold $threshold minDist $minDist',
    );
    LogHelper.logDebug(
      'debug -> model user ${user.modelData} vs predictData $predictedData',
    );

    if (currDist <= threshold && currDist < minDist) {
      minDist = currDist;
      predictedResult = user;
    }
    LogHelper.logDebug('debug -> predictedResult $predictedResult');
    return predictedResult;
  }

  List _preProcess(CameraImage image, Face faceDetected, bool? isDispose) {
    try {
      imglib.Image croppedImage = _cropFace(image, faceDetected, isDispose);
      imglib.Image img = imglib.copyResizeCropSquare(croppedImage, 112);

      Float32List imageAsList = imageToByteListFloat32(img);
      return imageAsList;
    } catch (e) {
      LogHelper.logDebug('Error during pre-processing: $e');
      return [];
    }
  }

  imglib.Image _cropFace(
    CameraImage image,
    Face faceDetected,
    bool? isDispose,
  ) {
    try {
      imglib.Image convertedImage = _convertCameraImage(image, isDispose);
      double x = faceDetected.boundingBox.left - 10.0;
      double y = faceDetected.boundingBox.top - 10.0;
      double w = faceDetected.boundingBox.width + 10.0;
      double h = faceDetected.boundingBox.height + 10.0;
      // return imglib.copyCrop(convertedImage, x: x.round(), y: y.round(), width: w.round(), height: h.round());
      return imglib.copyCrop(
        convertedImage,
        x.round(),
        y.round(),
        w.round(),
        h.round(),
      );
    } catch (e) {
      LogHelper.logDebug('Error during face cropping: $e');
      rethrow;
    }
  }

  imglib.Image _convertCameraImage(CameraImage image, bool? isDispose) {
    try {
      // var img = convertToImage(image, isDispose: isDispose) ?? imglib.Image(width: 1, height: 1); // A 1x1 default image
      // var img1 = imglib.copyRotate(img, angle: -90);
      LogHelper.logDebug(
        "convertToImage: format=${image.format.group}, planes=${image.planes.length}, isDispose=$isDispose",
      );
      var img = convertToImage(image, isDispose: isDispose);
      LogHelper.logDebug("convertToImage: img $img");
      var img1 = imglib.copyRotate(img!, -90);
      LogHelper.logDebug("convertToImage: img1 $img1");
      return img1;
    } catch (e) {
      LogHelper.logDebug('Error during image conversion: $e');
      rethrow;
    }
  }

  Float32List imageToByteListFloat32(imglib.Image image) {
    try {
      var convertedBytes = Float32List(1 * 112 * 112 * 3);
      var buffer = Float32List.view(convertedBytes.buffer);
      int pixelIndex = 0;

      for (var i = 0; i < 112; i++) {
        for (var j = 0; j < 112; j++) {
          var pixel = image.getPixel(j, i);
          buffer[pixelIndex++] = (imglib.getRed(pixel) - 128) / 128;
          buffer[pixelIndex++] = (imglib.getGreen(pixel) - 128) / 128;
          buffer[pixelIndex++] = (imglib.getBlue(pixel) - 128) / 128;
          // buffer[pixelIndex++] = (pixel.r - 128) / 128;
          // buffer[pixelIndex++] = (pixel.g - 128) / 128;
          // buffer[pixelIndex++] = (pixel.b - 128) / 128;
        }
      }
      return convertedBytes.buffer.asFloat32List();
    } catch (e) {
      LogHelper.logDebug('Error during image to byte list conversion: $e');
      return Float32List(0);
    }
  }

  // disable because model data only one, next create register for multiple model data with capture photo left, right, and straight position
  // Future<ProfileModel?> _searchResult(
  //   List predictedData, {
  //   required List<ProfileModel> users,
  // }) async {
  //   double minDist = 999;
  //   double currDist = 0.0;
  //   ProfileModel? predictedResult;

  //   LogHelper.logDebug('users.length=> ${users.length}');

  //   for (ProfileModel u in users) {
  //     // LogHelper.logDebug('Debug ->u.modelData ${u.modelData}');
  //     // LogHelper.logDebug('Debug -> predictedData ${predictedData}');

  //     currDist = _euclideanDistance(u.modelData, predictedData);
  //     // For testing purpose, use fixed model data
  //     // currDist = _euclideanDistance(AppConst.modelDataDummy, predictedData);

  //     LogHelper.logDebug(
  //       'debug -> currDist $currDist treshold $threshold minDist $minDist',
  //     );

  //     if (currDist <= threshold && currDist < minDist) {
  //       minDist = currDist;
  //       predictedResult = u;
  //     }
  //   }
  //   LogHelper.logDebug('debug -> predictedResult $predictedResult');
  //   return predictedResult;
  // }

  double _euclideanDistance(List? e1, List? e2) {
    LogHelper.logDebug(
      'TRACE:ML _euclideanDistance e1=${e1?.length} e2=${e2?.length}',
    );

    // Jika salah satu list null atau kosong, kembalikan nilai besar (bukan exception)
    if (e1 == null || e2 == null || e1.isEmpty || e2.isEmpty) {
      LogHelper.logDebug(
        'TRACE:ML _euclideanDistance -> NULL or EMPTY returning infinity',
      );
      return double.infinity; // nilai besar supaya tidak lolos threshold
    }

    // Pastikan panjang list sama (kalau tidak, ambil minimal panjang)
    int len = min(e1.length, e2.length);

    double sum = 0.0;
    for (int i = 0; i < len; i++) {
      sum += pow((e1[i] - e2[i]), 2);
    }
    return sqrt(sum);
  }

  void setPredictedData(value) {
    _predictedData = value;
    _hasPredictedData = value != null && value is List && value.isNotEmpty;
  }

  dispose() {
    _isDisposed = true;
    _hasPredictedData = false;
    _predictedData = [];
    _interpreter?.close();
    _interpreter = null;
  }
}
