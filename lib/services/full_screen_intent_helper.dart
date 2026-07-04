import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FullScreenIntentHelper {
  static const MethodChannel _channel =
      MethodChannel('com.butterflydevs.salahmaster/fullscreen_permission');

  static Future<bool> canUseFullScreenIntent() async {
    try {
      final bool? canUse =
          await _channel.invokeMethod('canUseFullScreenIntent');
      return canUse ?? false;
    } catch (e) {
      debugPrint("FullScreenIntent check error: $e");
      return false;
    }
  }

  static Future<void> openSettings() async {
    try {
      await _channel.invokeMethod('openFullScreenSettings');
    } catch (e) {
      debugPrint("Error opening Full Screen Settings: $e");
    }
  }
}
