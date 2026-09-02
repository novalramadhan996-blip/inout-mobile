import 'package:cloud_firestore/cloud_firestore.dart';

class LastMessageModel {
  final String? content;
  final String? senderId;
  final Timestamp? timestamp;
  final String? type;
  final List<dynamic>? readBy;

  LastMessageModel({
    this.content,
    this.senderId,
    this.timestamp,
    this.type,
    this.readBy,
  });

  factory LastMessageModel.fromFirestore(Map<String, dynamic> data) {
    return LastMessageModel(
      content: data['content'] ?? '',
      senderId: data['senderId'].toString(),
      timestamp: data['timestamp'] is Timestamp ? data['timestamp'] as Timestamp : Timestamp.now(),
      type: data['type'] ?? '',
      readBy: data['readBy'] is List ? data['readBy'] as List<dynamic> : [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'content': content,
      'timestamp': timestamp,
      'type': type,
      'senderId': senderId,
       if (readBy != null) 'readBy': FieldValue.arrayUnion(readBy?? [])
    };
  }

  Map<String, dynamic> toFirestoreUpdate() {
    return {
     if (readBy != null) 'readBy': FieldValue.arrayUnion(readBy?? []),
    };
  }
}