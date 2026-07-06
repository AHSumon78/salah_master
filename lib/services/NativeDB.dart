import 'package:flutter/services.dart';

import '../models/Alarm.dart';
import '../models/AppSettings.dart';
import '../models/Location.dart';
import '../models/Mosque.dart';

class NativeDB {
  static const MethodChannel _channel = MethodChannel("com.butterflydevs.salahmaster/db");

  // ================= LOCATION =================
  static Future<int> insertLocation({
    required String name,
    required double lat,
    required double lon,
    required double diameter,
    required int preAlarm,
  }) async {
    return await _channel.invokeMethod("insertLocation", {
      "name": name,
      "lat": lat,
      "lon": lon,
      "diameter": diameter,
      "preAlarm": preAlarm,
    });
  }

  static Future<List<Location>> getLocations() async {
    final result = await _channel.invokeMethod("getLocations");
    print(result); // এখানে চেক করলে দেখবে এখন পুরো নামেই ডেটা আসছে
    return (result as List)
        .map((e) => Location.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> updateLocation(Location location) async {
    try {
      await _channel.invokeMethod("updateLocation", {
        "id": location.id,
        "name": location.name,
        "lat": location.latitude,
        "lon": location.longitude,
        "diameter": location.diameter,
        "preAlarm": location.preAlarmMinutes,
      });
      print("Location updated successfully in Native DB");
    } catch (e) {
      print("Failed to update location: $e");
    }
  }

  static Future<void> updateLocationSwitch(int id) async {
    try {
      // নেটিভ মেথড 'updateLocationSwitch' কল করা হচ্ছে শুধু ID দিয়ে
      final bool result = await _channel.invokeMethod("updateLocationSwitch", {
        "id": id,
      });

      if (result) {
        print("Location switch for ID: $id processed successfully.");
      }
    } catch (e) {
      print("Failed to switch location: $e");
    }
  }

  static Future<Location?> getLocationById(int id) async {
    try {
      final Map? result =
          await _channel.invokeMethod("getLocationById", {"id": id});
      if (result != null) {
        return Location.fromMap(Map<String, dynamic>.from(result));
      }
    } catch (e) {
      print("Error fetching location by ID: $e");
    }
    return null;
  }

  static Future<void> deleteLocation(int id) async {
    try {
      await _channel.invokeMethod("deleteLocation", {"id": id});
      print("Location $id deleted successfully");
    } catch (e) {
      print("Failed to delete location: $e");
    }
  }

  // ================= ALARM =================
  static Future<void> insertAlarm(Alarm alarm) async {
    try {
      // সরাসরি অ্যালার্ম অবজেক্টের toMap() কল করলেই সব ডাটা চলে যাবে
      await _channel.invokeMethod("insertAlarm", alarm.toMap());
      print("Alarm inserted successfully: ${alarm.title}");
    } catch (e) {
      print("Failed to insert alarm: $e");
    }
  }

  static Future<List<Alarm>> getAlarms(int locationId) async {
    final result = await _channel.invokeMethod("getAlarmsByLocation", {
      "locationId": locationId,
    });

    return (result as List).map((e) => Alarm.fromMap(Map.from(e))).toList();
  }

  static Future<List<Alarm>> getGeneralAlarms() async {
    final result = await _channel.invokeMethod("getAlarmsByLocation", {
      "locationId": 10,
    });

    return (result as List).map((e) => Alarm.fromMap(Map.from(e))).toList();
  }

  static Future<void> updateAlarm(Alarm alarm) async {
    await _channel.invokeMethod("updateAlarm", {
      "id": alarm.id, // ডাটাবেজ আইডি
      "title": alarm.title,
      "hour": alarm.alarmTime.hour,
      "minute": alarm.alarmTime.minute,
      "isActive": alarm.isActive,
      "isDaily": true, // বা আপনার লজিক অনুযায়ী
      "daysMask": alarm.daysMask,
      "sound": alarm.sound,
      "locationId": alarm.locationId, // মডেলে এই ফিল্ডটি থাকা জরুরি
    });
  }

  static Future<Alarm?> getAlarmById(int id) async {
    try {
      final Map? result =
          await _channel.invokeMethod("getAlarmById", {"id": id});

      if (result != null) {
        return Alarm.fromMap(Map<String, dynamic>.from(result));
      }
    } catch (e) {
      print("Error fetching alarm by ID: $e");
    }
    return null;
  }

  static Future<void> deleteAlarm(int id) async {
    try {
      await _channel.invokeMethod("deleteAlarm", {"id": id});
      print("Alarm with id $id deleted successfully");
    } catch (e) {
      print("Failed to delete alarm: $e");
    }
  }

  // ================= SETTINGS =================
  static Future<AppSettings> getAppSettings() async {
    final map = await _channel.invokeMethod("getSettings");

    if (map != null) {
      return AppSettings.fromMap(Map<String, dynamic>.from(map));
    } else {
      return AppSettings(
          id: 1,
          currentLocationId: 0, // অথবা আপনার প্রথম লোকেশনের আইডি
          currentLocation: "None",
          enable: true);
    }
  }

  static Future<void> updateSettings({
    required int locationId,
    required String location,
    required bool enable,
  }) async {
    await _channel.invokeMethod("updateSettings", {
      "id": 1,
      "currentLocationId": locationId,
      "currentLocation": location,
      "enable": enable ? 1 : 0,
    });
  }

  static Future<void> insertMosques(List<Mosque> mosques) async {
    try {
      final List<Map<String, dynamic>> data = mosques
          .map((m) => {
                "name": m.name,
                "lat": m.lat,
                "lon": m.lon,
              })
          .toList();

      await _channel.invokeMethod("insertMosques", {"mosques": data});
    } catch (e) {
      print("Error inserting mosques: $e");
    }
  }

  static Future<List<Mosque>> getMosques() async {
    try {
      final List? result = await _channel.invokeMethod("getMosques");
      if (result == null) return [];

      return result
          .map((e) => Mosque.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      print("Error getting mosques: $e");
      return [];
    }
  }

  static Future<void> deleteMosque(int id) async {
    await _channel.invokeMethod("deleteMosque", {"id": id});
  }

  static Future<void> saveDefaultSettings() async {
    try {
      await _channel.invokeMethod("saveDefaultAlarmSettings");
    } catch (e) {
      print("Save Error: $e");
    }
  }

  static Future<Map<String, dynamic>> getSettings() async {
    try {
      final result = await _channel.invokeMethod("getAlarmSettings");

      if (result == null) {
        return {
          "vibration": true,
          "gradual_volume_increase": true,
          "snooze_time": 3,
          "snooze_duration": 5,
          "auto_stop_alarm": 10,
          "pre_alarm_reminder": true,
          "missed_alarm_notification": true,
          "auto_silent_loaction": true,
          "auto_silent_by_alarm": false,
        };
      }
      // print("My Map Data: ${Map<String, dynamic>.from(result)}");
      return Map<String, dynamic>.from(result);
    } catch (e) {
      print("Get Error: $e");

      return {
        "vibration": true,
        "gradual_volume_increase": true,
        "snooze_time": 3,
        "snooze_duration": 5,
        "auto_stop_alarm": 10,
        "pre_alarm_reminder": true,
        "missed_alarm_notification": true,
        "auto_silent_location": true,
        "auto_silent_by_alarm": false,
      };
    }
  }

  static Future<void> updateSetting(String key, dynamic value) async {
    try {
      await _channel.invokeMethod("updateAlarmSettings", {
        "key": key,
        "value": value,
      });
    } catch (e) {
      print("Update Error: $e");
    }
  }

  // ==================== DND STATUS ====================

  static Future<bool> isDndGranted() async {
    try {
      final bool result = await _channel.invokeMethod(
        "isDndPermissionGranted",
      );

      return result;
    } catch (e) {
      print("DND Error: $e");

      return false;
    }
  }

  // ==================== OPEN DND SETTINGS ====================

  static Future<void> requestDndPermission() async {
    try {
      await _channel.invokeMethod(
        "requestDndPermission",
      );
    } catch (e) {
      print("Request DND Error: $e");
    }
  }

  static Future<void> startManualSilent({int minutes = 15}) async {
    try {
      await _channel.invokeMethod('startManualSilent', {'minutes': minutes});
    } catch (e) {
      print("Request manual silent Error: $e");
    }
  }

  static Future<void> stopManualSilent() async {
    try {
      await _channel.invokeMethod('stopManualSilent');
    } catch (e) {
      print("Request manual silent Error: $e");
    }
  }

  static Future<void> scheduleAllSilentTimes() async {
    try {
      await _channel.invokeMethod('scheduleAllSilentTimes');
    } catch (e) {
      print("Request schedule time silent Error: $e");
    }
  }

  static Future<void> cancelAllSilentTimes() async {
    try {
      await _channel.invokeMethod('cancelAllSilentTimes');
    } catch (e) {
      print("Request cancel time silent Error: $e");
    }
  }

  static Future<void> rescheduleAllSilentTimes() async {
    try {
      final data = await NativeDB.getSettings();
      if (data.isEmpty) {
        return;
      }
      if (data["auto_silent_by_alarm"] ?? false) {
        await _channel.invokeMethod('cancelAllSilentTimes');
        await _channel.invokeMethod('scheduleAllSilentTimes');
      }
    } catch (e) {
      print("Request cancel time silent Error: $e");
    }
  }
}
