import 'package:alarm/managers/HijriCalendarManager.dart';
import 'package:alarm/services/app_theme_extension.dart';
import 'package:alarm/services/daily_once.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hijri/hijri_calendar.dart'; 

// ১. সম্পূর্ণ ডাইনামিক ইসলামিক ইভেন্ট মডেল ক্লাস
class DynamicIslamicEvent {
  final String name;
  final String nameBn; // 🔥 বাংলা নাম
  final int hijriMonth;
  final int hijriDay;

  const DynamicIslamicEvent({
    required this.name,
    required this.nameBn, // 🔥
    required this.hijriMonth,
    required this.hijriDay,
  });
}

class IslamicEventManager {
  static final ValueNotifier<Map<String, dynamic>?> countdownNotifier =
      ValueNotifier<Map<String, dynamic>?>(null);

  // 🕋 ২. বাংলা নাম সহ উৎসবগুলোর চিরস্থায়ী ফিক্সড ডাটাবেজ
  static const List<DynamicIslamicEvent> _islamicEvents = [
    DynamicIslamicEvent(
        name: "Islamic New Year",
        nameBn: "হিজরি নববর্ষ",
        hijriMonth: 1,
        hijriDay: 1),
    DynamicIslamicEvent(
        name: "Ashura\n(10 Muharram)",
        nameBn: "আশুরা\n(১০ মহররম)",
        hijriMonth: 1,
        hijriDay: 10),
    DynamicIslamicEvent(
        name: "Eid-e-Miladunnabi",
        nameBn: "ঈদে মিলাদুন্নবী",
        hijriMonth: 3,
        hijriDay: 12),
    DynamicIslamicEvent(
        name: "Shab-e-Meraj", nameBn: "শবে মেরাজ", hijriMonth: 7, hijriDay: 27),
    DynamicIslamicEvent(
        name: "Shab-e-Barat", nameBn: "শবে বরাত", hijriMonth: 8, hijriDay: 15),
    DynamicIslamicEvent(
        name: "Ramadan Begins",
        nameBn: "রমজান শুরু",
        hijriMonth: 9,
        hijriDay: 1),
    DynamicIslamicEvent(
        name: "Shab-e-Qadr", nameBn: "শবে কদর", hijriMonth: 9, hijriDay: 27),
    DynamicIslamicEvent(
        name: "Eid-ul-Fitr", nameBn: "ঈদুল ফিতর", hijriMonth: 10, hijriDay: 1),
    DynamicIslamicEvent(
        name: "Hajj (Arafah Day)",
        nameBn: "আরাফাহর দিন (হজ)",
        hijriMonth: 12,
        hijriDay: 9),
    DynamicIslamicEvent(
        name: "Eid-ul-Azha", nameBn: "ঈদুল আজহা", hijriMonth: 12, hijriDay: 10),
        // আয়ামে বিজ যোগ করুন (শেষে)
    DynamicIslamicEvent(
        name: "Ayyam al-Bid",
        nameBn: "আয়ামে বিজ",
        hijriMonth: 0,      // ০ মানে সব মাস
        hijriDay: 13),

    DynamicIslamicEvent(
        name: "Ayyam al-Bid",
        nameBn: "আয়ামে বিজ",
        hijriMonth: 0,
        hijriDay: 14),

    DynamicIslamicEvent(
        name: "Ayyam al-Bid",
        nameBn: "আয়ামে বিজ",
        hijriMonth: 0,
        hijriDay: 15),
  ];

  // 🧠 ৩. নির্দিষ্ট হিজরি তারিখের ইংরেজি তারিখ বের করার গাণিতিক অ্যালগরিদম (অপরিবর্তিত)
  static DateTime _estimateGregorianDate(int hijriMonth, int hijriDay,
      int adjustment, int curYear, int curMonth, int curDay) {
    if (hijriMonth == 0) {  // আয়ামে বিজ হ্যান্ডলিং
    hijriMonth = curMonth; // বর্তমান মাসে চেক করবে
    if (hijriDay < curDay) {
      hijriMonth = curMonth + 1; // যদি তারিখ পার হয়ে যায় তাহলে পরের মাস
      if (hijriMonth > 12) hijriMonth = 1;
    }
  }
    final DateTime now = DateTime.now();
    const double hijriYearInDays = 354.367;
    const double hijriMonthInDays = 29.53;

    DateTime bestEstimate = DateTime(now.year + 1, 12, 31);
    int minDiff = 999999;

    for (int yearOffset in [-1, 0, 1, 2]) {
      int testHijriYear = curYear + yearOffset;

      double totalDaysFromToday = (testHijriYear - curYear) * hijriYearInDays +
          (hijriMonth - curMonth) * hijriMonthInDays +
          (hijriDay - curDay);

      DateTime estimatedDate = DateTime(now.year, now.month, now.day)
          .add(Duration(days: totalDaysFromToday.round()));

      int diff = estimatedDate
          .difference(DateTime(now.year, now.month, now.day))
          .inDays;

      if (diff >= 0 && diff < minDiff) {
        minDiff = diff;
        bestEstimate = estimatedDate;
      }
    }
    return bestEstimate;
  }

  // 🎯 ৪. ডাইনামিকালি ইভেন্ট হিসাব করার মূল মেথড
  static Future<void> initAndCalculateCountdown() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final int adjustment = prefs.getInt("hijri_adjustment") ?? -1;

      final hijriData = await HijriCalendarManager.getHijriDateRaw();

      final curYear = int.parse(hijriData['year'].toString());
      final curMonth = hijriData['month']['number'];
      final curDay = int.parse(hijriData['day'].toString());

      final now = DateTime.now();

      // টার্গেট অবজেক্ট ট্র্যাক করার জন্য ভেরিয়েবল
      DynamicIslamicEvent closestEvent = _islamicEvents.first;
      int minDays = 9999;

      for (var event in _islamicEvents) {
        int targetMonth = event.hijriMonth;
        int targetDay = event.hijriDay;

        if (event.hijriMonth == 0) {
  // রমজানে আয়্যামে বীয দেখাবে না
        if (curMonth == 9) {
          continue;
        }

        // শুধু ১-১৫ তারিখ পর্যন্ত দেখাবে
        if (curDay > 15) {
          continue;
        }
      }
      if (event.hijriMonth == 0) {
        if (curDay < 16) {
          targetMonth = curMonth;
          if (targetDay < curDay) {
            targetMonth++;
            if (targetMonth > 12) targetMonth = 1;
          }
        } else {
          targetMonth = curMonth + 1;
          if (targetMonth > 12) targetMonth = 1;
        }
      }
        final DateTime targetDate = _estimateGregorianDate(event.hijriMonth,
            event.hijriDay, adjustment, curYear, curMonth, curDay);
        final int difference =
            DateTime(targetDate.year, targetDate.month, targetDate.day)
                .difference(DateTime(now.year, now.month, now.day))
                .inDays;

        if (difference >= 0 && difference < minDays) {
          minDays = difference;
          closestEvent = event;
        }
      }

      // 🔄 কোনো টেক্সট বা ভাষা এখানে ফিক্স না করে সরাসরি র ডেটা পুশ (যাতে উইজেট রানটাইমে ভাষা বদলাতে পারে)
      countdownNotifier.value = {
        "event": closestEvent,
        "minDays": minDays,
        "adjustment": adjustment,
      };
    } catch (e) {
      debugPrint("$e");
      // এরর খেলেও ফ্যালব্যাক হিসেবে প্রথম ইভেন্ট অবজেক্ট পাস করছি
      countdownNotifier.value = {
        "event": _islamicEvents.first,
        "minDays": -1,
        "adjustment": -1,
      };
    }
  }

  static Future<void> updateAdjustment(int newAdjustment) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("hijri_adjustment", newAdjustment);
    await initAndCalculateCountdown();
  }

  // 🕋 ৫. হোম স্ক্রিনের গ্রিডে বসানোর জন্য চারকোনা盒 উইজেট (UI)
  static Widget buildCountdownGridTile(BuildContext context) {
    return ValueListenableBuilder<Map<String, dynamic>?>(
      valueListenable: countdownNotifier,
      builder: (context, data, child) {
        if (data == null) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardBackground,
            ),
            child: const Center(
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.teal)))),
          );
        }

        // 🌐 লাইভ উইজেট ট্রি এর ল্যাঙ্গুয়েজ ট্র্যাকিং (ভাষা বদলালে এটি সাথে সাথে ট্রিগার হবে)
        final isBangla = Localizations.localeOf(context).languageCode == 'bn';

        // 🎯 নটিফায়ার থেকে ডেটা রিসিভ
        final event = data["event"] as DynamicIslamicEvent;
        final int minDays = data["minDays"] as int;

        // 🔄 রানটাইমে ভাষা অনুযায়ী টেক্সট ফরম্যাটিং
        String eventNameDisplay = isBangla ? event.nameBn : event.name;
        String daysDisplay;

        if (minDays == -1) {
          daysDisplay = isBangla ? "শীঘ্রই আসছে" : "Coming Soon";
        } else if (minDays == 0) {
          daysDisplay = isBangla ? "আজ" : "Today";
        } else {
          daysDisplay = isBangla
              ? "${HijriCalendarManager.toBanglaNumber(minDays.toString())} দিন পর"
              : "In $minDays Days";
        }

        return Material(
          color: Theme.of(context).cardBackground,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _showAllEventsBottomSheet(context),
            splashColor: Colors.redAccent.withValues(alpha: 0.15),
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
                        isBangla
                            ? "কাউন্টডাউন"
                            : "Countdown", // ← ডাইনামিক হেডার
                        style: Theme.of(context).caption.copyWith(
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
                        eventNameDisplay, // 👈 ডাইনামিক ইভেন্ট নেম
                        style: Theme.of(context).title.copyWith(
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
                    daysDisplay, // 👈 ডাইনামিক দিন কাউন্টডাউন
                    style: Theme.of(context).caption.copyWith(
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

  // 🕋 ৬. পুরো বছরের ছুটির তালিকা স্লাইড বটমশিট (রিয়েল-টাইম অ্যাডজাস্টমেন্ট বাটন সহ)
  // 🕋 ৬. পুরো বছরের ছুটির তালিকা স্লাইড বটমশিট (রিয়েল-টাইম অ্যাডজাস্টমেন্ট বাটন সহ)
  static void _showAllEventsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).appBackground,
      builder: (context) {
        return ValueListenableBuilder<Map<String, dynamic>?>(
          valueListenable: countdownNotifier,
          builder: (context, data, child) {
            if (data == null) return const SizedBox.shrink();

            final int currentAdjustment = data["adjustment"] as int;
            final now = DateTime.now();

            // 🌐 কারেন্ট অ্যাপের ল্যাঙ্গুয়েজ চেক (bn বা en)
            final bool isBn =
                Localizations.localeOf(context).languageCode == 'bn';

            // লাইভ রিয়েল-টাইম ডেট থেকে কারেন্ট ক্যালিব্রেশন জেনারেট করা হচ্ছে
            final localHijri = HijriCalendar.fromDate(
                DateTime.now().add(Duration(days: currentAdjustment)));
            final int curYear = localHijri.hYear;
            final int curMonth = localHijri.hMonth;
            final int curDay = localHijri.hDay;

            // বর্তমান অ্যাডজাস্টমেন্ট অনুযায়ী লিস্ট সাজানো
            List<Map<String, dynamic>> sortedEvents = _islamicEvents
                .map((event) {
              final targetDate = _estimateGregorianDate(event.hijriMonth,
                  event.hijriDay, currentAdjustment, curYear, curMonth, curDay);
              return {
                "name":
                    isBn ? event.nameBn : event.name, // 👈 ডাইনামিক ইভেন্ট নেম
                "date": targetDate,
                "daysLeft":
                    DateTime(targetDate.year, targetDate.month, targetDate.day)
                        .difference(DateTime(now.year, now.month, now.day))
                        .inDays,
              };
            }).toList()
              ..sort((a, b) =>
                  (a["daysLeft"] as int).compareTo(b["daysLeft"] as int));

            return Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.80),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // হেডার রো
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_month,
                                color: Theme.of(context).iconColor),
                            const SizedBox(width: 10),
                            Text(
                              isBn
                                  ? "ইসলামিক পবিত্র दिनসমূহ"
                                  : "Islamic Holy Days", // 👈 ডাইনামিক হেডার
                              style: Theme.of(context).title,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                          icon: Icon(Icons.close,
                              color: Theme.of(context).iconColor),
                          onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  Divider(color: Theme.of(context).iconColor, height: 15),

                  // 🛠️ ডাইনামিক অ্যাডজাস্টমেন্ট কন্ট্রোলার বাটন এরিয়া
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardBackground,
                      border: Border.all(
                          color: Colors.black.withValues(alpha: 0.2), width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isBn
                                    ? "হিজরি সমন্বয়"
                                    : "Hijri Adjustment", // 👈 ডাইনামিক
                                style: Theme.of(context).title,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isBn
                                    ? "আপনার চাঁদ দেখার উপর ভিত্তি করে তারিখ পরিবর্তন করুন"
                                    : "Tune date according to your moon sight", // 👈 ডাইনামিক
                                style: Theme.of(context)
                                    .caption
                                    .copyWith(fontSize: 10),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              // মাইনাস বাটন
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: Icon(Icons.remove_circle_outline,
                                    color: Theme.of(context).iconColor,
                                    size: 22),
                                onPressed: () =>
                                    updateAdjustment(currentAdjustment - 1),
                              ),
                              // বর্তমান দিনের টেক্সট শো
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 2, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.teal.withValues(alpha: 0.15),
                                ),
                                child: Text(
                                  isBn
                                      ? (currentAdjustment >= 0
                                          ? "+${HijriCalendarManager.toBanglaNumber(currentAdjustment.toString())} দিন"
                                          : "${HijriCalendarManager.toBanglaNumber(currentAdjustment.toString())} দিন")
                                      : (currentAdjustment >= 0
                                          ? "+$currentAdjustment Day"
                                          : "$currentAdjustment Day"), // 👈 ডাইনামিক দিন ফরম্যাট
                                  style: Theme.of(context)
                                      .time
                                      .copyWith(fontSize: 10),
                                ),
                              ),
                              // প্লাস বাটন
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: Icon(Icons.add_circle_outline,
                                    color: Theme.of(context).iconColor),
                                onPressed: () =>
                                    updateAdjustment(currentAdjustment + 1),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),

                  // ছুটির দিনগুলোর মেইন লিস্ট ভিউ
                  Expanded(
                    child: ListView.builder(
                      itemCount: sortedEvents.length,
                      itemBuilder: (context, index) {
                        final event = sortedEvents[index];
                        final DateTime targetDate = event["date"];
                        final int daysLeft = event["daysLeft"];

                        // 🌐 ভাষা অনুযায়ী মাসের নাম নির্ধারণ
                        final monthsEn = [
                          "Jan",
                          "Feb",
                          "Mar",
                          "Apr",
                          "May",
                          "Jun",
                          "Jul",
                          "Aug",
                          "Sep",
                          "Oct",
                          "Nov",
                          "Dec"
                        ];
                        final monthsBn = [
                          "জানু",
                          "ফেব্রু",
                          "মার্চ",
                          "এপ্রিল",
                          "মে",
                          "জুন",
                          "জুলাই",
                          "আগস্ট",
                          "সেপ্টে",
                          "অক্টো",
                          "নভে",
                          "ডিসে"
                        ];

                        final String dayStr = isBn
                            ? HijriCalendarManager.toBanglaNumber(
                                targetDate.day.toString())
                            : targetDate.day.toString();
                        final String yearStr = isBn
                            ? HijriCalendarManager.toBanglaNumber(
                                targetDate.year.toString())
                            : targetDate.year.toString();
                        final String monthStr = isBn
                            ? monthsBn[targetDate.month - 1]
                            : monthsEn[targetDate.month - 1];

                        final dateText = isBn
                            ? "$dayStr $monthStr, $yearStr"
                            : "$dayStr $monthStr, $yearStr";

                        // 🌐 কাউন্টডাউন টেক্সট লোকাল্যাংক লজিক
                        String daysLeftText;
                        if (daysLeft == 0) {
                          daysLeftText = isBn ? "আজ" : "Today";
                        } else if (daysLeft < 0) {
                          final absDays = daysLeft.abs().toString();
                          daysLeftText = isBn
                              ? "${HijriCalendarManager.toBanglaNumber(absDays)} দিন আগে"
                              : "$absDays Days Ago";
                        } else {
                          daysLeftText = isBn
                              ? "${HijriCalendarManager.toBanglaNumber(daysLeft.toString())} দিন বাকি"
                              : "$daysLeft Days Left";
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 1),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardBackground,
                            border: Border.all(
                                color: Colors.black.withValues(alpha: 0.05),
                                width: 1),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(event["name"],
                                      style: Theme.of(context).subtitle),
                                  const SizedBox(height: 4),
                                  Text(dateText,
                                      style: Theme.of(context).caption),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                    color: Colors.tealAccent.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6)),
                                child: Text(
                                  daysLeftText,
                                  style: TextStyle(
                                      color: Theme.of(context).iconColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),
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
  }

  static Future<Map<String, dynamic>> getEventData() async {
    final prefs = await SharedPreferences.getInstance();
    final adjustment = prefs.getInt("hijri_adjustment") ?? -1;

    // 🌐 SharedPreferences থেকে ভাষা নির্ধারণ (ব্যাকগ্রাউন্ড আইসোলেটের জন্য নিরাপদ)
    final String localeCode = prefs.getString('app_language_code') ?? 'en';
    final bool isBn = localeCode == 'bn';

    final hijriData = await HijriCalendarManager.getHijriDateRaw();

    final curYear = int.parse(hijriData['year'].toString());
    final curMonth = hijriData['month']['number'];
    final curDay = int.parse(hijriData['day'].toString());

    final now = DateTime.now();

    DynamicIslamicEvent closestEvent = _islamicEvents.first;
    int minDays = 9999;

    for (var event in _islamicEvents) {
      int targetMonth = event.hijriMonth;
      int targetDay = event.hijriDay;

      // if (curDay <16 && event.hijriMonth == 0) {           // আয়ামে বিজ
      //   targetMonth = curMonth;
      //   if (targetDay < curDay) {
      //     targetMonth = curMonth + 1;
      //     if (targetMonth > 12) targetMonth = 1;
      //   }
      // }
      if (event.hijriMonth == 0) {
  // রমজানে আয়্যামে বীয দেখাবে না
        if (curMonth == 9) {
          continue;
        }

        // শুধু ১-১৫ তারিখ পর্যন্ত দেখাবে
        if (curDay > 15) {
          continue;
        }
      }
      if (event.hijriMonth == 0) {
        if (curDay < 16) {
          targetMonth = curMonth;
          if (targetDay < curDay) {
            targetMonth++;
            if (targetMonth > 12) targetMonth = 1;
          }
        } else {
          targetMonth = curMonth + 1;
          if (targetMonth > 12) targetMonth = 1;
        }
      }
      final targetDate = _estimateGregorianDate(
        event.hijriMonth,
        event.hijriDay,
        adjustment,
        curYear,
        curMonth,
        curDay,
      );

      final diff = DateTime(targetDate.year, targetDate.month, targetDate.day)
          .difference(DateTime(now.year, now.month, now.day))
          .inDays;

      if (diff >= 0 && diff < minDays) {
        minDays = diff;
        closestEvent = event;
      }
    }

    // 🌐 রিটানিং ডাটার ভাষা হ্যান্ডেলিং
    String eventNameDisplay = isBn ? closestEvent.nameBn : closestEvent.name;
    String daysDisplay;

    if (minDays == 0) {
      if (await shouldShowEventNotificationToday(closestEvent.name)) {
        await initializeNotifications();
    await showIslamicEventNotification(
      id: 500,
      title: eventNameDisplay,
      body: isBn
          ? "আজ $eventNameDisplay"
          : "$eventNameDisplay is today",
    );
  }
      daysDisplay = isBn ? "আজ" : "Today";
    } else {
      daysDisplay = isBn
          ? "${HijriCalendarManager.toBanglaNumber(minDays.toString())} দিন পর"
          : "\n\t\t\tIn $minDays Days";
    }

    return {
      "name": eventNameDisplay,
      "days": daysDisplay,
    };
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> showIslamicEventNotification({
  required int id,
  required String title,
  required String body,
}) async {
  const AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails(
    'islamic_event_channel',
    'Islamic Events',
    channelDescription: 'Islamic event notifications',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    autoCancel: true,
  );

  const NotificationDetails details =
      NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    id: id,
    title: title,
    body: body,
    notificationDetails: details
  );
}
Future<void> initializeNotifications() async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings settings =
      InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(settings: settings);
}