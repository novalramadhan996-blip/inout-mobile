// import 'dart:io';

// import 'package:mobile_in_out/core/resources/theme/colors.dart';
// import 'package:mobile_in_out/core/utils/widgets/app_lable.dart';
// import 'package:mobile_in_out/core/utils/widgets/app_pick_images.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';

// class AppInputImages extends StatelessWidget {
//   const AppInputImages({
//     super.key,
//     this.label = "",
//     this.isRequired = false,
//     required this.onPicked,
//     this.previewImage = "",
//     this.errorText,
//   });

//   final String label, previewImage;
//   final bool isRequired;
//   final Function(XFile?) onPicked;
//   final String? errorText;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           AppLabel(
//             label: label,
//             isRequired: isRequired,
//           ),
//           InkWell(
//             onTap: () => AppPickImages(onPicked: onPicked, context: context),
//             child: previewImage == ""
//                 ? Container(
//                     height: 72,
//                     width: 72,
//                     decoration: const BoxDecoration(
//                       color: Color(0XFFF7F8F8),
//                       borderRadius: BorderRadius.all(
//                         Radius.circular(4),
//                       ),
//                     ),
//                     child: const Icon(
//                       Icons.add_a_photo,
//                       color: AppColors.greyButtonColor,
//                     )
//                   )
//                 : Container(
//                     height: 72,
//                     width: 72,
//                     decoration: BoxDecoration(
//                       color: const Color(0XFFF7F8F8),
//                       borderRadius: const BorderRadius.all(
//                         Radius.circular(4),
//                       ),
//                       image: DecorationImage(
//                         image: FileImage(
//                           File(previewImage),
//                         ),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//           ),
//           errorText == null
//               ? Container()
//               : Padding(
//                   padding: const EdgeInsets.only(left: 12),
//                   child: Text(
//                     errorText.toString(),
//                     style: const TextStyle(fontSize: 10, color: AppColors.redColors),
//                   ),
//                 ),
//         ],
//       ),
//     );
//   }
// }
