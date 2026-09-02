import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mobile_in_out/core/utils/widgets/app_coming_soon.dart';

@RoutePage()
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return const AppComingSoon(
      title: "CHAT PAGE",
      icon: Icons.chat_bubble_outline,
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   final chatItem = ListOf.chat;
  //   return Scaffold(
  //     body: CstmScrollView(
  //       title: "INBOX",
  //       onPressedInIcon: () {},
  //       iconAction: Icons.add,
  //       sliverChildDelegate: SliverChildBuilderDelegate(
  //         childCount: chatItem.length,
  //         (context, index) {
  //           final chat = chatItem[index];
  //           return AppListTileWithDivider(
  //             onTap: () => context.router.push(
  //               ChatRoomRoute(
  //                 nameUser: chat.name!,
  //                 imageUrl: chat.imageUrl!,
  //               ),
  //             ),
  //             paddingTop: 5,
  //             leading: ClipOval(
  //               child: Container(
  //                 width: 50,
  //                 height: 50,
  //                 decoration: BoxDecoration(
  //                   image: DecorationImage(
  //                     image: AssetImage(
  //                       chat.imageUrl!,
  //                     ),
  //                     fit: BoxFit.cover,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             title: chat.name!,
  //             titleStyle: AppStyle(
  //               color: AppColors.blackColor,
  //               weight: bold,
  //             ).headline2,
  //             subtitle: Text(
  //               chat.message!,
  //               style: AppStyle(color: AppColors.blackColor)
  //                   .headline4
  //                   .copyWith(fontSize: 15),
  //               maxLines: 2,
  //               overflow: TextOverflow.ellipsis,
  //             ),
  //             trailing: Column(
  //               children: [
  //                 Text(chat.time!),
  //                 const SizedBox(
  //                   height: 10,
  //                 ),
  //                 ClipOval(
  //                   child: Container(
  //                     height: 15,
  //                     width: 15,
  //                     color: (chat.onStatus == true)
  //                         ? AppColors.redColors
  //                         : AppColors.primaryColor,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }

}
