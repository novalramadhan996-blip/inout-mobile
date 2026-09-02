import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_in_out/core/resources/constants/assets.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/resources/theme/theme.dart';
import 'package:mobile_in_out/core/utils/base_state/base_state.dart';
import 'package:mobile_in_out/core/utils/extensions/widget_extension.dart';
import 'package:mobile_in_out/core/utils/localizations/app_translations.dart';
import 'package:mobile_in_out/core/utils/widgets/app_button.dart';
import 'package:mobile_in_out/core/utils/widgets/app_input.dart';
import 'package:mobile_in_out/feature/report_activity/data/model/activity_request_model.dart';
import 'package:mobile_in_out/feature/report_activity/presentation/provider/report_activity_state_provider.dart';
import 'package:mobile_in_out/feature/task/model/response_upload_image.dart';

@RoutePage()
class ReportActivityScreen extends ConsumerStatefulWidget {
  const ReportActivityScreen({super.key});

  @override
  ConsumerState<ReportActivityScreen> createState() =>
      _ReportActivityScreenState();
}

class _ReportActivityScreenState extends ConsumerState<ReportActivityScreen> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  XFile? _imageFile;
  String _imageUrl = '';
  bool _isLoadingUploadImage = false;
  bool _isLoadingSave = false;
  bool _isReadyClick = false;
  Position? _position;

  @override
  void initState() {
    _getCurrentLocation();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> processImage(WidgetRef ref, XFile? pickedFile) async {
    if (pickedFile != null) {
      setState(() {
        _isLoadingUploadImage = true;
        _imageFile = null;
        _imageUrl = '';
        _isReadyClick = false;
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
          break;
        }

        quality -= 5;
      } while (quality > 0);

      if (compressedFile != null) {
        await ref
            .read(reportActivityNotifierProvider.notifier)
            .uploadImage(File(compressedFile.path));

        final state = ref.read(reportActivityNotifierProvider);

        if (state.state == ConcreteState.loaded) {
          final json = state.data as Map<String, dynamic>;
          final ResponseUploadImage resultUploadFile =
              ResponseUploadImage.fromJson(json);
          final url = resultUploadFile.imageUrl;
          if (url != null && url.isNotEmpty) {
            setState(() {
              _imageFile = pickedFile;
              _imageUrl = url;
              if (_titleCtrl.text.isNotEmpty) {
                _isReadyClick = true;
              }
            });
          }
        }

        setState(() {
          _isLoadingUploadImage = false;
        });
      }
    }
  }

  Future<void> _saveData(WidgetRef ref) async {
    if (_titleCtrl.text.isNotEmpty && _imageUrl.isNotEmpty) {
      setState(() {
        _isLoadingSave = true;
      });
      ActivityRequestModel activityRequestModel = ActivityRequestModel(
        activityType: _titleCtrl.text,
        descr: _descCtrl.text,
        latitude: _position != null ? _position?.latitude ?? 0.0 : 0.0,
        longitude: _position != null ? _position?.longitude ?? 0.0 : 0.0,
        photoUrl: _imageUrl,
      );

      await ref
          .read(reportActivityNotifierProvider.notifier)
          .createActivity(activityRequestModel);

      final state = ref.read(reportActivityNotifierProvider);

      if (state.state == ConcreteState.loaded) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppTranslations.translate('success_saving_data')),
              backgroundColor: AppColors.primaryColor,
            ),
          );
          context.router.pop(true);
        }
      } else if (state.state == ConcreteState.failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppTranslations.translate('failed_saving_data')),
              backgroundColor: AppColors.redColors,
            ),
          );
        }
      }

      setState(() {
        _isLoadingSave = false;
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.translate('report_activity_title')),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppTranslations.translate('upload_photo'),
                style: AppTheme.bodyText.copyWith(
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ).horizontalPadded(15),

              const SizedBox(height: 10),

              if (_imageFile != null)
                Container(
                  height: 150,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.greyColor),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _imageFile?.path != null
                        ? Image.file(File(_imageFile!.path), fit: BoxFit.cover)
                        : SizedBox.shrink(),
                  ),
                ),

              const SizedBox(height: 10),

              InkWell(
                onTap: () => showModalBottomSheet(
                  context: context,
                  builder: (_) => SafeArea(
                    child: Wrap(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.photo_library),
                          title: Text(
                            AppTranslations.translate('photo_from_gallery'),
                          ),
                          onTap: () async {
                            Navigator.pop(context);
                            final pickedFile = await ImagePicker().pickImage(
                              source: ImageSource.gallery,
                            );
                            if (pickedFile != null) {
                              await processImage(ref, pickedFile);
                            }
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.photo_camera),
                          title: Text(
                            AppTranslations.translate('photo_from_camera'),
                          ),
                          onTap: () async {
                            Navigator.pop(context);
                            final pickedFile = await ImagePicker().pickImage(
                              source: ImageSource.camera,
                            );
                            if (pickedFile != null) {
                              await processImage(ref, pickedFile);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                child: Container(
                  height: 70,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xffD4F3F9),
                  ),
                  child: Center(
                    child: _isLoadingUploadImage
                        ? const CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Color(0xff187498),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(Assets.icAddPhoto, width: 24),
                              const SizedBox(width: 10),
                              Text(
                                AppTranslations.translate(
                                  'tap_to_upload_photo',
                                ),
                                style: AppTheme.subtitle.copyWith(
                                  color: const Color(0xff187498),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Divider(color: AppColors.greyColor, thickness: 5),

              const SizedBox(height: 16),

              Text(
                AppTranslations.translate('title'),
                style: AppTheme.bodyText.copyWith(
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ).horizontalPadded(15),

              const SizedBox(height: 8),

              AppInput(
                onChanged: (value) {
                  final ready = value.isNotEmpty && _imageUrl.isNotEmpty;
                  if (ready != _isReadyClick) {
                    setState(() {
                      _isReadyClick = ready;
                    });
                  }
                },
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return AppTranslations.translate('title_is_required');
                  }
                  return null;
                },
                controller: _titleCtrl,
                hintText: AppTranslations.translate('input_title'),
              ).horizontalPadded(15),

              const SizedBox(height: 20),

              Text(
                AppTranslations.translate('desc'),
                style: AppTheme.bodyText.copyWith(
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ).horizontalPadded(15),

              const SizedBox(height: 8),

              AppInput(
                controller: _descCtrl,
                hintText: AppTranslations.translate('write_note_here'),
                maxLines: 4,
              ).horizontalPadded(15),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppButton(
        buttonName: AppTranslations.translate('save'),
        isDisabled: !_isReadyClick,
        isLoading: _isLoadingSave,
        onPress: () => _saveData(ref),
      ).horizontalPadded(15).bottomPadded(15),
    );
  }
}
