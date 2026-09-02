import 'dart:developer';
import 'dart:io';
import 'package:chat/core/utils/request_state.dart';
import 'package:chat/models/response_upload_model.dart';
import 'package:chat/repositories/repository.dart';
import 'package:flutter/foundation.dart';

class ChatViewModel with ChangeNotifier {
  final Repository _repository;

  ChatViewModel(this._repository);

  RequestState _stateView = RequestState.Empty;
  RequestState get stateView => _stateView;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  ResponseUploadModel _responseData = ResponseUploadModel();
  ResponseUploadModel get responseData => _responseData;

  Future<void> uploadFile(File file) async {
    _stateView = RequestState.Loading;
    notifyListeners();

    final response = await _repository.uploadFile(file: file);

    response.fold(
      (error) {
        log('error ${error.message.toString()}');
        _errorMessage = error.message.toString();
        _stateView = RequestState.Error;
        notifyListeners();
      },
      (data) async {
        _stateView = RequestState.Loaded;

        _responseData = data.response ?? ResponseUploadModel();

        notifyListeners();
      },
    );
  }

  Future<String> getGroupName(String? groupId) async {
    final response = await _repository.getGroupData(request: groupId ?? '');

    String? result = '';

    response.fold(
      (error) {
        log('error ${error.message.toString()}');
      },
      (data) {
        _stateView = RequestState.Loaded;
        // result = data.response?.projectName;
        result = data.response?.organizationName;
      },
    );

    return result ?? '';
  }

  Future<String> getUserName(String? userId) async {
    log('userid $userId');
    final response = await _repository.getUserData(request: userId ?? '');

    String? result = '';

    response.fold(
      (error) {
        log('error ${error.message.toString()}');
      },
      (data) {
        _stateView = RequestState.Loaded;
        result = data.response?.employeeName;
      },
    );

    return result ?? '';
  }
}
