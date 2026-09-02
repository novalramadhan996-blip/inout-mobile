import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:chat/core/routes/router_import.dart';
import 'package:chat/core/resources/constants/app_constants.dart';
import 'package:chat/core/routes/router_import.gr.dart';
import 'package:chat/core/widget/circle_image.dart';
import 'package:chat/models/chats_model.dart';
import 'package:chat/ui/chat_detail_screen.dart';
import 'package:flutter/material.dart';

class ConversationList extends StatelessWidget {
  final String id;
  final String name;
  final String messageText;
  final String imageUrl;
  final String time;
  final bool isMessageRead;
  final String userId;
  final String type;
  final int readCount;
  final String userName;
  final String userImage;
  final String? senderId;
  final String? senderName;
  final String? typeMessage;
  final ChatsModel? chatsModel;
  final Function(String)? onDelete;

  const ConversationList({
    super.key,
    required this.id,
    required this.name,
    required this.messageText,
    required this.imageUrl,
    required this.time,
    required this.isMessageRead,
    required this.userId,
    required this.type,
    required this.readCount,
    required this.userName,
    required this.userImage,
    this.senderId,
    this.senderName,
    this.typeMessage,
    required this.chatsModel,
    this.onDelete,
  });

  Widget badgeCounter(int readCountData) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
        border:
            Border.all(color: Colors.white, width: 2), // Optional white border
      ),
      constraints: const BoxConstraints(
        minWidth: 20,
        minHeight: 20,
      ),
      child: Text(
        readCountData.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  String senderCheck() {
    String sender = '';
    if (chatsModel?.lastMessage?.senderId == userId) {
      sender = 'You';
    } else {
      log('senderName $senderName');
      sender = senderName ?? "Personal-${chatsModel?.lastMessage?.senderId}";
    }
    return '$sender :';
  }

  Widget _contentMessage(BuildContext context) {
    if (typeMessage == AppConstants.typeMessageImage ||
        typeMessage == AppConstants.typeMessageFile ||
        typeMessage == AppConstants.typeMessageVideo) {
      if (type == AppConstants.typeChatGroup) {
        return Row(children: [
          Flexible(
            fit: FlexFit.loose,
            child: Text(
              senderCheck(),
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight:
                      isMessageRead ? FontWeight.normal : FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 5),
          Icon(
            typeMessage == AppConstants.typeMessageImage
                ? Icons.image
                : typeMessage == AppConstants.typeMessageVideo
                    ? Icons.movie
                    : Icons.insert_drive_file,
            color: Colors.grey.shade600,
            size: 20,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              messageText,
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight:
                      isMessageRead ? FontWeight.normal : FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ]);
      } else {
        return Row(children: [
          Icon(
            typeMessage == AppConstants.typeMessageImage
                ? Icons.image
                : typeMessage == AppConstants.typeMessageVideo
                    ? Icons.movie
                    : Icons.insert_drive_file,
            color: Colors.grey.shade600,
            size: 20,
          ),
          const SizedBox(width: 5),
          Expanded(
              child: Text(
            messageText,
            style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight:
                    isMessageRead ? FontWeight.normal : FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )),
        ]);
      }
    } else {
      if (type == AppConstants.typeChatGroup) {
        return Text(
          '${senderCheck()} $messageText',
          style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: isMessageRead ? FontWeight.normal : FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      } else {
        return Text(
          messageText,
          style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: isMessageRead ? FontWeight.normal : FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    log('Debug => participants ${chatsModel?.participants?.length}');

    Widget conversationWidget = GestureDetector(
      onTap: () {
        context.router.push(ChatDetailRoute(
            chatData: ChatData(
          id: id,
          userId: userId,
          type: type,
          userName: userName,
          userImage: userImage,
          senderId: senderId,
          totalParticipants: chatsModel?.participants?.length ?? 0,
        )));
      },
      child: Container(
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  // CircleAvatar(
                  //   backgroundImage: NetworkImage(imageUrl),
                  //   maxRadius: 30,
                  // ),
                  CircleImage(
                      imageUrl: imageUrl,
                      height: 50,
                      width: 50,
                      iconDefault: type == AppConstants.typeChatGroup
                          ? Icons.group
                          : Icons.person),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(name, style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 6),
                          _contentMessage(context)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(time,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: isMessageRead
                            ? FontWeight.normal
                            : FontWeight.bold)),
                if (readCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: badgeCounter(readCount),
                  ),
              ],
            )
          ],
        ),
      ),
    );

    // If onDelete callback is provided, wrap with Dismissible
    if (onDelete != null) {
      return Dismissible(
        key: Key(id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20.0),
          color: Colors.red,
          child: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Delete Conversation'),
                content: Text(
                    'Are you sure you want to delete the conversation with $name? This action cannot be undone.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Delete'),
                  ),
                ],
              );
            },
          );
        },
        onDismissed: (direction) {
          onDelete!(id);
        },
        child: conversationWidget,
      );
    }

    return conversationWidget;
  }
}
