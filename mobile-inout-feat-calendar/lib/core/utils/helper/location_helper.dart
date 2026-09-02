import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationHelper {
  static Future<bool> checkAndEnableLocation() async {
    // 1. Cek apakah GPS aktif
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Buka setting lokasi
      await Geolocator.openLocationSettings();
      return false;
    }

    // 2. Cek permission
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    // 3. Kalau permanently denied
    if (permission == LocationPermission.deniedForever) {
      await openAppSettings();
      return false;
    }

    return true;
  }

  static Future<Map<String, dynamic>> getAddressFromLatLng(
    Position position,
  ) async {
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        return {};
      }

      final Placemark place = placemarks.first;

      return {
        'name': place.name ?? '',
        'street': place.street ?? '',
        'subLocality': place.subLocality ?? '',
        'locality': place.locality ?? '',
        'subAdministrativeArea': place.subAdministrativeArea ?? '',
        'administrativeArea': place.administrativeArea ?? '',
        'postalCode': place.postalCode ?? '',
        'country': place.country ?? '',
        'isoCountryCode': place.isoCountryCode ?? '',
        'thoroughfare': place.thoroughfare ?? '',
        'subThoroughfare': place.subThoroughfare ?? '',
      };
    } catch (e) {
      return {};
    }
  }
}
