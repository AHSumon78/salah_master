// lib/screens/location_details_screen.dart
import 'package:alarm/models/Location.dart';
import 'package:alarm/screens/commons/appBar_background.dart';
import 'package:alarm/screens/commons/app_background.dart';
import 'package:alarm/services/NativeDB.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // উপরে ইম্পোর্ট করে নিন
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class LocationDetailsScreen extends StatefulWidget {
  final Location location;
  const LocationDetailsScreen({super.key, required this.location});

  @override
  State<LocationDetailsScreen> createState() => _LocationDetailsScreenState();
}

class _LocationDetailsScreenState extends State<LocationDetailsScreen> {
  late Location _location;
  late String appName;
  late TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();
    // Use the location passed from the constructor
    _location = widget.location;
    appName = "com.shohan.alarm.project";
    // এখন আপনি appName ব্যবহার করতে পারবেন কারণ ক্লাসটি তৈরি হয়ে গেছে
    textEditingController = TextEditingController(text: appName);
  }

  Future<void> _saveLocation() async {
    await NativeDB.updateLocation(_location);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _pickLocation() async {
    LatLng? pickedLocation;

    // ১. ফোনের লোকেশন পারমিশন চেক করা
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // ২. কারেন্ট পজিশন নেওয়া
    Position currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatefulBuilder(
          // এটি ব্যবহার করছি যাতে পিন সিলেক্ট করলে সাথে সাথে দেখা যায়
          builder: (context, setModalState) => Scaffold(
            appBar: AppBarCommon(
              title: "Select Location",
              actions: [
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () => Navigator.pop(context, pickedLocation),
                )
              ],
            ),
            body: AppBackground(
              child: FlutterMap(
                options: MapOptions(
                  // এখানে কারেন্ট লোকেশন দেওয়া হলো
                  initialCenter: LatLng(
                      currentPosition.latitude, currentPosition.longitude),
                  initialZoom: 15.0,
                  onTap: (tapPosition, point) {
                    setModalState(() {
                      pickedLocation = point;
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: appName,
                  ),
                  if (pickedLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: pickedLocation!,
                          width: 80,
                          height: 80,
                          child: const Icon(Icons.location_on,
                              color: Colors.red, size: 40),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (result != null && result is LatLng) {
      setState(() {
        _location.latitude = result.latitude;
        _location.longitude = result.longitude;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCommon(
        title: 'Edit ${_location.name} Location',
      ),
      body: AppBackground(
        child: Stack(
          children: [
            // Large mosque icon in the background
            Center(
              child: Icon(
                Icons.mosque,
                color: Colors.grey
                    .withValues(alpha: 0.1), // Adjusted opacity for subtle effect
                size: 200, // Large size for background
              ),
            ),
            // The main content of the screen
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _location.name,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.teal.shade800,
                              ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: TextEditingController(
                          text: _location.latitude.toString()),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Latitude',
                        labelStyle: const TextStyle(color: Colors.teal),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.teal, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        _location.latitude = double.tryParse(value) ?? 0.0;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: TextEditingController(
                          text: _location.longitude.toString()),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Longitude',
                        labelStyle: const TextStyle(color: Colors.teal),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.teal, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        _location.longitude = double.tryParse(value) ?? 0.0;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: TextEditingController(
                          text: _location.diameter.toString()),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Radius (meters)',
                        labelStyle: const TextStyle(color: Colors.teal),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.teal, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        _location.diameter = double.tryParse(value) ?? 0;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        // TextField কে Expanded দিয়ে র‍্যাপ করুন
                        // Expanded(
                        //   child: TextField(
                        //     controller: textEditingController,
                        //     keyboardType: TextInputType.number,
                        //     decoration: InputDecoration(
                        //       labelText: 'Request Name',
                        //       labelStyle: const TextStyle(color: Colors.teal),
                        //       border: OutlineInputBorder(
                        //         borderRadius: BorderRadius.circular(12),
                        //       ),
                        //       focusedBorder: OutlineInputBorder(
                        //         borderRadius: BorderRadius.circular(12),
                        //         borderSide: const BorderSide(
                        //             color: Colors.teal, width: 2),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // const SizedBox(
                        //     width:
                        //         8), // টেক্সট ফিল্ড ও বাটনের মাঝে সামান্য গ্যাপের জন্য
                        // TextButton(
                        //   onPressed: () => appName = textEditingController.text,
                        //   child: const Text("SAVE"),
                        // ),
                      ],
                    ),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _pickLocation,
                        icon: const Icon(Icons.map, color: Colors.white),
                        label: const Text(
                          'Select on Map',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _saveLocation,
                        label: const Text(
                          'Save Location',
                          style: TextStyle(color: Colors.white),
                        ),
                        icon: const Icon(Icons.save, color: Colors.white),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade800,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
