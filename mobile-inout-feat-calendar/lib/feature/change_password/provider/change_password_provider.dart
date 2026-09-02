import 'package:mobile_in_out/core/resources/repositories/repository.dart';
import 'package:mobile_in_out/core/utils/enum_state.dart';
import 'package:flutter/material.dart';
import 'package:mobile_in_out/core/utils/models/auth/request_change_password.dart';

class ChangePasswordProvider extends ChangeNotifier {
  final Repository _repository;

  ChangePasswordProvider(this._repository);

  TextEditingController oldpassword = TextEditingController();
  TextEditingController newpassword = TextEditingController();
  TextEditingController confirmNewpassword = TextEditingController();

  RequestState _state = RequestState.Empty;
  RequestState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<void> changePassword(String oldPassword, String newPassword) async {
    _state = RequestState.Empty;
    _state = RequestState.Loading;
    RequestChangePassword request = RequestChangePassword(
      oldPassword: oldpassword.text,
      newPassword: newpassword.text
    );
    final result = await _repository.changePassword(request: request);

    result.fold(
      (failure) {
        _state = RequestState.Error;
        _errorMessage = failure.message.toString();
        notifyListeners();
      },
      (response) {
        _state = RequestState.Loaded;
        _resetErrorMessage();
        notifyListeners();
      }
    );
  }

  bool get getIsValidPassword => newpassword.text == confirmNewpassword.text;

  _resetErrorMessage() {
    oldpassword.clear();
    newpassword.clear();
    confirmNewpassword.clear();
    notifyListeners();
  }
}