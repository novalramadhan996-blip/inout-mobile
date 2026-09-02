import 'package:chat/models/pagination_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class MessageRepositoryInterface {
  
  Future<PaginatedMessages> getMessage(String chatId, DocumentSnapshot? lastDoc, int limit);

}