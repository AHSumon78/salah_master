import 'package:alarm/screens/commons/appBar_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';

class FullMapMosqueScreen extends StatelessWidget {
  final LatLng? userLocation;
  final List<dynamic> mosques;

  final LatLng kaabaLocation = const LatLng(21.4225, 39.8262);

  const FullMapMosqueScreen({
    super.key,
    this.userLocation,
    required this.mosques,
  });

  bool _isValidLatLng(double? lat, double? lng) {
    if (lat == null || lng == null) return false;
    return lat.isFinite && lng.isFinite;
  }

  @override
  Widget build(BuildContext context) {
    const LatLng fallback = LatLng(23.6850, 90.3563);

    final LatLng safeUserLocation = (userLocation != null &&
            userLocation!.latitude.isFinite &&
            userLocation!.longitude.isFinite)
        ? userLocation!
        : fallback;

    return Scaffold(
      appBar: const AppBarCommon(
        title: "Nearby Mosques & Qibla Finder",
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: safeUserLocation,
          initialZoom: 16,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.butterflydevs.salahmaster',
          ),

          // 🧭 Qibla Line (SAFE)
          if (userLocation != null &&
              userLocation!.latitude.isFinite &&
              userLocation!.longitude.isFinite)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: [safeUserLocation, kaabaLocation],
                  strokeWidth: 4.0,
                  color: Colors.orange.withValues(alpha: 0.8),
                ),
              ],
            ),

          // 🕋 Kaaba Marker (SAFE)
          MarkerLayer(
            markers: [
              Marker(
                point: kaabaLocation,
                width: 80,
                height: 80,
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, color: Colors.brown, size: 40),
                    Text(
                      "Kaaba",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        backgroundColor: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 📍 Live Location (SAFE)
          const CurrentLocationLayer(
            alignPositionOnUpdate: AlignOnUpdate.always,
            alignDirectionOnUpdate: AlignOnUpdate.always,
            style: LocationMarkerStyle(
              marker: DefaultLocationMarker(
                child: Icon(
                  Icons.navigation,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              markerSize: Size(40, 40),
              showAccuracyCircle: true,
            ),
          ),

          // 🕌 Mosques (FULL SAFE FILTER)
          MarkerLayer(
            markers: mosques.map((m) {
              final lat = m['lat'] ?? m['center']?['lat'];
              final lon = m['lon'] ?? m['center']?['lon'];

              if (!_isValidLatLng(lat, lon)) {
                return const Marker(
                  point: LatLng(0, 0),
                  child: SizedBox.shrink(),
                );
              }

              return Marker(
                point: LatLng(lat, lon),
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.mosque,
                  color: Colors.teal,
                  size: 25,
                ),
              );
            }).toList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () {
          // optional: animate to user location
        },
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}
