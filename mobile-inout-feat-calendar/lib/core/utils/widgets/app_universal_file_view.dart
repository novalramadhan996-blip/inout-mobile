import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile_in_out/core/utils/helper/global_utils.dart';
import 'package:mobile_in_out/core/utils/widgets/app_video_player.dart';
import 'package:mobile_in_out/core/utils/widgets/pdf_viewer_widget.dart';
import 'package:open_filex/open_filex.dart';

class UniversalFileViewer extends StatelessWidget {
  final String url;
  final String mimeType;

  const UniversalFileViewer({
    super.key,
    required this.url,
    required this.mimeType,
  });

  @override
  Widget build(BuildContext context) {
    
    final imageExtensions = ['jpg', 'jpeg', 'png'];

    if (imageExtensions.contains(mimeType)) {
      return Image.network(url, fit: BoxFit.contain);
    } else if (mimeType == 'pdf') {
      return PdfViewerWidget(url: url);
    } else if (mimeType == 'mp4') {
      return VideoPlayerFromUrl(url: url);
    } else {
      return FutureBuilder<File>(
        future: GlobalUtils.downloadFile(url),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(child: Text("File not available"));
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.insert_drive_file, size: 48),
              SizedBox(height: 8),
              Text("The file cannot be displayed directly"),
              ElevatedButton(
                onPressed: () => OpenFilex.open(snapshot.data!.path),
                child: Text("Open in another application"),
              ),
            ],
          );
        },
      );
    }
  }
}