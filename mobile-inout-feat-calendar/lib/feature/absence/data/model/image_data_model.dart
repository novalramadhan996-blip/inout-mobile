import 'dart:io';

import 'package:camera/camera.dart';

class ImageDataModel {
  final String? base64;
  final XFile? file;
  final File? fileData;
  final String? urlPath;
  final String? extFile;

  ImageDataModel({
    this.base64,
    this.file,
    this.urlPath,
    this.fileData,
    this.extFile,
  });
}
