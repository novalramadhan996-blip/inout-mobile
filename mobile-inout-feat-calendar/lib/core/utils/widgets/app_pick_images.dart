import 'dart:ui';

import 'package:mobile_in_out/core/resources/theme/dimension.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AppPickImages {
  final Function(XFile?) onPicked;
  final BuildContext context;

  AppPickImages({required this.onPicked, required this.context}) {
    showModalBottomSheet(
      context: context,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(Dimension.rounded),
                topRight: Radius.circular(Dimension.rounded)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 20, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Select Image",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () => _pickImages(true),
                        child: const Icon(
                          Icons.browse_gallery,
                          size: 50,
                        ),
                      ),
                      const Text("Gallery")
                    ],
                  ),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () => _pickImages(false),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 50,
                        ),
                      ),
                      const Text("Camera")
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isDismissible: false,
      enableDrag: true,
    );
  }

  void _pickImages(bool isGallery) async {
    Navigator.pop(context);
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: isGallery ? ImageSource.gallery : ImageSource.camera, imageQuality: 50);
    onPicked(image);
  }
}