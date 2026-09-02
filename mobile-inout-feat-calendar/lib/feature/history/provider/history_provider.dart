import 'package:mobile_in_out/core/resources/repositories/repository.dart';
import 'package:mobile_in_out/core/utils/enum_state.dart';
import 'package:mobile_in_out/core/utils/models/history/absence_history_model.dart';
import 'package:mobile_in_out/core/utils/models/history/detail_history_model.dart';
import 'package:mobile_in_out/core/utils/models/history/history_model.dart';
import 'package:flutter/material.dart';
import 'package:mobile_in_out/core/utils/models/list_data_request.dart';

class HistoryProvider extends ChangeNotifier {
  final Repository _repository;
  HistoryProvider(this._repository);

  // State
  RequestState _state = RequestState.Empty;
  RequestState get state => _state;

  // Error
  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // Data
  // Comment because deprecated, when already stable please removed
  // List<AbsenceRecord> _history = [];
  // List<AbsenceRecord> get history => _history;
  List<AbsenceHistoryModel> _history = [];
  List<AbsenceHistoryModel> get history => _history;



  // Comment because deprecated, when already stable please removed
  // Future<void> getHistory(String accountId) async {
  //   _state = RequestState.Loading;
  //   notifyListeners();

  //   final result = await _repository.getHistory(accountId: accountId);

  //   result.fold(
  //     (error) {
  //       _state = RequestState.Error;
  //       _errorMessage = error.message.toString();
  //       notifyListeners();
  //     },
  //     (data) {
  //       _state = RequestState.Loaded;
  //       _history = data.response ?? [];
  //       notifyListeners();
  //     },
  //   );
  // }

   Future<void> getHistory(ListDataRequest request) async {
    _state = RequestState.Loading;
    notifyListeners();

    final result = await _repository.getHistory(request: request);

    result.fold(
      (error) {
        _state = RequestState.Error;
        _errorMessage = error.message.toString();
        notifyListeners();
      },
      (data) {
        _state = RequestState.Loaded;
        _history = data.response ??  [];
        notifyListeners();
      },
    );
  }

  // Comment because deprecated, when already stable please removed
  // AbsenceRecordDetail? _detailHistory;
  // AbsenceRecordDetail? get detailHistory => _detailHistory;
  AbsenceHistoryModel? _detailHistory;
  AbsenceHistoryModel? get detailHistory => _detailHistory;

  RequestState _stateDetail = RequestState.Empty;
  RequestState get stateDetail => _stateDetail;

  String _errorMessageDetail = '';
  String get errorMessageDetail => _errorMessageDetail;

  // Comment because deprecated, when already stable please removed
  // Future<void> getDetailHistory(String absenceId) async {
  //   _detailHistory = null;
  //   _errorMessageDetail = '';
  //   _stateDetail = RequestState.Loading;
  //   notifyListeners();

  //   final result = await _repository.getDetailHistory(absenceId: absenceId);

  //   result.fold(
  //     (error) {
  //       _stateDetail = RequestState.Error;
  //       _errorMessageDetail = error.message.toString();
  //       notifyListeners();
  //     },
  //     (data) {
  //       _stateDetail = RequestState.Loaded;
  //       _detailHistory = data.response;
  //       notifyListeners();
  //     },
  //   );
  // }
   Future<void> getDetailHistory(String attendanceId) async {
    _detailHistory = null;
    _errorMessageDetail = '';
    _stateDetail = RequestState.Loading;
    notifyListeners();

    final result = await _repository.getDetailHistory(attendanceId: attendanceId);

    result.fold(
      (error) {
        _stateDetail = RequestState.Error;
        _errorMessageDetail = error.message.toString();
        notifyListeners();
      },
      (data) {
        _stateDetail = RequestState.Loaded;
        _detailHistory = data.response;
        notifyListeners();
      },
    );
  }
}