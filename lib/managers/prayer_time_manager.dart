import 'dart:async';
import 'package:alarm/l10n/generated/app_localizations.dart';
import 'package:alarm/managers/HijriCalendarManager.dart';
import 'package:alarm/managers/islamic_event_manager.dart';
import 'package:alarm/services/app_theme_extension.dart';
import 'package:alarm/services/daily_once.dart';
import 'package:alarm/services/prayer_calculation_settings.dart';
import 'package:flutter/material.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:home_widget/home_widget.dart';

// Location Model Import
import 'package:alarm/models/Location.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerTimeManager {
  // 🔥 ১. স্ট্রিং এর বদলে এখন Map পাস হবে যাতে "wakt_key" এবং "is_ends" ট্র্যাক করা যায়
  static final ValueNotifier<Map<String, dynamic>?> prayerTitleNotifier =
      ValueNotifier<Map<String, dynamic>?>(null);

  static final ValueNotifier<String> prayerCountdownNotifier =
      ValueNotifier<String>("00:00:00");

  static Timer? _prayerTimer;

  // 🔥 হোম স্ক্রিন উইজেটের ট্র্যাকিং ভেরিয়েবলও এখন ওয়াক্ত কী দিয়ে হবে
  static String _lastSentWaktKey = "";

  static void startSmartPrayerTimer({
    required BuildContext context,
    required Location? location,
  }) async {
    _prayerTimer?.cancel();
    _lastSentWaktKey = "";

    final prefs = await SharedPreferences.getInstance();
    await shouldRunLocationUpdate();
    double lat =  prefs.getDouble('lat') ?? 24.3745;
    double lng =  prefs.getDouble('lng') ?? 88.6042;
    final coords = Coordinates(lat, lng);

    () async {
      final params = await getSavedPrayerCalculationParameters();

      _prayerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();

      final pt = PrayerTimes(
        coordinates: coords,
        date: now,
        calculationParameters: params,
        precision: true,
      );

      final fajr = pt.fajr.toLocal();
      final sunrise = pt.sunrise.toLocal();
      final dhuhr = pt.dhuhr.toLocal();
      final asr = pt.asr.toLocal();
      final maghrib = pt.maghrib.toLocal();
      final isha = pt.isha.toLocal();
      final nextFajr = fajr.add(const Duration(days: 1));

      final sunriseEnd = sunrise.add(const Duration(minutes: 20));
      final zawalStart = dhuhr.subtract(const Duration(minutes: 15));

      String waktKey = "";
      bool isEnds = false;
      Duration diff;

      // ==================== লজিক (শুধু Key এবং Status সেট করা হচ্ছে) ====================

      if (now.isAfter(fajr) && now.isBefore(sunrise)) {
        waktKey = "fajr";
        isEnds = true;
        diff = sunrise.difference(now);
      } else if (now.isAfter(sunrise) && now.isBefore(sunriseEnd)) {
        waktKey = "forbidden";
        isEnds = false;
        diff = sunriseEnd.difference(now);
      } else if (now.isAfter(sunriseEnd) && now.isBefore(zawalStart)) {
        waktKey = "dhuhr";
        isEnds = false; // Next Dhuhr
        diff = dhuhr.difference(now);
      } else if (now.isAfter(zawalStart) && now.isBefore(dhuhr)) {
        waktKey = "jawal";
        isEnds = false;
        diff = dhuhr.difference(now);
      } else if (now.isAfter(dhuhr) && now.isBefore(asr)) {
        waktKey = "dhuhr";
        isEnds = true;
        diff = asr.difference(now);
      } else if (now.isAfter(asr) && now.isBefore(maghrib)) {
        waktKey = "asr";
        isEnds = true;
        diff = maghrib.difference(now);
      } else if (now.isAfter(maghrib) && now.isBefore(isha)) {
        waktKey = "maghrib";
        isEnds = true;
        diff = isha.difference(now);
      } else if (now.isAfter(isha) && now.isBefore(nextFajr)) {
        waktKey = "isha";
        isEnds = true;
        diff = nextFajr.difference(now);
      } else {
        waktKey = "fajr";
        isEnds = false; // Next Fajr
        diff = fajr.difference(now);
      }

      final hours = diff.inHours;
      final minutes = diff.inMinutes.remainder(60);
      final seconds = diff.inSeconds.remainder(60);

      // 🔄 র ডেটা নোটিফায়ারে পুশ (উইজেট নিজের মতো ভাষা হ্যান্ডেল করবে)
      prayerTitleNotifier.value = {
        "wakt_key": waktKey,
        "is_ends": isEnds,
      };

      prayerCountdownNotifier.value =
          "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";

      // 🔥 হোম স্ক্রিন উইজেট আপডেট লজিক
      if (_lastSentWaktKey != waktKey) {
        _lastSentWaktKey = waktKey;

        // হোম স্ক্রিন উইজেটের টেক্সট জেনারেশন (এখানে আপনি আপনার পছন্দমত ব্যাকগ্রাউন্ড সেফ লজিক রাখতে পারেন)
        String widgetTitle = isEnds ? "$waktKey Ends" : "Next $waktKey";

        sendDataToHomeScreenWidget(
          currentTitle: widgetTitle,
          fajr: fajr,
          sunrise: sunrise,
          dhuhr: dhuhr,
          asr: asr,
          maghrib: maghrib,
          isha: isha,
          nextFajr: nextFajr,
        );
      }
      });
    }();
  }

  static void stopTimer() {
    _prayerTimer?.cancel();
  }

  /// UI Widget
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

        // 🎯 ডেটা এক্সট্র্যাক্ট করা
        final String waktKey = prayerData["wakt_key"] ?? "";
        final bool isWaktRunning = prayerData["is_ends"] ?? false;

        // 🚫 নিষিদ্ধ বা জাওয়াল ওয়াক্ত চেক
        final bool isNisiddho = waktKey == "forbidden" || waktKey == "jawal";

        // 🔄 রানটাইমে ভাষা অনুযায়ী ওয়াক্তের সঠিক নাম এবং টাইটেল তৈরি
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

        // "Ends" অথবা "Next" যোগ করা (লোকালাইজড উপায়ে)
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
                    displayTitle, // 👈 এখন এটি ভাষা পরিবর্তনের সাথে সাথে ইনস্ট্যান্ট চেঞ্জ হবে
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

  /// ইংরেজি সংখ্যা (যেমন: 0123...) কে বাংলা সংখ্যায় (যেমন: ০১২৩...) রূপান্তর করার স্ট্যাটিক ফাংশন
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

    // পুরো স্ট্রিংটির প্রতিটি ক্যারেক্টার ম্যাপ করে বাংলা সংখ্যায় কনভার্ট করবে
    return input.characters.map((char) => englishToBangla[char] ?? char).join();
  }

  // 🔥 এই ফাংশনটি এখন public করা হয়েছে (আন্ডারস্কোর বাদ দিয়ে)
  // যাতে Workmanager-ও এখান থেকে একবারে সব সময় উইজেটে পাঠাতে পারে
  static Future<void> sendDataToHomeScreenWidget({
    required String currentTitle,
    required DateTime fajr,
    required DateTime sunrise,
    required DateTime dhuhr,
    required DateTime asr,
    required DateTime maghrib,
    required DateTime isha,
    required DateTime nextFajr,
  }) async {
    final now = DateTime.now();
    DateTime referenceDate = now;
    bool isNight = true;

    // ☀️ প্যারামিটার থেকে পাওয়া সূর্যোদয় ও সূর্যাস্তের (মাগরিব) মাঝে হলে সেটি "Day"
    if (now.isAfter(sunrise) && now.isBefore(maghrib)) {
      isNight = false;
    }

    // 🌇 মাগরিবের পর হলে ইসলামিক দিন পরিবর্তন হয়ে পরের দিন (Next Day) হয়ে যাবে
    if (now.isAfter(maghrib)) {
      referenceDate = referenceDate.add(const Duration(days: 1));
    }

    // 🌐 ১. SharedPreferences থেকে কনটেক্সট ছাড়া ভাষা রিড করা
    final prefs = await SharedPreferences.getInstance();
    final String localeCode = prefs.getString('app_language_code') ?? 'en';
    final bool isBn = localeCode == 'bn';

    // 🗓️ ২. ভাষা অনুযায়ী বারের নাম এবং দিন/রাত স্ট্যাটাস তৈরি (intl প্যাকেজ অটোমেটিক বার বাংলায় করে দেবে)
    final dayName = DateFormat('EEEE', localeCode).format(referenceDate);

    // ৩. দিন/রাত টেক্সট লোকাল অনুযায়ী ডাইনামিক করা
    String dayNightStatus;
    if (isNight) {
      dayNightStatus = isBn ? "$dayName রাত" : "$dayName Night";
    } else {
      dayNightStatus = isBn ? "$dayName দিন" : dayName;
    }

    // 🕌 আপনার ম্যানেজার থেকে মূল হিজরি ডেট নিয়ে আসা (কোনো context ছাড়া)
    final hijriDate = await HijriCalendarManager.getHijriDate();

    // দুইটা একসাথে কম্বাইন করা: "🌙 ২৫ জিলকদ ১৪৪৭ হিজরি\n(সোমবার রাত)"
    final finalHijriString = "$hijriDate\n$dayNightStatus";

    // 📲 উইজেট ডেটাতে সেভ করা
    await HomeWidget.saveWidgetData<String>(
      'hijri_date',
      finalHijriString,
    );
    final eventData = await IslamicEventManager.getEventData();

    await HomeWidget.saveWidgetData<String>(
      'event_name',
      eventData['name'],
    );

    await HomeWidget.saveWidgetData<String>(
      'event_days',
      eventData['days'],
    );

    // ১. বর্তমান টাইটেল বা ওয়াক্তের নাম পাঠানো
    await HomeWidget.saveWidgetData<String>('widget_title', currentTitle);

    // টাইম ফরম্যাটের সংখ্যাগুলোকেও যদি উইজেটে বাংলায় দেখাতে চান, তবে localeCode পাস করতে পারেন
    await HomeWidget.saveWidgetData<String>(
      'sunrise_text',
      DateFormat('hh:mm a', localeCode).format(sunrise),
    );

    await HomeWidget.saveWidgetData<String>(
      'sunset_text',
      DateFormat('hh:mm a', localeCode).format(maghrib),
    );

    // ২. সব ওয়াক্তের টার্গেট টাইমস্ট্যাম্প একবারে পাঠানো
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

    // ৩. উইজেটকে রিফ্রেশ করার কমান্ড দেওয়া
    await HomeWidget.updateWidget(name: 'IslamicWidgetProvider');
    print("Home Screen Widget synchronized successfully!");
  }
}
