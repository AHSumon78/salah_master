import 'dart:convert';

import 'package:alarm/l10n/generated/app_localizations.dart';
import 'package:alarm/models/Mosque.dart';
import 'package:alarm/screens/commons/appBar_background.dart';
import 'package:alarm/screens/commons/app_background.dart';
import 'package:alarm/screens/commons/app_card.dart';
import 'package:alarm/screens/maps/MapPickerScreen.dart';
import 'package:alarm/services/NativeDB.dart';
import 'package:alarm/services/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'FullMapMosqueScreen.dart';

import '../commons/base_text.dart';

class MosqueLocatorScreen extends StatefulWidget {
  const MosqueLocatorScreen({super.key});

  @override
  State<MosqueLocatorScreen> createState() => _MosqueLocatorScreenState();
}

class _MosqueLocatorScreenState extends State<MosqueLocatorScreen> {
  LatLng? _currentLocation;
  List<dynamic> _mosques = [];
  bool _isLoading = false;
  int _displayedMosqueCount = 0;

  final Distance _distance = const Distance();

  @override
  void initState() {
    super.initState();
    _loadMosquesFromDB();
    _determinePositionAndSort();
  }

  double _calculateDistance(double lat, double lon) {
    if (_currentLocation == null) return 0;
    return _distance.as(LengthUnit.Meter, _currentLocation!, LatLng(lat, lon));
  }

  void _sortMosquesByDistance() {
    if (_currentLocation == null) return;
    _mosques.sort((a, b) {
      final distA = _calculateDistance(a['lat'], a['lon']);
      final distB = _calculateDistance(b['lat'], b['lon']);
      return distA.compareTo(distB);
    });
  }

  Future<void> _loadMosquesFromDB() async {
    await Future.delayed(const Duration(seconds: 1));
    final data = await NativeDB.getMosques();

    if (!mounted) return;
    setState(() {
      _mosques = data
          .map((e) => {'id': e.id, 'name': e.name, 'lat': e.lat, 'lon': e.lon})
          .toList();
    });

    // অ্যানিমেশন লুপ
    for (int i = 0; i <= _mosques.length; i++) {
      if (!mounted) return;
      setState(() {
        _displayedMosqueCount = i;
      });
      await Future.delayed(const Duration(milliseconds: 30));
    }
  }

  Future<void> _determinePositionAndSort() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position position = await Geolocator.getCurrentPosition();
      if (!mounted) return;

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      for (int i = _displayedMosqueCount; i >= 0; i--) {
        if (!mounted) return;
        setState(() {
          _displayedMosqueCount = i;
        });
        await Future.delayed(const Duration(milliseconds: 10));
      }

      _sortMosquesByDistance();

      for (int i = 0; i <= _mosques.length; i++) {
        if (!mounted) return;
        setState(() {
          _displayedMosqueCount = i;
        });
        await Future.delayed(const Duration(milliseconds: 30));
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  Future<void> _openMap(double lat, double lon) async {
    final Uri googleUrl =
        Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lon");
    await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
  }

  Future<void> _findNearbyMosques() async {
    if (_currentLocation == null) return;

    setState(() => _isLoading = true);

    final String query = """
    [out:json][timeout:25];
    (
      node(around:4500,${_currentLocation!.latitude},${_currentLocation!.longitude})["amenity"="place_of_worship"]["religion"="muslim"];
      way(around:4500,${_currentLocation!.latitude},${_currentLocation!.longitude})["amenity"="place_of_worship"]["religion"="muslim"];
    );
    out center;
  """;

    final String url =
        "https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(query)}";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'Flutter_Mosque_App/1.0'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List elements = data['elements'];

        List<Mosque> mosques = elements.map<Mosque>((m) {
          return Mosque(
            name: m['tags']?['name'] ?? 'Unnamed Mosque',
            lat: m['lat'] ?? m['center']?['lat'],
            lon: m['lon'] ?? m['center']?['lon'],
          );
        }).toList();

        await NativeDB.insertMosques(mosques);
        final updated = await NativeDB.getMosques();

        // সর্ট করার আগে লিস্টটি খালি করার অ্যানিমেশন
        for (int i = _displayedMosqueCount; i >= 0; i--) {
          if (!mounted) return;
          setState(() {
            _displayedMosqueCount = i;
          });
          await Future.delayed(const Duration(milliseconds: 10));
        }

        _mosques = updated
            .map((e) => {
                  'id': e.id,
                  'name': e.name,
                  'lat': e.lat,
                  'lon': e.lon,
                })
            .toList();

        _sortMosquesByDistance();

        setState(() {
          _isLoading = false;
        });

        // নতুন সর্টেড ডাটা একে একে লোড হওয়ার অ্যানিমেশন
        for (int i = 0; i <= _mosques.length; i++) {
          if (!mounted) return;
          setState(() {
            _displayedMosqueCount = i;
          });
          await Future.delayed(const Duration(milliseconds: 35));
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage("Error: $e");
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _openAddLocationScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MapPickerScreen()),
    );

    if (result != null) {
      final name = result['name'];
      final lat = result['lat'];
      final lon = result['lon'];

      await NativeDB.insertMosques([
        Mosque(name: "\$$name", lat: lat, lon: lon),
      ]);

      await _loadMosquesFromDB();
    }
  }

  Future<void> _deleteMosque(int id) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Mosque"),
          content: const Text("Are you sure you want to delete this mosque?"),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel")),
            TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child:
                    const Text("Delete", style: TextStyle(color: Colors.red))),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await NativeDB.deleteMosque(id);
        await _loadMosquesFromDB();
        _showMessage("Mosque deleted successfully.");
      } catch (e) {
        _showMessage("Failed to delete mosque: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBarCommon(
        title: l.nearbymosquesList,
        actions: [
          if (_currentLocation != null)
            IconButton(
              onPressed: _isLoading ? null : _findNearbyMosques,
              icon: Icon(Icons.refresh, color: Theme.of(context).iconColor),
            )
        ],
      ),
      body: AppBackground(
        child: Column(
          children: [
            AppCard(
              child: Text(
                _currentLocation == null
                    ? "Your Location: Getting location..."
                    : "Your Location: ${_currentLocation!.latitude.toStringAsFixed(4)}, ${_currentLocation!.longitude.toStringAsFixed(4)}",
                textAlign: TextAlign.center,
                style: Theme.of(context).title,
              ),
            ),
            Expanded(
              child: _buildMosqueList(),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton.extended(
              heroTag: "add_location",
              onPressed: _openAddLocationScreen,
              icon: const Icon(Icons.add_location_alt, color: Colors.white),
              label: Text(l.add, style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.orange.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 10),
            FloatingActionButton.extended(
              heroTag: "find",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullMapMosqueScreen(
                      userLocation: _currentLocation,
                      mosques: _mosques,
                    ),
                  ),
                );
              },
              backgroundColor: Colors.teal.withValues(alpha: 0.6),
              icon: const Icon(Icons.map, color: Colors.white),
              label: Text(l.find, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

// ==================== আলাদা মেথড (Smooth Scrolling এর জন্য) ====================
  Widget _buildMosqueList() {
    if (_isLoading && _mosques.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_mosques.isEmpty) {
      return const Center(
        child: Text("No mosques found", style: TextStyle(fontSize: 18)),
      );
    }

    return ListView.builder(
      cacheExtent: 1500, // Smooth Scrolling এর জন্য
      // scrollCacheExtent: ScrollCacheExtent.pixels(1500), 
       padding: const EdgeInsets.only(bottom: 230),
      physics: const AlwaysScrollableScrollPhysics(),
      // বা ClampingScrollPhysics() ট্রাই করতে পার
      itemCount: _displayedMosqueCount,
      itemBuilder: (context, index) {
        if (index >= _mosques.length) return const SizedBox.shrink();

        final mosque = _mosques[index];
        final id = mosque['id'];
        final name = mosque['name'];
        final lat = mosque['lat'];
        final lon = mosque['lon'];
        final distance = _calculateDistance(lat, lon);

        return AppCard(
          child: Material(
            // 👈 Add this widget here
            type: MaterialType.transparency,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).appBackground,
                child: Icon(Icons.mosque, color: Theme.of(context).iconColor),
              ),
              title: Text(name, style: AppText.title(context)),
              subtitle: Text(
                "Distance: ${distance.toStringAsFixed(0)} m",
                style: Theme.of(context).chip,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.directions,
                        color: Colors.blue, size: 28),
                    onPressed: () => _openMap(lat, lon),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 28),
                    onPressed: () => _deleteMosque(id),
                  ),
                ],
              ),
              onTap: () => _openMap(lat, lon),
            ),
          ),
        );
      },
    );
  }
}
