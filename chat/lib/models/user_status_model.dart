import 'package:cloud_firestore/cloud_firestore.dart';

class UserStatusModel {
  final String? id;
  final Timestamp? lastUpdate;
  final String? status;

  UserStatusModel({
    this.id, 
    this.lastUpdate, 
    this.status
  });

  factory UserStatusModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserStatusModel(
      id: id,
      lastUpdate: data['lastUpdate'],
      status: data['status'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'lastUpdate': lastUpdate,
      'status': status,
    };
  }
}