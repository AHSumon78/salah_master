// lib/screens/home_screen.dart
import 'dart:async';
import 'dart:ui';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:alarm/l10n/generated/app_localizations.dart';
import 'package:alarm/managers/manual_silent_grid_tile.dart';
import 'package:alarm/managers/widget_manager.dart';
import 'package:alarm/models/Alarm.dart';
import 'package:alarm/screens/commons/appBar_background.dart';
import 'package:alarm/screens/commons/app_background.dart';
import 'package:alarm/screens/commons/app_card.dart';
import 'package:alarm/screens/helper/app.dart';
import 'package:alarm/screens/utilities/about_page.dart';
import 'package:alarm/screens/utilities/help_screen.dart';
import 'package:alarm/screens/helper/card.dart';
import 'package:alarm/screens/helper/sun_moon_tracker.dart';
import 'package:alarm/screens/others_alarm/alarm_form_screen.dart';
import 'package:alarm/screens/utilities/settings_screen.dart';
import 'package:alarm/managers/HijriCalendarManager.dart';
import 'package:alarm/services/NativeDB.dart';
import 'package:alarm/managers/SoundManager.dart';
import 'package:alarm/services/alarm_permission_helper.dart';
import 'package:alarm/managers/allah_names_manager.dart';
import 'package:alarm/services/app_theme_extension.dart';
import 'package:alarm/managers/dua_manager.dart';
import 'package:alarm/managers/islamic_event_manager.dart';
import 'package:alarm/managers/prayer_time_manager.dart';
import 'package:alarm/services/alarm_scheduler_service.dart';
import 'package:alarm/services/daily_once.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:alarm/models/AppSettings.dart';
import 'package:alarm/models/Location.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alarm/services/prayer_calculation_settings.dart';

// ---------------------------------------------------------------------------
// Isolated alarm card — RepaintBoundary prevents neighbour repaints
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// HomeScreen
// ---------------------------------------------------------------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  List<Alarm> _alarms = [];
  List<Location> _locations = [];
  Location? _currentLocation;
  late AppSettings _appSettings;
  // ডিফল্ট ১০ মিনিট সিলেক্ট থাকবে
  Timer? _countdownTimer;

  bool _isLoadingAlarms = true;
  int _visibleCount = 0;

  // Cached sun/moon data — recomputed only when location changes
  SunMoonData? sunMoonData;

  final TextEditingController _preAlarmController = TextEditingController();
  late final AlarmPermissionHelper _permissionHelper;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _permissionHelper = AlarmPermissionHelper(context);

    // প্রথম লঞ্চে পারমিশন চাওয়ার জন্য একটু দেরি করে কল করো
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAppDataOnStartup();
    });
    // টেস্ট করার জন্য ডামি ডাটা দিয়ে কল করা হলো:
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _preAlarmController.dispose();
    _countdownTimer?.cancel();
    SoundManager.dispose();
    super.dispose();
  }

  // ---- Initialization -------------------------------------------------------

  Future<void> _initializeAppDataOnStartup() async {
    debugPrint('[HomeScreen] Starting initialization.');
    if (kIsWeb) {
      _loadWebPreviewSunMoonTracker();
      return;
    }

    await _initializeWidgetScheduler();
    await _permissionHelper.requestPermissionsOnFirstLaunch();
    if (await _permissionHelper.areAllPermissionsGranted()) {
      _startAlarmAndService();
    }
    await _loadAppSettingsAndSetCurrentLocation();
    IslamicEventManager.initAndCalculateCountdown();
    if (!context.mounted) return;
    if (_currentLocation != null) {
      _recomputeSunMoon();
      PrayerTimeManager.startSmartPrayerTimer(
          context: context, location: _currentLocation);

      await _loadAlarmsForCurrentLocation();
      if (!context.mounted) return;
    } else {
      PrayerTimeManager.startSmartPrayerTimer(context: context, location: null);
    }

    if (mounted) setState(() {});
  }

  Future<void> _initializeWidgetScheduler() async {
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    if (!isAndroid) return;

    if (!await shouldRunToday()) {
      print("Widget scheduler already set today.");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('is_notification_on')) {
      await prefs.setBool('is_notification_on', true);
    }
    if (!prefs.containsKey('scheduler_enabled')) {
      await prefs.setBool('scheduler_enabled', true);
    }
    final enabled = prefs.getBool('scheduler_enabled') ?? true;

    if (!enabled) return;
    final ok = await AndroidAlarmManager.oneShotAt(
      getNextSchedulerTime(),
      1,
      dailySchedulerDispatcher,
      exact: true,
      wakeup: true,
      allowWhileIdle: true,
      rescheduleOnReboot: true,
      alarmClock: true,
    );
    print("Widget scheduler set = $ok");
  }

  void _loadWebPreviewSunMoonTracker() {
    if (!mounted) return;

    setState(() {
      _currentLocation = Location(
        name: 'Web Preview',
        latitude: 24.3745,
        longitude: 88.6042,
      );
      _preAlarmController.text = '0';
      _recomputeSunMoon();
      _isLoadingAlarms = false;
    });
  }

  void _recomputeSunMoon() {
    if (_currentLocation == null) return;
    sunMoonData = SunMoonData.compute(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _checkPermissionsAndDismissDialog();

      // অ্যাপ সামনে আসলেই অ্যানিমেশন ট্রিগার করার জন্য ডেটা রিফ্রেশ

      if (mounted) {
        setState(() {
          _recomputeSunMoon();
        });
      }
    }
  }

  // ---- Permissions ----------------------------------------------------------

  Future<void> _checkPermissionsAndDismissDialog() async {
    if (await _permissionHelper.areAllPermissionsGranted()) {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      _startAlarmAndService();
    }
  }

  void _startAlarmAndService() async {
    const svcChannel = MethodChannel('com.butterflydevs.salahmaster/channel');
    try {
      debugPrint('[HomeScreen] Calling native method: startAlarmAndService');
      final String result =
          await svcChannel.invokeMethod('startAlarmAndService');
      debugPrint('Native Response: $result');
    } on PlatformException catch (e) {
      debugPrint('Failed to start service and alarm: ${e.message}');
    } catch (e) {
      debugPrint('Unknown error: $e');
    }
  }

  // ---- Data loading ---------------------------------------------------------

  Future<void> _loadAppSettingsAndSetCurrentLocation() async {
    _locations = await NativeDB.getLocations();
    if (_locations.isEmpty) {
      debugPrint('[HomeScreen] No locations found yet.');
      if (kIsWeb && mounted) {
        setState(() {
          _currentLocation = Location(
            name: 'Web Preview',
            latitude: 24.3745,
            longitude: 88.6042,
          );
          _preAlarmController.text = '0';
        });
      }
      return;
    }
    _appSettings = await NativeDB.getAppSettings();
    final found = _locations.firstWhere(
      (l) => l.id == _appSettings.currentLocationId,
      orElse: () => _locations.first,
    );
    if (mounted) {
      setState(() {
        _currentLocation = found;
        _preAlarmController.text =
            _currentLocation?.preAlarmMinutes.toString() ?? '0';
      });
    }
  }

  Future<void> _loadAlarmsForCurrentLocation() async {
    if (_currentLocation == null || _currentLocation!.id == null) {
      if (mounted) setState(() => _alarms = []);
      return;
    }
    await _loadAlarms(_currentLocation!);
  }

  Future<void> _onLocationChanged(Location? newLocation) async {
    if (newLocation == null || newLocation.id == _currentLocation?.id) return;

    _appSettings = await NativeDB.getAppSettings();
    if (mounted) {
      setState(() {
        _currentLocation = newLocation;
        _preAlarmController.text = newLocation.preAlarmMinutes.toString();
      });
    }
    await NativeDB.updateLocationSwitch(newLocation.id!);
    await _loadAlarms(newLocation);
  }

  Future<void> updateSetting(Location location) async {
    _appSettings.currentLocation = location.name;
    _appSettings.currentLocationId = location.id!;
    await NativeDB.updateSettings(
      locationId: _appSettings.currentLocationId,
      location: _appSettings.currentLocation,
      enable: _appSettings.enable,
    );
  }

  /// FIX: Only call setState twice (start + end), not once per alarm.
  /// The stagger animation uses a single _visibleCount ticker approach but
  /// batches updates to avoid per-item full-tree rebuilds.
  Future<void> _loadAlarms(Location location) async {
    if (mounted) {
      setState(() {
        _isLoadingAlarms = true;
        _visibleCount = 0;
      });
    }

    // ১. ডেটাবেজ থেকে সব অ্যালার্ম নিয়ে আসা
    final results = await Future.wait([
      NativeDB.getAlarms(location.id!),
      Future.delayed(const Duration(milliseconds: 100)),
    ]);

    List<Alarm> allAlarms = results[0] as List<Alarm>;

    // ২. আলাদা ফাংশনটি কল করে ইনঅ্যাক্টিভ অ্যালার্মগুলো ব্যাকগ্রাউন্ডে আপডেট করা
    if (allAlarms.isNotEmpty) {
      bool isUpdated =
          await _syncInactiveAlarmsWithPrayerTimes(location, allAlarms);
      // যদি কোনো অ্যালার্ম আপডেট হয়ে থাকে, তবে ডেটাবেজ থেকে ফ্রেশ লিস্ট আবার রিড করব
      if (isUpdated) {
        allAlarms = await NativeDB.getAlarms(location.id!);
      }
    }

    // ৩. UI স্টেট আপডেট করা
    if (mounted) {
      setState(() {
        _alarms = allAlarms;
        _isLoadingAlarms = false;
      });
    }

    // ৪. অ্যানিমেশন স্ট্যাগার লুপ
    for (int i = 1; i <= allAlarms.length; i++) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 70));
      if (mounted) setState(() => _visibleCount = i);
    }
    await NativeDB.rescheduleAllSilentTimes();
  }

  Future<bool> _syncInactiveAlarmsWithPrayerTimes(
      Location location, List<Alarm> alarmList) async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getString('is_first_time_sync') ?? 'true';
    if (isFirstTime == 'true') {
      await prefs.setString('is_first_time_sync', 'false');
      // প্রথমবারের জন্য কোনো আপডেট করা হবে না

      final now = DateTime.now();
      final coords = Coordinates(location.latitude, location.longitude);

      // 🔥 নতুন সেটিংস থেকে Madhab + Calculation Method নেওয়া হচ্ছে
      final params = await getSavedPrayerCalculationParameters();

      // adhan_dart দিয়ে আজকের নামাজের সময় ক্যালকুলেট করা
      final pt = PrayerTimes(
        coordinates: coords,
        date: now,
        calculationParameters: params,
        precision: true,
      );

      bool hasAnyChange = false;

      for (var alarm in alarmList) {
        if (!alarm.isActive) {
          DateTime? prayerDateTime;

          switch (alarm.title?.toLowerCase()) {
            case 'fajr':
              prayerDateTime = pt.fajr.toLocal();
              break;
            case 'sunrise':
              prayerDateTime = pt.sunrise.toLocal();
              break;
            case 'dhuhr':
              prayerDateTime = pt.dhuhr.toLocal();
              break;
            case 'asr':
              prayerDateTime = pt.asr.toLocal();
              break;
            case 'maghrib':
              prayerDateTime = pt.maghrib.toLocal();
              break;
            case 'isha':
              prayerDateTime = pt.isha.toLocal();
              break;
          }

          if (prayerDateTime != null) {
            if (alarm.alarmTime.hour != prayerDateTime.hour ||
                alarm.alarmTime.minute != prayerDateTime.minute) {
              alarm.alarmTime = TimeOfDay(
                hour: prayerDateTime.hour,
                minute: prayerDateTime.minute,
              );

              await NativeDB.updateAlarm(alarm);
              hasAnyChange = true;
            }
          }
        }
      }

      return hasAnyChange;
    }
    return false;
  }

  // ---- Pre-alarm setting ----------------------------------------------------

  Future<void> _saveCurrentLocationPreAlarmSetting(String textValue) async {
    if (_currentLocation == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Please select a location before setting pre-alarm.')),
        );
      }
      _preAlarmController.text = '0';
      return;
    }
    final newValue = int.tryParse(textValue);
    if (newValue == null || newValue < 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Please enter a valid positive number for pre-alarm minutes.')),
        );
      }
      _preAlarmController.text = _currentLocation!.preAlarmMinutes.toString();
      return;
    }
    final currentLocation = _currentLocation;
    if (currentLocation == null || currentLocation.id == null) {
      debugPrint('[HomeScreen] Location or Location ID is null.');
      return;
    }
    currentLocation.preAlarmMinutes = newValue;
    await NativeDB.updateLocation(currentLocation);
    await NativeDB.updateLocationSwitch(currentLocation.id!);
    if (mounted) setState(() {});
  }

  // ---- Alarm interactions ---------------------------------------------------

  Future<void> _selectTime(BuildContext context, Alarm alarm) async {
    final Alarm? updated = await showModalBottomSheet<Alarm>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.75,
        child: AlarmFormScreen(initialAlarm: alarm, isQuickEdit: true),
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        alarm.alarmTime = updated.alarmTime;
        alarm.title = updated.title;
        alarm.sound = updated.sound;
        alarm.isDaily = updated.isDaily;
        alarm.isActive = updated.isActive;
        alarm.daysMask = updated.daysMask;
      });
      await NativeDB.updateAlarm(alarm);
    }
  }

  Future<void> _selectSound(BuildContext context, Alarm alarm) async {
    final selected = await SoundManager.selectSound(context);
    if (selected != null && selected != alarm.sound && mounted) {
      setState(() => alarm.sound = selected);
      await NativeDB.updateAlarm(alarm);
    }
  }

  Future<void> _onToggleAlarm(Alarm alarm, bool newValue) async {
    setState(() => alarm.isActive = newValue);
    await NativeDB.updateAlarm(alarm);
  }

  // ---- Build ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBarCommon(
        title: ' ',
        actions: [
          const SizedBox(width: 20),
          if (_currentLocation != null && _locations.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Color.lerp(Theme.of(context).appBarColor,
                        Theme.of(context).iconColor, 0.1)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Location>(
                    value: _currentLocation,
                    icon: Icon(Icons.location_on,
                        color: Theme.of(context).iconColor),
                    onChanged: _onLocationChanged,
                    // Ensure the text color is readable against your gradient
                    dropdownColor: Theme.of(context).appBarColor,
                    items: _locations.map((loc) {
                      return DropdownMenuItem<Location>(
                        value: loc,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            loc.name,
                            style: Theme.of(context).title, // Standard style
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
      drawer: Drawer(
        // Drawer-এর ভেতর থেকে অতিরিক্ত প্যাডিং সরানোর জন্য Container বা Column ব্যবহার করা ভালো
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent, // স্বচ্ছ স্ট্যাটাস বার
            statusBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
          ),
          child: AppBackground(
            child: SafeArea(
              top: true, // এটি স্ট্যাটাস বারের ওপরের ডিফল্ট প্যাডিং সরিয়ে দেয়
              child: Material(
                // 👈 Add this widget here
                type: MaterialType.transparency,
                child: ListView(
                  padding: EdgeInsets
                      .zero, // নিশ্চিত করুন লিস্টভিউ একদম জিরো থেকে শুরু হচ্ছে
                  children: [
                    DrawerHeader(
                      margin: EdgeInsets
                          .zero, // হেডারের নিচের ডিফল্ট মার্জিন জিরো করুন
                      padding: const EdgeInsets.fromLTRB(16, 40, 16,
                          8), // ওপরের প্যাডিং বাড়িয়ে দিন যাতে আইকন নিচে থাকে
                      decoration: BoxDecoration(
                        color: Theme.of(context).appBarColor,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.mosque,
                              size: 40, color: Theme.of(context).iconColor),
                          const SizedBox(height: 10),
                          Text(App.appName(),
                              style: Theme.of(context)
                                  .title
                                  .copyWith(fontSize: 25)),
                        ],
                      ),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.settings,
                        color: Theme.of(context).iconColor,
                      ),
                      title: Text(
                        lang.settings,
                        style: Theme.of(context).title,
                      ),
                      onTap: () {
                        // Navigator.pop(context); // ড্রয়ার বন্ধ হবে

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SettingsScreen()),
                        ); //.then((_) {
                        // // ফিরে এসে আবার ড্রয়ার খুলে দাও
                        //                   if (context.mounted) {
                        //                     Future.delayed(const Duration(milliseconds: 200), () {
                        //                       Scaffold.of(context).openDrawer();
                        //                     });
                        //                   }});
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.widgets_outlined,
                        color: Theme.of(context).iconColor,
                      ),
                      title: Text(
                        lang.addHomeScreenWidget, // বা সরাসরি "Add Home Screen Widget"
                        style: Theme.of(context).title,
                      ),
                      subtitle: Text(
                        lang.addHomeScreenWidgetDescription, // Optional
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      onTap: () async {
                        Navigator.pop(context);

                        final ok = await WidgetManager.addWidget();

                        if (!context.mounted) return;

                        if (!ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(
                              content: Text(
                                "Your device doesn't support adding widgets directly. "
                                "Please add it from the Home Screen widget picker.",
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.help_outline,
                        color: Theme.of(context).iconColor,
                      ),
                      title: Text(lang.help, style: Theme.of(context).title),
                      onTap: () {
                        // Navigator.pop(context); // ড্রয়ার বন্ধ হবে

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => HelpScreen()),
                        ); //.then((_) {
                        // // ফিরে এসে আবার ড্রয়ার খুলে দাও
                        //                   if (context.mounted) {
                        //                     Future.delayed(const Duration(milliseconds: 200), () {
                        //                       Scaffold.of(context).openDrawer();
                        //                     });
                        //                   }});
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.help_outline,
                        color: Theme.of(context).iconColor,
                      ),
                      title: Text(lang.about, style: Theme.of(context).title),
                      onTap: () {
                        //Navigator.pop(context); // ড্রয়ার বন্ধ হবে

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AboutPage()),
                        ); //.then((_) {
                        // // ফিরে এসে আবার ড্রয়ার খুলে দাও
                        //                   if (context.mounted) {
                        //                     Future.delayed(const Duration(milliseconds: 200), () {
                        //                       Scaffold.of(context).openDrawer();
                        //                     });
                        //                   }});
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: AppBackground(
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            // 1. Sun/Moon Tracker — isolated widget, animates without touching list
            SliverToBoxAdapter(
              child: sunMoonData == null
                  ? const Center(
                      // 👈 এই Center উইজেটটি পুরো স্ক্রিনে ছড়ানো বন্ধ করবে এবং মাঝখানে আনবে
                      child: SizedBox(
                        height: 100,
                        width: 100,
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : SunMoonTracker(data: sunMoonData!),
            ),
            SliverToBoxAdapter(
                child: GridView.count(
              crossAxisCount: 3, // ২ কলামের সমান চারকোনা বক্স গ্রিড
              crossAxisSpacing: 1,
              mainAxisSpacing: 1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                const ManualSilentGridTile(),
                PrayerTimeManager.buildNextPrayerGridTile(),
                const HijriCalendarTile(),
                AllahNamesManager.buildAllahNamesGridTile(context),
                DuaManager.buildDuaGridTile(context),
                IslamicEventManager.buildCountdownGridTile(context),
              ],
            )),

            // 2. Pre-alarm card
            SliverToBoxAdapter(
              child: AppCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '${lang.ringPrayer} ',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 🛠️ এখানে ক্লিক করলে টাইম স্ক্রোলার বটমশীট ওপেন হবে
                          InkWell(
                            onTap: () => _showMinuteScroller(context),
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                    color: Colors.teal.shade100, width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.teal.shade100
                                        .withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.alarm,
                                      size: 16, color: Colors.teal),
                                  const SizedBox(width: 6),
                                  Text(
                                    // কারেন্ট ভ্যালু দেখাবে (ডিফল্ট ০ বা ৫)
                                    int.tryParse(_preAlarmController.text)
                                            ?.toString() ??
                                        '0',
                                    style: const TextStyle(
                                        color: Colors.teal,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(Icons.arrow_drop_down,
                                      color: Colors.teal, size: 16),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${lang.min} ${lang.before}',
                            style:const TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Alarm list
            if (_currentLocation == null)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.teal),
                      SizedBox(height: 16),
                      Text(
                        'Loading locations and alarms...',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else if (_isLoadingAlarms)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, __) => const SkeletonCard(),
                    childCount: 6,
                  ),
                ),
              )
            else if (_alarms.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.alarm_off,
                            size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No prayer alarms set for '
                          '${_currentLocation!.name} yet.'
                          ' Default prayer times will appear here.',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.only(
                    left: 0, right: 0, top: 0, bottom: 100.0),
                sliver: SliverList(
                  // FIX: childCount = _visibleCount so Flutter never builds
                  // invisible items at all (no SizedBox.shrink waste).
                  delegate: SliverChildBuilderDelegate(
                    (_, index) {
                      final alarm = _alarms[index];
                      return AlarmCard(
                        key: ValueKey(
                            alarm.id), // stable key prevents re-creation
                        alarm: alarm,
                        onTapTime: () => _selectTime(context, alarm),
                        onTapSound: () => _selectSound(context, alarm),
                        onToggle: (v) => _onToggleAlarm(alarm, v),
                      );
                    },
                    childCount: _visibleCount.clamp(0, _alarms.length),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showMinuteScroller(BuildContext context) {
    int currentValue = int.tryParse(_preAlarmController.text) ?? 0;
    if (currentValue < 0 || currentValue > 30) currentValue = 0;

    final FixedExtentScrollController scrollController =
        FixedExtentScrollController(initialItem: currentValue);

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        // 🛠️ StatefulBuilder ব্যবহার করে বটমশীটের ভেতরের স্টেট (Selected Index) ডাইনামিকালি চেঞ্জ করা হবে
        final lang = AppLocalizations.of(context)!;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SizedBox(
              height: 280,
              child: Column(
                children: [
                  // 🔝 হেডার সেকশন
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${lang.ringPrayer} $currentValue ${currentValue <= 1 ? lang.minute : lang.minutes} ${lang.before}',
                          style: Theme.of(context).title,
                        ),
                        TextButton(
                          onPressed: () {
                            final selectedValue = scrollController.selectedItem;
                            setState(() {
                              _preAlarmController.text =
                                  selectedValue.toString();
                            });
                            _saveCurrentLocationPreAlarmSetting(
                                selectedValue.toString());
                            Navigator.pop(context);
                          },
                          child: Text(
                            lang.save,
                            style: TextStyle(
                                color: Theme.of(context).iconColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: Theme.of(context).iconColor,
                  ),

                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 44,
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.symmetric(
                              horizontal: BorderSide(
                                  color: Colors.teal.withOpacity(0.2),
                                  width: 1),
                            ),
                          ),
                        ),

                        // 🎡 লিস্ট হুইল উইজেট
                        ListWheelScrollView.useDelegate(
                          controller: scrollController,
                          itemExtent:
                              42, // কন্টেইনার হাইটের সাথে সামঞ্জস্য রেখে ৪২ করা হয়েছে
                          perspective: 0.004, // হালকা ও স্মুথ ৩ডি কার্ভ ইফেক্ট
                          diameterRatio: 1.2,
                          physics: const FixedExtentScrollPhysics(),

                          // ⚡ স্ক্রোল করার সাথে সাথে মাঝখানের ইনডেক্স ট্র্যাক করবে
                          onSelectedItemChanged: (int index) {
                            setModalState(() {
                              currentValue =
                                  index; // সিলেক্টেড ভ্যালু আপডেট হবে
                            });
                          },

                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: 31,
                            builder: (context, index) {
                              // 💡 চেক করা হচ্ছে এই আইটেমটিই বর্তমানে সিলেক্টেড কিনা
                              final bool isSelected = (index == currentValue);

                              return AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 150),
                                style: TextStyle(
                                  fontSize: isSelected
                                      ? 21
                                      : 16, // সিলেক্টেড আইটেমটি আকারে বড় হবে
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors
                                          .teal // সিলেক্টেড আইটেম ডিপ টিল কালার
                                      : Colors.grey.shade500.withOpacity(
                                          0.7), // বাকিগুলো হালকা ফেইডেড গ্রে
                                ),
                                child: Center(
                                  child: Text('$index ${lang.min}'),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
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
}
