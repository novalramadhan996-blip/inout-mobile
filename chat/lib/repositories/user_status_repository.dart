import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_status_model.dart';

class UserStatusRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserStatusModel> getUserStatus(senderId) async {
    log('getUserStatus senderId ${senderId}');
    final snapshot =
        await _firestore.collection('userStatus').doc(senderId).get();

    log('getUserStatus Repo ${snapshot.data()}');

    if (!snapshot.exists) return UserStatusModel();

    return UserStatusModel.fromFirestore(snapshot.data() ?? {}, snapshot.id);
  }

  Future<void> updateUserStatus(
      UserStatusModel userStatus, String userId) async {
    if (userId.isNotEmpty) {
      await _firestore
          .collection('userStatus')
          .doc(userId)
          .set(userStatus.toFirestore(), SetOptions(merge: true));
    }
  }
}
