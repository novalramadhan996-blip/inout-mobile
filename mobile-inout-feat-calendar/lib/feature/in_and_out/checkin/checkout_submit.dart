// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:mobile_in_out/core/global/provider/location_provider.dart';
import 'package:mobile_in_out/core/resources/constants/assets.dart';
import 'package:mobile_in_out/core/resources/injector/di.dart';
import 'package:mobile_in_out/core/resources/theme/app_style.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/resources/theme/theme.dart';
import 'package:mobile_in_out/core/routes/router_import.gr.dart';
import 'package:mobile_in_out/core/utils/dialogs.dart';
import 'package:mobile_in_out/core/utils/enum_state.dart';
import 'package:mobile_in_out/core/utils/extensions/date_extension.dart';
import 'package:mobile_in_out/core/utils/extensions/widget_extension.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';
import 'package:mobile_in_out/core/utils/models/list_data_request.dart';
import 'package:mobile_in_out/core/utils/models/schedule_model.dart';
import 'package:mobile_in_out/core/utils/widgets/app_bar_general.dart';
import 'package:mobile_in_out/core/utils/widgets/app_button.dart';
import 'package:mobile_in_out/core/utils/widgets/app_input.dart';
import 'package:mobile_in_out/feature/auth/provider/auth_provider.dart';
import 'package:mobile_in_out/feature/history/model/group_shift_schedule_response.dart';
import 'package:mobile_in_out/feature/in_and_out/providers/in_out_provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_in_out/feature/task/model/response_upload_image.dart';
import 'package:mobile_in_out/feature/task/provider/task_provider.dart';
import 'package:provider/provider.dart';

@Deprecated(
  "Don't use this class, alternative please using class CheckInSubmitPage, "
  "deprecated since merge page checkin submit with checkout submit, please remove when apps already stable",
)
@RoutePage()
class CheckOutSubmitPage extends StatefulWidget {
  const CheckOutSubmitPage({super.key});

  @override
  State<CheckOutSubmitPage> createState() => _CheckOutSubmitPageState();
}

class _CheckOutSubmitPageState extends State<CheckOutSubmitPage> {
  late InOutProvider inOutProvider;
  late LocationProvider locationProvider;
  late AuthProvider authProvider;
  late final TaskProvider _taskProvider;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  bool _isEnableButton = true;

  @override
  void initState() {
    inOutProvider = Provider.of<InOutProvider>(context, listen: false);
    locationProvider = Provider.of<LocationProvider>(context, listen: false);
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    _taskProvider = sl<TaskProvider>();

    _getCurrentPosition();
    super.initState();
  }

  void _getCurrentPosition() async {
    Future.microtask(() async {
      // Show loading dialog
      Dialogs.showLoadingDialog(context);

      // Get work shift
      await inOutProvider.getWorkSschedule(
        // request: ListDataRequest(
        //   page: 0,
        //   limit: 100,
        //   search: "",
        //   sortBy: "created",
        //   orderBy: "desc",
        //   filter: {
        //     "employee_id": "FJonup6xBd6TsNenEJAUErzHh3uAuDFuF4FqvuIjW4QjTUIhEp",
        //   },
        // )
      );

      // Get current position
      await inOutProvider.getCurrentPosition();

      // Close loading dialog
      Dialogs.dismissDialog(context);
    });
  }

  bool getInOrUnknown() {
    final InOutProvider provider = Provider.of<InOutProvider>(
      context,
      listen: false,
    );
    final double radiusInKm = (provider.mySchedule?.radius ?? 0) / 1000.0;
    bool? inWorkLocation;

    final double workLatitude =
        authProvider.profileModel.location?.latitude ?? 0;
    final double workLongitude =
        authProvider.profileModel.location?.longitude ?? 0;

    final double currentLatitude = provider.currentPosition?.latitude ?? 0;
    final double currentLongitude = provider.currentPosition?.longitude ?? 0;

    final distanceInMeters = Geolocator.distanceBetween(
      workLatitude,
      workLongitude,
      currentLatitude,
      currentLongitude,
    );

    final distanceInKm = distanceInMeters / 1000;

    inWorkLocation = distanceInKm <= radiusInKm;

    return inWorkLocation;
  }

  void _toggleButtonState() {
    setState(() {
      _isEnableButton = !_isEnableButton;
    });
  }

  void _onCheckOut() async {
    if (_isEnableButton) {
      _toggleButtonState();
      Dialogs.showLoadingDialog(context);
      final InOutProvider provider = Provider.of<InOutProvider>(
        context,
        listen: false,
      );
      final nrp = authProvider.profileModel.userId ?? "";
      await provider.checkOut().then((_) async {
        LogHelper.logDebug(
          'Debug -> checkout_submit : Check Out State: ${provider.state} ✅',
        );
        if (provider.state == RequestState.Error) {
          Dialogs.dismissDialog(context);
          await scaffoldMessengerKey.currentState
              ?.showSnackBar(
                const SnackBar(
                  content: Text('Check In Failed'),
                  backgroundColor: AppColors.redColors,
                  duration: Duration(seconds: 2),
                ),
              )
              .closed;
          _toggleButtonState();
          return;
        }

        if (provider.state == RequestState.Loaded) {
          Dialogs.dismissDialog(context);

          await scaffoldMessengerKey.currentState
              ?.showSnackBar(
                const SnackBar(
                  content: Text('Check Out Success'),
                  backgroundColor: AppColors.greenColor,
                  duration: Duration(seconds: 2),
                ),
              )
              .closed;

          await authProvider.fetchProfileNoSaveToLocal();
          await provider.deleteInOutLocal();
          await provider.fetchCheckInLocal();

          context.router.popForced();
        }
      });
    } else {
      return;
    }
  }

  Future<void> _onBackPress() async {
    inOutProvider.clearDataProvider();
    // inOutProvider.disposeProvider();
    // context.router.popForced();
    LogHelper.logDebug('Debug -> checkin_submit : _onBackPress');
  }

  @override
  Widget build(BuildContext context) {
    return
    // PopScope(
    //   onPopInvoked: (bool willPop) async {
    //     LogHelper.logDebug('Debug -> checkin_submit : onPopInvoked $willPop');
    //     Future.microtask(() async {
    //       await _onBackPress();
    //     });
    //   },
    //   child:
    MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: Scaffold(
        bottomNavigationBar: AppButton(
          buttonName: 'Check Out',
          color: _isEnableButton ? AppColors.greenColor : AppColors.greyColor,
          onPress: () => _onCheckOut(),
        ).horizontalPadded(15).bottomPadded(15),
        appBar: AppBarGeneral(
          backgroundColor: AppColors.whiteColor,
          colorIcon: AppColors.primaryColor,
          styleTitle: AppStyle(
            color: AppColors.blackColor,
            weight: bold,
          ).headline2,
          colorTitle: AppColors.blackColor,
          title: 'Check Out Confirmation',
        ),
        body: Consumer<InOutProvider>(
          builder: (context, provider, _) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Confirmed!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ).horizontalPadded(15),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xffD4F3F9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info, size: 15).rightPadded(10),
                        const Text(
                          'Please make sure you are in the right location!',
                          style: TextStyle(fontSize: 12, color: Colors.black),
                        ),
                      ],
                    ),
                  ).topPadded(12).horizontalPadded(15),

                  const Divider(
                    color: Color(0xffF1F5F9),
                    thickness: 10,
                  ).verticalPadded(24),

                  Text(
                    'Work Location',
                    style: AppTheme.bodyText.copyWith(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ).horizontalPadded(15),

                  InkWell(
                    onTap: () {
                      context.router.push(
                        MapRoute(
                          currentPosition: provider.currentPosition!,
                          detailAddress:
                              provider.currentAddress ?? "Unknown Location",
                          workLocation: [
                            // provider.mySchedule ?? ScheduleModel(),
                            provider.mySchedule ?? GroupShiftScheduleResponse(),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.greyColor,
                          width: 1,
                        ),
                      ),
                      child: provider.currentPosition != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                'https://maps.googleapis.com/maps/api/staticmap?center=${provider.currentPosition!.latitude},${provider.currentPosition!.longitude}&zoom=15&size=400x200&markers=color:red%7Clabel:C%7C${provider.currentPosition!.latitude},${provider.currentPosition!.longitude}&key=AIzaSyDs_YJEqyaAlKaFH-XaMyp8L6Hua7U05D0',
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Center(child: CircularProgressIndicator()),
                    ),
                  ).horizontalPadded(15).topPadded(16).bottomPadded(16),

                  Text(
                    "Current Location:",
                    style: AppTheme.bodyText.copyWith(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ).horizontalPadded(15).bottomPadded(5),

                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xffF1F5F9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      provider.currentAddress ?? "Unknown Location",
                      style: AppTheme.subtitle,
                    ).horizontalPadded(15),
                  ).horizontalPadded(16),

                  Container(
                    padding: const EdgeInsets.all(8),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xffF1F5F9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: AppColors.greyColor,
                        ),
                        Text(
                          getInOrUnknown()
                              ? "In work location"
                              : "Your location not in work location",
                          style: AppTheme.subtitle.copyWith(
                            color: getInOrUnknown()
                                ? AppColors.blackColor
                                : AppColors.redColors,
                          ),
                        ).horizontalPadded(15),
                      ],
                    ),
                  ).horizontalPadded(16),

                  const Divider(
                    color: Color(0xffF1F5F9),
                    thickness: 10,
                  ).verticalPadded(24),

                  Text(
                    "Check Out Time",
                    style: AppTheme.bodyText.copyWith(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ).horizontalPadded(15),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Time", style: AppTheme.subtitle),
                      Text(
                        DateTime.now().formatTime(),
                        style: AppTheme.subtitle.copyWith(
                          color: AppColors.blackColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ).horizontalPadded(15),

                  const Divider(
                    color: AppColors.greyColor,
                    thickness: 1,
                  ).horizontalPadded(15).verticalPadded(0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Date", style: AppTheme.subtitle),
                      Text(
                        DateTime.now().toFormattedDate(),
                        style: AppTheme.subtitle.copyWith(
                          color: AppColors.blackColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ).horizontalPadded(15),

                  const Divider(
                    color: Color(0xffF1F5F9),
                    thickness: 10,
                  ).verticalPadded(24),

                  Text(
                    'Notes',
                    style: AppTheme.bodyText.copyWith(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ).horizontalPadded(15),
                  AppInput(
                    controller: provider.noteCtrl,
                    hintText: 'Write your note here',
                    onChanged: (value) {},
                    maxLines: 4,
                  ).horizontalPadded(15),

                  const Divider(
                    color: Color(0xffF1F5F9),
                    thickness: 10,
                  ).verticalPadded(24),

                  Text(
                    'Upload Photo',
                    style: AppTheme.bodyText.copyWith(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ).horizontalPadded(15).bottomPadded(),

                  // Show Image and can delete picked image
                  if (provider.imageFile != null) ...[
                    Consumer<InOutProvider>(
                      builder: (context, watch, _) {
                        return Stack(
                          children: [
                            Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.greyColor,
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  File(watch.imageFile!.path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => watch.deleteImage(),
                              ),
                            ),
                          ],
                        );
                      },
                    ).horizontalPadded(16),
                    const SizedBox(height: 10),
                  ],

                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext bc) {
                          return SafeArea(
                            child: Wrap(
                              children: <Widget>[
                                ListTile(
                                  leading: const Icon(Icons.photo_library),
                                  title: const Text('Photo from Gallery'),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    final pickedFile = await ImagePicker()
                                        .pickImage(source: ImageSource.gallery);
                                    LogHelper.logDebug(
                                      'Picked File: $pickedFile',
                                    );
                                    if (pickedFile != null) {
                                      await processImage(pickedFile);
                                    }
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.photo_camera),
                                  title: const Text('Photo from Camera'),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    final pickedFile = await ImagePicker()
                                        .pickImage(source: ImageSource.camera);
                                    await processImage(pickedFile);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      height: 70,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xffD4F3F9),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(Assets.icAddPhoto, width: 24),
                          const SizedBox(width: 10),
                          Text(
                            "Tap to Upload Photo",
                            style: AppTheme.subtitle.copyWith(
                              color: const Color(0xff187498),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ).horizontalPadded(15),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
      // )
    );
  }

  Future<void> processImage(XFile? pickedFile) async {
    if (pickedFile != null) {
      final filePath = pickedFile.path;
      XFile? compressedFile;
      int quality = 100;
      int targetSize = 200 * 1024; // 200KB in bytes

      // Loop until the file is less than or equal to 200KB
      do {
        compressedFile = await FlutterImageCompress.compressAndGetFile(
          filePath,
          '$filePath.jpg',
          quality: quality,
        );

        final fileSize = await compressedFile?.length();
        if (fileSize != null && fileSize <= targetSize) {
          break; // Stop if file size is less than or equal to 200KB
        }

        quality -= 5; // Reduce quality to compress further
      } while (quality > 0);

      if (compressedFile != null) {
        final bytes = await compressedFile.readAsBytes();
        final base64Image = base64Encode(bytes);

        final ResponseUploadImage resultUploadFile = await _taskProvider
            .uploadImage(File(compressedFile.path));
        final url = resultUploadFile.imageUrl;

        if (url != null && url.isNotEmpty) {
          context.read<InOutProvider>()
            ..setImageBase64(base64Image)
            ..setImageFile(pickedFile)
            ..setUrlImagePath(url);
        }
      }
    }
  }
}
