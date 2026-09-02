import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';
import 'package:mobile_in_out/core/utils/localizations/app_translations.dart';
import 'package:mobile_in_out/core/utils/widgets/app_universal_file_view.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AttachmentItemWidget extends StatelessWidget {
  final String attachmentId;
  final String taskId;
  final String? attachmentUrl;
  final String? attachmentName;
  final String? attachmentType;
  final int? isThumbnail;
  final Function? onDelete;

  const AttachmentItemWidget({
    super.key,
    required this.attachmentId,
    required this.taskId,
    this.attachmentUrl,
    this.attachmentName,
    this.attachmentType,
    this.isThumbnail,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              attachmentName ?? '',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.blackColor,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  // Handle download action
                  _downloadFile(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Icon(
                    Icons.download,
                    size: 24,
                    color: AppColors.blackColor,
                  ),
                ),
              ),
              const SizedBox(width: 3),
              GestureDetector(
                onTap: () {
                  // Handle show action
                  _showFileViewer(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Icon(
                    Icons.remove_red_eye_outlined,
                    size: 24,
                    color: AppColors.blackColor,
                  ),
                ),
              ),
              const SizedBox(width: 3),
              GestureDetector(
                onTap: () {
                  // Handle delete action
                  LogHelper.logDebug('delete attachment: $attachmentId');
                  onDelete?.call(attachmentId);
                },
                child: Container(
                  padding: const EdgeInsets.only(left: 3),
                  child: Icon(
                    Icons.delete_outline,
                    size: 24,
                    color: AppColors.blackColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFileViewer(BuildContext context) {
    if (attachmentUrl == null || attachmentUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTranslations.translate('file_url_not_available')),
        ),
      );
      return;
    }

    // Special handling for PDF files to avoid gesture conflicts
    if (attachmentType?.toLowerCase() == 'pdf') {
      _showPdfViewer(context);
    } else {
      _showRegularFileViewer(context);
    }
  }

  void _showPdfViewer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: false, // Disable drag to prevent conflicts with PDF gestures
      builder: (context) => WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          return false;
        },
        child: Container(
          height: MediaQuery.of(context).size.height * 0.95,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        attachmentName ??
                            AppTranslations.translate('pdf_viewer'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              // PDF viewer content
              Expanded(
                child: UniversalFileViewer(
                  url: attachmentUrl!,
                  mimeType: attachmentType ?? "",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRegularFileViewer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        attachmentName ??
                            AppTranslations.translate('file_viewer'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              // File viewer content
              Expanded(
                child: UniversalFileViewer(
                  url: attachmentUrl!,
                  mimeType: attachmentType ?? "",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadFile(BuildContext context) async {
    if (attachmentUrl == null || attachmentUrl!.isEmpty) {
      _showNotification(
        context,
        AppTranslations.translate('error'),
        AppTranslations.translate('file_url_not_available'),
        false,
      );
      return;
    }

    // Check permission before download
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.manageExternalStorage,
    ].request();

    bool hasStoragePermission =
        statuses[Permission.storage]!.isGranted ||
        statuses[Permission.manageExternalStorage]!.isGranted;

    if (!hasStoragePermission) {
      // Show dialog to explain why permission is needed
      if (!context.mounted) return;
      final result = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppTranslations.translate('permission_required')),
          content: Text(AppTranslations.translate('storage_permission_desc')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(AppTranslations.translate('cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(AppTranslations.translate('allow')),
            ),
          ],
        ),
      );
      if (result == true) {
        // Request permission again
        statuses = await [
          Permission.storage,
          Permission.manageExternalStorage,
        ].request();
        hasStoragePermission =
            statuses[Permission.storage]!.isGranted ||
            statuses[Permission.manageExternalStorage]!.isGranted;
      }
    }

    if (!hasStoragePermission) {
      _showNotification(
        context,
        AppTranslations.translate('error'),
        AppTranslations.translate('storage_access_permission'),
        false,
      );
      return;
    }

    try {
      // Show loading notification
      if (!context.mounted) return;
      _showNotification(
        context,
        AppTranslations.translate('downloading'),
        AppTranslations.translate('downloading_file'),
        true,
      );

      // Download file
      final response = await http.get(Uri.parse(attachmentUrl!));
      if (response.statusCode != 200) {
        if (!context.mounted) return;
        _showNotification(
          context,
          AppTranslations.translate('error'),
          '${AppTranslations.translate('failed_download')}${response.statusCode})',
          false,
        );
        return;
      }

      // Get download directory
      Directory? downloadDir;
      if (Platform.isAndroid) {
        try {
          // For Android 10+ (API 29+), use external storage directory instead of direct Downloads folder
          downloadDir = await getExternalStorageDirectory();
          if (downloadDir != null) {
            // Create Downloads subdirectory in external storage
            downloadDir = Directory('${downloadDir.path}/Downloads');
            if (!await downloadDir.exists()) {
              await downloadDir.create(recursive: true);
            }
          }

          // Fallback to app documents directory if external storage is not available
          if (downloadDir == null || !await downloadDir.exists()) {
            downloadDir = await getApplicationDocumentsDirectory();
            downloadDir = Directory('${downloadDir.path}/Downloads');
            if (!await downloadDir.exists()) {
              await downloadDir.create(recursive: true);
            }
          }
        } catch (e) {
          // Fallback to app documents directory
          downloadDir = await getApplicationDocumentsDirectory();
          downloadDir = Directory('${downloadDir.path}/Downloads');
          if (!await downloadDir.exists()) {
            await downloadDir.create(recursive: true);
          }
        }
      } else {
        downloadDir = await getApplicationDocumentsDirectory();
        downloadDir = Directory('${downloadDir.path}/Downloads');
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
      }

      if (downloadDir == null) {
        if (!context.mounted) return;
        _showNotification(
          context,
          AppTranslations.translate('error'),
          AppTranslations.translate('download_directory'),
          false,
        );
        return;
      }

      // Test write permission
      try {
        final testFile = File('${downloadDir.path}/test_write.tmp');
        await testFile.writeAsString('test');
        await testFile.delete();
      } catch (e) {
        if (!context.mounted) return;
        _showNotification(
          context,
          AppTranslations.translate('error'),
          AppTranslations.translate('write_permission'),
          false,
        );
        return;
      }

      // Create filename with timestamp to avoid conflicts
      String fileName = attachmentName ?? 'file';
      String extension = attachmentType ?? '';

      // Remove invalid characters from filename
      fileName = fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');

      if (extension.isNotEmpty && !fileName.contains('.')) {
        fileName = '$fileName.$extension';
      }

      // Add timestamp if file exists
      final file = File('${downloadDir.path}/$fileName');
      if (await file.exists()) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final nameWithoutExt = fileName.contains('.')
            ? fileName.substring(0, fileName.lastIndexOf('.'))
            : fileName;
        final ext = fileName.contains('.')
            ? fileName.substring(fileName.lastIndexOf('.'))
            : '';
        fileName = '${nameWithoutExt}_$timestamp$ext';
      }

      // Save file
      final finalFile = File('${downloadDir.path}/$fileName');
      try {
        await finalFile.writeAsBytes(response.bodyBytes);
      } catch (e) {
        if (e.toString().contains('Permission denied')) {
          if (!context.mounted) return;
          _showNotification(
            context,
            AppTranslations.translate('error'),
            AppTranslations.translate('write_permission'),
            false,
          );
        } else {
          if (!context.mounted) return;
          _showNotification(
            context,
            AppTranslations.translate('error'),
            '${AppTranslations.translate('failed_save_file')}: $e',
            false,
          );
        }
        return;
      }

      // Show success notification
      String successMessage;
      if (downloadDir.path.contains('Downloads')) {
        successMessage =
            '${AppTranslations.translate('file_saved')}$fileName\n\n${AppTranslations.translate('location_download')}${downloadDir.path}';
      } else {
        successMessage =
            '${AppTranslations.translate('file_saved_to')}${downloadDir.path}/$fileName';
      }

      if (!context.mounted) return;
      _showNotification(
        context,
        AppTranslations.translate('download_completed'),
        successMessage,
        false,
      );
    } catch (e) {
      String errorMessage = 'Gagal mengunduh file';

      if (e.toString().contains('Permission denied')) {
        errorMessage = AppTranslations.translate('unable_access_storage');
      } else if (e.toString().contains('Network')) {
        errorMessage = AppTranslations.translate('network_error_download');
      } else if (e.toString().contains('404')) {
        errorMessage = AppTranslations.translate('file_not_found');
      }

      if (!context.mounted) return;
      _showNotification(context, 'Error', errorMessage, false);
    }
  }

  void _showNotification(
    BuildContext context,
    String title,
    String message,
    bool isProgress,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (isProgress)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            if (isProgress) SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(message, style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: isProgress ? Colors.blue : Colors.green,
        duration: isProgress ? Duration(seconds: 2) : Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action:
            title == AppTranslations.translate('error') &&
                message.contains('storage')
            ? SnackBarAction(
                label: AppTranslations.translate('go_to_settings'),
                textColor: Colors.white,
                onPressed: () => _openAppSettings(),
              )
            : null,
      ),
    );
  }

  void _openAppSettings() {
    openAppSettings();
  }
}
