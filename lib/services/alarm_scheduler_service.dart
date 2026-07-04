import 'package:adhan_dart/adhan_dart.dart';
import 'package:alarm/managers/prayer_time_manager.dart';
import 'package:alarm/services/daily_once.dart';
import 'package:alarm/services/prayer_calculation_settings.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// const List<int> _prayerEventAlarmIds = [
//   101,
//   102,
//   103,
//   104,
//   105,
//   106,
//   107,
//   108,
//   501,
//   502,
//   503,
//   504,
//   505,
//   506,
//   507,
//   508,
// ];

Future<void> initializeDebugNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,
  );
}

Future<void> showDebugNotification(int id, String title, String body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'alarm_debug_channel',
    'Alarm Debug',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: true,
    playSound: false,
    autoCancel: true,
    enableVibration: false,
    timeoutAfter: 4*60000,
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    id: id,
    title: title,
    body: body,
    notificationDetails: platformChannelSpecifics,
  );
}

String _resolveDisplayTitle({
  required DateTime now,
  required DateTime fajr,
  required DateTime sunrise,
  required DateTime dhuhr,
  required DateTime asr,
  required DateTime maghrib,
  required DateTime isha,
  required DateTime nextFajr,
}) {
  final sunriseEnd = sunrise.add(const Duration(minutes: 20));
  final zawalStart = dhuhr.subtract(const Duration(minutes: 15));

  if (now.isBefore(fajr)) return 'Next: Fajr';
  if (now.isBefore(sunrise)) return 'Fajr Ends';
  if (now.isBefore(sunriseEnd)) return 'Forbidden Time';
  if (now.isBefore(zawalStart)) return 'Next: Dhuhr';
  if (now.isBefore(dhuhr)) return 'Forbidden';
  if (now.isBefore(asr)) return 'Dhuhr Ends';
  if (now.isBefore(maghrib)) return 'Asr Ends';
  if (now.isBefore(isha)) return 'Maghrib Ends';
  if (now.isBefore(nextFajr)) return 'Isha Ends';
  return 'Next: Fajr';
}

Future<void> _syncWidgetForPrayerTimes({
  required DateTime now,
  required DateTime fajr,
  required DateTime sunrise,
  required DateTime dhuhr,
  required DateTime asr,
  required DateTime maghrib,
  required DateTime isha,
  required DateTime nextFajr,
}) async {
  final displayTitle = _resolveDisplayTitle(
    now: now,
    fajr: fajr,
    sunrise: sunrise,
    dhuhr: dhuhr,
    asr: asr,
    maghrib: maghrib,
    isha: isha,
    nextFajr: nextFajr,
  );

  await PrayerTimeManager.sendDataToHomeScreenWidget(
    currentTitle: displayTitle,
    fajr: fajr,
    sunrise: sunrise,
    dhuhr: dhuhr,
    asr: asr,
    maghrib: maghrib,
    isha: isha,
    nextFajr: nextFajr,
  );
}

@pragma('vm:entry-point')
void prayerEventDispatcher(int id) async {
  print('[AlarmManager] Target Time Reached! Updating Widget. Event ID: $id');
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  await initializeDebugNotifications();
  await initializeDateFormatting('bn', null);
  await initializeDateFormatting('en', null);

  final prefs = await SharedPreferences.getInstance();
  final notify = prefs.getBool('is_notification_on') ?? true;
  if (notify) {
    await showDebugNotification(997, 'Widgets Updating', 'Updating');
  }

  await shouldRunLocationUpdate();
  double lat =  prefs.getDouble('lat') ?? 24.3745;
  double lng =  prefs.getDouble('lng') ?? 88.6042;

  // try {
  //   bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
  //   LocationPermission permission = await Geolocator.checkPermission();
  //   if (isLocationServiceEnabled &&
  //       (permission == LocationPermission.always ||
  //           permission == LocationPermission.whileInUse)) {
  //     Position? position = await Geolocator.getLastKnownPosition();
  //     if (position != null) {
  //       lat = position.latitude;
  //       lng = position.longitude;
  //     }
  //   }
  // } catch (e) {
  //   print('Geolocator Error in Dispatcher: $e');
  // }

  final coords = Coordinates(lat, lng);
  final params = await getSavedPrayerCalculationParameters();
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

  String displayTitle = '';
  if (now.isAfter(fajr) && now.isBefore(sunriseEnd)) {
    displayTitle = 'Forbidden Time';
  } else if (now.isAfter(zawalStart) && now.isBefore(dhuhr)) {
    displayTitle = 'Forbidden';
  } else if (now.isAfter(fajr) && now.isBefore(sunrise)) {
    displayTitle = 'Fajr Ends';
  } else if (now.isAfter(sunrise) && now.isBefore(dhuhr)) {
    displayTitle = 'Next: Dhuhr';
  } else if (now.isAfter(dhuhr) && now.isBefore(asr)) {
    displayTitle = 'Dhuhr Ends';
  } else if (now.isAfter(asr) && now.isBefore(maghrib)) {
    displayTitle = 'Asr Ends';
  } else if (now.isAfter(maghrib) && now.isBefore(isha)) {
    displayTitle = 'Maghrib Ends';
  } else if (now.isAfter(isha) && now.isBefore(nextFajr)) {
    displayTitle = 'Isha Ends';
  } else {
    displayTitle = 'Next: Fajr';
  }

  // int nextPrayerMillis;
  // if (displayTitle == 'Forbidden Time') {
  //   nextPrayerMillis = sunriseEnd.millisecondsSinceEpoch;
  // } else if (displayTitle == 'Forbidden') {
  //   nextPrayerMillis = dhuhr.millisecondsSinceEpoch;
  // } else if (displayTitle == 'Fajr Ends') {
  //   nextPrayerMillis = sunrise.millisecondsSinceEpoch;
  // } else if (displayTitle == 'Next: Dhuhr') {
  //   nextPrayerMillis = dhuhr.millisecondsSinceEpoch;
  // } else if (displayTitle == 'Dhuhr Ends') {
  //   nextPrayerMillis = asr.millisecondsSinceEpoch;
  // } else if (displayTitle == 'Asr Ends') {
  //   nextPrayerMillis = maghrib.millisecondsSinceEpoch;
  // } else if (displayTitle == 'Maghrib Ends') {
  //   nextPrayerMillis = isha.millisecondsSinceEpoch;
  // } else if (displayTitle == 'Isha Ends') {
  //   nextPrayerMillis = nextFajr.millisecondsSinceEpoch;
  // } else {
  //   nextPrayerMillis = fajr.millisecondsSinceEpoch;
  // }


  await PrayerTimeManager.sendDataToHomeScreenWidget(
    currentTitle: displayTitle,
    fajr: fajr,
    sunrise: sunrise,
    dhuhr: dhuhr,
    asr: asr,
    maghrib: maghrib,
    isha: isha,
    nextFajr: nextFajr,
  );
}

@pragma('vm:entry-point')
void dailySchedulerDispatcher() async {
  print('[AlarmManager] Daily Scheduler Triggered! Setting up alarms...');
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  await initializeDebugNotifications();

  final prefs = await SharedPreferences.getInstance();
  final notify = prefs.getBool('is_notification_on') ?? true;
  if (notify) {
    await showDebugNotification(993, 'Updating daily', 'widgets');
  }
  print('[AlarmManager] Daily Scheduler Triggered! Setting up alarms...');

  await initializeDateFormatting('bn', null);
  await initializeDateFormatting('en', null);

  await shouldRunLocationUpdate();
  double lat =  prefs.getDouble('lat') ?? 24.3745;
  double lng =  prefs.getDouble('lng') ?? 88.6042;

  // try {
  //   bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
  //   LocationPermission permission = await Geolocator.checkPermission();
  //   if (isLocationServiceEnabled &&
  //       (permission == LocationPermission.always ||
  //           permission == LocationPermission.whileInUse)) {
  //     Position? position = await Geolocator.getLastKnownPosition();
  //     position ??= await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.low,
  //       timeLimit: const Duration(seconds: 5),
  //     );
  //     lat = position.latitude;
  //     lng = position.longitude;
  //   }
  // } catch (e) {
  //   print('Geolocator Error in Scheduler: $e');
  // }

  final coords = Coordinates(lat, lng);
  final params = await getSavedPrayerCalculationParameters();
  final now = DateTime.now();

  final ptToday = PrayerTimes(
    coordinates: coords,
    date: now,
    calculationParameters: params,
    precision: true,
  );
  final ptTomorrow = PrayerTimes(
    coordinates: coords,
    date: now.add(const Duration(days: 1)),
    calculationParameters: params,
    precision: true,
  );

  final fajr = ptToday.fajr.toLocal();
  final sunrise = ptToday.sunrise.toLocal();
  final dhuhr = ptToday.dhuhr.toLocal();
  final asr = ptToday.asr.toLocal();
  final maghrib = ptToday.maghrib.toLocal();
  final isha = ptToday.isha.toLocal();
  final nextFajr = ptTomorrow.fajr.toLocal();

  await _syncWidgetForPrayerTimes(
    now: now,
    fajr: fajr,
    sunrise: sunrise,
    dhuhr: dhuhr,
    asr: asr,
    maghrib: maghrib,
    isha: isha,
    nextFajr: nextFajr,
  );

  Map<int, DateTime> dailyEvents = {
    101: fajr,
    102: sunrise,
    103: sunrise.add(const Duration(minutes: 20)),
    104: dhuhr.subtract(const Duration(minutes: 15)),
    105: dhuhr,
    106: asr,
    107: maghrib,
    108: isha,
    501: ptTomorrow.fajr.toLocal(),
    502: ptTomorrow.sunrise.toLocal(),
    503: ptTomorrow.sunrise.toLocal().add(const Duration(minutes: 20)),
    504: ptTomorrow.dhuhr.toLocal().subtract(const Duration(minutes: 15)),
    505: ptTomorrow.dhuhr.toLocal(),
    506: ptTomorrow.asr.toLocal(),
    507: ptTomorrow.maghrib.toLocal(),
    508: ptTomorrow.isha.toLocal(),
  };

  

  var scheduledCount = 0;

  for (var entry in dailyEvents.entries) {
    final alarmId = entry.key;
    final targetTime = entry.value;
    final firstUpdateTime = targetTime.add(const Duration(seconds: 3));
final secondUpdateTime = targetTime.add(const Duration(minutes: 5));


    if (targetTime.isAfter(now)) {
      print('Scheduling Alarm ID: $alarmId at $firstUpdateTime');
      await AndroidAlarmManager.cancel(alarmId);
      bool ok = await AndroidAlarmManager.oneShotAt(
        firstUpdateTime,
        alarmId,
        prayerEventDispatcher,
        exact: true,
        wakeup: true,
        allowWhileIdle: true,
        alarmClock: true,
        rescheduleOnReboot: true,
      );
    await AndroidAlarmManager.cancel(alarmId+ 1000);
     await AndroidAlarmManager.oneShotAt(
        secondUpdateTime,
        (alarmId+ 1000),
        prayerEventDispatcher,
        exact: true,
        wakeup: true,
        allowWhileIdle: true,
        alarmClock: true,
        rescheduleOnReboot: true,
      );
      print("Alarm scheduled = $ok");
      if (ok) {
        scheduledCount++;
      }
    }
  }

  if (scheduledCount > 0) {
    await markDailySchedulerSetToday();
  }

  final enabled = prefs.getBool('scheduler_enabled') ?? true;
  print('[AlarmManager] Scheduler Enabled: $enabled');
  if (enabled) {
    await scheduleNextRun();
  }
  print('[AlarmManager] All alarms scheduled successfully.');
}

Future<void> scheduleNextRun() async {
  const schedulerId = 1;

  await AndroidAlarmManager.cancel(schedulerId);

  final nextRun = _nextDailySchedulerTime();
  bool ok = await AndroidAlarmManager.oneShotAt(
    nextRun,
    schedulerId,
    dailySchedulerDispatcher,
    exact: true,
    wakeup: true,
    allowWhileIdle: true,
    alarmClock: true,
    rescheduleOnReboot: true,

  );
  print("Alarm scheduled = $ok");
}

DateTime _nextDailySchedulerTime() {
  final now = DateTime.now();
  var next = DateTime(now.year, now.month, now.day, 0, 5);

  if (!next.isAfter(now)) {
    next = next.add(const Duration(days: 1));
  }

  print("Next daily scheduler time: $next");
  return next;
}

DateTime getNextSchedulerTime() {
  final now = DateTime.now();

  var next = DateTime(
    now.year,
    now.month,
    now.day,
    now.hour,
    now.minute,
    now.second + 10,
  );

  if (!next.isAfter(now)) {
    next = next.add(const Duration(days: 1));
  }
  print("Next scheduler time: $next");
  return next;
}
