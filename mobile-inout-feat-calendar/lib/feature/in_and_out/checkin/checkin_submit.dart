// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:mobile_in_out/core/resources/constants/app_const.dart';
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
import 'package:mobile_in_out/core/utils/models/list_data_request.dart';
import 'package:mobile_in_out/core/utils/widgets/app_bar_general.dart';
import 'package:mobile_in_out/core/utils/widgets/app_button.dart';
import 'package:mobile_in_out/core/utils/widgets/app_input.dart';
import 'package:mobile_in_out/feature/auth/provider/auth_provider.dart';
import 'package:mobile_in_out/feature/history/model/group_shift_schedule_response.dart';
import 'package:mobile_in_out/feature/home/data/model/employee_detail_model.dart';
import 'package:mobile_in_out/feature/home/data/model/working_location.dart';
import 'package:mobile_in_out/feature/home/presentation/provider/home_provider.dart';
import 'package:mobile_in_out/feature/in_and_out/providers/in_out_provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_in_out/feature/in_and_out/providers/organization_provider.dart';
import 'package:mobile_in_out/feature/task/model/response_upload_image.dart';
import 'package:mobile_in_out/feature/task/provider/task_provider.dart';
import 'package:provider/provider.dart';

@Deprecated(
  "Don't use this class"
  "deprecated since revamp checkin v2, please remove when apps already stable",
)
@RoutePage()
class CheckInSubmitPage extends StatefulWidget {
  final String typeAbsence;
  const CheckInSubmitPage({super.key, required this.typeAbsence});

  @override
  State<CheckInSubmitPage> createState() => _CheckInSubmitPageState();
}

class _CheckInSubmitPageState extends State<CheckInSubmitPage> {
  late InOutProvider _inOutProvider;
  late AuthProvider _authProvider;
  late final TaskProvider _taskProvider;
  late HomeProvider _homeProvider;

  // comment because location not used this api, please remove when apps already publish and stable
  // late OrganizationProvider _organizationProvider;

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  bool _isEnableButton = true;
  bool _isWorkLocation = false;
  bool _isLoadingUploadImage = false;
  EmployeeDetailModel? _employeeDetail;

  @override
  void initState() {
    _inOutProvider = Provider.of<InOutProvider>(context, listen: false);
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _taskProvider = sl<TaskProvider>();
    _homeProvider = Provider.of<HomeProvider>(context, listen: false);

    // comment because location not used this api, please remove when apps already publish and stable
    // _organizationProvider = sl<OrganizationProvider>();

    _getCurrentPosition();

    super.initState();
  }

  void _getCurrentPosition() async {
    Future.microtask(() async {
      // Show loading dialog
      Dialogs.showLoadingDialog(context);

      // comment because location not used this api, please remove when apps already publish and stable
      // get work location
      // await _organizationProvider.getOrganization(
      //   ListDataRequest(
      //     page: 0,
      //     limit: 100,
      //     search: "",
      //     sortBy: "created",
      //     orderBy: "desc",
      //     filter: {"employee_id": _authProvider.profileModel.userId},
      //   ),
      // );

      // comment because not used, please remove when apps already publish and stable 1/12/2025
      // Get work shift
      // await _inOutProvider.getWorkSschedule();

      // Get current position
      await _inOutProvider.getCurrentPosition();

      await _homeProvider.getEmployeeDetail();
      _employeeDetail = _homeProvider.employeeDetail;

      setState(() {
        _isWorkLocation = getInOrUnknown();
      });

      // Close loading dialog
      Dialogs.dismissDialog(context);
    });
  }

  void _toggleButtonState() {
    setState(() {
      _isEnableButton = !_isEnableButton;
    });
  }

  Future<void> _onCheckIn() async {
    if (!_isEnableButton) return;

    _toggleButtonState();
    Dialogs.showLoadingDialog(context);

    try {
      final InOutProvider provider = context.read<InOutProvider>();
      final bool isCheckIn = widget.typeAbsence == AppConst.TYPE_CHECK_IN;

      await (isCheckIn ? provider.checkIn() : provider.checkOut());

      if (provider.state == RequestState.Error) {
        _showSnackBar(
          isCheckIn ? "Check In Failed" : "Check Out Failed",
          color: AppColors.redColors,
        );
        return;
      }

      if (provider.state == RequestState.Loaded) {
        _showSnackBar(
          isCheckIn ? "Check In Success" : "Check Out Success",
          color: AppColors.greenColor,
        );

        await _authProvider.fetchProfileNoSaveToLocal();
        if (widget.typeAbsence == AppConst.TYPE_CHECK_OUT) {
          await provider.deleteInOutLocal();
        }
        await provider.fetchCheckInLocal();
        context.read<HomeProvider>().markRefresh();
        // context.router.popForced(true);
        context.pop(true);
        context.pop(true);
      }
    } finally {
      Dialogs.dismissDialog(context);
      _toggleButtonState();
    }
  }

  Future<void> _showSnackBar(String message, {required Color color}) async {
    await scaffoldMessengerKey.currentState
        ?.showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: color,
            duration: const Duration(seconds: 2),
          ),
        )
        .closed;
  }

  bool getInOrUnknown() {
    final InOutProvider provider = Provider.of<InOutProvider>(
      context,
      listen: false,
    );
    bool inWorkLocation = false;

    if (_employeeDetail != null) {
      WorkingLocation? workingLocation = _employeeDetail?.workingLocation;
      if (workingLocation != null) {
        final double radiusInKm = (workingLocation.radius ?? 0) / 1000.0;

        final double workLatitude = workingLocation.latitude ?? 0;
        final double workLongitude = workingLocation.longitude ?? 0;

        final double currentLatitude = provider.currentPosition?.latitude ?? 0;
        final double currentLongitude =
            provider.currentPosition?.longitude ?? 0;

        final distanceInMeters = Geolocator.distanceBetween(
          workLatitude,
          workLongitude,
          currentLatitude,
          currentLongitude,
        );

        final distanceInKm = distanceInMeters / 1000;

        inWorkLocation = distanceInKm <= radiusInKm;

        if (inWorkLocation) {
          provider.setDistanceWorkLocation(distanceInKm);
        }
      }
    }

    return inWorkLocation;
  }

  // comment because location not used this api, please remove when apps already publish and stable
  // bool getInOrUnknownOld() {
  //   final InOutProvider provider = Provider.of<InOutProvider>(
  //     context,
  //     listen: false,
  //   );

  //   bool inWorkLocation = false;
  //   for (var item in _organizationProvider.organization) {
  //     if (inWorkLocation == false) {
  //       final double radiusInKm = (item.location?.radius ?? 0) / 1000.0;

  //       final double workLatitude = item.location?.latitude ?? 0;
  //       final double workLongitude = item.location?.longitude ?? 0;

  //       final double currentLatitude = provider.currentPosition?.latitude ?? 0;
  //       final double currentLongitude =
  //           provider.currentPosition?.longitude ?? 0;

  //       final distanceInMeters = Geolocator.distanceBetween(
  //         workLatitude,
  //         workLongitude,
  //         currentLatitude,
  //         currentLongitude,
  //       );

  //       final distanceInKm = distanceInMeters / 1000;

  //       inWorkLocation = distanceInKm <= radiusInKm;

  //       if (inWorkLocation) {
  //         provider.setDistanceWorkLocation(distanceInKm);
  //       }

  //       LogHelper.logDebug('debug distance -> location ${item.location?.locationName}');
  //       LogHelper.logDebug(
  //         'debug distance -> distanceInKm $distanceInKm vs radiusInKm $radiusInKm',
  //       );
  //       LogHelper.logDebug('debug distance -> inworklocation $inWorkLocation');
  //     }
  //   }

  //   return inWorkLocation;
  // }

  Future<void> _onBackPress() async {
    _inOutProvider.clearDataProvider();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (bool willPop) async {
        Future.microtask(() async {
          await _onBackPress();
        });
      },
      child: MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        home: Scaffold(
          bottomNavigationBar: AppButton(
            buttonName: widget.typeAbsence == AppConst.TYPE_CHECK_IN
                ? 'Check In'
                : 'Check Out',
            color: _isEnableButton ? AppColors.greenColor : AppColors.greyColor,
            onPress: () => _onCheckIn(),
          ).horizontalPadded(15).bottomPadded(15),
          appBar: AppBarGeneral(
            backgroundColor: AppColors.whiteColor,
            colorIcon: AppColors.primaryColor,
            styleTitle: AppStyle(
              color: AppColors.blackColor,
              weight: bold,
            ).headline2,
            colorTitle: AppColors.blackColor,
            title: widget.typeAbsence == AppConst.TYPE_CHECK_IN
                ? 'Check In Confirmation'
                : 'Check Out Confirmation',
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
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
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
                              provider.mySchedule ??
                                  GroupShiftScheduleResponse(),
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
                    ).horizontalPadded(16).bottomPadded(),

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
                            _isWorkLocation
                                ? "In work location"
                                : "Your location not in work location",
                            style: AppTheme.subtitle.copyWith(
                              color: _isWorkLocation
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
                      widget.typeAbsence == AppConst.TYPE_CHECK_IN
                          ? "Check In Time"
                          : "Check Out Time",
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
                      onTap: () async {
                        if (_isLoadingUploadImage) return;
                        final pickedFile = await ImagePicker().pickImage(
                          source: ImageSource.camera,
                        );
                        await processImage(pickedFile);
                      },

                      // deprecated code to pick image from gallery or camera, please remove when apps already publish production
                      // onTap: () {
                      //   showModalBottomSheet(
                      //     context: context,
                      //     builder: (BuildContext bc) {
                      //       return SafeArea(
                      //         child: Wrap(
                      //           children: <Widget>[
                      //             ListTile(
                      //               leading: const Icon(Icons.photo_library),
                      //               title: const Text('Photo from Gallery'),
                      //               onTap: () async {
                      //                 Navigator.pop(context);
                      //                 final pickedFile = await ImagePicker()
                      //                     .pickImage(
                      //                       source: ImageSource.gallery,
                      //                     );
                      //                 LogHelper.logDebug('Picked File: $pickedFile');
                      //                 if (pickedFile != null) {
                      //                   await processImage(pickedFile);
                      //                 }
                      //               },
                      //             ),
                      //             ListTile(
                      //               leading: const Icon(Icons.photo_camera),
                      //               title: const Text('Photo from Camera'),
                      //               onTap: () async {
                      //                 Navigator.pop(context);
                      //                 final pickedFile = await ImagePicker()
                      //                     .pickImage(
                      //                       source: ImageSource.camera,
                      //                     );
                      //                 await processImage(pickedFile);
                      //               },
                      //             ),
                      //           ],
                      //         ),
                      //       );
                      //     },
                      //   );
                      // },
                      child: Container(
                        height: 70,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xffD4F3F9),
                        ),
                        child: Center(
                          child: _isLoadingUploadImage
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Color(0xff187498),
                                  ),
                                )
                              : Row(
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
      ),
    );
  }

  Future<void> processImage(XFile? pickedFile) async {
    if (pickedFile != null) {
      setState(() {
        _isLoadingUploadImage = true;
      });
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
        setState(() {
          _isLoadingUploadImage = false;
        });
      }
    }
  }
}
