import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/utils/helper/date_helper.dart';
import 'package:mobile_in_out/core/utils/widgets/app_image_profile_rounded.dart';
import 'package:mobile_in_out/core/utils/widgets/app_video_player.dart';

class ChildCommentItemWidget extends StatelessWidget {
  final String commentId;
  final String? parentCommentId;
  final String module;
  final String moduleId;
  final String? content;
  final String? contentType;
  final String? imageContent;
  final String? status;
  final String? createdAt;
  final String? createdBy;
  final String? updatedAt;
  final String? updatedBy;

  const ChildCommentItemWidget({
    super.key,
    required this.commentId,
    this.parentCommentId,
    required this.module,
    required this.moduleId,
    this.content,
    this.contentType,
    this.imageContent,
    this.status,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
  });

  @override
  Widget build(BuildContext context) {
    String initialName = createdBy ?? "Unknown";
    return Column(
      children: [
        const SizedBox(height: 5),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppImageProfileRounded(
              width: 40, 
              height: 40,
              profileUrl: imageContent != null && imageContent != "" ? imageContent : "",
              initialName: initialName[0].toUpperCase(),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Row(
                    children: [
                      Text(
                        createdBy ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.blackColor
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        createdAt != null ? DateHelper.stringToTimeAgo(createdAt) : '',
                        style: TextStyle(
                          fontSize: 12, 
                          color: AppColors.greyFont,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ]
                  ),
                  if (contentType == "image") ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        content ?? '',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox(
                            height: 100,
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: Icon(
                                Icons.broken_image,
                                color: AppColors.greyComponent,
                                size: 94,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ] else if (contentType == "video") ...[
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: VideoPlayerFromUrl(url: content ?? ''),
                      ),
                  ] else ...[ 
                    const SizedBox(height: 5),
                    Text(
                      content ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: AppColors.blackColor
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}