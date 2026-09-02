// ignore_for_file: use_build_context_synchronously
import 'dart:io';

import 'package:mobile_in_out/core/resources/constants/assets.dart';
import 'package:mobile_in_out/core/resources/theme/app_style.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/resources/theme/theme.dart';
import 'package:mobile_in_out/core/routes/router_import.gr.dart';
import 'package:mobile_in_out/core/utils/dialogs.dart';
import 'package:mobile_in_out/core/utils/enum_state.dart';
import 'package:mobile_in_out/core/utils/extensions/date_extension.dart';
import 'package:mobile_in_out/core/utils/extensions/widget_extension.dart';
import 'package:mobile_in_out/core/utils/localizations/app_translations.dart';
import 'package:mobile_in_out/core/utils/models/history/absence_history_model.dart';
import 'package:mobile_in_out/core/utils/models/list_data_request.dart';
import 'package:mobile_in_out/core/utils/widgets/app_bar_general.dart';
import 'package:mobile_in_out/core/utils/widgets/app_button.dart';
import 'package:mobile_in_out/core/utils/widgets/app_form_profile.dart';
import 'package:mobile_in_out/core/utils/widgets/app_image_profile_rounded.dart';
import 'package:mobile_in_out/feature/auth/provider/auth_provider.dart';
import 'package:mobile_in_out/feature/history/provider/history_provider.dart';
import 'package:mobile_in_out/feature/home/data/model/employee_detail_model.dart';
import 'package:mobile_in_out/feature/home/presentation/provider/home_provider.dart';
import 'package:mobile_in_out/feature/in_and_out/providers/in_out_provider.dart';
import 'package:mobile_in_out/feature/profile/providers/profile_provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ProfileProvider provider;
  late AuthProvider authProvider;
  late InOutProvider _inoutProvider;
  late HomeProvider _homeProvider;
  late HistoryProvider _historyProvider;

  String _workLocation = '';
  String _gender = '';
  String _idCard = '';
  String _employeCode = '';
  String _division = '';
  String _position = '';
  AbsenceHistoryModel _history = AbsenceHistoryModel();

  @override
  void initState() {
    provider = context.read<ProfileProvider>();
    authProvider = context.read<AuthProvider>();
    _inoutProvider = context.read<InOutProvider>();
    _homeProvider = Provider.of<HomeProvider>(context, listen: false);
    _historyProvider = context.read<HistoryProvider>();

    initProviderAuth();

    Future.microtask(() {
      _getWorkLocation();
      _getHistory();
    });

    super.initState();
  }

  void initProviderAuth() async {
    await authProvider.fetchProfileNoSaveToLocal();
    await provider.fetchProfileFromApi(
      userId: authProvider.profileModel.userId ?? '',
    );

    final userId = authProvider.profileModel.userId;
    if (userId != null && userId.isNotEmpty) {
      _inoutProvider.getGroupShiftList(
        request: ListDataRequest(
          page: 0,
          limit: 100,
          search: "",
          sortBy: "created",
          orderBy: "desc",
          filter: {"employee_id": userId},
        ),
      );
      _inoutProvider.getWorkSschedule(
        request: ListDataRequest(
          page: 0,
          limit: 100,
          search: "",
          sortBy: "created",
          orderBy: "desc",
          filter: {
            "employee_id": userId,
            "business_day_id": DateTime.now().weekday,
          },
        ),
      );
    }
  }

  void _getHistory() async {
    await _historyProvider.getHistory(
      ListDataRequest(
        page: 0,
        limit: 100,
        search: "",
        orderBy: "desc",
        sortBy: "created",
        filter: {"employee_id": authProvider.profileModel.userId},
      ),
    );

    if (_historyProvider.history.isNotEmpty) {
      setState(() {
        _history = _historyProvider.history.first;
      });

      DateTime dateTimeIn;
      DateTime dateTimeOut;
      try {
        if (_history.timeIn != '') {
          dateTimeIn = DateTime.parse(_history.timeIn!);
          if (mounted) {
            setState(() {
              provider.timeInCtrl.text = dateTimeIn.formatTime24Hours();
            });
          }
        }

        if (_history.timeOut != '') {
          dateTimeOut = DateTime.parse(_history.timeOut!);
          if (mounted) {
            setState(() {
              provider.timeOutCtrl.text = dateTimeOut.formatTime24Hours();
            });
          }
        }
      } catch (e) {}

      provider.locationCtrl.text = _history.addressIn ?? '';
    }
  }

  Future<void> _getWorkLocation() async {
    await _homeProvider.getEmployeeDetail();
    EmployeeDetailModel? employeeDetail = _homeProvider.employeeDetail;
    setState(() {
      _workLocation = employeeDetail.workingLocation?.locationName ?? '';
      _gender = employeeDetail.gender ?? '';
      _idCard = employeeDetail.idcard ?? '';
      _division = employeeDetail.organization?.organizationName ?? '';
      _position = employeeDetail.jobTitle?.jobTitleName ?? '';
      _employeCode = employeeDetail.employeeCode ?? '';
    });

    provider.genderCtrl.text = _gender;
    provider.idCardCtrl.text = _idCard;
    provider.divisionCtrl.text = _division;
    provider.positionCtrl.text = _position;
    provider.employIdCtrl.text = _employeCode;
  }

  Future<void> pickImageWithPermission({bool? isFromCamera = true}) async {
    PermissionStatus cameraPermissionStatus = await Permission.camera.status;
    PermissionStatus storagePermissionStatus = await Permission.storage.status;

    if (cameraPermissionStatus.isGranted && storagePermissionStatus.isGranted) {
      pickFile(isFromCamera: isFromCamera);
    } else {
      Map<Permission, PermissionStatus> permissionStatuses = await [
        Permission.camera,
        Permission.storage,
      ].request();

      if (permissionStatuses[Permission.camera]!.isGranted &&
          permissionStatuses[Permission.storage]!.isGranted) {
        pickFile(isFromCamera: isFromCamera);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppTranslations.translate('permission_denied')),
          ),
        );
      }
    }
  }

  Future<void> pickFile({bool? isFromCamera = true}) async {
    var picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: isFromCamera == true ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 50,
      preferredCameraDevice: CameraDevice.front,
      requestFullMetadata: false,
    );

    if (pickedFile != null) {
      provider.setImageProfilePath(pickedFile.path);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTranslations.translate('no_image_selected'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBarGeneral(
            backgroundColor: AppColors.whiteColor,
            colorIcon: AppColors.primaryColor,
            styleTitle: AppStyle(
              color: AppColors.blackColor,
              weight: bold,
            ).headline2,
            colorTitle: AppColors.blackColor,
            title: AppTranslations.translate('profile'),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Image with Edit Icon
                    Stack(
                      children: [
                        Center(
                          child: Consumer<AuthProvider>(
                            builder: (context, watch, _) {
                              var profileUrl = watch.profileModel.profileUrl;
                              String initialName =
                                  watch.profileModel.name ?? "Unknown";
                              return AppImageProfileRounded(
                                width: 100,
                                height: 100,
                                profileUrl:
                                    profileUrl != null && profileUrl != ""
                                    ? "https://inout-dev.2ndc.app/thumbnail/$profileUrl"
                                    : "",
                                initialName: initialName[0].toUpperCase(),
                              );
                            },
                          ),
                        ),
                        // Positioned(
                        //   right: -90,
                        //   left: 0,
                        //   bottom: 0,
                        //   child: GestureDetector(
                        //     onTap: () {
                        //       showModalBottomSheet(
                        //         context: context,
                        //         builder: (context) {
                        //           return SizedBox(
                        //             height: 250,
                        //             child: Column(
                        //               children: [
                        //                 ListTile(
                        //                   leading: const Icon(Icons.camera_alt),
                        //                   title: Text(
                        //                     AppTranslations.translate('camera'),
                        //                   ),
                        //                   onTap: () async {
                        //                     Navigator.pop(context);
                        //                     pickImageWithPermission();
                        //                   },
                        //                 ),
                        //                 ListTile(
                        //                   leading: const Icon(Icons.photo),
                        //                   title: Text(
                        //                     AppTranslations.translate(
                        //                       'gallery',
                        //                     ),
                        //                   ),
                        //                   onTap: () async {
                        //                     Navigator.pop(context);
                        //                     pickImageWithPermission(
                        //                       isFromCamera: false,
                        //                     );
                        //                   },
                        //                 ),
                        //               ],
                        //             ),
                        //           );
                        //         },
                        //       );
                        //     },
                        //     child: const CircleAvatar(
                        //       radius: 15,
                        //       backgroundColor: Colors.blue,
                        //       child: Icon(
                        //         Icons.edit,
                        //         color: Colors.white,
                        //         size: 18,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            buttonName: AppTranslations.translate('activity'),
                            onPress: () {
                              context.router.push(const HistoryRoute());
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppButton(
                            buttonName: AppTranslations.translate(
                              'working_shift',
                            ),
                            onPress: () {
                              context.router.push(const GroupListRoute());
                            },
                          ),
                        ),
                      ],
                    ),

                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.asset(Assets.icMiniLoc, width: 35),
                              const SizedBox(width: 10),
                              Text(
                                AppTranslations.translate('work_information'),
                                style: AppTheme.bodyText.copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                          Consumer<InOutProvider>(
                            builder: (context, inOutprovider, _) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xffF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppTranslations.translate('location'),
                                      style: AppTheme.bodyText.copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _workLocation,
                                      style: AppTheme.bodyText.copyWith(
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Divider(
                                      color: AppColors.blackColor,
                                      thickness: 1,
                                    ),

                                    // Time In
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                AppTranslations.translate(
                                                  'time_in',
                                                ),
                                                style: AppTheme.bodyText
                                                    .copyWith(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              Text(
                                                inOutprovider
                                                        .mySchedule
                                                        ?.shiftStartTime ??
                                                    '',
                                                style: AppTheme.bodyText
                                                    .copyWith(fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                AppTranslations.translate(
                                                  'time_out',
                                                ),
                                                style: AppTheme.bodyText
                                                    .copyWith(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              Text(
                                                inOutprovider
                                                        .mySchedule
                                                        ?.shiftEndTime ??
                                                    '',
                                                style: AppTheme.bodyText
                                                    .copyWith(fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                AppTranslations.translate(
                                                  'day',
                                                ),
                                                style: AppTheme.bodyText
                                                    .copyWith(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              Text(
                                                getDayName(
                                                  int.tryParse(
                                                        inOutprovider
                                                                .mySchedule
                                                                ?.businessDay
                                                                ?.businessDayId
                                                                .toString() ??
                                                            '0',
                                                      ) ??
                                                      0,
                                                ),
                                                style: AppTheme.bodyText
                                                    .copyWith(fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ).topPadded(6);
                            },
                          ),
                        ],
                      ),
                    ).topPadded(8).bottomPadded(8),

                    const SizedBox(height: 20),

                    // Profile Info Section
                    Text(
                      AppTranslations.translate('profile_info'),
                      style: AppTheme.heading5.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppFormProfile(
                      readOnly: true,
                      label: AppTranslations.translate('name'),
                      hinttext: AppTranslations.translate('your_name_hint'),
                      onchanged: (value) {},
                      controller: provider.nameCtrl,
                    ),
                    AppFormProfile(
                      readOnly: true,
                      label: AppTranslations.translate('email'),
                      hinttext: AppTranslations.translate('your_email_hint'),
                      onchanged: (value) {},
                      controller: provider.emailCtrl,
                    ),
                    AppFormProfile(
                      readOnly: true,
                      label: AppTranslations.translate('phone_number'),
                      hinttext: AppTranslations.translate('your_phone_hint'),
                      onchanged: (value) {},
                      controller: provider.phoneCtrl,
                    ),
                    AppFormProfile(
                      readOnly: true,
                      label: AppTranslations.translate('date_of_birth'),
                      hinttext: AppTranslations.translate('your_dob_hint'),
                      onchanged: (value) {},
                      controller: provider.dobCtrl,
                    ),
                    AppFormProfile(
                      readOnly: true,
                      label: AppTranslations.translate('gender'),
                      hinttext: AppTranslations.translate('your_gender_hint'),
                      onchanged: (value) {},
                      controller: provider.genderCtrl,
                    ),
                    const SizedBox(height: 20),

                    // Employee Info Section
                    Text(
                      AppTranslations.translate('employee_info'),
                      style: AppTheme.heading5.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppFormProfile(
                      readOnly: true,
                      label: AppTranslations.translate('id_card'),
                      hinttext: AppTranslations.translate('your_id_card_hint'),
                      onchanged: (value) {},
                      controller: provider.idCardCtrl,
                    ),
                    AppFormProfile(
                      readOnly: true,
                      label: AppTranslations.translate('nrp'),
                      hinttext: AppTranslations.translate('your_nrp_hint'),
                      onchanged: (value) {},
                      controller: provider.employIdCtrl,
                    ),
                    AppFormProfile(
                      readOnly: true,
                      label: AppTranslations.translate('division'),
                      hinttext: AppTranslations.translate('your_division_hint'),
                      onchanged: (value) {},
                      controller: provider.divisionCtrl,
                    ),
                    AppFormProfile(
                      readOnly: true,
                      label: AppTranslations.translate('position'),
                      hinttext: AppTranslations.translate('your_position_hint'),
                      onchanged: (value) {},
                      controller: provider.positionCtrl,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: AppFormProfile(
                            readOnly: true,
                            label: AppTranslations.translate('time_in'),
                            hinttext: AppTranslations.translate(
                              'your_time_in_hint',
                            ),
                            onchanged: (value) {},
                            controller: provider.timeInCtrl,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppFormProfile(
                            readOnly: true,
                            label: AppTranslations.translate('time_out'),
                            hinttext: AppTranslations.translate(
                              'your_time_out_hint',
                            ),
                            onchanged: (value) {},
                            controller: provider.timeOutCtrl,
                          ),
                        ),
                      ],
                    ),
                    AppFormProfile(
                      readOnly: true,
                      label: AppTranslations.translate('location'),
                      hinttext: AppTranslations.translate('your_location_hint'),
                      onchanged: (value) {},
                      controller: provider.locationCtrl,
                    ),

                    // DottedBorder(
                    //   options: RoundedRectDottedBorderOptions(
                    //     color: AppColors.blackColor,
                    //     strokeWidth: 1,
                    //     radius: const Radius.circular(10),
                    //   ),
                    //   child: GestureDetector(
                    //     onTap: () {
                    //       // please uncomment when already fixing from api
                    //       // bypass check status for show face registration
                    //       // if (authProvider.profileModel.status == 2) {
                    //       context.router.push(const FaceregistrationRoute());
                    //       // return;
                    //       // }

                    //       // ScaffoldMessenger.of(context)
                    //       //     .showSnackBar(const SnackBar(
                    //       //   content: Text(
                    //       //       'You are not allowed to register face. Please contact your admin'),
                    //       //   backgroundColor: AppColors.redColors,
                    //       // ));
                    //     },
                    //     child: Container(
                    //       width: double.infinity,
                    //       height: 45,
                    //       decoration: BoxDecoration(
                    //         borderRadius: BorderRadius.circular(10),
                    //       ),
                    //       child: const Row(
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         children: [
                    //           Icon(Icons.face, color: AppColors.blackColor),
                    //           SizedBox(width: 10),
                    //           Text('Register Face', style: subtitle4),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ).bottomPadded(10),

                    // Container(
                    //   padding: const EdgeInsets.symmetric(horizontal: 10),
                    //   width: double.infinity,
                    //   height: 50,
                    //   decoration: BoxDecoration(
                    //     border: Border.all(width: 1, color: AppColors.blackColor),
                    //     borderRadius: BorderRadius.circular(10),
                    //   ),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: [
                    //       const Flexible(
                    //         child: Text(
                    //           'Allow app to track your location',
                    //           style: subtitle4,
                    //         ),
                    //       ),
                    //       Switch(
                    //         onChanged: (newValue) {
                    //           // Create pop up dialog to ask user permission to track location
                    //           showDialog(
                    //               context: context,
                    //               builder: (context) {
                    //                 return AlertDialog(
                    //                   title: const Text('Location Permission'),
                    //                   content: const Text(
                    //                       'Do you want to allow this app to track your location?'),
                    //                   actions: [
                    //                     TextButton(
                    //                       onPressed: () {
                    //                         Navigator.pop(context);

                    //                         provider.setSwitchValue(!newValue);

                    //                         if (!newValue) {}
                    //                       },
                    //                       child: const Text('No'),
                    //                     ),
                    //                     TextButton(
                    //                       onPressed: () {
                    //                         Navigator.pop(context);
                    //                         provider.setSwitchValue(newValue);

                    //                         if (newValue) {
                    //                           AuthProvider.trackLocation();
                    //                           ();
                    //                         } else {
                    //                           AuthProvider.cacelSchedule();
                    //                         }
                    //                       },
                    //                       child: const Text('Yes'),
                    //                     ),
                    //                   ],
                    //                 );
                    //               });
                    //         },
                    //         inactiveThumbColor: AppColors.whiteColor,
                    //         activeColor: AppColors.whiteColor,
                    //         activeTrackColor: AppColors.primaryColor,
                    //         inactiveTrackColor: AppColors.blackColor,
                    //         value: provider.switchValue,
                    //       ),
                    //     ],
                    //   ),
                    // ),

                    // disable because this feature not ready integrate with api
                    // Save Changes Button
                    // AppButton(
                    //   buttonName: AppTranslations.translate('save_changes'),
                    //   onPress: () {
                    //     Dialogs.showLoadingDialog(context);
                    //     provider
                    //         .updateImageProfile(
                    //           isUpdateProfile: provider.imageProfilePath != null,
                    //           userId: authProvider.profileModel.userId ?? '',
                    //         )
                    //         .then((value) {
                    //           Dialogs.dismissDialog(context);
                    //           if (provider.state == RequestState.Loaded) {
                    //             context.router.popForced();
                    //             ScaffoldMessenger.of(context).showSnackBar(
                    //               SnackBar(
                    //                 content: Text(
                    //                   AppTranslations.translate('profile_saved'),
                    //                 ),
                    //               ),
                    //             );
                    //           }
                    //         });
                    //   },
                    // ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

String getDayName(int dayNumber) {
  const daysOfWeek = [
    'Minggu',
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
  ];

  if (dayNumber < 0 || dayNumber > 6) {
    throw ArgumentError('Day number must be between 0 and 6');
  }

  return daysOfWeek[dayNumber];
}
