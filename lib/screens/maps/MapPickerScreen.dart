import 'package:alarm/screens/commons/appBar_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng? selected;
  LatLng? currentLocation;

  final MapController controller = MapController();
  final TextEditingController nameController = TextEditingController();

  bool _mapMovedOnce = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) return;

      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!pos.latitude.isFinite || !pos.longitude.isFinite) return;

      final LatLng safeLocation = LatLng(pos.latitude, pos.longitude);

      setState(() {
        currentLocation = safeLocation;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_mapMovedOnce) {
          controller.move(safeLocation, 15);
          _mapMovedOnce = true;
        }
      });
    } catch (e) {
      debugPrint("Location error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    const fallback = LatLng(23.7, 90.4);

    final LatLng mapCenter = (currentLocation != null &&
            currentLocation!.latitude.isFinite &&
            currentLocation!.longitude.isFinite)
        ? currentLocation!
        : fallback;

    return Scaffold(
      appBar: const AppBarCommon(
        title: "Pick Location",
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: controller,
            options: MapOptions(
              initialCenter: mapCenter,
              initialZoom: 15,
              onTap: (tapPos, point) {
                if (point.latitude.isFinite && point.longitude.isFinite) {
                  setState(() {
                    selected = point;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "com.example.slient",
              ),

              // 📍 Selected marker
              if (selected != null &&
                  selected!.latitude.isFinite &&
                  selected!.longitude.isFinite)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: selected!,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),

              // 📍 Current location marker
              if (currentLocation != null &&
                  currentLocation!.latitude.isFinite &&
                  currentLocation!.longitude.isFinite)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: currentLocation!,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 30,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // SAVE PANEL
          if (selected != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Location Name",
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, {
                            "name": nameController.text,
                            "lat": selected!.latitude,
                            "lon": selected!.longitude,
                          });
                        },
                        child: const Text("Save Location"),
                      )
                    ],
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
