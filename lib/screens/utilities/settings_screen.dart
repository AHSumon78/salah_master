import 'package:alarm/app.dart';
import 'package:alarm/l10n/generated/app_localizations.dart';
import 'package:alarm/managers/islamic_event_manager.dart';
import 'package:alarm/managers/prayer_time_manager.dart';
import 'package:alarm/screens/commons/appBar_background.dart';
import 'package:alarm/screens/commons/app_background.dart';
import 'package:alarm/services/NativeDB.dart';
import 'package:alarm/services/alarm_permission_helper.dart';
import 'package:alarm/services/alarm_scheduler_service.dart';
import 'package:alarm/services/prayer_calculation_settings.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  bool _vibrationEnabled = true;
  bool _gradualVolume = false;
  bool _preAlarmReminder = false;

  // Permissions State
  bool _batteryGranted = false;
  bool _fullscreenGranted = false;
  bool _exactAlarmGranted = false;
  bool _dndGranted = false;
  bool _notificationGranted = false;
  bool _locationGranted = false;
  bool _audioGranted = false;

  bool _autoSilent = true;
  bool _autoSilentSchedule = false;
  int _snoozeTime = 3;
  int _snoozeDuration = 5;
  int _autoStopMinutes = 10;
  bool _widgetsUpdate = true;
  bool _schedulerEnabled = true;
  String _prayerCalculationMethod = 'muslim_world_league';
  String _prayerMadhab = 'hanafi';
  int _silentDuration = 30;

  late final AlarmPermissionHelper _permissionHelper;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _permissionHelper = AlarmPermissionHelper(context);
    _loadPermissionStatus();
    _loadSettings();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadPermissionStatus();
    }
  }

  // ================= LOAD SETTINGS =================
  Future<void> _loadSettings() async {
    final data = await NativeDB.getSettings();
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _vibrationEnabled = data["vibration"] ?? true;
      _gradualVolume = data["gradual_volume_increase"] ?? false;
      _snoozeTime = data["snooze_time"] ?? 3;
      _snoozeDuration = data["snooze_duration"] ?? 5;
      _autoStopMinutes = data["auto_stop_alarm"] ?? 10;
      _preAlarmReminder = data["pre_alarm_reminder"] ?? true;
      _autoSilent = data["auto_silent_location"] ?? true;
      _autoSilentSchedule = data["auto_silent_by_alarm"] ?? false;
      _widgetsUpdate = prefs.getBool('is_notification_on') ?? true;
      _schedulerEnabled = prefs.getBool('scheduler_enabled') ?? true;
      _prayerCalculationMethod =
          prefs.getString('prayer_calculation_method') ?? 'muslim_world_league';
      _prayerMadhab = prefs.getString('prayer_madhab') ?? 'hanafi';
       _silentDuration = prefs.getInt("silent_duration") ?? 30;
    });
  }

  // ================= SAVE SINGLE SETTING =================
  Future<void> _updateSetting(String key, dynamic value) async {
    await NativeDB.updateSetting(key, value);
    await _loadSettings(); // 🔥 AUTO RELOAD UI
  }

  Future<void> _saveSilentDuration(int value) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setInt("silent_duration", value);
  await _timeBaseSilent(); // Update silent times based on the new duration

  setState(() {
    _silentDuration = value;
  });
}

  // ================= LOAD PERMISSIONS =================
  Future<void> _loadPermissionStatus() async {
    _batteryGranted = await _permissionHelper.isBatteryOptimizationGranted();
    _fullscreenGranted = await _permissionHelper.isFullScreenGranted();
    _exactAlarmGranted = await _permissionHelper.isExactAlarmGranted();
    _dndGranted = await _permissionHelper.isDndGranted();
    _notificationGranted = await _permissionHelper.isNotificationGranted();
    _locationGranted = await _permissionHelper.isLocationGranted();
    _audioGranted = await _permissionHelper.isAudioPermissionGranted();

    if (mounted) setState(() {});
  }

  // ================= REQUEST PERMISSION & REFRESH =================
  Future<void> _requestPermissionAndRefresh(
      Future<void> Function() request) async {
    await request();
    await _loadPermissionStatus();
  }

  Future<void> _timeBaseSilent() async {
    if (_autoSilentSchedule) {
      await NativeDB.scheduleAllSilentTimes();
    } else {
      await NativeDB.cancelAllSilentTimes();
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBarCommon(title: lang.settings),
      body: AppBackground(
        child: Material(
          type: MaterialType.transparency,
          child: ListView(
            children: [
              // Theme Selector
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      lang.theme,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    StatefulBuilder(
                      builder: (context, setState) {
                        final myAppState =
                            context.findAncestorStateOfType<MyAppState>();

                        return DropdownButton<ThemeMode>(
                          value: myAppState?.themeMode ?? ThemeMode.system,
                          underline: const SizedBox(),
                          items: [
                            DropdownMenuItem(
                              value: ThemeMode.system,
                              child: Text(lang.system),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.light,
                              child: Text(lang.light),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.dark,
                              child: Text(lang.dark),
                            ),
                          ],
                          onChanged: (ThemeMode? newMode) {
                            if (newMode != null) {
                              myAppState?.setThemeMode(newMode);
                              setState(() {});
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Language Selector
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      lang.language,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    DropdownButton<String>(
                      value: Localizations.localeOf(context).languageCode,
                      underline: Container(),
                      icon:
                          const Icon(Icons.arrow_drop_down, color: Colors.teal),
                      onChanged: (String? newValue) async {
                        if (newValue != null) {
                          final myAppState =
                              context.findAncestorStateOfType<MyAppState>();
                          if (myAppState != null) {
                            myAppState.setLocale(Locale(newValue));
                          }
                        }
                        PrayerTimeManager.startSmartPrayerTimer(
                            context: context, location: null);
                        await IslamicEventManager.initAndCalculateCountdown();
                      },
                      items: const [
                        DropdownMenuItem<String>(
                          value: 'en',
                          child: Text(
                            'English',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        DropdownMenuItem<String>(
                          value: 'bn',
                          child: Text(
                            'বাংলা',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),

              // Alarm Behavior Section
              _buildSectionHeader(lang.alarmBehavior),
              SwitchListTile(
                title: Text(lang.vibration),
                value: _vibrationEnabled,
                onChanged: (val) async {
                  setState(() => _vibrationEnabled = val);
                  await _updateSetting("vibration", val);
                },
              ),
              SwitchListTile(
                title: Text(lang.gradualVolumeIncrease),
                value: _gradualVolume,
                onChanged: (val) async {
                  setState(() => _gradualVolume = val);
                  await _updateSetting("gradual_volume_increase", val);
                },
              ),
              ListTile(
                title: Text(lang.snoozeLimit),
                subtitle: Text("$_snoozeTime ${lang.times}"),
                trailing: DropdownButton<int>(
                  value: _snoozeTime,
                  items: [1, 2, 3, 4, 5]
                      .map((e) => DropdownMenuItem(
                          value: e, child: Text("$e ${lang.times}")))
                      .toList(),
                  onChanged: (val) async {
                    if (val == null) return;
                    setState(() => _snoozeTime = val);
                    await _updateSetting("snooze_time", val);
                  },
                ),
              ),
              ListTile(
                title: Text(lang.snoozeDuration),
                subtitle: Text("$_snoozeDuration ${lang.minutes}"),
                trailing: DropdownButton<int>(
                  value: _snoozeDuration,
                  items: [5, 10, 15, 20]
                      .map((e) => DropdownMenuItem(
                          value: e, child: Text("$e ${lang.min}")))
                      .toList(),
                  onChanged: (val) async {
                    if (val == null) return;
                    setState(() => _snoozeDuration = val);
                    await _updateSetting("snooze_duration", val);
                  },
                ),
              ),
              ListTile(
                title: Text(lang.autoStopAlarm),
                subtitle: Text("$_autoStopMinutes ${lang.minutes}"),
                trailing: DropdownButton<int>(
                  value: _autoStopMinutes,
                  items: [5, 10, 15, 20]
                      .map((e) => DropdownMenuItem(
                          value: e, child: Text("$e ${lang.min}")))
                      .toList(),
                  onChanged: (val) async {
                    if (val == null) return;
                    setState(() => _autoStopMinutes = val);
                    await _updateSetting("auto_stop_alarm", val);
                  },
                ),
              ),
              const Divider(),

              // Advanced Section
              _buildSectionHeader(lang.advanced),
              SwitchListTile(
                title: Text(lang.preAlarmReminder),
                value: _preAlarmReminder,
                onChanged: (val) async {
                  setState(() => _preAlarmReminder = val);
                  await _updateSetting("pre_alarm_reminder", val);
                },
              ),
              SwitchListTile(
                title: Text(lang.loactionBaseAutoSilent),
                subtitle: Text(lang.loactionBaseAutoSilentSubtitle),
                value: _autoSilent,
                onChanged: (val) async {
                  setState(() => _autoSilent = val);
                  await _updateSetting("auto_silent_location", val);
                },
              ),
              SwitchListTile(
                title: Text(lang.prayerTimeBaseAutoSilent),
                subtitle: Text(lang.prayerTimeBaseAutoSilentSubtitle),
                value: _autoSilentSchedule,
                onChanged: (val) async {
                  setState(() => _autoSilentSchedule = val);

                  await _updateSetting("auto_silent_by_alarm", val);
                  await _timeBaseSilent();
                },
              ),

              if (_autoSilentSchedule)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: DropdownButtonFormField<int>(
                    value: _silentDuration,
                    decoration: const InputDecoration(
                      labelText: "Silent Duration",
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 15,
                        child: Text("15 ${lang.minute}"),
                      ),
                      DropdownMenuItem(
                        value: 20,
                        child: Text("20 ${lang.minute}"),
                      ),
                      DropdownMenuItem(
                        value: 30,
                        child: Text("30 ${lang.minute}"),
                      ),
                      DropdownMenuItem(
                        value: 40,
                        child: Text("40 ${lang.minute}"),
                      ),
                    ],
                    onChanged: (value) async {
                      if (value == null) return;

                      await _saveSilentDuration(value);
                    },
                  ),
                ),
              SwitchListTile(
                title: Text(lang.widgetUpdate),
                value: _widgetsUpdate,
                onChanged: (val) async {
                  setState(() {
                    _widgetsUpdate = val;
                  });
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('is_notification_on', _widgetsUpdate);
                },
              ),
              SwitchListTile(
                title: const Text('Widget scheduler'),
                subtitle: const Text('Auto update home screen widget'),
                value: _schedulerEnabled,
                onChanged: (val) async {
                  setState(() => _schedulerEnabled = val);
                  if (val) {
                    await enableScheduler();
                  } else {
                    await disableScheduler();
                  }
                },
              ),
              // Prayer Madhab
              ListTile(
                title: const Text("Madhab"),
                subtitle: Text(prayerMadhabLabel(_prayerMadhab)),
                trailing: DropdownButton<String>(
                  value: _prayerMadhab,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'hanafi', child: Text('Hanafi')),
                    DropdownMenuItem(value: 'shafi', child: Text('Shafi')),
                  ],
                  onChanged: (String? newValue) async {
                    if (newValue != null && newValue != _prayerMadhab) {
                      setState(() {
                        _prayerMadhab = newValue;
                      });

                      await savePrayerMadhabCode(newValue);

                      // প্রেয়ার টাইমার রিফ্রেশ
                      PrayerTimeManager.startSmartPrayerTimer(
                        context: context,
                        location: null,
                      );
                    }
                  },
                ),
              ),
              // Prayer Calculation Method
// ==================== Prayer Calculation Method ====================
              ListTile(
                title: Text(
                  Localizations.localeOf(context).languageCode == 'bn'
                      ? "ক্যালকুলেশন মেথড"
                      : "Calculation Method",
                ),
                subtitle:
                    Text(getCalculationMethodLabel(_prayerCalculationMethod)),
                trailing: DropdownButton<String>(
                  value: _prayerCalculationMethod,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                        value: 'muslim_world_league',
                        child: Text('Muslim World League')),
                    DropdownMenuItem(
                        value: 'egyptian', child: Text('Egyptian')),
                    DropdownMenuItem(value: 'karachi', child: Text('Karachi')),
                    DropdownMenuItem(
                        value: 'umm_al_qura', child: Text('Umm Al-Qura')),
                    DropdownMenuItem(value: 'dubai', child: Text('Dubai')),
                    DropdownMenuItem(value: 'qatar', child: Text('Qatar')),
                    DropdownMenuItem(value: 'kuwait', child: Text('Kuwait')),
                  ],
                  onChanged: (String? newValue) async {
                    if (newValue != null &&
                        newValue != _prayerCalculationMethod) {
                      setState(() {
                        _prayerCalculationMethod = newValue;
                      });

                      await saveCalculationMethod(newValue);

                      // 🔥 প্রেয়ার টাইমার রিস্টার্ট (ম্যানেজার চেঞ্জ না করে)
                      // final location = await NativeDB.getLastSavedLocation(); // যদি এই ফাংশন থাকে
                      PrayerTimeManager.startSmartPrayerTimer(
                        context: context,
                        location: null,
                      );
                    }
                  },
                ),
              ),
              const Divider(),
              // Display and Access Section (Permissions)
              _buildSectionHeader(lang.displayAndAccess),
              _permissionTile(
                icon: Icons.location_on_outlined,
                title: lang.locationPermission,
                subtitle: lang.locationPermissionSubtitle,
                granted: _locationGranted,
                onTap: () => _requestPermissionAndRefresh(
                  _permissionHelper.requestLocationAlways,
                ),
              ),
              _permissionTile(
                icon: Icons.notifications_active_outlined,
                title: lang.notificationPermission,
                subtitle: lang.notificationPermissionSubtitle,
                granted: _notificationGranted,
                onTap: () => _requestPermissionAndRefresh(
                  _permissionHelper.requestNotificationPermission,
                ),
              ),
              _permissionTile(
                icon: Icons.battery_alert,
                title: lang.batteryOptimization,
                subtitle: lang.batteryOptimizationSubtitle,
                granted: _batteryGranted,
                onTap: () => _requestPermissionAndRefresh(
                  _permissionHelper.requestBatteryOptimization,
                ),
              ),
              _permissionTile(
                icon: Icons.alarm_on,
                title: lang.alarmsAndRemindersPermission,
                subtitle: lang.alarmsAndRemindersPermissionSubtitle,
                granted: _exactAlarmGranted,
                onTap: () => _requestPermissionAndRefresh(
                  _permissionHelper.requestExactAlarm,
                ),
              ),
              _permissionTile(
                icon: Icons.fullscreen,
                title: lang.fullScreenIntent,
                subtitle: lang.fullScreenIntentsubtitle,
                granted: _fullscreenGranted,
                onTap: () => _requestPermissionAndRefresh(
                  _permissionHelper.requestFullScreenIntent,
                ),
              ),
              _permissionTile(
                icon: Icons.notifications_active,
                title: lang.doNotDisturbAccess,
                subtitle: lang.doNotDisturbAccessSubtitle,
                granted: _dndGranted,
                onTap: () => _requestPermissionAndRefresh(
                  _permissionHelper.requestDndPermission,
                ),
              ),
              _permissionTile(
                icon: Icons.music_note_outlined,
                title: lang.audioFilesPermission,
                subtitle: lang.audioFilesPermissionSubtitle,
                granted: _audioGranted,
                onTap: () => _requestPermissionAndRefresh(
                  _permissionHelper.requestAudioPermission,
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }

  // ================= HELPERS =================
  Widget _permissionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool granted,
    required VoidCallback onTap,
  }) {
    final lang = AppLocalizations.of(context)!;
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: granted ? Colors.green : Colors.orange,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          granted ? lang.granted : lang.grant,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      onTap: granted ? null : onTap,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Future<void> disableScheduler() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('scheduler_enabled', false);

    // Main scheduler cancel
    await AndroidAlarmManager.cancel(1);

    // Prayer alarms cancel
    for (final id in [
      101,
      102,
      103,
      104,
      105,
      106,
      107,
      108,
      501,
      502,
      503,
      504,
      505,
      506,
      507,
      508,
    ]) {
      await AndroidAlarmManager.cancel(id);
    }
  }

  Future<void> enableScheduler() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('scheduler_enabled', true);

    await AndroidAlarmManager.oneShotAt(
      getNextSchedulerTime(),
      1,
      dailySchedulerDispatcher,
      exact: true,
      wakeup: true,
      allowWhileIdle: true,
      rescheduleOnReboot: true,
    );
  }
}
