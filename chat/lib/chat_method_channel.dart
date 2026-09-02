import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'chat_platform_interface.dart';

/// An implementation of [ChatPlatform] that uses method channels.
class MethodChannelChat extends ChatPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('chat');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
