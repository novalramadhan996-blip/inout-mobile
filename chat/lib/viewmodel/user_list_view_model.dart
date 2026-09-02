import 'dart:developer';
import 'package:chat/core/utils/request_state.dart';
import 'package:chat/models/filter_list_model_request.dart';
import 'package:chat/models/profile_model.dart';
import 'package:chat/models/user_list_model.dart';
import 'package:chat/repositories/repository.dart';
import 'package:flutter/foundation.dart';

class UserListViewModel with ChangeNotifier {
  final Repository _repository;

  UserListViewModel(this._repository);

  RequestState _stateView = RequestState.Empty;
  RequestState get stateView => _stateView;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<UserListModel> _userListData = [];
  List<UserListModel> get userListData => _userListData;

  Future<void> getUserList(FilterListModelRequest request) async {
    _stateView = RequestState.Loading;
    notifyListeners();

    final response = await _repository.getUserList(request: request);

    response.fold(
      (error) {
        log('error ${error.message.toString()}');
        _errorMessage = error.message.toString();
        _stateView = RequestState.Error;
        notifyListeners();
      },
      (data) async {
        _stateView = RequestState.Loaded;

        List<UserListModel>? responseData = data.response;
        log('Debug => UserListViewModel : getUserList responseData $responseData');
        _userListData = responseData ?? [];

        notifyListeners();
      },
    );
  }

  Future<ProfileModel?> getProfileLocal() async {
    final response = await _repository.getProfileLocal();
    return response;
  }
}
