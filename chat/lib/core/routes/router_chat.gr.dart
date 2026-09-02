// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i5;
import 'package:chat/ui/chat_detail_screen.dart' as _i1;
import 'package:chat/ui/chat_screen.dart' as _i2;
import 'package:chat/ui/home_screen.dart' as _i3;
import 'package:chat/ui/loading_screen.dart' as _i4;
import 'package:flutter/material.dart' as _i6;

/// generated route for
/// [_i1.ChatDetailScreen]
class ChatDetailRoute extends _i5.PageRouteInfo<ChatDetailRouteArgs> {
  ChatDetailRoute({
    _i6.Key? key,
    _i1.ChatData? chatData,
    String? navFrom = 'gsm_tracker',
    List<_i5.PageRouteInfo>? children,
  }) : super(
          ChatDetailRoute.name,
          args: ChatDetailRouteArgs(
            key: key,
            chatData: chatData,
            navFrom: navFrom,
          ),
          initialChildren: children,
        );

  static const String name = 'ChatDetailRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChatDetailRouteArgs>(
        orElse: () => const ChatDetailRouteArgs(),
      );
      return _i1.ChatDetailScreen(
        key: args.key,
        chatData: args.chatData,
        navFrom: args.navFrom,
      );
    },
  );
}

class ChatDetailRouteArgs {
  const ChatDetailRouteArgs({
    this.key,
    this.chatData,
    this.navFrom = 'gsm_tracker',
  });

  final _i6.Key? key;

  final _i1.ChatData? chatData;

  final String? navFrom;

  @override
  String toString() {
    return 'ChatDetailRouteArgs{key: $key, chatData: $chatData, navFrom: $navFrom}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatDetailRouteArgs) return false;
    return key == other.key &&
        chatData == other.chatData &&
        navFrom == other.navFrom;
  }

  @override
  int get hashCode => key.hashCode ^ chatData.hashCode ^ navFrom.hashCode;
}

/// generated route for
/// [_i2.ChatScreen]
class ChatRoute extends _i5.PageRouteInfo<ChatRouteArgs> {
  ChatRoute({_i6.Key? key, String? navFrom, List<_i5.PageRouteInfo>? children})
      : super(
          ChatRoute.name,
          args: ChatRouteArgs(key: key, navFrom: navFrom),
          initialChildren: children,
        );

  static const String name = 'ChatRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChatRouteArgs>(
        orElse: () => const ChatRouteArgs(),
      );
      return _i2.ChatScreen(key: args.key, navFrom: args.navFrom);
    },
  );
}

class ChatRouteArgs {
  const ChatRouteArgs({this.key, this.navFrom});

  final _i6.Key? key;

  final String? navFrom;

  @override
  String toString() {
    return 'ChatRouteArgs{key: $key, navFrom: $navFrom}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatRouteArgs) return false;
    return key == other.key && navFrom == other.navFrom;
  }

  @override
  int get hashCode => key.hashCode ^ navFrom.hashCode;
}

/// generated route for
/// [_i3.HomeScreen]
class HomeRoute extends _i5.PageRouteInfo<void> {
  const HomeRoute({List<_i5.PageRouteInfo>? children})
      : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i3.HomeScreen();
    },
  );
}

/// generated route for
/// [_i4.LoadingScreen]
class LoadingRoute extends _i5.PageRouteInfo<void> {
  const LoadingRoute({List<_i5.PageRouteInfo>? children})
      : super(LoadingRoute.name, initialChildren: children);

  static const String name = 'LoadingRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i4.LoadingScreen();
    },
  );
}
