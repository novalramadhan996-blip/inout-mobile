// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:mobile_in_out/core/resources/injector/di.dart';
import 'package:mobile_in_out/core/resources/theme/app_style.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/routes/router_import.dart';
import 'package:mobile_in_out/core/routes/router_import.gr.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';
import 'package:mobile_in_out/core/utils/models/profile_model.dart';
import 'package:mobile_in_out/core/utils/widgets/app_bar_general.dart';
import 'package:mobile_in_out/core/utils/widgets/app_button.dart';
import 'package:mobile_in_out/core/utils/widgets/faces/camera_detection_preview.dart';
import 'package:mobile_in_out/feature/auth/provider/auth_provider.dart';
import 'package:mobile_in_out/feature/in_and_out/providers/in_out_provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mobile_in_out/feature/task/model/response_upload_file.dart';
import 'package:mobile_in_out/feature/task/model/response_upload_image.dart';
import 'package:mobile_in_out/feature/task/provider/task_provider.dart';
import 'package:provider/provider.dart';

@Deprecated(
  "Don't use this class"
  "deprecated since revamp checkin v2, please remove when apps already stable",
)
@RoutePage()
class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key});

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage>
    with WidgetsBindingObserver, RouteAware {
  late InOutProvider provider;
  late AuthProvider authProvider;
  late final TaskProvider _taskProvider;
  late Timer _timer;
  bool _isWaiting = true;
  bool _isPopBack = false;
  bool _isCheckIn = true;

  @override
  void initState() {
    provider = Provider.of<InOutProvider>(context, listen: false);
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    _taskProvider = sl<TaskProvider>();

    _startDelayTimer();
    startTimer();
    Future.microtask(() => provider.start());
    provider.initialize();
    provider.isDispose = false;
    provider.isCaptureImage = false;

    super.initState();

    loadIsCheckin();

    WidgetsBinding.instance.addObserver(this);
  }

  void loadIsCheckin() async {
    await provider.fetchCheckInLocal();
    setState(() {
      _isCheckIn = context.read<InOutProvider>().checkInResponse == null;
    });
  }

  List<NavigatorObserver> get observers => [RouterObserver()];

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      // make condition to check if the user is still face not detected please back to home
      if (mounted) context.router.popForced();
      stopTimer();

      String typeAttendence = '';
      if (_isCheckIn) {
        typeAttendence = 'Check In';
      } else {
        typeAttendence = 'Check Out';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Time out, You took too long to $typeAttendence !'),
            backgroundColor: AppColors.redColors,
          ),
        );
      }
    });
  }

  void _startDelayTimer() {
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isWaiting = false; // Set the waiting flag after 2 seconds
      });
    });
  }

  void stopTimer() {
    _timer.cancel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to RouterObserver
    final observer = observers.first;
    if (observer is RouterObserver) {
      var contextData = ModalRoute.of(context)!;
      observer.subscribe(this, contextData);
      if (_isPopBack == true) {
        WidgetsBinding.instance.addObserver(this);
        _isWaiting = true;
        _startDelayTimer();
        provider.isPictureTaken = false;
        provider.isCaptureImage = false;
        provider.start();
        startTimer();
      }
      if (contextData.isCurrent == false) {
        _isPopBack = true;
        WidgetsBinding.instance.removeObserver(this);
        stopTimer();
      } else {
        _isPopBack = false;
      }
    }
  }

  @override
  void dispose() {
    // Unsubscribe from RouterObserver
    final observer = observers.first;
    if (observer is RouterObserver) {
      observer.unsubscribe(this);
    }
    WidgetsBinding.instance.removeObserver(this);
    provider.isDispose = true;
    provider.disposeProvider();
    stopTimer();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        _startDelayTimer();
        provider.isPictureTaken = false;
        provider.isCaptureImage = false;
        provider.start();
        startTimer();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        stopTimer();
        _isWaiting = true;
        provider.cameraService.dispose();
    }
  }

  Future<void> onTap({required InOutProvider provider}) async {
    provider.isCaptureImage = true;
    await provider.takePicture(context);
    if (provider.faceDetectorService.faceDetected) {
      await Future.delayed(Duration(seconds: 1));
      ProfileModel? user = await provider.mlService.predict(
        user: authProvider.profileModel,
      );

      if (user != null) {
        provider.isPictureTaken = false;
        provider.isCaptureImage = false;
        provider.imagePath = provider.cameraService.imagePath;

        WidgetsBinding.instance.removeObserver(this);
        stopTimer();

        await Future.delayed(Duration(seconds: 1));
        if (!mounted) return;
        setState(() {
          provider.cameraService.dispose();
          _isWaiting = true;
        });

        final ResponseUploadImage resultUploadFile = await _taskProvider
            .uploadImage(File(provider.cameraService.imagePath ?? ''));
        final url = resultUploadFile.imageUrl;
        if (url != null && url.isNotEmpty) {
          provider.urlFace = url;
          setState(() {
            provider.cameraService.dispose();
            _isWaiting = false;
          });
          context.router.push(
            CheckInSubmitRoute(
              typeAbsence: _isCheckIn ? "checkIn" : "checkOut",
            ),
          );
        } else {
          context.router.popForced();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Upload foto failed'),
              backgroundColor: AppColors.redColors,
            ),
          );
        }
      }

      if (user == null) {
        LogHelper.logDebug("Debug checkin_page => user = null");
        provider.isPictureTaken = false;
        provider.isCaptureImage = false;
        provider.frameFaces();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Face not recognized'),
            backgroundColor: AppColors.redColors,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InOutProvider>(
      builder: (context, provider, _) {
        late Widget bodyTop;
        late Widget body;
        final disableRedBorder = !provider.faceDetectorService.disableButton;
        var isTap = false;

        body = CameraDetectionPreview();

        if (_isWaiting) {
          bodyTop = Center(child: CircularProgressIndicator());
        } else {
          bodyTop = Padding(
            padding: const EdgeInsets.all(15.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  body, // Body Face Detecion
                  Container(
                    height: 70,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: AppButton(
                      buttonName: 'Submit',
                      color: disableRedBorder
                          ? AppColors.primaryColor
                          : AppColors.greyColor,
                      onPress: () {
                        if (!disableRedBorder) {
                          return;
                        }
                        if (isTap == false) {
                          isTap = true;
                          onTap(provider: provider);
                        }
                      },
                    ),
                  ),
                ],
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
            title: 'Check Face',
            onBackPressed: () {
              context.router.popForced();
              provider.clearDataProvider();
              stopTimer();
            },
          ),
          body: bodyTop,
        );
      },
    );
  }
}
