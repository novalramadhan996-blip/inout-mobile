import 'dart:developer';
import 'package:chat/core/utils/request_state.dart';
import 'package:chat/repositories/repository_google_map.dart';
import 'package:flutter/foundation.dart';

class MapViewModel with ChangeNotifier {
  final RepositoryGoogleMap _repository;

  MapViewModel(this._repository);

  RequestState _stateView = RequestState.Empty;
  RequestState get stateView => _stateView;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Map<String, dynamic> _responseData = {};
  Map<String, dynamic> get responseData => _responseData;

  Future<Map<String, dynamic>> getRouteMap(String origin, String destination,
      {String? mode}) async {
    _stateView = RequestState.Loading;
    notifyListeners();

    Map<String, dynamic> result = {};

    final response =
        await _repository.getRouteMap(origin, destination, mode: mode);

    response.fold(
      (error) {
        log('error ${error.message.toString()}');
        _errorMessage = error.message.toString();
        _stateView = RequestState.Error;
        notifyListeners();
        return {};
      },
      (data) async {
        _stateView = RequestState.Loaded;

        // _responseData = data.response ?? {};

        result = data.response ?? {};

        notifyListeners();
      },
    );

    // log('return result $result');

    return result;
  }
}
