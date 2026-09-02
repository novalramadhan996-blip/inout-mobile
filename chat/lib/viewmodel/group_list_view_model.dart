import 'dart:developer';
import 'package:chat/core/utils/request_state.dart';
import 'package:chat/models/filter_list_model_request.dart';
import 'package:chat/models/organization_model.dart';
import 'package:chat/repositories/repository.dart';
import 'package:flutter/foundation.dart';

class GroupListViewModel with ChangeNotifier {
  final Repository _repository;

  GroupListViewModel(this._repository);

  RequestState _stateView = RequestState.Empty;
  RequestState get stateView => _stateView;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // List<ProjectModel> _groupListData = [];
  // List<ProjectModel> get groupListData => _groupListData;

  // Future<void> getGroupList(FilterListModelRequest request) async {
  //   _stateView = RequestState.Loading;
  //   notifyListeners();

  //   final response = await _repository.getGroupList(request: request);

  //   response.fold(
  //     (error) {
  //       log('error ${error.message.toString()}');
  //       _errorMessage = error.message.toString();
  //       _stateView = RequestState.Error;
  //       notifyListeners();
  //     },
  //     (data) async {
  //       _stateView = RequestState.Loaded;

  //       List<ProjectModel>? responseData = data.response;
  //       log('Debug => UserListViewModel : getUserList responseData $responseData');
  //       _groupListData = responseData ?? [];

  //       notifyListeners();
  //     },
  //   );
  // }

  List<OrganizationModel> _groupListData = [];
  List<OrganizationModel> get groupListData => _groupListData;

  Future<void> getGroupList(
      String appsId, FilterListModelRequest request) async {
    _stateView = RequestState.Loading;
    notifyListeners();

    final response =
        await _repository.getGroupList(appsId: appsId, request: request);

    response.fold(
      (error) {
        log('error ${error.message.toString()}');
        _errorMessage = error.message.toString();
        _stateView = RequestState.Error;
        notifyListeners();
      },
      (data) async {
        _stateView = RequestState.Loaded;

        List<OrganizationModel>? responseData = data.response;
        log('Debug => UserListViewModel : getUserList responseData $responseData');
        _groupListData = responseData ?? [];

        notifyListeners();
      },
    );
  }
}
