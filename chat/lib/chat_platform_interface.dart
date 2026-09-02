import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'chat_method_channel.dart';

abstract class ChatPlatform extends PlatformInterface {
  /// Constructs a ChatPlatform.
  ChatPlatform() : super(token: _token);

  static final Object _token = Object();

  static ChatPlatform _instance = MethodChannelChat();

  /// The default instance of [ChatPlatform] to use.
  ///
  /// Defaults to [MethodChannelChat].
  static ChatPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ChatPlatform] when
  /// they register themselves.
  static set instance(ChatPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
