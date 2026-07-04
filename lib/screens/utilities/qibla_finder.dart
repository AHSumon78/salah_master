import 'dart:async';
import 'dart:math' as math;
import 'package:alarm/l10n/generated/app_localizations.dart';
import 'package:alarm/screens/commons/appBar_background.dart';
import 'package:alarm/screens/commons/app_background.dart';
import 'package:alarm/services/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';

class QiblaFinderScreen extends StatefulWidget {
  const QiblaFinderScreen({super.key});

  @override
  State<QiblaFinderScreen> createState() => _QiblaFinderScreenState();
}

class _QiblaFinderScreenState extends State<QiblaFinderScreen> {
  double _qiblaDirection = 0.0;
  double _distanceKm = 0.0;
  double _heading = 0.0;

  bool _isLoading = true;
  bool _needsCalibration = false;

  final String _errorMessage = '';

  StreamSubscription? _compassSubscription;

  static const EventChannel _compassChannel =
      EventChannel('qibla_compass_stream');

  @override
  void initState() {
    super.initState();

    // 🔥 Default Dhaka location FIRST (fallback)
    _calculateQiblaAndDistance(23.8103, 90.4125);

    _startCompass();
    _determinePosition();
  }

  void _startCompass() {
    _compassSubscription =
        _compassChannel.receiveBroadcastStream().listen((event) {
      if (!mounted) return;

      final data = Map<String, dynamic>.from(event);

      final double heading = (data['heading'] as num).toDouble();

      final int accuracy = (data['accuracy'] as num).toInt();

      setState(() {
        // 🔥 calibration detect
        _needsCalibration = accuracy <= 1;

        // 🔥 smooth movement
        _heading = (_heading * 0.9) + (heading * 0.1);
      });
    });
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        return; // 🔥 Dhaka fallback থাকবে
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 🔥 Real location override
      _calculateQiblaAndDistance(
        position.latitude,
        position.longitude,
      );
    } catch (e) {
      // 🔥 Silent fail (Dhaka already used)
    }
  }

  void _calculateQiblaAndDistance(
    double userLat,
    double userLng,
  ) {
    const double makkahLat = 21.4225;
    const double makkahLng = 39.8262;

    double lat1 = userLat * math.pi / 180.0;
    double lon1 = userLng * math.pi / 180.0;
    double lat2 = makkahLat * math.pi / 180.0;
    double lon2 = makkahLng * math.pi / 180.0;

    const double R = 6371.0;

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    double c = 2 *
        math.atan2(
          math.sqrt(a),
          math.sqrt(1 - a),
        );

    double distance = R * c;

    double y = math.sin(dLon) * math.cos(lat2);

    double x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    double bearing = math.atan2(y, x);

    double bearingDegrees = bearing * 180.0 / math.pi;

    double qiblaDirection = (bearingDegrees + 360.0) % 360.0;

    setState(() {
      _qiblaDirection = qiblaDirection;
      _distanceKm = distance;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 Difference calculation
    double diff = (_qiblaDirection - _heading + 360) % 360;

    if (diff > 180) {
      diff = 360 - diff;
    }

    // 🔥 snap effect
    double displayDiff = diff < 1 ? 0 : diff;

    // 🔥 vibration
    if (diff < 1 && !_needsCalibration) {
      HapticFeedback.mediumImpact();
    }
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).appBackground,
      appBar: AppBarCommon(
        title: l.qiblaFinder,
      ),
      body: AppBackground(
        child: Builder(
          builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return Container(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _errorMessage.isNotEmpty
                      ? Center(
                          child: Text(
                            _errorMessage,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            const SizedBox(height: 10),

                            const SizedBox(height: 20),

                            /// 🔥 Degree Indicator
                            Column(
                              children: [
                                const SizedBox(height: 20),
                                Text(
                                  "${displayDiff.toStringAsFixed(1)}°",
                                  style: TextStyle(
                                    color: diff < 5
                                        ? Colors.greenAccent
                                        : (isDark
                                            ? Colors.white
                                            : Colors.black),
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  diff < 5 ? l.aligned : l.adjust,
                                  style: TextStyle(
                                    color: diff < 5
                                        ? Colors.greenAccent
                                        : (isDark
                                            ? Colors.white60
                                            : Colors.black54),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            Expanded(
                              child: Center(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    /// 🔥 Compass
                                    Transform.rotate(
                                      angle: -_heading * math.pi / 180,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                            width: 280,
                                            height: 280,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: isDark
                                                    ? Colors.white24
                                                    : Colors.black26,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                          _DirText(
                                            l.north,
                                            isDark,
                                            top: true,
                                          ),
                                          _DirText(
                                            l.south,
                                            isDark,
                                            bottom: true,
                                          ),
                                          _DirText(
                                            l.west,
                                            isDark,
                                            left: true,
                                          ),
                                          _DirText(
                                            l.east,
                                            isDark,
                                            right: true,
                                          ),
                                        ],
                                      ),
                                    ),

                                    /// 🔥 Arrow
                                    // Opacity(
                                    //opacity: _needsCalibration ? 0.4 : 1,
                                    Transform.rotate(
                                      angle: (_qiblaDirection - _heading) *
                                          math.pi /
                                          180,
                                      child: Icon(
                                        Icons.navigation,
                                        size: 80,
                                        color: diff < 5
                                            ? Colors.greenAccent
                                            : Colors.teal,
                                      ),
                                    ),
                                    //),
                                  ],
                                ),
                              ),
                            ),

                            /// 🔥 Info Card
                            Container(
                              margin: const EdgeInsets.all(16),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.white,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    l.qiblaDirection,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "${_qiblaDirection.toStringAsFixed(1)}°",
                                    style: const TextStyle(
                                      color: Colors.teal,
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "${l.distance}: ${_distanceKm.toStringAsFixed(1)} ${l.km}",
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white60
                                          : Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    "${l.heading}: ${_heading.toStringAsFixed(1)}°",
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white38
                                          : Colors.black45,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 100),
                          ],
                        ),
            );
          },
        ),
      ),
    );
  }
}

class _DirText extends StatelessWidget {
  final String text;
  final bool isDark;

  final bool top;
  final bool bottom;
  final bool left;
  final bool right;

  const _DirText(
    this.text,
    this.isDark, {
    this.top = false,
    this.bottom = false,
    this.left = false,
    this.right = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top ? 20 : null,
      bottom: bottom ? 20 : null,
      left: left ? 20 : null,
      right: right ? 20 : null,
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? Colors.white70 : Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
