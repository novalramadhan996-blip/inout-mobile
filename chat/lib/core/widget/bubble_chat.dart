import 'dart:developer';

import 'package:chat/core/resources/constants/app_constants.dart';
import 'package:chat/core/utils/global_utils.dart';
import 'package:chat/core/widget/bubble_chat/bubble_special_three.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BubbleChat extends StatelessWidget {
  final String id;
  final String type;
  final String sender;
  final String userId;
  final String content;
  final String? senderName;
  final String? senderImage;
  final String typeMessage;
  final String? fileName;
  final String? fileType;
  final String? fileUrl;
  final bool? isAllRead;
  final VoidCallback? onDelete;

  const BubbleChat({
    super.key,
    required this.id,
    required this.type,
    required this.sender,
    required this.userId,
    required this.content,
    required this.senderName,
    required this.senderImage,
    required this.typeMessage,
    this.fileName,
    this.fileType,
    this.fileUrl,
    this.isAllRead = false,
    this.onDelete,
  });

  String _senderName() {
    if (sender == userId) {
      return '';
    } else {
      return senderName ?? '';
    }
  }

  Future<void> _launchInBrowserView(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
      log('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSender = sender == userId ? true : false;
    return Container(
        padding:
            const EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            type == AppConstants.typeChatGroup && !isSender
                ? CircleAvatar(
                    backgroundImage: NetworkImage(senderImage ??
                        "https://randomuser.me/api/portraits/men/39.jpg"),
                    maxRadius: 15,
                  )
                : const SizedBox(width: 0),
            Expanded(
              child: GestureDetector(
                  onTap: () {
                    log('clicked chat');
                    if (typeMessage == AppConstants.typeMessageFile ||
                        typeMessage == AppConstants.typeMessageImage) {
                      GlobalUtils.downloadFile(fileUrl ?? '', fileName ?? '');
                    } else if (typeMessage == AppConstants.typeMessageVideo) {
                      log('Open video on browser');
                      log('Video URL: $fileUrl');
                      _launchInBrowserView(Uri.parse(fileUrl ?? ''));
                    }
                  },
                  onLongPress: () {
                    // Only show delete option for messages sent by the current user
                    if (isSender && onDelete != null) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Delete Message'),
                            content: const Text(
                                'Are you sure you want to delete this message?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  onDelete!();
                                },
                                child: const Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: BubbleSpecialThree(
                    text: content,
                    color: const Color(0xFFE8E8EE),
                    tail: true,
                    isSender: isSender,
                    sent: false,
                    delivered: isAllRead == false ? true : false,
                    seen: isAllRead ?? false,
                    time: "",
                    type: type,
                    name: _senderName(),
                    typeMessage: typeMessage,
                    fileName: fileName,
                    fileType: fileType,
                    fileUrl: fileUrl,
                  )),
            )
          ],
        ));
  }
}
