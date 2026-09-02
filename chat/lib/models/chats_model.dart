import 'package:chat/models/last_message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatsModel {
  final String? id;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final String? groupId;
  final String? createdBy;
  final String? type;
  final LastMessageModel? lastMessage;
  final List<dynamic>? participants;
  final Map<String, int>? unreadCounts;

  ChatsModel({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.groupId,
    this.createdBy,
    this.type,
    this.lastMessage,
    this.participants,
    this.unreadCounts,
  });

  factory ChatsModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ChatsModel(
      id: id,
      createdAt: data['createdAt'] is Timestamp
          ? data['createdAt'] as Timestamp
          : Timestamp.now(),
      updatedAt: data['updatedAt'] is Timestamp
          ? data['updatedAt'] as Timestamp
          : Timestamp.now(),
      groupId: data['groupId'].toString(),
      createdBy: data['createdBy'].toString(),
      type: data['type'] ?? '',
      lastMessage: LastMessageModel.fromFirestore(data['lastMessage'] ?? {}),
      participants: data['participants'] is List
          ? data['participants'] as List<dynamic>
          : [],
      unreadCounts: data['unreadCounts'] != null
          ? Map<String, int>.from((data['unreadCounts'] as Map)
              .map((key, value) => MapEntry(key.toString(), value as int)))
          : {},
      // groupName: data['groupName'],
      // groupAvatar: data['groupAvatar'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'groupId': groupId,
      'createdBy': createdBy,
      'type': type,
      'lastMessage': lastMessage,
      'participants': participants,
      'unreadCounts': unreadCounts,
      // 'groupName': groupName,
      // 'groupAvatar': groupAvatar,
    };
  }

  Map<String, dynamic> toFirestoreUpdate() {
    return {
      'unreadCounts': unreadCounts,
    };
  }
}
