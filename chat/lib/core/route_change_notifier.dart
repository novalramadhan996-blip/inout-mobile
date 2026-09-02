import 'package:flutter/material.dart';

class RouteChangeNotifier extends ChangeNotifier {
  // A simple state variable to indicate route change, if needed
  bool _hasRouteChanged = false;

  bool get hasRouteChanged => _hasRouteChanged;

  void notifyRouteChange() {
    _hasRouteChanged = true;  // Toggle the route change state
    notifyListeners(); // Notify listeners to update UI or trigger actions
  }

  void stopNotifyRouteChange() {
    _hasRouteChanged = false;
  }
}