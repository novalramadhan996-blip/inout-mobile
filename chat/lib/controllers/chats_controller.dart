import 'package:chat/models/chats_model.dart';
import 'package:chat/models/chats_request_model.dart';
import 'package:chat/models/last_message_model.dart';
import 'package:chat/repositories/chats_repository.dart';


class ChatsController {
  final ChatsRepository _chatsRepository = ChatsRepository();

  Future<List<ChatsModel>> fetchChats(userId) async {
    return await _chatsRepository.getChats(userId);
  }

  Future<List<ChatsModel>> getChatsPrivate(userId, senderId) async {
    return await _chatsRepository.getChatsPrivate(userId, senderId);
  }

  Future<List<ChatsModel>> getChatsGroup(id) async {
    return await _chatsRepository.getChatsGroup(id);
  }

  Future<String> addChat(ChatsRequestModel chat, LastMessageModel lastMessage) async {
    String documentId = await _chatsRepository.addChat(chat, lastMessage);
    return documentId;
  }

  Future<String> updateChat(chatId, updateChatData) async {
    String result = await _chatsRepository.updateChat(chatId, updateChatData);
    return result;
  }

  Future<String> deleteChat(String chatId) async {
    String result = await _chatsRepository.deleteChat(chatId);
    return result;
  }
}