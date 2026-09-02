import 'package:chat/models/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaginatedMessages {
  final List<MessageModel> messages;
  final DocumentSnapshot? lastDoc;

  PaginatedMessages({required this.messages, this.lastDoc});
}