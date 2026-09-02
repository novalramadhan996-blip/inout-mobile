import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:mobile_in_out/core/resources/repositories/repository.dart';
import 'package:mobile_in_out/core/utils/enum_state.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';
import 'package:mobile_in_out/core/utils/models/member_list_model.dart';
import 'package:mobile_in_out/feature/board/model/response_project.dart';
import 'package:mobile_in_out/feature/board/model/response_task.dart';

class BoardProvider with ChangeNotifier {
  final Repository _repository;

  BoardProvider(this._repository);

  RequestState _stateView = RequestState.Empty;
  RequestState get stateView => _stateView;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<ResponseBoard> _projectListData = [];
  List<ResponseBoard> get projectListData => _projectListData;

  List<ResponseTask> _taskListData = [];
  List<ResponseTask> get taskListData => _taskListData;

  List<ProjectTaskMemberModel> _memberListData = [];
  List<ProjectTaskMemberModel> get memberListData => _memberListData;

  Future<void> getProjectBoardList(
    String projectId,
    String page,
    String limit,
    String sortby,
    String orderby, {
    String? search,
  }) async {
    _stateView = RequestState.Loading;
    notifyListeners();

    final response = await _repository.getProjectBoardList(
      projectId,
      page,
      limit,
      sortby,
      orderby,
      search: search,
    );

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

        List<ResponseBoard>? responseData = data.response;
        LogHelper.logDebug(
          'Debug => ProjectList : getProjectList responseData $responseData',
        );
        _projectListData = responseData ?? [];

        notifyListeners();
      },
    );
  }

  Future<void> getProjectTaskList(
    String projectId,
    String boardId,
    String page,
    String limit,
    String sortby,
    String orderby, {
    String? search,
  }) async {
    _stateView = RequestState.Loading;
    notifyListeners();

    final response = await _repository.getProjectTaskList(
      projectId,
      boardId,
      page,
      limit,
      sortby,
      orderby,
      search: search,
    );

    response.fold(
      (error) {
        LogHelper.logDebug('error ${error.message.toString()}');
        _errorMessage = error.message.toString();
        _stateView = RequestState.Error;
        notifyListeners();
      },
      (data) async {
        _stateView = RequestState.Loaded;

        List<ResponseTask>? responseData = data.response;
        LogHelper.logDebug(
          'Debug => ProjectList : getProjectList responseData $responseData',
        );
        _taskListData = responseData ?? [];

        notifyListeners();
      },
    );
  }

  Future<void> getMemberList(
    String projectId,
    String boardId,
    String taskId,
    String page,
    String limit,
    String sortby,
    String orderby, {
    String? search,
  }) async {
    _stateView = RequestState.Loading;
    notifyListeners();

    final response = await _repository.getMemberList(
      projectId,
      boardId,
      taskId,
      page,
      limit,
      sortby,
      orderby,
      search: search,
    );

    response.fold(
      (error) {
        LogHelper.logDebug('error ${error.message.toString()}');
        _errorMessage = error.message.toString();
        _stateView = RequestState.Error;
        notifyListeners();
      },
      (data) async {
        _stateView = RequestState.Loaded;

        List<ProjectTaskMemberModel>? responseData = data.response;
        LogHelper.logDebug(
          'Debug => MemberList : getTaskList responseData $responseData',
        );
        _memberListData = responseData ?? [];

        notifyListeners();
      },
    );
  }
}
