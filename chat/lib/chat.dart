
import 'chat_platform_interface.dart';

class Chat {
  Future<String?> getPlatformVersion() {
    return ChatPlatform.instance.getPlatformVersion();
  }
}
