import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_in_out/core/resources/constants/app_font.dart';
import 'package:mobile_in_out/core/resources/constants/assets.dart';
import 'package:mobile_in_out/core/resources/injector/di.dart';
import 'package:mobile_in_out/core/resources/local/pref_service.dart';
import 'package:mobile_in_out/core/resources/theme/app_style.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/routes/router_import.gr.dart';
import 'package:mobile_in_out/core/utils/base_state/base_state.dart';
import 'package:mobile_in_out/core/utils/dialogs.dart';
import 'package:mobile_in_out/core/utils/helper/date_helper.dart';
import 'package:mobile_in_out/core/utils/localizations/app_translations.dart';
import 'package:mobile_in_out/core/utils/models/list_data_request.dart';
import 'package:mobile_in_out/core/utils/widgets/app_bar_general.dart';
import 'package:mobile_in_out/core/utils/widgets/app_button.dart';
import 'package:mobile_in_out/core/utils/widgets/app_input.dart';
import 'package:mobile_in_out/feature/absence/data/model/image_data_model.dart';
import 'package:mobile_in_out/feature/calendar/data/model/request/request_event_attachment.dart';
import 'package:mobile_in_out/feature/calendar/data/model/response/response_event_attachment.dart';
import 'package:mobile_in_out/feature/calendar/data/model/response/response_event_employee.dart';
import 'package:mobile_in_out/feature/calendar/data/model/response/response_events.dart';
import 'package:mobile_in_out/feature/calendar/data/model/user_participant_model.dart';
import 'package:mobile_in_out/feature/calendar/page/create_event_page.dart';
import 'package:mobile_in_out/feature/calendar/presentation/provider/calendar_state_provider.dart';
import 'package:mobile_in_out/feature/home/data/model/employee_detail_model.dart';
import 'package:mobile_in_out/feature/report_activity/presentation/provider/report_activity_state_provider.dart';
import 'package:mobile_in_out/feature/task/model/response_upload_file.dart';
import 'package:mobile_in_out/feature/task/model/response_upload_image.dart';

@RoutePage()
class DetailEventPage extends ConsumerStatefulWidget {
  final ResponseEvents? scheduleEvent;
  const DetailEventPage({super.key, this.scheduleEvent});

  @override
  ConsumerState<DetailEventPage> createState() => _DetailEventPageState();
}

class _DetailEventPageState extends ConsumerState<DetailEventPage> {
  final TextEditingController _noteCtrl = TextEditingController();
  final ShardPrefService _prefService = sl<ShardPrefService>();

  String _title = '';
  String _startDate = '';
  String _startTime = '';
  String _endTime = '';
  String _location = '';
  String _checkinTime = '-';
  String _checkoutTime = '-';
  String _totalHours = '-';
  bool _isExpandPhotos = false;
  bool _isLoadingUploadImage = false;
  bool _isCreator = true;
  String _eventEmployeeId = '';
  List<UserParticipant> _userParticipant = [];
  List<ImageDataModel> _imagesUpload = [];
  List<ResponseEventAttachment> _eventAttachments = [];
  final imageExtensions = ['jpg', 'jpeg', 'png'];
  final videoExtensions = ['mp4', 'mkv', 'mov', 'avi', 'webm', 'flv', 'wmv'];
  final documentExtensions = ['pdf', 'doc', 'docx', 'xls', 'xlsx'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getEventDetail();
      _getAttachmentList();
      _getEventEmployeeList();
    });
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      _getEventDetail(),
      _getAttachmentList(),
      _getEventEmployeeList(),
    ]);
  }

  Future<void> _getEventDetail() async {
    final eventId = widget.scheduleEvent?.eventId;
    if (eventId == null || eventId.isEmpty) return;

    await ref.read(eventDetailNotifierProvider.notifier).getEventById(eventId);
  }

  Future<void> _getAttachmentList() async {
    final eventId = widget.scheduleEvent?.eventId;
    if (eventId == null || eventId.isEmpty) return;

    await ref
        .read(attachmentListEventNotifierProvider.notifier)
        .getAttachmentEventList(
          ListDataRequest(
            offset: 0,
            limit: 100,
            sortBy: 'created',
            orderBy: 'desc',
            filter: {'event_id': eventId},
          ),
        );
  }

  Future<void> _getEventEmployeeList() async {
    final eventId = widget.scheduleEvent?.eventId;
    if (eventId == null || eventId.isEmpty) return;

    // get logged in user employee_id from cached employee detail
    String employeeId = '';
    final cached = await _prefService.getString(PrefServiceKey.employeeDetail);
    if (cached != null && cached.isNotEmpty) {
      try {
        final employee = EmployeeDetailModel.fromJson(
          json.decode(cached) as Map<String, dynamic>,
        );
        employeeId = employee.employeeId ?? '';
      } catch (e) {
        log('failed to parse employee detail: $e');
      }
    }
    if (employeeId.isEmpty) return;

    await ref
        .read(employeeListEventNotifierProvider.notifier)
        .getEmployeeEventList(
          ListDataRequest(
            offset: 0,
            limit: 100,
            sortBy: 'created',
            orderBy: 'desc',
            filter: {'event_id': eventId},
          ),
        );
    if (!mounted) return;

    final state = ref.read(employeeListEventNotifierProvider);
    if (state.state == ConcreteState.loaded && state.data != null) {
      ResponseEventEmployee? mine;
      for (final item in state.data!) {
        if (item.employeeId == employeeId) {
          mine = item;
          break;
        }
      }

      setState(() {
        _eventEmployeeId = mine?.eventEmployeeId ?? '';
      });
      log('event_employee_id for current user: $_eventEmployeeId');
    }
  }

  void _initData(ResponseEvents event) {
    log('init data ${event.eventDateStart}');
    final dateStart = event.eventDateStart != null
        ? DateTime.tryParse(event.eventDateStart!)
        : null;
    final dateEnd = event.eventDateEnd != null
        ? DateTime.tryParse(event.eventDateEnd!)
        : null;

    setState(() {
      _title = event.eventName ?? '-';
      _startDate = dateStart != null
          ? DateHelper.convertStringToDateTimeFormat(
                  dateStart,
                  "EEEE, d MMM yyyy",
                ) ??
                '-'
          : '-';
      _startTime = dateStart != null
          ? DateHelper.convertStringToDateTimeFormat(dateStart, "HH:mm") ?? '-'
          : '-';
      _endTime = dateEnd != null
          ? DateHelper.convertStringToDateTimeFormat(dateEnd, "HH:mm") ?? '-'
          : '-';
      _location = event.locationId ?? '-';

      _userParticipant =
          event.employeeList
              ?.map(
                (e) => UserParticipant(
                  id: int.tryParse(e.employeeId ?? '') ?? 0,
                  name: e.employeeName ?? '',
                ),
              )
              .toList() ??
          [];

      if (dateStart != null && dateEnd != null) {
        final diff = dateEnd.difference(dateStart);
        final hours = diff.inHours;
        final minutes = diff.inMinutes.remainder(60);
        _totalHours =
            '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
      }
    });
  }

  Future<void> _insertEventAttachment(String url, String? ext) async {
    final eventId = widget.scheduleEvent?.eventId;
    if (eventId == null || eventId.isEmpty) return;

    String employeeId = '';
    String employeeName = '';
    final cached = await _prefService.getString(PrefServiceKey.employeeDetail);
    if (cached != null && cached.isNotEmpty) {
      try {
        final employee = EmployeeDetailModel.fromJson(
          json.decode(cached) as Map<String, dynamic>,
        );
        employeeId = employee.employeeId ?? '';
        employeeName = employee.employeeName ?? '';
      } catch (e) {
        log('failed to parse employee detail: $e');
      }
    }

    final attachmentName = Uri.parse(url).pathSegments.isNotEmpty
        ? Uri.parse(url).pathSegments.last
        : '';

    await ref
        .read(attachmentEventNotifierProvider.notifier)
        .insertAttachmentEvent(
          RequestEventAttachment(
            eventId: eventId,
            employeeId: employeeId,
            employeeName: employeeName,
            attachmentUrl: url,
            attachmentName: attachmentName,
            attachmentType: ext,
          ),
        );

    final state = ref.read(attachmentEventNotifierProvider);
    if (state.state == ConcreteState.loaded) {
      await _getAttachmentList();
    }
  }

  void _confirmDeleteAttachment(int index) {
    Dialogs.confirmDialog(
      context,
      title: AppTranslations.translate('delete_attachment'),
      message: AppTranslations.translate('confirm_delete_attachment'),
      positiveLabel: AppTranslations.translate('yes'),
      negativeLabel: AppTranslations.translate('cancel'),
      dialogCallback: () => _deleteAttachment(index),
    );
  }

  Future<void> _deleteAttachment(int index) async {
    if (index < 0 || index >= _eventAttachments.length) return;

    final attachmentId = _eventAttachments[index].eventAttachmentId;
    if (attachmentId == null || attachmentId.isEmpty) {
      setState(() {
        _imagesUpload.removeAt(index);
      });
      return;
    }

    await ref
        .read(attachmentEventNotifierProvider.notifier)
        .deleteAttachmentEvent(attachmentId);
  }

  Future<void> _processImage(XFile? pickedFile) async {
    if (pickedFile != null) {
      if (!mounted) return;
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

      if (!mounted) return;
      if (compressedFile != null) {
        await ref
            .read(reportActivityNotifierProvider.notifier)
            .uploadImage(File(compressedFile.path));
        if (!mounted) return;

        final state = ref.read(reportActivityNotifierProvider);

        if (state.state == ConcreteState.loaded) {
          final bytes = await compressedFile.readAsBytes();
          final base64Image = base64Encode(bytes);

          final json = state.data as Map<String, dynamic>;
          final ResponseUploadImage resultUploadFile =
              ResponseUploadImage.fromJson(json);
          final url = resultUploadFile.imageUrl;
          if (url != null && url.isNotEmpty) {
            if (!mounted) return;
            setState(() {
              _imagesUpload.add(
                ImageDataModel(
                  base64: base64Image,
                  file: pickedFile,
                  urlPath: url,
                  extFile: 'jpg',
                ),
              );
            });
            await _insertEventAttachment(url, 'jpg');
          }
        }
        if (!mounted) return;
        setState(() {
          _isLoadingUploadImage = false;
        });
      }
    }
  }

  Future<void> _processFile(FilePickerResult resultFile) async {
    if (!mounted) return;
    setState(() {
      _isLoadingUploadImage = true;
    });

    File file = File(resultFile.files.single.path ?? '');
    String? fileExtension = resultFile.files.single.extension;

    await ref.read(reportActivityNotifierProvider.notifier).uploadFile(file);
    if (!mounted) return;

    final state = ref.read(reportActivityNotifierProvider);

    if (state.state == ConcreteState.loaded) {
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      final json = state.data as Map<String, dynamic>;
      final ResponseUploadFile resultUploadFile = ResponseUploadFile.fromJson(
        json,
      );
      final url = resultUploadFile.url;
      if (url != null && url.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _imagesUpload.add(
            ImageDataModel(
              base64: base64Image,
              fileData: file,
              urlPath: url,
              extFile: fileExtension,
            ),
          );
        });
        await _insertEventAttachment(url, fileExtension);
      }
    }

    if (!mounted) return;
    setState(() {
      _isLoadingUploadImage = false;
    });
  }

  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: Text(AppTranslations.translate('camera')),
                  onTap: () async {
                    Navigator.pop(context);
                    final pickedFile = await ImagePicker().pickImage(
                      source: ImageSource.camera,
                    );
                    if (pickedFile != null) {
                      await _processImage(pickedFile);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.attach_file),
                  title: Text(AppTranslations.translate('attach_file')),
                  onTap: () async {
                    Navigator.pop(context);
                    List<String> allowedExtensions = [];

                    allowedExtensions = [
                      ...imageExtensions,
                      ...videoExtensions,
                      ...documentExtensions,
                    ];

                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(
                          type: FileType.custom,
                          allowedExtensions: allowedExtensions,
                        );

                    if (result != null) {
                      await _processFile(result);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _showDataSelectUser() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _userParticipant.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 7,
      ),
      itemBuilder: (_, index) {
        final user = _userParticipant[index];

        return Row(
          children: [
            const Icon(Icons.circle, size: 10, color: AppColors.grey),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                user.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontFamily: AppFont.fontMontserrat,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<BaseState<List<ResponseEventAttachment>>>(
      attachmentListEventNotifierProvider,
      (previous, next) {
        if (next.state == ConcreteState.loaded && next.data != null) {
          setState(() {
            _eventAttachments = next.data!;
            _imagesUpload = next.data!
                .map(
                  (a) => ImageDataModel(
                    base64: '',
                    urlPath: a.attachmentUrl ?? '',
                    extFile: a.attachmentType,
                  ),
                )
                .toList();
          });
        }
      },
    );

    ref.listen<BaseState<ResponseEventAttachment>>(
      attachmentEventNotifierProvider,
      (previous, next) {
        if (next.state == ConcreteState.failure && next.message.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(next.message)));
        } else if (next.state == ConcreteState.loaded &&
            next.message == 'delete') {
          _getAttachmentList();
        }
      },
    );

    ref.listen<BaseState<ResponseEvents>>(eventDetailNotifierProvider, (
      previous,
      next,
    ) {
      if (next.state == ConcreteState.loaded && next.data != null) {
        log('data ${next.data?.eventName}');
        _initData(next.data!);
      } else if (next.state == ConcreteState.failure &&
          next.message.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.message)));
      }
    });

    return Scaffold(
      appBar: AppBarGeneral(
        backgroundColor: AppColors.whiteColor,
        colorIcon: AppColors.primaryColor,
        styleTitle: AppStyle(
          color: AppColors.blackColor,
          weight: bold,
        ).headline2,
        colorTitle: AppColors.blackColor,
        title: AppTranslations.translate('event_details'),
        action: [
          AppButton(
            buttonName: AppTranslations.translate('edit'),
            width: 80,
            onPress: () async {
              final event = widget.scheduleEvent;
              if (event == null) return;
              final result = await context.router.push(
                CreateEventRoute(
                  typeEvent: TypeEvent.editEvent,
                  eventId: event.eventId,
                  eventName: event.eventName,
                  eventDateStart: event.eventDateStart,
                  eventDateEnd: event.eventDateEnd,
                  locationId: event.locationId,
                ),
              );
              if (result == true) {
                _getEventDetail();
              }
            },
          ),
          SizedBox(width: 10),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 30),
        child: AppButton(
          isDisabled: !_isCreator,
          buttonName: AppTranslations.translate('submit'),
          onPress: () => {
            //TODO Submit
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                    fontFamily: AppFont.fontMontserrat,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  _startDate,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.black,
                    fontFamily: AppFont.fontMontserrat,
                  ),
                ),
                Text(
                  "${AppTranslations.translate('from')} $_startTime ${AppTranslations.translate('to')} $_endTime",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.black,
                    fontFamily: AppFont.fontMontserrat,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  _location,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                    fontFamily: AppFont.fontMontserrat,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  AppTranslations.translate('invitee'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                    fontFamily: AppFont.fontMontserrat,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: _showDataSelectUser(),
                ),
                // hide this feature because not used on this version
                // SizedBox(height: 24),
                // AppButton(
                //   buttonName: AppTranslations.translate('view_qr_code'),
                //   onPress: () => {
                //     context.router.push(
                //       QrCodeMeetingRoute(data: 'data sample 123'),
                //     ),
                //   },
                // ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => {
                            context.router.push(
                              CheckinMeetingRoute(
                                isCheckin: false,
                                eventId: widget.scheduleEvent?.eventId,
                                eventEmployeeId: _eventEmployeeId,
                              ),
                            ),
                          },
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Image.asset(
                                  Assets.icCheckInMeeting,
                                  width: 70,
                                  height: 70,
                                ),
                                Text(
                                  _checkinTime,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: AppFont.fontMontserrat,
                                    color: AppColors.black,
                                  ),
                                ),
                                SizedBox(height: 7),
                                Text(
                                  AppTranslations.translate('check_in'),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: AppFont.fontMontserrat,
                                    color: AppColors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            _totalHours,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              fontFamily: AppFont.fontMontserrat,
                              color: AppColors.black,
                            ),
                          ),
                          SizedBox(height: 7),
                          Text(
                            AppTranslations.translate('total_hrs'),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: AppFont.fontMontserrat,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => {
                            context.router.push(
                              CheckinMeetingRoute(
                                isCheckin: true,
                                eventId: widget.scheduleEvent?.eventId,
                                eventEmployeeId: _eventEmployeeId,
                              ),
                            ),
                          },
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Image.asset(
                                  Assets.icCheckOutMeeting,
                                  width: 70,
                                  height: 70,
                                ),
                                Text(
                                  _checkoutTime,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: AppFont.fontMontserrat,
                                    color: AppColors.black,
                                  ),
                                ),
                                SizedBox(height: 7),
                                Text(
                                  AppTranslations.translate('check_out'),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: AppFont.fontMontserrat,
                                    color: AppColors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                InkWell(
                  onTap: () {
                    setState(() {
                      _isExpandPhotos = !_isExpandPhotos;
                    });
                  },
                  child: SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            AppTranslations.translate('attachments'),
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: AppColors.black,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          child: Icon(
                            !_isExpandPhotos
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_up,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                if (_isExpandPhotos) ...[
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount:
                          _imagesUpload.length + 1, // +1 untuk tombol add
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        // tombol add
                        if (index == _imagesUpload.length) {
                          return InkWell(
                            onTap: () async {
                              if (_isCreator == true) {
                                if (_isLoadingUploadImage) return;
                                _showImageSourceBottomSheet();
                              }
                            },
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.greyColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.greyColor),
                              ),
                              child: Center(
                                child: _isLoadingUploadImage
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.add, size: 30),
                              ),
                            ),
                          );
                        }

                        // thumbnail image
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            children: [
                              _imagesUpload[index].extFile == 'jpg'
                                  ? Image.network(
                                      _imagesUpload[index].urlPath ?? '',
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 80,
                                      height: 80,
                                      color: AppColors.greyColor.withOpacity(
                                        0.2,
                                      ),
                                      child: const Icon(Icons.attach_file),
                                    ),

                              // optional delete icon
                              Positioned(
                                top: 4,
                                right: 4,
                                child: InkWell(
                                  onTap: () {
                                    if (_isCreator)
                                      _confirmDeleteAttachment(index);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                AppInput(
                  controller: _noteCtrl,
                  hintText: AppTranslations.translate('write_note_here'),
                  onChanged: (value) {},
                  maxLines: 4,
                  readOnly: !_isCreator,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
