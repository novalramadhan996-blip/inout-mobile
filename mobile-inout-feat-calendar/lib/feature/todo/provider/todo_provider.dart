import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobile_in_out/core/resources/repositories/repository.dart';
import 'package:mobile_in_out/core/utils/enum_state.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';
import 'package:mobile_in_out/core/utils/models/list_data_request.dart';
import 'package:mobile_in_out/feature/todo/model/response_project.dart';

class TodoProvider with ChangeNotifier {
  final Repository _repository;

  TodoProvider(this._repository);

  RequestState _stateView = RequestState.Empty;
  RequestState get stateView => _stateView;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<ResponseProject> _projectListData = [];
  List<ResponseProject> get projectListData => _projectListData;

  Future<void> getProjectList(ListDataRequest request) async {
    _stateView = RequestState.Loading;
    notifyListeners();

    final response = await _repository.getProjectList(request);

    response.fold(
      (error) {
        LogHelper.logDebug('error ${error.message.toString()}');
        _errorMessage = error.message.toString();
        _stateView = RequestState.Error;
        _projectListData = [];
        notifyListeners();
      },
      (data) async {
        _stateView = RequestState.Loaded;

        List<ResponseProject>? responseData = data.response;
        LogHelper.logDebug(
          'Debug => ProjectList : getProjectList responseData $responseData',
        );
        _projectListData = responseData ?? [];

        notifyListeners();
      },
    );
  }
}
