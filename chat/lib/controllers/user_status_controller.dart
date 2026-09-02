import '../models/user_status_model.dart';
import '../repositories/user_status_repository.dart';

class UserStatusController {
  final UserStatusRepository _userStatusRepository = UserStatusRepository();

  Future<UserStatusModel> fetchUsers(senderId) async {
    return await _userStatusRepository.getUserStatus(senderId);
  }

  Future<void> updateUserStatus(
      UserStatusModel? userStatus, String? userId) async {
    await _userStatusRepository.updateUserStatus(
        userStatus ?? UserStatusModel(), userId ?? '');
  }
}
