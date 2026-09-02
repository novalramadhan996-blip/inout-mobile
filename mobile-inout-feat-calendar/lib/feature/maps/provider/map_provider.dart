import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapProvider extends ChangeNotifier {
  late GoogleMapController mapController;
  void setMapController(GoogleMapController controller) {
    mapController = controller;
    notifyListeners();
  }

  var controller = Completer();
  void setCompleter(GoogleMapController googleMapController) {
    controller = Completer();
    controller.complete(googleMapController);
    notifyListeners();
  }
}