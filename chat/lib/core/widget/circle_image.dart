import 'dart:developer';

import 'package:flutter/material.dart';

class CircleImage extends StatelessWidget {
  final String? imageUrl;
  final double height;
  final double width;
  final IconData iconDefault;
  final Color? color;

  const CircleImage({
    super.key,
    this.imageUrl,
    required this.height,
    required this.width,
    required this.iconDefault,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: imageUrl != '' ?
        Image.network(
          imageUrl ?? '',
          height: height,
          width: width,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade200,
              child: Icon(
                iconDefault,
                size: height,
                color: color ?? Colors.grey,
              ),
            );
          },
        )
      : 
      Container(
        color: Colors.grey.shade200,
        child: Icon(
          iconDefault,
          size: height,
          color: color ?? Colors.grey,
        ),
      ),
    );
  }
  
}