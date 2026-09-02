import 'package:chat/models/chats_model.dart';
import 'package:chat/models/chats_request_model.dart';
import 'package:chat/models/last_message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ChatsModel>> getChats(userId) async {
    final snapshot = await _firestore
      .collection('chats')
      .where('participants', arrayContains: userId)
      .orderBy('updatedAt', descending: true)
      .get();

    return snapshot.docs
        .map((doc) => ChatsModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<List<ChatsModel>> getChatsPrivate(userId, senderId) async {
    final snapshot = await _firestore
      .collection('chats')
      .where('participants', arrayContainsAny: [userId, senderId])
      .where('type', isEqualTo: 'private')
      .orderBy('updatedAt', descending: true)
      .get();

    return snapshot.docs
        .map((doc) => ChatsModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<String> addChat(ChatsRequestModel chat, LastMessageModel lastMessage) async {

    DocumentReference docRef = await _firestore.collection('chats').add(chat.toFirestore());

    await _firestore
      .collection('chats')
      .doc(docRef.id)
      .update({
        "lastMessage" : lastMessage.toFirestore()
      });

    String documentId = docRef.id;
    return documentId;
  }

  Future<String> updateChat(String chatId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('chats').doc(chatId).update(updatedData);
      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  Future<List<ChatsModel>> getChatsGroup(id) async {
    final snapshot = await _firestore
      .collection('chats')
      .where('type', isEqualTo: 'group')
      .where('groupId', isEqualTo: id)
      .get();

    return snapshot.docs
        .map((doc) => ChatsModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<String> deleteChat(String chatId) async {
    try {
      // Delete all messages in the chat first
      final messagesSnapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();
      
      // Delete all messages in a batch
      WriteBatch batch = _firestore.batch();
      for (var doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      
      // Delete the chat document
      await _firestore.collection('chats').doc(chatId).delete();
      
      return "success";
    } catch (e) {
      return e.toString();
    }
  }

}