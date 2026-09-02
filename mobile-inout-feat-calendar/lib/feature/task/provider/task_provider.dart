import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_in_out/core/resources/repositories/repository.dart';
import 'package:mobile_in_out/core/utils/base_response.dart';
import 'package:mobile_in_out/core/utils/enum_state.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';
import 'package:mobile_in_out/feature/task/model/request_add_attachment.dart';
import 'package:mobile_in_out/feature/task/model/request_comment.dart';
import 'package:mobile_in_out/feature/task/model/response_attachment.dart';
import 'package:mobile_in_out/feature/task/model/response_comment.dart';
import 'package:mobile_in_out/feature/task/model/response_task_item.dart';
import 'package:mobile_in_out/feature/task/model/response_upload_file.dart';
import 'package:mobile_in_out/feature/task/model/response_upload_image.dart';

class TaskProvider with ChangeNotifier {
  final Repository _repository;

  TaskProvider(this._repository);

  RequestState _stateView = RequestState.Empty;
  RequestState get stateView => _stateView;
  String _errorMessage = '';
  String get errorMessage => _errorMessage;
  BaseResponse _responseMessage = BaseResponse();
  BaseResponse get responseMessage => _responseMessage;
  List<ResponseTaskItem> _taskListData = [];
  List<ResponseTaskItem> get taskListData => _taskListData;
  ResponseTaskItem _detailTask = ResponseTaskItem();
  ResponseTaskItem get detailTask => _detailTask;

  RequestState _stateViewAttachment = RequestState.Empty;
  RequestState get stateViewAttachment => _stateViewAttachment;
  String _errorMessageAttachment = '';
  String get errorMessageAttachment => _errorMessageAttachment;
  List<ResponseAttachment> _attachmentListData = [];
  List<ResponseAttachment> get attachmentListData => _attachmentListData;
  ResponseUploadFile _resultUploadFile = ResponseUploadFile();
  ResponseUploadFile get resultUploadFile => _resultUploadFile;

  RequestState _stateViewComment = RequestState.Empty;
  RequestState get stateViewComment => _stateViewComment;
  String _errorMessageComment = '';
  String get errorMessageComment => _errorMessageComment;
  List<ResponseComment> _commentListData = [];
  List<ResponseComment> get commentListData => _commentListData;
  static const String module = 'Task';

  RequestState _stateViewReply = RequestState.Empty;
  RequestState get stateViewReply => _stateViewReply;
  String _errorMessageReply = '';
  String get errorMessageReply => _errorMessageReply;
  List<ResponseComment> _replyListData = [];
  List<ResponseComment> get replyListData => _replyListData;

  Future<void> getAttachmentList(String taskId) async {
    _stateViewAttachment = RequestState.Loading;
    notifyListeners();

    final response = await _repository.getAttachmentList(taskId);

    response.fold(
      (error) {
        LogHelper.logDebug('error ${error.message.toString()}');
        _errorMessageAttachment = error.message.toString();
        _stateViewAttachment = RequestState.Error;
        notifyListeners();
      },
      (data) async {
        _stateViewAttachment = RequestState.Loaded;

        List<ResponseAttachment>? responseData = data.response;
        LogHelper.logDebug(
          'Debug => TaskList : getTaskList responseData $responseData',
        );
        _attachmentListData = responseData ?? [];

        notifyListeners();
      },
    );
  }

  Future<void> getTaskItemList(
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

    final response = await _repository.getProjectTaskItemList(
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

        List<ResponseTaskItem>? responseData = data.response;
        LogHelper.logDebug(
          'Debug => TaskList : getTaskList responseData $responseData',
        );
        _taskListData = responseData ?? [];

        notifyListeners();
      },
    );
  }

  Future<void> getDetailTask(
    String projectId,
    String boardId,
    String parentTaskId,
    String taskId,
  ) async {
    _stateView = RequestState.Loading;
    notifyListeners();

    final response = await _repository.getDetailTask(
      projectId,
      boardId,
      parentTaskId,
      taskId,
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

        ResponseTaskItem? responseData = data.response;
        LogHelper.logDebug(
          'Debug => TaskList : detailGetTask responseData $responseData',
        );
        _detailTask = responseData ?? ResponseTaskItem();

        notifyListeners();
      },
    );
  }

  Future<void> updateTaskItemList(
    String projectId,
    String boardId,
    String taskId,
    String taskItemId,
    bool checked,
  ) async {
    _stateView = RequestState.Loading;
    notifyListeners();

    final response = await _repository.updateProjectTaskItemList(
      projectId,
      boardId,
      taskId,
      taskItemId,
      checked,
    );

    response.fold(
      (error) {
        LogHelper.logDebug('error ${error.message.toString()}');
        _errorMessage = error.message.toString();
        _responseMessage = BaseResponse(
          response: _errorMessage,
          errorMessage: _errorMessage,
          status: false,
        );
        _stateView = RequestState.Error;
        notifyListeners();
      },
      (data) async {
        _stateView = RequestState.Loaded;
        _responseMessage = data;
        notifyListeners();
      },
    );
  }

  Future<void> getCommentList(String taskId) async {
    _stateViewComment = RequestState.Loading;
    notifyListeners();

    final response = await _repository.getCommentList(module, taskId);

    response.fold(
      (error) {
        LogHelper.logDebug('error ${error.message.toString()}');
        _errorMessageComment = error.message.toString();
        _stateViewComment = RequestState.Error;
        notifyListeners();
      },
      (data) async {
        _stateViewComment = RequestState.Loaded;

        List<ResponseComment>? responseData = data.response;
        LogHelper.logDebug(
          'Debug => TaskList : getTaskList responseData $responseData',
        );
        _commentListData = responseData ?? [];

        notifyListeners();
      },
    );
  }

  Future<void> getReplyList(String commentId) async {
    _stateViewReply = RequestState.Loading;
    notifyListeners();

    final response = await _repository.getReplyList(commentId);

    response.fold(
      (error) {
        LogHelper.logDebug('error ${error.message.toString()}');
        _errorMessageReply = error.message.toString();
        _stateViewReply = RequestState.Error;
        notifyListeners();
      },
      (data) async {
        _stateViewReply = RequestState.Loaded;

        List<ResponseComment>? responseData = data.response;
        LogHelper.logDebug(
          'Debug => TaskList : getTaskList responseData $responseData',
        );
        _replyListData = responseData ?? [];

        notifyListeners();
      },
    );
  }

  Future<void> addComment(RequestComment request) async {
    _stateView = RequestState.Loading;
    notifyListeners();

    final response = await _repository.addComment(request);

    response.fold(
      (error) {
        LogHelper.logDebug('error ${error.message.toString()}');
        _errorMessage = error.message.toString();
        _responseMessage = BaseResponse(
          response: _errorMessage,
          errorMessage: _errorMessage,
          status: false,
        );
        _stateView = RequestState.Error;
        notifyListeners();
      },
      (data) async {
        _stateView = RequestState.Loaded;
        _responseMessage = data;
        notifyListeners();
      },
    );
  }

  Future<void> uploadFile(File file) async {
    _stateView = RequestState.Loading;
    notifyListeners();

    final response = await _repository.uploadFile(file);

    response.fold(
      (error) {
        LogHelper.logDebug('error ${error.message.toString()}');
        _errorMessage = error.message.toString();
        _stateView = RequestState.Error;
        notifyListeners();
      },
      (data) async {
        _stateView = RequestState.Loaded;

        ResponseUploadFile? responseData = data.response;
        LogHelper.logDebug(
          'Debug => TaskList : getTaskList responseData $responseData',
        );
        _resultUploadFile = responseData ?? ResponseUploadFile();

        notifyListeners();
      },
    );
  }

  Future<ResponseUploadImage> uploadImage(File file) async {
    final response = await _repository.uploadImage(file);

    return response.fold(
      (error) {
        LogHelper.logDebug('error ${error.message.toString()}');
        return ResponseUploadImage();
      },
      (data) async {
        _stateView = RequestState.Loaded;

        ResponseUploadImage? responseData = data.response;
        LogHelper.logDebug('Debug => UploadImage :responseData $responseData');

        return responseData ?? ResponseUploadImage();
      },
    );
  }

  Future<void> addAttachment(RequestAddAttachment request) async {
    _stateView = RequestState.Loading;
    notifyListeners();

    final response = await _repository.addAttachment(request);

    response.fold(
      (error) {
        LogHelper.logDebug('error ${error.message.toString()}');
        _errorMessage = error.message.toString();
        _responseMessage = BaseResponse(
          response: _errorMessage,
          errorMessage: _errorMessage,
          status: false,
        );
        _stateView = RequestState.Error;
        notifyListeners();
      },
      (data) async {
        _stateView = RequestState.Loaded;
        _responseMessage = data;
        notifyListeners();
      },
    );
  }

  Future<void> removeAttachment(String attachmentId) async {
    _stateView = RequestState.Loading;
    notifyListeners();

    final response = await _repository.removeAttachment(attachmentId);

    response.fold(
      (error) {
        LogHelper.logDebug('error ${error.message.toString()}');
        _errorMessage = error.message.toString();
        _responseMessage = BaseResponse(
          response: _errorMessage,
          errorMessage: _errorMessage,
          status: false,
        );
        _stateView = RequestState.Error;
        notifyListeners();
      },
      (data) async {
        _stateView = RequestState.Loaded;
        _responseMessage = data;
        notifyListeners();
      },
    );
  }
}
