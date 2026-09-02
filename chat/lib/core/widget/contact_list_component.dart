import 'dart:developer';
import 'package:auto_route/auto_route.dart';
import 'package:chat/controllers/chats_controller.dart';
import 'package:chat/core/resources/injector/di.dart';
import 'package:chat/core/routes/router_import.dart';
import 'package:chat/core/routes/router_import.gr.dart';
import 'package:chat/core/widget/circle_image.dart';
import 'package:chat/core/widget/dialog_widget.dart';
import 'package:chat/models/chats_request_model.dart';
import 'package:chat/models/filter_list_model_request.dart';
import 'package:chat/models/last_message_model.dart';
import 'package:chat/models/organization_model.dart';
import 'package:chat/models/user_list_model.dart';
import 'package:chat/repositories/repository.dart';
import 'package:chat/ui/chat_detail_screen.dart';
import 'package:chat/viewmodel/group_member_view_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ContactListComponent extends StatefulWidget {
  final String? id;
  final String? name;
  final String? imageUrl;
  final String? userId;
  final String? type;
  final bool isGroup;
  final bool isAdmin;
  final List<UserListModel>? users;
  final List<OrganizationModel>? organizations;

  const ContactListComponent({
    super.key,
    this.id,
    this.name,
    this.imageUrl,
    this.userId,
    this.type,
    required this.isGroup,
    required this.isAdmin,
    this.users,
    this.organizations,
  });

  @override
  State<ContactListComponent> createState() => _ContactListComponentState();
}

class _ContactListComponentState extends State<ContactListComponent> {
  final ChatsController _chatsController = ChatsController();

  void _newChat(BuildContext context) async {
    String documentId = '';
    int totalParticipants = 0;

    log('Debug -> chat_detail_screen top ${widget.userId} dan ${widget.id}');
    final chatsController = await _chatsController.getChatsPrivate(
        widget.userId != null && widget.userId != '' ? widget.userId : '-1',
        widget.id);

    final sortChat = chatsController.where((chat) {
      List<dynamic> participantData = chat.participants ?? [];
      log('participantData $participantData');
      bool isParticipant = participantData.contains(widget.userId) &&
          participantData.contains(widget.id.toString()) &&
          participantData.length == 2;
      log('participantData $isParticipant');
      return isParticipant;
    }).toList();

    log('Debug -> chat_detail_screen top ${sortChat.length}');

    if (sortChat.isEmpty) {
      log('Debug -> chat_detail_screen ${widget.userId} dan ${widget.id.toString()}');
      List<String> participants = [widget.userId ?? '', widget.id.toString()];
      Map<String, int> unreadCounts = {
        widget.userId ?? '-1': 0,
        widget.id.toString(): 1,
      };

      log('participants, $participants');
      final chatData = ChatsRequestModel(
        createdBy: widget.userId,
        type: 'private',
        participants: participants,
        unreadCounts: unreadCounts,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      final newLastMessage = LastMessageModel(
          content: "",
          senderId: widget.userId,
          timestamp: Timestamp.fromDate(DateTime.now()),
          type: 'text',
          readBy: [widget.userId]);

      documentId = await _chatsController.addChat(chatData, newLastMessage);
      totalParticipants = participants.length;
    } else {
      log('Debug -> chat_detail_screen chatsController ${sortChat.first.participants}');
      documentId = sortChat.first.id ?? '';
      log('Debug -> chat_detail_screen documentId $documentId');
      totalParticipants = sortChat.first.participants?.length ?? 0;
    }

    if (context.mounted) {
      context.router.push(
        ChatDetailRoute(
          chatData: ChatData(
            id: documentId,
            userId: widget.userId ?? '',
            type: widget.type ?? '',
            userName: widget.name ?? '',
            userImage: widget.imageUrl ?? '',
            senderId: widget.id.toString(),
            totalParticipants: totalParticipants,
          ),
        ),
      );
    }
  }

  void _newChatGroup(BuildContext context) async {
    final repository = sl<Repository>();
    final groupMemberViewModel = GroupMemberViewModel(repository);

    bool hasAccess = false;

    if (widget.organizations != null && widget.organizations!.isNotEmpty) {
      for (final org in widget.organizations!) {
        final organizationId = org.organizationId;
        if (organizationId != null) {
          final request = FilterListModelRequest(
            limit: 1,
            filter: FilterData(
                organizationId: organizationId, employeeId: widget.userId),
          );

          await groupMemberViewModel.getGroupMember(request);
          final members = groupMemberViewModel.groupMemberData;

          final isUserInOrg = members.any(
            (member) => member.employeeId == widget.userId,
          );

          if (isUserInOrg) {
            hasAccess = true;
            break;
          }
        }
      }
    }

    log('hasAccess $hasAccess');
    log('hasadmin ${widget.isAdmin}');

    if (widget.isAdmin || hasAccess) {
      String documentId = '';
      int totalParticipants = 0;

      log('Debug -> chat_detail_screen group id ${widget.id}');
      final chatsController = await _chatsController.getChatsGroup(widget.id);
      log('Debug -> chat_detail_screen chatsController ${chatsController.length}');

      List<String> participants = [];
      Map<String, int> unreadCounts = {};
      widget.users?.forEach((user) {
        participants.add(user.employeeId.toString());
      });

      participants.add(widget.userId.toString());

      log('participants, $participants');

      if (chatsController.isEmpty) {
        log('Debug -> chat_detail_screen create ${widget.userId}');
        log('Debug -> chat_detail_screen create ${chatsController.length}');

        widget.users?.forEach((user) {
          unreadCounts[user.employeeId.toString()] = 0;
        });
        unreadCounts[widget.userId.toString()] = 0;

        log('unreadCounts, $unreadCounts');

        final chatData = ChatsRequestModel(
          createdBy: widget.userId,
          type: 'group',
          groupId: widget.id,
          participants: participants,
          unreadCounts: unreadCounts,
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
        );

        final newLastMessage = LastMessageModel(
            content: "",
            senderId: widget.userId,
            timestamp: Timestamp.fromDate(DateTime.now()),
            type: 'text',
            readBy: [widget.userId]);

        documentId = await _chatsController.addChat(chatData, newLastMessage);
        totalParticipants = participants.length;
      } else {
        log('Debug -> chat_detail_screen update chatsController ${chatsController.first.participants}');
        documentId = chatsController.first.id ?? '';
        totalParticipants = chatsController.first.participants?.length ?? 0;
        log('Debug -> chat_detail_screen documentId $documentId');
        final updateData = {
          "participants": participants,
          "unreadCounts": unreadCounts,
        };
        String result =
            await _chatsController.updateChat(documentId, updateData);
        log('result $result');
      }

      if (context.mounted) {
        context.router.push(
          ChatDetailRoute(
            chatData: ChatData(
                id: documentId,
                userId: widget.userId ?? '',
                type: widget.type ?? '',
                userName: widget.name ?? '',
                userImage: widget.imageUrl ?? '',
                senderId: widget.id.toString(),
                totalParticipants: totalParticipants),
          ),
        );
      }
    } else {
      if (context.mounted) {
        DialogWidget.alertDialog(context, 'Anda tidak bisa masuk group');
      }
    }
  }

  void hideBottomSheet(BuildContext context) {
    if (context.mounted) {
      context.router.maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        hideBottomSheet(context);
        if (widget.isGroup) {
          _newChatGroup(context);
        } else {
          _newChat(context);
        }
      },
      child: Container(
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  CircleImage(
                      // imageUrl: widget.imageUrl,
                      height: 50,
                      width: 50,
                      iconDefault: widget.isGroup ? Icons.group : Icons.person),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(widget.name ?? '',
                              style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
