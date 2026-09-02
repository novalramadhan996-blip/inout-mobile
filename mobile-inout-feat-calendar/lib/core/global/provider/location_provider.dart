import 'package:mobile_in_out/core/resources/repositories/repository.dart';
import 'package:mobile_in_out/core/utils/enum_state.dart';
import 'package:mobile_in_out/core/utils/models/list_data_request.dart';
import 'package:mobile_in_out/core/utils/models/work_location/work_location_model.dart';
import 'package:flutter/material.dart';

class LocationProvider extends ChangeNotifier {
  final Repository _repository;
  LocationProvider(this._repository);
  
  // Fetch Work Location
  List<Location> _workLocation = [];
  List<Location> get workLocation => _workLocation;

  RequestState _workLocationState = RequestState.Empty;
  RequestState get workLocationState => _workLocationState;

  String _workLocationErrorMessage = '';
  String get workLocationErrorMessage => _workLocationErrorMessage;

  Future<void> fetchWorkLocation(ListDataRequest request) async {
    _workLocationState = RequestState.Loading;
    final result = await _repository.getWorkLocation(request: request);

    result.fold(
      (failure) {
        _workLocationErrorMessage = failure.message.toString();
        _workLocationState = RequestState.Error;
        notifyListeners();
      },
      (data) {
        _workLocation = data.response?.rows ?? [];
        _workLocationState = RequestState.Loaded;
        notifyListeners();
      },
    );
  }
}