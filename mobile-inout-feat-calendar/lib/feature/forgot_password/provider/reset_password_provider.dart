import 'package:mobile_in_out/core/resources/repositories/repository.dart';
import 'package:mobile_in_out/core/utils/enum_state.dart';
import 'package:flutter/material.dart';
import 'package:mobile_in_out/core/utils/models/auth/request_reset_password.dart';

class ResetPasswordProvider extends ChangeNotifier {
  final Repository _repository;
  ResetPasswordProvider(this._repository);

  TextEditingController nameCtrl = TextEditingController();
  TextEditingController otpCtrl = TextEditingController();

  RequestState _requestState = RequestState.Empty;
  RequestState get requestState => _requestState;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<void> requestResetPassword() async {
    _requestState = RequestState.Loading;
    notifyListeners();

    final response = await _repository.requestResetPassword(
      email: nameCtrl.text,
    );

    response.fold(
      (failure) {
        _errorMessage = failure.message.toString();
        _requestState = RequestState.Error;
        notifyListeners();
      },
      (data) {
        _requestState = RequestState.Loaded;
        notifyListeners();
      },
    );
  }

  RequestState _resetState = RequestState.Empty;
  RequestState get resetState => _resetState;

  String _resetErrorMessage = '';
  String get resetErrorMessage => _resetErrorMessage;

  Future<void> resetPassword() async {
    _resetState = RequestState.Loading;
    notifyListeners();
    RequestResetPassword request = RequestResetPassword(
      email: nameCtrl.text,
      code: otpCtrl.text,
    );
    final response = await _repository.resetPassword(request: request);

    response.fold(
      (failure) {
        _resetErrorMessage = failure.message.toString();
        _resetState = RequestState.Error;
        notifyListeners();
      },
      (data) {
        _resetState = RequestState.Loaded;
        notifyListeners();

        _clearCtrl();
      },
    );
  }

  _clearCtrl() {
    nameCtrl.clear();
    otpCtrl.clear();
  }
}
