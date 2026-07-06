import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/app_theme_extension.dart';

class IslamicEventManager {
  // নেটিভ মেথড চ্যানেল (আপনার এক্সিস্টিং চ্যানেল স্ট্রাকচার অনুযায়ী)
  static const MethodChannel _channel =
      MethodChannel('com.butterflydevs.salahmaster/prayer_event');

  // UI আপডেট করার জন্য নটিফায়ার (সরাসরি ম্যাপ হোল্ড করবে)
  static final ValueNotifier<Map<String, dynamic>?> countdownNotifier =
      ValueNotifier<Map<String, dynamic>?>(null);

  static Future<void> initAndCalculateCountdown() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // 🌟 ফিক্স: ডিফল্ট অ্যাডজাস্টমেন্ট -1 সেট করা হলো
      if (!prefs.containsKey("flutter.hijri_adjustment")) {
        await prefs.setInt("flutter.hijri_adjustment", -1);
      }
      final int adjustment = prefs.getInt("flutter.hijri_adjustment") ?? -1;

      final Map<dynamic, dynamic>? nativeData =
          await _channel.invokeMethod('getEventData', {
        'adjustment': adjustment,
      });

      if (nativeData != null) {
        countdownNotifier.value = {
          "name": nativeData['name'] ?? '',
          "days": nativeData['days'] ?? '',
          "minDays": nativeData['minDays'] ?? 0,
          "adjustment": adjustment,
        };
      }
    } catch (e) {
      debugPrint("Error in native countdown fetch: $e");
      countdownNotifier.value = {
        "name": "Error",
        "days": "N/A",
        "minDays": -1,
        "adjustment": -1,
      };
    }
  }

  // ৫. বাহ্যিক সার্ভিস থেকে ডাটা পাওয়ার মেথড
  static Future<Map<String, dynamic>> getEventData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      // 🌟 ফিক্স: এখানেও ডিফল্ট ভ্যালু -1 রাখা হলো
      final int adjustment = prefs.getInt("flutter.hijri_adjustment") ?? -1;

      final Map<dynamic, dynamic>? nativeData =
          await _channel.invokeMethod('getEventData', {
        'adjustment': adjustment,
      });

      if (nativeData != null) {
        return {
          "name": nativeData['name'] ?? '',
          "days": nativeData['days'] ?? '',
          "minDays": nativeData['minDays'] ?? 0,
        };
      }
    } catch (e) {
      debugPrint("Error in getEventData forwarder: $e");
    }

    return {
      "name": "Error",
      "days": "N/A",
      "minDays": -1,
    };
  }

  // ২. হিজরি ডেট অ্যাডজাস্টমেন্ট আপডেট করা
  static Future<void> updateAdjustment(int newAdjustment) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("flutter.hijri_adjustment", newAdjustment);
    await initAndCalculateCountdown();
  }

  // ৩. হোম স্ক্রিনের কাউন্টডাউন উইজেট (Grid Tile)
  static Widget buildCountdownGridTile(BuildContext context) {
    return ValueListenableBuilder<Map<String, dynamic>?>(
      valueListenable: countdownNotifier,
      builder: (context, data, child) {
        if (data == null) {
          return Container(
            padding: const EdgeInsets.all(12),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.teal)),
              ),
            ),
          );
        }

        final String eventNameDisplay = data["name"] ?? '';
        final String daysDisplay = data["days"] ?? '';

        return Material(
          color: Theme.of(context).cardBackground,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _showAllEventsBottomSheet(context),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.hourglass_top_rounded,
                          color: Theme.of(context).iconColor, size: 20),
                      Text(
                        Localizations.localeOf(context).languageCode == 'bn'
                            ? "কাউন্টডাউন"
                            : "Countdown",
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).iconColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        eventNameDisplay,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            height: 1.2),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    daysDisplay,
                    style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ৪. বটম শিট - সব ইভেন্টের লিস্ট দেখানো
  static void _showAllEventsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return ValueListenableBuilder<Map<String, dynamic>?>(
          valueListenable: countdownNotifier,
          builder: (context, data, child) {
            if (data == null) return const SizedBox.shrink();

            final int currentAdjustment = data["adjustment"] as int;
            final bool isBn =
                Localizations.localeOf(context).languageCode == 'bn';

            return FutureBuilder<List<dynamic>>(
              future: _channel.invokeMethod('getAllSortedEvents', {
                'adjustment': currentAdjustment,
              }).then(
                  (value) => value != null ? List<dynamic>.from(value) : []),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox(
                    height: 200,
                    child: Center(
                        child: CircularProgressIndicator(color: Colors.teal)),
                  );
                }

                final List<dynamic> nativeEvents = snapshot.data!;

                return Container(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.80),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                isBn
                                    ? "ইসলামিক গুরুত্বপূর্ণ দিনসমূহ"
                                    : "Islamic Holy Days",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.pop(context)),
                          ],
                        ),
                      ),

                      // হিজরি অ্যাডজাস্টমেন্ট উইজেট
                      ListTile(
                        title:
                            Text(isBn ? "হিজরি সমন্বয়" : "Hijri Adjustment"),
                        subtitle: Text(isBn
                            ? "চাঁদ দেখার ওপর ভিত্তি করে তারিখ পরিবর্তন করুন"
                            : "Tune date according to moon sight"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () =>
                                    updateAdjustment(currentAdjustment - 1)),
                            Text(isBn
                                ? "${_toBanglaNumber(currentAdjustment.toString())} দিন"
                                : "$currentAdjustment Day"),
                            IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () =>
                                    updateAdjustment(currentAdjustment + 1)),
                          ],
                        ),
                      ),
                      const Divider(),

                      // ইভেন্ট লিস্ট
                      Expanded(
                        child: ListView.builder(
                          itemCount: nativeEvents.length,
                          itemBuilder: (context, index) {
                            final Map<dynamic, dynamic> event =
                                Map<dynamic, dynamic>.from(nativeEvents[index]);
                            final String eventName = event["name"] ?? "";
                            final int daysLeft = event["daysLeft"] ?? 0;

                            final String dateText =
                                "${event['day']}/${event['month']}/${event['year']}";

                            String daysLeftText = isBn
                                ? "${_toBanglaNumber(daysLeft.toString())} দিন বাকি"
                                : "$daysLeft Days Left";
                            if (daysLeft == 0)
                              daysLeftText = isBn ? "আজ" : "Today";

                            return ListTile(
                              title: Text(eventName),
                              subtitle: Text(dateText),
                              trailing: Chip(label: Text(daysLeftText)),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ৫. বাহ্যিক সার্ভিস থেকে ডাটা পাওয়ার মেথড

  // হিজরি ম্যানেজারের ডিপেন্ডেন্সি এড়াতে লোকাল সংখ্যা কনভার্টার মেথড
  static String _toBanglaNumber(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bangla = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

    String result = input;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], bangla[i]);
    }
    return result;
  }
}
