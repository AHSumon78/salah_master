import 'package:flutter/services.dart';

class WidgetManager {
  static const MethodChannel _channel =
      MethodChannel('widget_channel');

  static Future<bool> addWidget() async {
    final result = await _channel.invokeMethod<bool>('addWidget');
    return result ?? false;
  }
}