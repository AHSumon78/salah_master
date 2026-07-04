import 'dart:convert';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:alarm/services/daily_once.dart';
import 'package:alarm/services/prayer_calculation_settings.dart';
import 'package:alarm/services/app_theme_extension.dart'; // আপনার কাস্টম থিম এক্সটেনশন
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🕋 হিজরি ক্যালেন্ডারের এপিআই এবং বটমশিট লজিক ম্যানেজার ক্লাস
class HijriCalendarManager {
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

  static String cleanHijriMonth(String month) {
    return month
        .replaceAll('ū', 'u')
        .replaceAll('ī', 'i')
        .replaceAll('Ḥ', 'H')
        .replaceAll('ḥ', 'h')
        .replaceAll('ā', 'a')
        .replaceAll('Dhū al', 'Dhul')
        .replaceAll('al-', 'al ')
        .trim();
  }

  // 🔄 ১. ওল্ড মেথড (BuildContext সহ): অ্যাপের ভেতরে আগের মতোই কাজ করবে
  // 🔥 ১. এখন আর কোনো BuildContext লাগবে না। অ্যাপ এবং ব্যাকগ্রাউন্ড দুই জায়গা থেকেই এই একটি মেথড কল করলেই হবে।
  static Future<String> getHijriDate() async {
    try {
      // SharedPreferences থেকে ইউজারের সেভ করা ভাষা রিড করা (আপনার MyAppState এর সাথে মিল রেখে 'app_language_code')
      final prefs = await SharedPreferences.getInstance();
      final String languageCode = prefs.getString('app_language_code') ?? 'en';

      // র-ডাটা নিয়ে আসা
      final data = await getHijriDateRaw();

      // ফরম্যাট করে রিটার্ন করা
      return getFormattedHijriDate(data, languageCode);
    } catch (e) {
      debugPrint("Error in getHijriDate: $e");
      return "---";
    }
  }

  // 🛠️ ২. ফরম্যাটিং মেথড (এটি আগের মতোই থাকবে, শুধু context এর জায়গায় languageCode নেয়)
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

  // 🔥 ২. নতুন ওভারলোডেড মেথড (BuildContext ছাড়া): যা ব্যাকগ্রাউন্ড থেকে কল করা যাবে
  static Future<String> getHijriDateFromBackground(String languageCode) async {
    final data = await getHijriDateRaw();
    return getFormattedHijriDate(data, languageCode);
  }

  static Future<Map<String, dynamic>> getHijriDateRaw() async {
    final prefs = await SharedPreferences.getInstance();
    final adjustment = prefs.getInt("hijri_adjustment") ?? -1;

    final data = await fetchAccurateHijriDate(
      adjustment: adjustment,
    );
    return data!;
  }
  static Future<Map<String, dynamic>?> fetchAccurateHijriDate({
  int adjustment = -1,
}) async {
  final prefs = await SharedPreferences.getInstance();

  DateTime referenceDate = DateTime.now();

  try {
    await shouldRunLocationUpdate();

    final double lat = prefs.getDouble('lat') ?? 24.3745;
    final double lng = prefs.getDouble('lng') ?? 88.6042;

    final coords = Coordinates(lat, lng);
    final params = await getSavedPrayerCalculationParameters();

    final pt = PrayerTimes(
      coordinates: coords,
      date: DateTime.now(),
      calculationParameters: params,
      precision: true,
    );

    final maghrib = pt.maghrib.toLocal();

    if (DateTime.now().isAfter(maghrib)) {
      referenceDate = referenceDate.add(const Duration(days: 1));
    }
  } catch (e) {
    debugPrint("Location/Maghrib calculation failed: $e");
  }

  referenceDate = referenceDate.add(Duration(days: adjustment));

  final cacheKey =
      DateFormat('yyyy-MM-dd').format(referenceDate) + "_$adjustment";

  final cachedKey = prefs.getString("cached_hijri_key");
  final cachedJson = prefs.getString("cached_hijri_data");

  // ==========================
  // Return cached data
  // ==========================
  if (cachedKey == cacheKey && cachedJson != null) {
    try {
      return Map<String, dynamic>.from(jsonDecode(cachedJson));
    } catch (_) {}
  }

  final today = DateFormat('dd-MM-yyyy').format(referenceDate);

  // ==========================
  // Online API
  // ==========================
  try {
    final url = Uri.parse("https://api.aladhan.com/v1/gToH/$today");

    final response =
        await http.get(url).timeout(const Duration(seconds: 7));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse['data']?['hijri'] != null) {
        final result = Map<String, dynamic>.from(
          jsonResponse['data']['hijri'],
        );

        await prefs.setString(
          "cached_hijri_key",
          cacheKey,
        );

        await prefs.setString(
          "cached_hijri_data",
          jsonEncode(result),
        );

        return result;
      }
    }
  } catch (e) {
    debugPrint("Online Hijri Fetch Failed: $e");
  }

  // ==========================
  // Offline fallback
  // ==========================
  HijriCalendar.setLocal('en');

  final localHijri = HijriCalendar.fromDate(referenceDate);

  final result = {
    'day': localHijri.hDay.toString(),
    'month': {
      'number': localHijri.hMonth,
      'en': localHijri.longMonthName,
      'ar': localHijri.longMonthName,
      'days': localHijri.lengthOfMonth,
    },
    'year': localHijri.hYear.toString(),
  };

  await prefs.setString(
    "cached_hijri_key",
    cacheKey,
  );

  await prefs.setString(
    "cached_hijri_data",
    jsonEncode(result),
  );

  return result;
}

  // static Future<Map<String, dynamic>?> fetchAccurateHijriDate({
  //   int adjustment = -1,
  // }) async {
  //   DateTime referenceDate = DateTime.now();
  //   try {
  //      final prefs = await SharedPreferences.getInstance();
  //     await shouldRunLocationUpdate();
  //     double lat =  prefs.getDouble('lat') ?? 24.3745;
  //     double lng =  prefs.getDouble('lng') ?? 88.6042;
  //     final coords = Coordinates(lat, lng);
  //     final params = await getSavedPrayerCalculationParameters();
  //     final pt = PrayerTimes(
  //       coordinates: coords,
  //       date: DateTime.now(),
  //       calculationParameters: params,
  //       precision: true,
  //     );
  //     final maghrib = pt.maghrib.toLocal();

  //     if (DateTime.now().isAfter(maghrib)) {
  //       referenceDate = referenceDate.add(const Duration(days: 1));
  //     }
  //   } catch (e) {
  //     debugPrint("Location/Maghrib calculation failed: $e");
  //   }

  //   referenceDate = referenceDate.add(Duration(days: adjustment));
  //   final today = DateFormat('dd-MM-yyyy').format(referenceDate);

  //   try {
  //     final url = Uri.parse('https://api.aladhan.com/v1/gToH/$today');
  //     final response = await http.get(url).timeout(const Duration(seconds: 7));
  //     if (response.statusCode == 200) {
  //       final jsonResponse = jsonDecode(response.body);
  //       if (jsonResponse['data']?['hijri'] != null) {
  //         return Map<String, dynamic>.from(
  //           jsonResponse['data']['hijri'],
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint("Online Hijri Fetch Failed: $e");
  //   }

  //   HijriCalendar.setLocal('en');
  //   final localHijri = HijriCalendar.fromDate(referenceDate);

  //   return {
  //     'day': localHijri.hDay.toString(),
  //     'month': {
  //       'number': localHijri.hMonth,
  //       'en': localHijri.longMonthName,
  //       'ar': localHijri.longMonthName,
  //       'days': localHijri.lengthOfMonth,
  //     },
  //     'year': localHijri.hYear.toString(),
  //   };
  // }

  // 🛠️ ৩. মডিফাইড ফরম্যাটিং মেথড: এখন আর BuildContext লাগে না, শুধু languageCode হলেই চলে!
  // static String getFormattedHijriDate(
  //     Map<String, dynamic>? hijriData, String languageCode) {
  //   if (hijriData == null) return "Loading...";

  //   final isBangla = languageCode == 'bn';

  //   String day = hijriData['day']?.toString() ?? '--';
  //   String year = hijriData['year']?.toString() ?? '----';

  //   final int monthNumber = hijriData['month']?['number'] as int? ?? 1;
  //   String monthName = hijriData['month']?['en']?.toString() ?? 'Month';

  //   if (isBangla) {
  //     day = toBanglaNumber(day);
  //     year = toBanglaNumber(year);
  //     monthName = _hijriMonthsBn[monthNumber] ?? monthName;

  //     return "$day\n$monthName, $year হিজরি";
  //   } else {
  //     monthName = cleanHijriMonth(monthName);
  //     return "$day\n$monthName, $year AH";
  //   }
  // }

  /// ফুল ক্যালেন্ডার দেখানোর জন্য প্রিমিয়াম বটমশিট মেথড
  static void showFullCalendarBottomSheet(
      BuildContext context, Map<String, dynamic> hijriData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).appBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        // 🌐 ১. অ্যাপের বর্তমান ভাষা চেক করা
        final isBangla = Localizations.localeOf(context).languageCode == 'bn';

        // ডাটা এক্সট্র্যাক্ট করা
        String monthEn = hijriData['month']['en']?.toString() ?? '';
        final monthAr = hijriData['month']['ar']?.toString() ?? '';
        final int monthNumber = hijriData['month']?['number'] as int? ?? 1;
        String year = hijriData['year']?.toString() ?? '';

        final currentDay =
            int.tryParse(hijriData['day']?.toString() ?? '1') ?? 1;
        final totalDays =
            int.tryParse(hijriData['month']['days']?.toString() ?? '30') ?? 30;

        // 🔄 ২. ভাষা অনুযায়ী হেডার ডাটা রূপান্তর
        if (isBangla) {
          year = "${toBanglaNumber(year)} হিজরি";
          monthEn = _hijriMonthsBn[monthNumber] ?? monthEn;
        } else {
          monthEn = cleanHijriMonth(monthEn);
          year = "$year AH";
        }

        // 🗓️ ৩. ভাষা অনুযায়ী সপ্তাহের বারের নাম সেট করা
        final List<String> weekDays = isBangla
            ? ['শনি', 'রবি', 'সোম', 'মঙ্গল', 'বুধ', 'বৃহ', 'শুক্র']
            : ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

        final DateTime phoneToday = DateTime.now();
        final DateTime baseGregorianDate =
            phoneToday.subtract(Duration(days: currentDay - 1));

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
                itemCount: totalDays,
                itemBuilder: (context, index) {
                  final dayNum = index + 1;
                  final bool isToday = dayNum == currentDay;

                  final correspondingGregDate =
                      baseGregorianDate.add(Duration(days: index));

                  // 🔢 ৪. গ্রিডের ভেতরের সংখ্যাগুলোকে ডাইনামিক করা
                  String displayDayNum = dayNum.toString();
                  String gregDayNumber = correspondingGregDate.day.toString();

                  if (isBangla) {
                    displayDayNum = toBanglaNumber(displayDayNum);
                    gregDayNumber = toBanglaNumber(gregDayNumber);
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: isToday
                          ? Colors.teal.withValues(alpha: 0.18)
                          : Theme.of(context).cardBackground,
                      border: Border.all(
                        color: isToday
                            ? Colors.tealAccent
                            : Colors.grey.withValues(alpha: 0.3),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          displayDayNum, // ← হিজরি তারিখ (বাংলা/ইংলিশ)
                          style: Theme.of(context).time.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          gregDayNumber, // ← ইংরেজি তারিখ (বাংলা/ইংলিশ)
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

// 📱 হোম স্ক্রিনে সরাসরি কল করার জন্য স্বাধীন উইজেট
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

    // 🌐 ১. অ্যাপের বর্তমান ভাষা চেক করা
    final isBangla = Localizations.localeOf(context).languageCode == 'bn';

    // ডাটা এক্সট্র্যাক্ট করা
    String day = _hijriDataCache!['day']?.toString() ?? '--';
    final int monthNumber = _hijriDataCache!['month']?['number'] as int? ?? 1;
    String monthDisplay =
        _hijriDataCache!['month']['en']?.toString() ?? 'Month';
    String year = _hijriDataCache!['year']?.toString() ?? '----';

    // 🔄 ২. ভাষা অনুযায়ী ডাটা রূপান্তর করার লজিক
    if (isBangla) {
      day = HijriCalendarManager.toBanglaNumber(day);
      year = HijriCalendarManager.toBanglaNumber(year);

      // বাংলা মাসের নামগুলোর ম্যাপ (আপনার ম্যানেজারের প্রাইভেট ম্যাপ থেকে সরাসরি নেওয়া)
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
        splashColor: Colors.teal.withValues(alpha: 0.15),
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
                    year, // ← ডাইনামিক হিজরি/AH বছর
                    style: Theme.of(context).caption.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                day, // ← ডাইনামিক বাংলা/ইংলিশ দিন
                style: Theme.of(context).time.copyWith(fontSize: 26, height: 1),
              ),
              const SizedBox(height: 4),
              Text(
                monthDisplay, // ← ডাইনামিক বাংলা/ইংলিশ মাস
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
