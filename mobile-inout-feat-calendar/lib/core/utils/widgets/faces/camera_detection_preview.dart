// ignore_for_file: library_private_types_in_public_api

import 'package:mobile_in_out/core/resources/injector/di.dart';
import 'package:mobile_in_out/core/resources/local/camera_service.dart';
import 'package:mobile_in_out/core/resources/local/face_detector_service.dart';
import 'package:mobile_in_out/core/utils/painter/face_painter.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:mobile_in_out/feature/in_and_out/providers/in_out_provider.dart';

class CameraDetectionPreview extends StatefulWidget {
  const CameraDetectionPreview({super.key});

  @override
  _CameraDetectionPreviewState createState() => _CameraDetectionPreviewState();
}

class _CameraDetectionPreviewState extends State<CameraDetectionPreview> {
  final CameraService _cameraService = sl<CameraService>();
  final FaceDetectorService _faceDetectorService = sl<FaceDetectorService>();
  late InOutProvider _inOutProvider;

  Position? _position;
  String _formattedTime = '';

  @override
  void initState() {
    super.initState();
    _inOutProvider = sl<InOutProvider>();
    _getCurrentLocation();
    _getCurrentTime();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Transform.scale(
      scale: 1.0,
      child: AspectRatio(
        aspectRatio: MediaQuery.of(context).size.aspectRatio / .8,
        child: OverflowBox(
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.fitHeight,
            child: SizedBox(
              width: width,
              height: (() {
                final controller = _cameraService.cameraController;
                final initialized =
                    controller != null &&
                    _cameraService.controllerIsInitialized;
                if (initialized) {
                  try {
                    return width * controller.value.aspectRatio;
                  } catch (_) {
                    return width;
                  }
                }
                return width;
              })(),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  _buildCameraPreview(),
                  if (_faceDetectorService.faceDetected)
                    CustomPaint(
                      painter: FacePainter(
                        face: _faceDetectorService.faces[0],
                        imageSize: _cameraService.getImageSize(),
                      ),
                    ),
                  // Add timestamp and location to the UI
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Time: $_formattedTime',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_position != null)
                          Text(
                            'Lat: ${_position!.latitude}, Long: ${_position!.longitude}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build camera preview with robust disposal safety checks.
  /// Performs final validation before rendering CameraPreview to avoid
  /// race conditions where controller could be disposed between checks.
  Widget _buildCameraPreview() {
    try {
      // Check if provider is disposing
      if (_inOutProvider.isDisposing) {
        return SizedBox.shrink();
      }

      final controller = _cameraService.cameraController;

      // Guard 1: null check
      if (controller == null) return SizedBox.shrink();

      // Guard 2: disposed check
      if (_cameraService.isDisposed) return SizedBox.shrink();

      // Guard 3: initialized check
      if (!_cameraService.controllerIsInitialized) {
        return SizedBox.shrink();
      }

      // Guard 4: final safety wrap before CameraPreview
      return _SafeCameraPreview(controller: controller);
    } catch (e) {
      return SizedBox.shrink();
    }
  }

  // Get the current location (latitude and longitude)
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    Position position = await Geolocator.getCurrentPosition();
    if (!mounted) return;
    setState(() {
      _position = position;
    });
  }

  // Get the current timestamp
  void _getCurrentTime() {
    setState(() {
      _formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    });
  }
}

class _SafeCameraPreview extends StatelessWidget {
  final CameraController controller;

  const _SafeCameraPreview({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CameraValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        if (!value.isInitialized) {
          return const SizedBox.shrink();
        }
        try {
          return controller.buildPreview();
        } on CameraException {
          return const SizedBox.shrink();
        } catch (_) {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
