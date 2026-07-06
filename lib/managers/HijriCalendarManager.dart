import 'dart:async';

import 'package:alarm/services/app_theme_extension.dart'; // কাস্টম থিম এক্সটেনশন ইম্পোর্ট করা হলো
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HijriCalendarManager {
  // নেটিভ মেথড চ্যানেল
  static const _platform =
      MethodChannel('com.butterflydevs.salahmaster/prayer_event');

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
      '9': '৯'
    };
    return input.characters.map((char) => englishToBangla[char] ?? char).join();
  }

  static const Map<int, String> _hijriMonthsBn = {
    1: 'মুহাররাম',
    2: 'সফর',
    3: 'রবিউল আউয়াল',
    4: 'রবিউস সানি',
    5: 'জুমাদাল উলা',
    6: 'জুমাদাস সানি',
    7: 'রজব',
    8: 'শাবান',
    9: 'রমজান',
    10: 'শাওয়াল',
    11: 'জিলকদ',
    12: 'জিলহজ'
  };

  // 🛠️ ফিক্স ১: ইংরেজি নামের স্পেশাল ক্যারেক্টার ও ডট রিমুভ করার নিখুঁত লজিক
  static String cleanHijriMonth(String month) {
    return month
        .replaceAll('Ḥ', 'H')
        .replaceAll('ḥ', 'h')
        .replaceAll('ā', 'a')
        .replaceAll('Ū', 'U')
        .replaceAll('ū', 'u')
        .replaceAll('Ī', 'I')
        .replaceAll('ī', 'i')
        .replaceAll('Dhি al', 'Dhu al')
        .replaceAll('Dh?', 'Dhu')
        .replaceAll('?', 'u')
        .trim();
  }

  static Future<String> getHijriDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String languageCode = prefs.getString('app_language_code') ?? 'en';
      final data = await getHijriDateRaw();
      return getFormattedHijriDate(data, languageCode);
    } catch (e) {
      debugPrint("Error in getHijriDate: $e");
      return "---";
    }
  }

  static String getFormattedHijriDate(
      Map<String, dynamic>? hijriData, String languageCode) {
    if (hijriData == null) return "Loading...";

    final isBangla = languageCode == 'bn';
    String day = hijriData['day']?.toString() ?? '--';
    String year = hijriData['year']?.toString() ?? '----';

    final int monthNumber = hijriData['month']?['number'] as int? ?? 1;
    String monthName = hijriData['month']?['en']?.toString() ?? 'Month';

    if (isBangla) {
      day = toBanglaNumber(day);
      year = toBanglaNumber(year);
      monthName = _hijriMonthsBn[monthNumber] ?? monthName;
      return "$day\t $monthName\n$year হিজরি";
    } else {
      monthName = cleanHijriMonth(monthName);
      return "$day\t $monthName\n$year AH";
    }
  }

  static Future<String> getHijriDateFromBackground(String languageCode) async {
    final data = await getHijriDateRaw();
    return getFormattedHijriDate(data, languageCode);
  }

  // নেটিভ মেথড চ্যানেল থেকে ডেটা রিড করার লজিক
  static Future<Map<String, dynamic>> getHijriDateRaw() async {
    try {
      final Map? rawData = await _platform.invokeMethod('getHijriDateRaw');
      if (rawData != null) {
        return Map<String, dynamic>.from(rawData);
      }
    } catch (e) {
      debugPrint("Failed to fetch Hijri data from Native: $e");
    }

    return {
      'day': '1',
      'month': {'number': 9, 'en': 'Ramadan', 'ar': 'رمضان', 'days': 30},
      'year': '1447'
    };
  }

  /// সম্পূর্ণ ক্যালেন্ডার বটমশিট (সঠিক তারিখ ও বার সিঙ্ক লজিকসহ)
  static void showFullCalendarBottomSheet(
      BuildContext context, Map<String, dynamic> hijriData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).appBackground, // কাস্টম ব্যাকগ্রাউন্ড
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final isBangla = Localizations.localeOf(context).languageCode == 'bn';

        String monthEn = hijriData['month']['en']?.toString() ?? '';
        final monthAr = hijriData['month']['ar']?.toString() ?? '';
        final int monthNumber = hijriData['month']?['number'] as int? ?? 1;
        String year = hijriData['year']?.toString() ?? '';

        final currentDay =
            int.tryParse(hijriData['day']?.toString() ?? '1') ?? 1;
        final totalDays =
            int.tryParse(hijriData['month']['days']?.toString() ?? '30') ?? 30;

        if (isBangla) {
          year = "${toBanglaNumber(year)} হিজরি";
          monthEn = _hijriMonthsBn[monthNumber] ?? monthEn;
        } else {
          monthEn = cleanHijriMonth(monthEn);
          year = "$year AH";
        }

        // 🛠️ আন্তর্জাতিক স্ট্যান্ডার্ড অনুযায়ী গ্রিড মেলাতে সপ্তাহ রবিবার (Sun) থেকে শুরু করা হলো
        final List<String> weekDays = isBangla
            ? ['রবি', 'সোম', 'মঙ্গল', 'বুধ', 'বৃহ', 'শুক্র', 'শনি']
            : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

        final DateTime phoneToday = DateTime.now();
        // মাসের ১ তারিখের ইংরেজি (Gregorian) অবজেক্ট বের করা হচ্ছে
        final DateTime baseGregorianDate =
            phoneToday.subtract(Duration(days: currentDay - 1));

        // 🛠️ ফিক্স ২: ১ তারিখ সপ্তাহের কী বার ছিল তার সঠিক Offset/Gap ক্যালকুলেশন
        // রবিবার=০, সোমবার=১ ... শনিবার=৬
        final int startOffsetGap =
            baseGregorianDate.weekday == 7 ? 0 : baseGregorianDate.weekday;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(monthEn, style: Theme.of(context).title),
                      Text(year, style: Theme.of(context).caption),
                    ],
                  ),
                  Text(
                    monthAr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
              Divider(color: Theme.of(context).iconColor, height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: weekDays
                      .map((day) => Expanded(
                            child: Center(
                              child: Text(
                                day,
                                style: Theme.of(context).subtitle.copyWith(
                                      fontWeight: isBangla
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: isBangla ? 12 : 14,
                                    ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                // 🛠️ আইটেম সংখ্যা = মাসের মোট দিন + শুরুর অফসেট গ্যাপ
                itemCount: totalDays + startOffsetGap,
                itemBuilder: (context, index) {
                  // শুরুর ফাঁকা দিনগুলোর জন্য খালি কনটেইনার বা রেন্ডার স্কিপ লজিক
                  if (index < startOffsetGap) {
                    return const SizedBox.shrink();
                  }

                  // প্রকৃত হিজরি দিনের নাম্বার হিসাব
                  final dayNum = index - startOffsetGap + 1;
                  final bool isToday = dayNum == currentDay;

                  // ১ তারিখের ইংরেজি অবজেক্টের সাথে বর্তমান ইনডেক্স মিলিয়ে নিখুঁত ইংরেজি ডেট জেনারেট
                  final correspondingGregDate =
                      baseGregorianDate.add(Duration(days: dayNum - 1));

                  String displayDayNum = dayNum.toString();
                  String gregDayNumber = correspondingGregDate.day.toString();

                  if (isBangla) {
                    displayDayNum = toBanglaNumber(displayDayNum);
                    gregDayNumber = toBanglaNumber(gregDayNumber);
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: isToday
                          ? Colors.teal.withOpacity(0.18)
                          : Theme.of(context).cardBackground,
                      border: Border.all(
                        color: isToday
                            ? Colors.tealAccent
                            : Colors.grey.withOpacity(0.3),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          displayDayNum,
                          style: Theme.of(context).time.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          gregDayNumber,
                          style: Theme.of(context)
                              .time
                              .copyWith(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

/// ক্যালেন্ডার উইজেট টাইল (হুবহু কমেন্টের মত সুন্দর কার্ড ডিজাইন ফিরিয়ে আনা হয়েছে)
class HijriCalendarTile extends StatefulWidget {
  const HijriCalendarTile({super.key});

  @override
  State<HijriCalendarTile> createState() => _HijriCalendarTileState();
}

class _HijriCalendarTileState extends State<HijriCalendarTile> {
  Map<String, dynamic>? _hijriDataCache;
  bool _isLoadingHijri = true;

  @override
  void initState() {
    super.initState();
    _initHijriCalendar();
  }

  void _initHijriCalendar() async {
    final data = await HijriCalendarManager.getHijriDateRaw();
    if (mounted) {
      setState(() {
        _hijriDataCache = data;
        _isLoadingHijri = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingHijri || _hijriDataCache == null) {
      return Container(
        height: 100,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Theme.of(context).cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
            ),
          ),
        ),
      );
    }

    final isBangla = Localizations.localeOf(context).languageCode == 'bn';

    String day = _hijriDataCache!['day']?.toString() ?? '--';
    final int monthNumber = _hijriDataCache!['month']?['number'] as int? ?? 1;
    String monthDisplay =
        _hijriDataCache!['month']['en']?.toString() ?? 'Month';
    String year = _hijriDataCache!['year']?.toString() ?? '----';

    if (isBangla) {
      day = HijriCalendarManager.toBanglaNumber(day);
      year = HijriCalendarManager.toBanglaNumber(year);

      const Map<int, String> hijriMonthsBn = {
        1: 'মুহাররাম',
        2: 'সফর',
        3: 'রবিউল আউয়াল',
        4: 'রবিউস সানি',
        5: 'জুমাদাল উলা',
        6: 'জুমাদাস সানি',
        7: 'রজব',
        8: 'শাবান',
        9: 'রমজান',
        10: 'শাওয়াল',
        11: 'জিলকদ',
        12: 'জিলহজ'
      };
      monthDisplay = hijriMonthsBn[monthNumber] ?? monthDisplay;
      year = "$year হিজরি";
    } else {
      monthDisplay = HijriCalendarManager.cleanHijriMonth(monthDisplay);
      year = "$year AH";
    }

    return Material(
      color: Theme.of(context).cardBackground,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => HijriCalendarManager.showFullCalendarBottomSheet(
            context, _hijriDataCache!),
        splashColor: Colors.teal.withOpacity(0.15),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.calendar_month_outlined,
                      color: Theme.of(context).iconColor, size: 20),
                  Text(
                    year,
                    style: Theme.of(context).caption.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                day,
                style: Theme.of(context).time.copyWith(fontSize: 26, height: 1),
              ),
              const SizedBox(height: 4),
              Text(
                monthDisplay,
                style: Theme.of(context)
                    .title
                    .copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
