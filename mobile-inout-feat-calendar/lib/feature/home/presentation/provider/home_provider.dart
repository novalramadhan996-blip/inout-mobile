import 'package:mobile_in_out/core/resources/local/local_service.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_in_out/core/resources/repositories/repository.dart';
import 'package:mobile_in_out/core/utils/enum_state.dart';
import 'package:mobile_in_out/feature/home/data/model/employee_detail_model.dart';

class HomeProvider extends ChangeNotifier {
  final Repository _repository;
  HomeProvider(this._repository);

  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  bool needRefresh = false;

  // State
  RequestState _state = RequestState.Empty;
  RequestState get state => _state;

  // Error
  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  EmployeeDetailModel _employeeDetail = EmployeeDetailModel();
  EmployeeDetailModel get employeeDetail => _employeeDetail;

  Future<bool> checkModelDataIsExist() async {
    final users = await _databaseHelper.queryAllUsers();
    if (users.first.modelData?.isEmpty ?? true) return false;
    return true;
  }

  void markRefresh() {
    needRefresh = true;
    notifyListeners();
  }

  Future<void> getEmployeeDetail() async {
    _state = RequestState.Loading;
    notifyListeners();

    final result = await _repository.getEmployeeDetail();

    result.fold(
      (error) {
        _state = RequestState.Error;
        _errorMessage = error.message.toString();
        notifyListeners();
      },
      (data) {
        _state = RequestState.Loaded;
        _employeeDetail = data.response ?? EmployeeDetailModel();
        notifyListeners();
      },
    );
  }
}
