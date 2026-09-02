import 'dart:developer';

import 'package:chat/models/last_message_model.dart';
import 'package:chat/models/message_model.dart';
import 'package:chat/models/pagination_message.dart';
import 'package:chat/repositories/message_repository_interface.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageRepository implements MessageRepositoryInterface {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Future<List<MessageModel>> getMessage(
  //   chatId,
  //   DocumentSnapshot? lastDoc,
  //   int limit,
  // ) async {
  //   Query query = _firestore
  //     .collection('chats')
  //     .doc(chatId)
  //     .collection('messages')
  //     .orderBy('timestamp', descending: true)
  //     .limit(limit);

  //   if (lastDoc != null) {
  //     query = query.startAfterDocument(lastDoc);
  //   }

  //   final snapshot = await query.get();

  //   return snapshot.docs
  //       .map((doc) => MessageModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
  //       .toList();
  // }

  @override
  Future<PaginatedMessages> getMessage(String chatId, DocumentSnapshot<Object?>? lastDoc, int limit) async{
    log('Debug -> Fetching messages for chatId: $chatId, lastDoc: $lastDoc, limit: $limit');
    Query query = _firestore
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .orderBy('timestamp', descending: true)
      .limit(limit);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    final snapshot = await query.get();

    final messages = snapshot.docs
      .map((doc) => MessageModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
      .toList();

    log('Debug -> Fetching messages ${messages.length}');

    return PaginatedMessages(
      messages: messages,
      lastDoc: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
    );
  }

  //not used
  Future<void> addMessage(MessageModel message, chatId) async {
    await _firestore
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .add(message.toFirestore());
  }

  //not used
  Future<void> updateLastMessage(LastMessageModel lastMessage, chatId) async {
    await _firestore
      .collection('chats')
      .doc(chatId)
      .update(lastMessage.toFirestore());
  }

  Future<void> readBy(userId, chatId) async {
    WriteBatch batch = _firestore.batch();

    final readBy = [userId];
    final DocumentReference chatRef = _firestore.collection('chats').doc(chatId);
    batch.update(chatRef, {
      'unreadCounts.$userId': 0,
      'lastMessage.readBy': FieldValue.arrayUnion(readBy)
    });
    final CollectionReference messageRef = _firestore.collection('chats').doc(chatId).collection('messages');
    final messagesSnapshot = await messageRef.get();
    for (final doc in messagesSnapshot.docs) {
      batch.update(doc.reference, {
        'readBy': FieldValue.arrayUnion(readBy),
      });
    }
    
    await batch.commit();
  }

  Future<void> createAndUpdateMessage(String userId, LastMessageModel lastMessage, MessageModel message, chatId) async {
    WriteBatch batch = _firestore.batch();

    final DocumentReference chatRef = _firestore.collection('chats').doc(chatId);
    final messagesSnapshot = await chatRef.get();
    final data = messagesSnapshot.data() as Map<String, dynamic>? ?? {};
    final unreadCounts = data['unreadCounts'] as Map<String, dynamic>? ?? {};
    log("unreadCounts: $unreadCounts");
    for (var entry in unreadCounts.entries) {
      log("entry key: ${entry.key} entry value: ${entry.value}");
      if (entry.key == userId) {
        batch.update(chatRef, {
          'unreadCounts.$userId': 0,
        });
      } else {
        batch.update(chatRef, {
          'unreadCounts.${entry.key}': entry.value + 1
        });
      }
    }
    final DocumentReference messageRef = _firestore.collection('chats').doc(chatId).collection('messages').doc();
    batch.update(chatRef,  {
      'lastMessage': lastMessage.toFirestore(),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
    batch.set(messageRef, message.toFirestore());

    await batch.commit();
  }

  Future<void> deleteMessage(String chatId, String messageId) async {
    
    // Delete the message from Firestore
    final deleteBatch = _firestore.batch();
    final messageRef = _firestore
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .doc(messageId);
    
    deleteBatch.delete(messageRef);
    await deleteBatch.commit();
    
    // update the latest lastMessage
    WriteBatch batch = _firestore.batch();

    // Get the latest remaining message to update lastMessage
    final remainingMessagesQuery = _firestore
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .orderBy('timestamp', descending: true)
      .limit(1);
    
    final remainingMessagesSnapshot = await remainingMessagesQuery.get();
    
    if (remainingMessagesSnapshot.docs.isNotEmpty) {
      // There are remaining messages, update lastMessage with the latest one
      final latestMessage = MessageModel.fromFirestore(
        remainingMessagesSnapshot.docs.first.data(),
        remainingMessagesSnapshot.docs.first.id
      );

      String contentMessage = latestMessage.content;
      if (contentMessage.isEmpty) {
        if (latestMessage.type == "image") {
          contentMessage = 'Photo';
        } else if (latestMessage.type == "video") {
          contentMessage = 'Video';
        } else {
          contentMessage = latestMessage.fileName ?? "";
        }
      }
      
      final lastMessage = LastMessageModel(
        content: contentMessage,
        senderId: latestMessage.sender,
        timestamp: latestMessage.timestamp,
        type: latestMessage.type,
        readBy: latestMessage.readBy,
      );
      
      final chatRef = _firestore.collection('chats').doc(chatId);
      batch.update(chatRef, {
        'lastMessage': lastMessage.toFirestore(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } else {
      // No remaining messages, clear the lastMessage
      final chatRef = _firestore.collection('chats').doc(chatId);
      batch.update(chatRef, {
        'lastMessage': null,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    }
    
    await batch.commit();
  }

}