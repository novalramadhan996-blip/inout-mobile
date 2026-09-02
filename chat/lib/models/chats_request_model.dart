import 'package:cloud_firestore/cloud_firestore.dart';

class ChatsRequestModel {
  final String? groupId;
  final String? createdBy;
  final String? type;
  final List<dynamic>? participants;
  final Map<String, int>? unreadCounts;
  final String? groupName;
  final String? groupAvatar;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  ChatsRequestModel({
    this.groupId,
    this.createdBy,
    this.type,
    this.participants,
    this.unreadCounts,
    this.groupName,
    this.groupAvatar,
    this.createdAt,
    this.updatedAt,
  });

  factory ChatsRequestModel.fromFirestore(
      Map<String, dynamic> data, String id) {
    return ChatsRequestModel(
      groupId: data['groupId'],
      createdBy: data['createdBy'],
      type: data['type'],
      participants: data['participants'] is List
          ? data['participants'] as List<dynamic>
          : [],
      unreadCounts: data['unreadCounts'] is Map<String, int>
          ? data['unreadCounts'] as Map<String, int>
          : {},
      groupName: data['groupName'],
      groupAvatar: data['groupAvatar'],
      createdAt: data['createdAt'] is Timestamp
          ? data['createdAt'] as Timestamp
          : Timestamp.now(),
      updatedAt: data['updatedAt'] is Timestamp
          ? data['updatedAt'] as Timestamp
          : Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'groupId': groupId,
      'createdBy': createdBy,
      'type': type,
      'participants': participants,
      'unreadCounts': unreadCounts,
      'groupName': groupName,
      'groupAvatar': groupAvatar,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
