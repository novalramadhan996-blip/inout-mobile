// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:chat/core/route_change_notifier.dart';
import 'package:chat/ui/chat_detail_screen.dart';
import 'package:chat/ui/home_screen.dart';
import 'package:chat/ui/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alice/alice.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chat_example/main.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('Verify Platform version', (WidgetTester tester) async {
    final RouteChangeNotifier _routeChangeNotifier = RouteChangeNotifier();

    final GoRouter _router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const LoadingScreen(),
        ),
        GoRoute(
          path: '/home_screen',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
            path: '/chat_detail',
            builder: (context, state) {
              final chatData = state.extra as ChatData; // Retrieve the object
              return ChatDetailScreen(chatData: chatData);
            }),
      ],
      refreshListenable: _routeChangeNotifier,
    );

    // final Alice alice;

    // Build our app and trigger a frame.
    // await tester.pumpWidget(MyApp(router: _router, alice: alice,));

    // Verify that platform version is retrieved.
    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is Text && widget.data!.startsWith('Running on:'),
      ),
      findsOneWidget,
    );
  });
}
