// lib/services/widget_service.dart

import 'package:home_widget/home_widget.dart';

class WidgetService {
  /// এই ফাংশনটি কল করলে হোম স্ক্রিন উইজেটের ডাটা এবং টাইটেল আপডেট হবে
  static Future<void> updateWidgetData({
    required String currentTitle,
    required DateTime fajr,
    required DateTime sunrise,
    required DateTime dhuhr,
    required DateTime asr,
    required DateTime maghrib,
    required DateTime isha,
    required DateTime nextFajr,
  }) async {
    // ১. উইজেটের মেমরিতে টাইটেল এবং সব ওয়াক্তের মিলিসেকেন্ড (Timestamp) সেভ করা
    await HomeWidget.saveWidgetData<String>('widget_title', currentTitle);

    await HomeWidget.saveWidgetData<int>(
        'fajr_time', fajr.millisecondsSinceEpoch);
    await HomeWidget.saveWidgetData<int>(
        'sunrise_time', sunrise.millisecondsSinceEpoch);
    await HomeWidget.saveWidgetData<int>(
        'dhuhr_time', dhuhr.millisecondsSinceEpoch);
    await HomeWidget.saveWidgetData<int>(
        'asr_time', asr.millisecondsSinceEpoch);
    await HomeWidget.saveWidgetData<int>(
        'maghrib_time', maghrib.millisecondsSinceEpoch);
    await HomeWidget.saveWidgetData<int>(
        'isha_time', isha.millisecondsSinceEpoch);
    await HomeWidget.saveWidgetData<int>(
        'next_fajr_time', nextFajr.millisecondsSinceEpoch);

    // ২. উইজেটকে রিফ্রেশ করার জন্য নেটিভ অ্যান্ডরয়েডের 'IslamicWidgetProvider' কে নক করা
    await HomeWidget.updateWidget(
      name: 'IslamicWidgetProvider',
      androidName:
          'IslamicWidgetProvider', // অ্যান্ড্রয়েডের জন্য সেফটি আর্গুমেন্ট
    );

    print("Widget data synchronized successfully with Native Android!");
  }
}
