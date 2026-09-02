import 'package:flutter/foundation.dart';
import 'package:mobile_in_out/core/resources/repositories/repository.dart';
import 'package:mobile_in_out/core/utils/enum_state.dart';
import 'package:mobile_in_out/core/utils/models/list_data_request.dart';
import 'package:mobile_in_out/core/utils/models/organization/organization_employee_model.dart';


class OrganizationProvider extends ChangeNotifier {
  final Repository _repository;
  OrganizationProvider(this._repository);

// State
  RequestState _state = RequestState.Empty;
  RequestState get state => _state;

  // Error
  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // Data
  List<OrganizationEmployee> _organization = [];
  List<OrganizationEmployee> get organization => _organization;

  Future<void> getOrganization(ListDataRequest request) async {
    _state = RequestState.Loading;
    notifyListeners();

    final result = await _repository.getOrganization(request);

    result.fold(
      (error) {
        _state = RequestState.Error;
        _errorMessage = error.message.toString();
        notifyListeners();
      },
      (data) {
        _state = RequestState.Loaded;
        _organization = data.response ??  [];
        notifyListeners();
      },
    );
  }

}