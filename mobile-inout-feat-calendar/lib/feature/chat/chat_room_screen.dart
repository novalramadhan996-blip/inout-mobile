import 'package:mobile_in_out/core/resources/theme/app_style.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/utils/extensions/widget_extension.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class ChatRoomPage extends StatefulWidget {
  final String nameUser;
  final String imageUrl;
  const ChatRoomPage({Key? key, required this.nameUser, required this.imageUrl})
      : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final List<String> messages = [];

  void addMessage(String chat) {
    setState(() {
      messages.add(chat);
    });
  }

  final TextEditingController messageController = TextEditingController();

  void sendMessage() {
    String message = messageController.text.trim();
    if (message.isNotEmpty) {
      addMessage(message);
      messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.router.popForced(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.primaryColor,
          ),
        ),
        title: CircleAvatar(
          radius: 25,
          child: Image.asset(widget.imageUrl),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 100),
            child: Text(
              widget.nameUser,
              style: AppStyle(
                color: AppColors.blackColor,
                weight: FontWeight.bold,
              ).headline2,
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Text(
                        'No messages yet',
                        style: AppStyle(
                          color: AppColors.blackColor,
                          weight: bold,
                        ).headline4,
                      ),
                    )
                  : ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return ChatBubble(
                          message: message,
                          isMyMessage: index % 2 == 0,
                        );
                      },
                    ),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: AppColors.greyColor,
                    ),
                    child: TextField(
                      controller: messageController,
                      style: const TextStyle(
                        color: AppColors.blackColor,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Type Message...',
                        hintStyle: TextStyle(
                          color: AppColors.blackColor,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ).horizontalPadded(10),
                ),
                const SizedBox(width: 10),
                Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: IconButton(
                    onPressed: sendMessage,
                    icon: const Icon(
                      Icons.send,
                      color: AppColors.whiteColor,
                    ),
                  ),
                ),
              ],
            ).horizontalPadded(10),
          ],
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMyMessage;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isMyMessage,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
            left: (isMyMessage) ? 80 : 0,
            right: (isMyMessage) ? 0 : 80,
            top: 10),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color:
              isMyMessage ? AppColors.bacgroundListChat : AppColors.greyColor,
          border: Border.all(
            width: 1,
            color: AppColors.greyButtonColor,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          message,
          style: subtitle4.copyWith(color: AppColors.blackColor),
        ),
      ),
    );
  }
}
