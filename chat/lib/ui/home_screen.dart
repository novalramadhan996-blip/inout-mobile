import 'dart:developer';
import 'package:auto_route/auto_route.dart';
import 'package:chat/core/resources/injector/di.dart';
import 'package:chat/core/resources/storage/shared_preference_service.dart';
import 'package:chat/ui/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SharedPreferenceService _prefService = sl<SharedPreferenceService>();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() async {
    final email = await _prefService.getString(PrefServiceKey.email);
    log('chat_screen -> email shared  : $email');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      resizeToAvoidBottomInset: false,
      body: const ChatScreen(),
      // body: Consumer<RouteChangeNotifier>(
      //   builder: (context, routeChangeNotifier, child) {
      //     return const ChatSreen()
      //   }
      // ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: "Chats",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_work),
            label: "Channels",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
