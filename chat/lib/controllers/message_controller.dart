import 'package:chat/models/chats_model.dart';
import 'package:chat/models/last_message_model.dart';
import 'package:chat/models/message_model.dart';
import 'package:chat/models/pagination_message.dart';
import 'package:chat/repositories/message_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageController {
  final MessageRepository _messageRepository = MessageRepository();

  Future<PaginatedMessages> fetchMessage(
    chatId,
    DocumentSnapshot? lastDoc,
    int limit,
  ) async {
    return await _messageRepository.getMessage(chatId, lastDoc, limit);
  }

  //not used
  Future<void> addMessage(MessageModel message, chatId) async {
    await _messageRepository.addMessage(message, chatId);
  }

  //not used
  Future<void> updateLastMessage(LastMessageModel lastMessage, chatId) async {
    await _messageRepository.updateLastMessage(lastMessage, chatId);
  }

  Future<void> readBy(userId, chatId) async {
    await _messageRepository.readBy(userId, chatId);
  }

  Future<void> createAndUpdateMessage(
    String userId,
    LastMessageModel lastMessage, 
    MessageModel message, 
    chatId,
  ) async {
    await _messageRepository.createAndUpdateMessage(userId, lastMessage, message, chatId);
  }

  Future<void> deleteMessage(String chatId, String messageId) async {
    await _messageRepository.deleteMessage(chatId, messageId);
  }
}