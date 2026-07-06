// lib/services/geolocation_service.dart
import 'package:geolocator/geolocator.dart';
import 'package:alarm/models/Location.dart';

class GeolocationService {
  /// Check and request location permissions, and get the current position.
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, return null or an error
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // Permissions are denied, return null
        return null;
      }
    }

    // Permissions are granted, return the current position.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  /// Calculates the distance between the current position and a target location.
  /// Returns the distance in meters.
  double getDistanceInMeters(
      Position currentPosition, Location targetLocation) {
    return Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      targetLocation.latitude,
      targetLocation.longitude,
    );
  }

  bool isInDistance(
      {required double locationDistance, required double currentDistance}) {
    return locationDistance >= currentDistance;
  }
}
