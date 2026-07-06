import 'package:alarm/l10n/generated/app_localizations.dart';
import 'package:alarm/services/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alarm/models/Location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerTimeManager {
  static final ValueNotifier<Map<String, dynamic>?> prayerTitleNotifier =
      ValueNotifier<Map<String, dynamic>?>(null);

  static final ValueNotifier<String> prayerCountdownNotifier =
      ValueNotifier<String>("00:00:00");

  static const _platform =
      MethodChannel('com.butterflydevs.salahmaster/prayer_event');

  static void startSmartPrayerTimer({
    required BuildContext context,
    required Location? location,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // সেফটি ডিফল্ট ভ্যালুসহ ল্যাটিচিউড এবং লঙ্গিচিউড রিড
    double lat = prefs.getDouble('lat') ?? 24.3745;
    double lng = prefs.getDouble('lng') ?? 88.6042;

    // কোটলিন থেকে আসা ডেটা রিসিভ করার হ্যান্ডলার
    _platform.setMethodCallHandler((call) async {
      if (call.method == "updatePrayerData") {
        final data = Map<String, dynamic>.from(call.arguments);

        final String waktKey = data["wakt_key"] ?? "";
        final bool isEnds = data["is_ends"] ?? false;
        final String countdown = data["countdown"] ?? "00:00:00";

        // UI নোটিফায়ার আপডেট
        prayerTitleNotifier.value = {
          "wakt_key": waktKey,
          "is_ends": isEnds,
        };
        prayerCountdownNotifier.value = countdown;
      }
      return null;
    });

    // নেটিভ সাইটের টাইমার স্টার্ট করার রিকোয়েস্ট পাঠানো
    try {
      await _platform
          .invokeMethod('startPrayerTimer', {'lat': lat, 'lng': lng});
    } catch (e) {
      debugPrint("Native timer start failed: $e");
    }
  }

  static void stopTimer() async {
    try {
      await _platform.invokeMethod('stopPrayerTimer');
    } catch (e) {
      debugPrint("Native timer stop failed: $e");
    }
  }

  /// UI Widget (একদম সেম রাখা হয়েছে)
  static Widget buildNextPrayerGridTile() {
    return ValueListenableBuilder<Map<String, dynamic>?>(
      valueListenable: PrayerTimeManager.prayerTitleNotifier,
      builder: (context, prayerData, child) {
        final l = AppLocalizations.of(context)!;
        final bool isBangla =
            Localizations.localeOf(context).languageCode == 'bn';

        if (prayerData == null) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Theme.of(context).cardBackground),
            child: const Center(
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))),
          );
        }

        final String waktKey = prayerData["wakt_key"] ?? "";
        final bool isWaktRunning = prayerData["is_ends"] ?? false;
        final bool isNisiddho = waktKey == "forbidden" || waktKey == "jawal";

        String displayTitle = "";

        switch (waktKey) {
          case "fajr":
            displayTitle = l.fajr;
            break;
          case "dhuhr":
            displayTitle = l.dhuhr;
            break;
          case "asr":
            displayTitle = l.asr;
            break;
          case "maghrib":
            displayTitle = l.maghrib;
            break;
          case "isha":
            displayTitle = l.isha;
            break;
          case "forbidden":
            displayTitle = l.forbidden;
            break;
          case "jawal":
            displayTitle = l.jawal;
            break;
          default:
            displayTitle = waktKey;
        }

        if (isWaktRunning) {
          displayTitle = "$displayTitle ${l.ends}";
        } else if (waktKey != "forbidden" && waktKey != "jawal") {
          displayTitle = "${l.next} $displayTitle";
        }

        return Material(
          color: Theme.of(context).cardBackground,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {},
            splashColor: Colors.teal.withValues(alpha: 0.15),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.mosque,
                        color: Theme.of(context).iconColor,
                        size: 20,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isNisiddho
                              ? Colors.red.withValues(alpha: 0.25)
                              : isWaktRunning
                                  ? Colors.teal.withValues(alpha: 0.2)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isNisiddho
                              ? l.forbiddenTime
                              : isWaktRunning
                                  ? l.live
                                  : l.prayer,
                          style: Theme.of(context).caption.copyWith(
                                color: isNisiddho ? Colors.red : null,
                              ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    displayTitle,
                    style: Theme.of(context).title.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  ValueListenableBuilder<String>(
                    valueListenable: PrayerTimeManager.prayerCountdownNotifier,
                    builder: (context, countdownValue, child) {
                      final String displayedCountdown = isBangla
                          ? PrayerTimeManager.toBanglaNumber(countdownValue)
                          : countdownValue;

                      return Text(
                        displayedCountdown,
                        style: Theme.of(context).time,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// সংখ্যা কনভার্টার
  static String toBanglaNumber(String input) {
    const englishToBangla = {
      '0': '০',
      '1': '১',
      '2': '২',
      '3': '৩',
      '4': '৪',
      '5': '৫',
      '6': '৬',
      '7': '৭',
      '8': '৮',
      '9': '৯',
    };
    return input.characters.map((char) => englishToBangla[char] ?? char).join();
  }
}
