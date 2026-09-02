import 'dart:developer';
import 'dart:io';

import 'package:mobile_in_out/core/resources/theme/app_style.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/utils/painter/face_painter.dart';
import 'package:mobile_in_out/core/utils/widgets/app_bar_general.dart';
import 'package:mobile_in_out/core/utils/widgets/app_button.dart';
import 'dart:math' as math;
import 'package:mobile_in_out/feature/profile/providers/profile_provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

@RoutePage()
class FaceregistrationPage extends StatefulWidget {
  const FaceregistrationPage({super.key});

  @override
  State<FaceregistrationPage> createState() => _FaceregistrationPageState();
}

class _FaceregistrationPageState extends State<FaceregistrationPage> {
  late final ProfileProvider provider;

  @override
  void initState() {
    // Initialize
    provider = context.read<ProfileProvider>();
    Future.microtask(() => provider.start());
    super.initState();
  }

  @override
  void dispose() {
    provider.disposeProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {

        const double mirror = math.pi;
        late Widget body;
        final width = MediaQuery.of(context).size.width;
        final height = MediaQuery.of(context).size.height;
        final disableRedBorder = !provider.faceDetectorService.disableButton;

        if (provider.initializing) {
          body = const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!provider.initializing && provider.pictureTaken) {
          body = SizedBox(
            width: width,
            height: height / 1.2,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(mirror),
              child: FittedBox(
                fit: BoxFit.cover,
                child: Image.file(File(provider.imagePath!)),
              ),
            ),
          );
        }

        if (!provider.initializing && !provider.pictureTaken) {
          body = Transform.scale(
            scale: 1.0,
            child: AspectRatio(
              aspectRatio: MediaQuery.of(context).size.aspectRatio / .8,
              child: OverflowBox(
                alignment: Alignment.center,
                child: FittedBox(
                  // fit: BoxFit.fitHeight,
                  child: SizedBox(
                    width: width,
                    height: provider.cameraService.cameraController != null ? width * (provider.cameraService.cameraController?.value.aspectRatio ?? 1.0) : width,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        provider.cameraService.cameraController != null ? CameraPreview(provider.cameraService.cameraController!) : SizedBox.shrink(),
                        CustomPaint(
                          painter: FacePainter(
                            face: provider.faceDetected,
                            imageSize: provider.imageSize is Size ? (provider.imageSize as Size) : Size(width, height),
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

        return Scaffold(
          appBar: AppBarGeneral(
            backgroundColor: AppColors.whiteColor,
            colorIcon: AppColors.primaryColor,
            styleTitle: AppStyle(
              color: AppColors.blackColor,
              weight: bold,
            ).headline2,
            colorTitle: AppColors.blackColor,
            title: 'Face Registration',
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
          floatingActionButton: !provider.initializing && provider.pictureTaken ? FloatingActionButton(
            foregroundColor: AppColors.whiteColor,
            onPressed: () {
              provider.reload();
              context.router.popForced();
            },
            child: const Icon(Icons.restore_rounded, color: AppColors.redColors),
          ) : null,
          body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Body Face Detecion
                  body,

                  Visibility(
                    visible: !provider.initializing && !provider.pictureTaken,
                    child: Container(
                      height: 70,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: AppButton(
                        color: disableRedBorder ? AppColors.primaryColor : AppColors.greyColor,
                        buttonName: 'Register',
                        onPress: () {
                          if (!disableRedBorder) {
                            return;
                          }
                          provider.onShot(context);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}
