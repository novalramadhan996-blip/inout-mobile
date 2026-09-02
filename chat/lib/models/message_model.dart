import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String content;
  final Timestamp timestamp;
  final String type;
  final String sender;
  final List<dynamic> readBy;
  final String? fileName;
  final String? fileType;
  final String? fileUrl;

  MessageModel({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.type,
    required this.sender,
    required this.readBy,
    this.fileName,
    this.fileType,
    this.fileUrl,
  });

  factory MessageModel.fromFirestore(Map<String, dynamic> data, String id) {
    return MessageModel(
      id: id, 
      content: data['content'] ?? '', 
      timestamp: data['timestamp'] is Timestamp ? data['timestamp'] as Timestamp : Timestamp.now(), 
      type: data['type'] ?? '', 
      sender: data['sender'].toString(),
      readBy: data['readBy'] is List ? data['readBy'] as List<dynamic> : [],
      fileName: data['fileName'] ?? '',
      fileType: data['fileType'] ?? '',
      fileUrl: data['fileUrl'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'content': content,
      'timestamp': timestamp,
      'type': type,
      'sender': sender,
      'readBy': FieldValue.arrayUnion(readBy),
      'fileName': fileName,
      'fileType': fileType,
      'fileUrl': fileUrl,
    };
  }
}