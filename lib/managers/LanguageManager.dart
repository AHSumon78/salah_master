import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';

class LanguageManager {
  // ১. একটি মেথড চ্যানেল ডিক্লেয়ার করুন (যেকোনো ইউনিক নাম দিতে পারেন)
  static const MethodChannel _channel =
      MethodChannel('com.butterflydevs.salahmaster/language');

  // ২. ভাষা পরিবর্তনের সময় এই ফাংশনটি কল করবেন
  static Future<void> syncLanguageToNative(String languageCode) async {
    try {
      // নেটিভ অ্যান্ড্রয়েডের কাছে languageCode (যেমন: 'bn' বা 'en') পাঠিয়ে দিন
      await _channel.invokeMethod('changeLanguage', {'code': languageCode});
      print("Language synced to native: $languageCode");
    } on PlatformException catch (e) {
      print("Failed to sync language: ${e.message}");
    }
    try {
      await HomeWidget.updateWidget(
        name:
            'IslamicWidgetProvider', // ⚠️ আপনার android/app/src/main/res/xml/widget_info.xml বা Manifest-এ যে নাম দেওয়া আছে (যেমন: IslamicWidgetProvider)
        androidName: 'IslamicWidgetProvider',
      );
      print("উইজেট সফলভাবে আপডেট করা হয়েছে!");
    } catch (e) {
      print("উইজেট আপডেট করতে ব্যর্থ: $e");
    }
  }
}
