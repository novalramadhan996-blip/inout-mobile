import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobile_in_out/core/resources/injector/di.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/utils/helper/date_helper.dart';
import 'package:mobile_in_out/core/utils/localizations/app_translations.dart';
import 'package:mobile_in_out/core/utils/widgets/app_image_profile_rounded.dart';
import 'package:mobile_in_out/core/utils/widgets/app_video_player.dart';
import 'package:mobile_in_out/feature/task/model/response_comment.dart';
import 'package:mobile_in_out/feature/task/provider/task_provider.dart';
import 'package:mobile_in_out/feature/task/widget/child_comment_item_widget.dart';

class CommentItemWidget extends StatefulWidget {
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
  final Function(ResponseComment comment)? onReply;

  const CommentItemWidget({
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
    this.onReply,
  });

  @override
  State<CommentItemWidget> createState() => _CommentItemWidgetState();

}

class _CommentItemWidgetState extends State<CommentItemWidget> {

  late final TaskProvider _taskProvider;
  
  bool _isLoading = false;
  final List<ResponseComment> _replyList = [];

  @override
  void initState() {
    _taskProvider = sl<TaskProvider>();
    
    super.initState();
    
    _fetchReplyList();
  }

  @override
  Widget build(BuildContext context) {
    String initialName = widget.createdBy ?? "Unknown";
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppImageProfileRounded(
              width: 40, 
              height: 40,
              profileUrl: widget.imageContent != null && widget.imageContent != "" ? widget.imageContent : "",
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
                        widget.createdBy ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.blackColor
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.createdAt != null ? DateHelper.stringToTimeAgo(widget.createdAt) : '',
                        style: TextStyle(
                          fontSize: 12, 
                          color: AppColors.greyFont,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ]
                  ),
                  if (widget.contentType == "image") ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.content ?? '',
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
                  ] else if (widget.contentType == "video") ...[
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: VideoPlayerFromUrl(url: widget.content ?? ''),
                      ),
                  ] else ...[ 
                    const SizedBox(height: 5),
                    Text(
                      widget.content ?? '',
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
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                widget.onReply?.call(ResponseComment(
                  commentId: widget.commentId,
                  createdBy: widget.createdBy
                ));
              },
              child: Text(
                AppTranslations.translate('reply'),
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: EdgeInsetsGeometry.only(left: 40),
            child: Column(
              children: _replyList.map((comment) {
                return ChildCommentItemWidget(
                  commentId: comment.commentId ?? '',
                  parentCommentId: comment.parentCommentId ?? '',
                  module: comment.module ?? '',
                  moduleId: comment.moduleId ?? '',
                  content: comment.content ?? '',
                  contentType: comment.contentType ?? '',
                  status: comment.status ?? '',
                  createdAt: comment.createdAt ?? '',
                  createdBy: comment.createdBy ?? '',
                  updatedAt: comment.updatedAt ?? '',
                  updatedBy: comment.updatedBy ?? '',
                );
              }).toList(),
            ),
          )
      ],
    );
  }

  Future<void> _fetchReplyList() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _replyList.clear();
    });

    await _taskProvider.getReplyList(widget.commentId);

    final List<ResponseComment> newItems = _taskProvider.replyListData;
    if (newItems.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } else {
      if (!mounted) return;
      setState(() {
        _replyList.addAll(newItems);
        _isLoading = false;
      });
    }
  }

}