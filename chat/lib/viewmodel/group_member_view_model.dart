import 'dart:developer';

import 'package:chat/core/utils/request_state.dart';
import 'package:chat/models/filter_list_model_request.dart';
import 'package:chat/models/organization_employee_model.dart';
import 'package:chat/repositories/repository.dart';
import 'package:flutter/material.dart';

class GroupMemberViewModel with ChangeNotifier {
  final Repository _repository;

  GroupMemberViewModel(this._repository);

  RequestState _stateView = RequestState.Empty;
  RequestState get stateView => _stateView;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<OrganizationEmployeeModel> _groupMemberData = [];
  List<OrganizationEmployeeModel> get groupMemberData => _groupMemberData;

  Future<void> getGroupMember(FilterListModelRequest request) async {
    _stateView = RequestState.Loading;
    notifyListeners();

    final response = await _repository.getGroupMermber(request: request);

    response.fold(
      (error) {
        log('error ${error.message.toString()}');
        _errorMessage = error.message.toString();
        _stateView = RequestState.Error;
        notifyListeners();
      },
      (data) async {
        _stateView = RequestState.Loaded;

        List<OrganizationEmployeeModel>? responseData = data.response;
        log('Debug => UserListViewModel : getUserList responseData $responseData');
        _groupMemberData = responseData ?? [];

        notifyListeners();
      },
    );
  }
}
