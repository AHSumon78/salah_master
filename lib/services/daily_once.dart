import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> shouldRunToday() async {
  final prefs = await SharedPreferences.getInstance();
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final lastRun = prefs.getString('last_daily_run');

  return lastRun != today;
}
Future<void> shouldRunLocationUpdate() async {
  final prefs = await SharedPreferences.getInstance();
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final lastRun = prefs.getString('last_location_update');

  if (lastRun != today) {
    await prefs.setString('last_location_update', today);
    // Perform location update logic here
    await updateLocation();
    
  }
  
}
Future<void> updateLocation() async {
  final prefs = await SharedPreferences.getInstance();
  try {
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();
    if (isLocationServiceEnabled &&
        (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse)) {
      Position? position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        await prefs.setDouble('lat', position.latitude);
        await prefs.setDouble('lng', position.longitude);
      }
    }
  } catch (e) {
    print('Geolocator Error in Dispatcher: $e');
  }
}

Future<void> markDailySchedulerSetToday() async {
  final prefs = await SharedPreferences.getInstance();
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  await prefs.setString('last_daily_run', today);
}

Future<bool> shouldShowEventNotificationToday(String eventName) async {
  final prefs = await SharedPreferences.getInstance();
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final key = 'event_notification_$eventName';
  final lastDate = prefs.getString(key);

  if (lastDate == today) {
    return false;
  }

  await prefs.setString(key, today);
  return true;
}
