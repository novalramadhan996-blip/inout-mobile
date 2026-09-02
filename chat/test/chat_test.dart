import 'package:flutter_test/flutter_test.dart';
import 'package:chat/chat.dart';
import 'package:chat/chat_platform_interface.dart';
import 'package:chat/chat_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockChatPlatform
    with MockPlatformInterfaceMixin
    implements ChatPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ChatPlatform initialPlatform = ChatPlatform.instance;

  test('$MethodChannelChat is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelChat>());
  });

  test('getPlatformVersion', () async {
    Chat chatPlugin = Chat();
    MockChatPlatform fakePlatform = MockChatPlatform();
    ChatPlatform.instance = fakePlatform;

    expect(await chatPlugin.getPlatformVersion(), '42');
  });
}
