import 'dart:developer';
import 'dart:typed_data';

import 'package:image/image.dart' as imglib;
import 'package:camera/camera.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';

// imglib.Image? convertToImage(CameraImage image,  {bool? isDispose = false}) {
//   try {
//     if (image.format.group == ImageFormatGroup.yuv420) {
//       if (isDispose == false) {
//         return _convertYUV420(image);
//       }
//     } else if (image.format.group == ImageFormatGroup.bgra8888) {
//       return _convertBGRA8888(image);
//     }
//   } catch (e) {
//     LogHelper.logDebug("ERROR: $e");
//   }
//   return null;
// }

imglib.Image? convertToImage(CameraImage image, {bool? isDispose = false}) {
  try {
    if (isDispose == false) {
      if (image.format.group == ImageFormatGroup.yuv420) {
        // if (isDispose == false) {
        return _convertYUV420(image);
        // }
      } else if (image.format.group == ImageFormatGroup.bgra8888) {
        return _convertBGRA8888(image);
      } else if (image.format.group == ImageFormatGroup.nv21) {
        return _convertNV21(image);
      }
    }
  } catch (e) {
    LogHelper.logDebug("ERROR convertToImage : $e");
  }
  return null;
}

// imglib.Image _convertBGRA8888(CameraImage image) {
//   final int width = image.width;
//   final int height = image.height;
//   final Uint8List bgraBytes = image.planes[0].bytes;

//   // Create RGBA buffer (4 bytes per pixel)
//   final Uint8List rgbaBytes = Uint8List(bgraBytes.length);

//   // Convert BGRA to RGBA
//   for (int i = 0; i < bgraBytes.length; i += 4) {
//     rgbaBytes[i] = bgraBytes[i + 2];     // R
//     rgbaBytes[i + 1] = bgraBytes[i + 1]; // G
//     rgbaBytes[i + 2] = bgraBytes[i];     // B
//     rgbaBytes[i + 3] = bgraBytes[i + 3]; // A
//   }

//   // Create image from RGBA bytes
//   return imglib.Image.fromBytes(
//     width: width,
//     height: height,
//     bytes: rgbaBytes.buffer,
//     numChannels: 4,
//     order: imglib.ChannelOrder.rgba,
//   );
// }

imglib.Image _convertBGRA8888(CameraImage image) {
  return imglib.Image.fromBytes(
    image.width,
    image.height,
    image.planes[0].bytes,
    format: imglib.Format.bgra,
  );
}

// imglib.Image _convertYUV420(CameraImage image) {
//   final int width = image.width;
//   final int height = image.height;
//   final imglib.Image img = imglib.Image(width: width, height: height); // RGB image

//   final Uint8List yPlane = image.planes[0].bytes;
//   final Uint8List uPlane = image.planes[1].bytes;
//   final Uint8List vPlane = image.planes[2].bytes;

//   final int uvRowStride = image.planes[1].bytesPerRow;
//   final int uvPixelStride = image.planes[1].bytesPerPixel ?? 1;

//   for (int y = 0; y < height; y++) {
//     for (int x = 0; x < width; x++) {
//       final int uvX = (x / 2).floor();
//       final int uvY = (y / 2).floor();
//       final int uvIndex = uvY * uvRowStride + uvX * uvPixelStride;

//       final int yIndex = y * width + x;
//       final int yp = yPlane[yIndex];
//       final int up = uPlane[uvIndex];
//       final int vp = vPlane[uvIndex];

//       final int r = (yp + 1.370705 * (vp - 128)).round().clamp(0, 255);
//       final int g = (yp - 0.337633 * (up - 128) - 0.698001 * (vp - 128)).round().clamp(0, 255);
//       final int b = (yp + 1.732446 * (up - 128)).round().clamp(0, 255);

//       img.setPixelRgb(x, y, r, g, b);
//     }
//   }

//   return img;
// }

imglib.Image _convertYUV420(CameraImage image) {
  int width = image.width;
  int height = image.height;
  var img = imglib.Image(width, height);
  const int hexFF = 0xFF000000;
  final int uvyButtonStride = image.planes[1].bytesPerRow;
  final int? uvPixelStride = image.planes[1].bytesPerPixel;
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      final int uvIndex =
          uvPixelStride! * (x / 2).floor() + uvyButtonStride * (y / 2).floor();
      final int index = y * width + x;
      final yp = image.planes[0].bytes[index];
      final up = image.planes[1].bytes[uvIndex];
      final vp = image.planes[2].bytes[uvIndex];
      int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
      int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
          .round()
          .clamp(0, 255);
      int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
      img.data[index] = hexFF | (b << 16) | (g << 8) | r;
    }
  }

  return img;
}

imglib.Image _convertNV21(CameraImage image) {
  final int width = image.width;
  final int height = image.height;
  final imglib.Image img = imglib.Image(width, height);
  const int hexFF = 0xFF000000;

  final bytes = image.planes[0].bytes; // NV21 hanya 1 plane
  final int frameSize = width * height;

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final int yp = bytes[y * width + x] & 0xFF;

      final int uvIndex = frameSize + (y >> 1) * width + (x & ~1);
      final int v = bytes[uvIndex] & 0xFF;
      final int u = bytes[uvIndex + 1] & 0xFF;

      int r = (yp + 1.370705 * (v - 128)).round().clamp(0, 255);
      int g = (yp - 0.698001 * (v - 128) - 0.337633 * (u - 128)).round().clamp(
        0,
        255,
      );
      int b = (yp + 1.732446 * (u - 128)).round().clamp(0, 255);

      img.data[y * width + x] = hexFF | (b << 16) | (g << 8) | r;
    }
  }

  return img;
}
