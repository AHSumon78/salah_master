import 'package:alarm/services/full_screen_intent_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlarmPermissionHelper {
  final BuildContext context;
  static const dbChannel = MethodChannel('com.butterflydevs.salahmaster/db');
  static const _firstLaunchDisclosureKey = 'permission_disclosure_seen_v1';

  AlarmPermissionHelper(this.context);

  Future<bool> areAllPermissionsGranted() async {
    final location = await Permission.locationAlways.status;
    final notification = await Permission.notification.status;
    final battery = await Permission.ignoreBatteryOptimizations.status;
    final fullScreen = await FullScreenIntentHelper.canUseFullScreenIntent();
    final exactAlarmGranted = await isExactAlarmGranted();

    bool dndGranted = false;
    try {
      dndGranted =
          await dbChannel.invokeMethod('isDndPermissionGranted') ?? false;
    } catch (_) {}

    return location.isGranted &&
        notification.isGranted &&
        exactAlarmGranted &&
        battery.isGranted &&
        fullScreen &&
        dndGranted;
  }

  Future<bool> requestAllPermissions() async {
    debugPrint('[PermissionHelper] Starting guided permission request.');

    await _requestForegroundLocation();
    await _requestNotificationPermission();
    await _requestBackgroundLocationWithDisclosure();
    await _requestAlarmReliabilityPermissions();

    return areAllPermissionsGranted();
  }

  Future<void> requestPermissionsOnFirstLaunch() async {
    if (await areAllPermissionsGranted()) return;

    final prefs = await SharedPreferences.getInstance();
    final hasSeenDisclosure = prefs.getBool(_firstLaunchDisclosureKey) ?? false;

    if (!hasSeenDisclosure) {
      final accepted = await _showFirstLaunchPermissionDisclosure();
      await prefs.setBool(_firstLaunchDisclosureKey, true);

      if (accepted != true) {
        if (context.mounted) {
          showSmartPermissionDialog(onRetry: requestAllPermissions);
        }
        return;
      }
    }

    final granted = await requestAllPermissions();
    if (!granted && context.mounted) {
      showSmartPermissionDialog(onRetry: openMissingPermissionSettings);
    }
  }

  Future<void> _requestForegroundLocation() async {
    final status = await Permission.locationWhenInUse.status;
    if (status.isGranted) return;

    await Permission.locationWhenInUse.request();
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isGranted) return;

    await Permission.notification.request();
  }

  Future<void> requestNotificationPermission() async {
    await _requestNotificationPermission();
  }

  Future<void> _requestBackgroundLocationWithDisclosure() async {
    final foreground = await Permission.locationWhenInUse.status;
    final background = await Permission.locationAlways.status;

    if (!foreground.isGranted || background.isGranted) return;
    if (!context.mounted) return;

    final accepted = await _showBackgroundLocationDisclosure();
    if (accepted == true) {
      await Permission.locationAlways.request();
    }
  }

  Future<void> _requestAlarmReliabilityPermissions() async {
    if (!(await isExactAlarmGranted())) {
      await requestExactAlarm();
    }

    if (!(await FullScreenIntentHelper.canUseFullScreenIntent())) {
      await requestFullScreenIntent();
    }

    if (!(await Permission.ignoreBatteryOptimizations.isGranted)) {
      await Permission.ignoreBatteryOptimizations.request();
    }

    bool isDndGranted = false;
    try {
      isDndGranted =
          await dbChannel.invokeMethod('isDndPermissionGranted') ?? false;
    } catch (_) {}

    if (!isDndGranted && context.mounted) {
      final accepted = await _showDndDisclosure();
      if (accepted == true) {
        await requestDndPermission();
      }
    }
  }

  Future<bool?> _showFirstLaunchPermissionDisclosure() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.verified_user_outlined, color: Colors.teal),
        title: const Text('Set up Salah Master'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Salah Master needs a few permissions to keep prayer alarms accurate and location features reliable.',
              ),
              SizedBox(height: 14),
              _PermissionReason(
                icon: Icons.location_on_outlined,
                title: 'Location',
                body:
                    'Used for real prayer times, qibla direction, nearby mosques, and Home/Office jamaat alarms.',
              ),
              _PermissionReason(
                icon: Icons.my_location_outlined,
                title: 'Background location',
                body:
                    'Used only for location-based jamaat alarms, mosque geofencing, and auto silent mode when the app is closed.',
              ),
              _PermissionReason(
                icon: Icons.alarm_on_outlined,
                title: 'Alarm access',
                body:
                    'Used for exact alarms, lock-screen alarm popup, notifications, vibration, and battery reliability.',
              ),
              _PermissionReason(
                icon: Icons.do_not_disturb_on_outlined,
                title: 'Do Not Disturb',
                body:
                    'Used only when you enable mosque, prayer-time, or manual silent mode.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Later'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showBackgroundLocationDisclosure() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.my_location_outlined, color: Colors.teal),
        title: const Text('Allow background location?'),
        content: const Text(
          'Background location lets Salah Master switch jamaat alarms when you travel between saved locations and enable mosque auto silent mode even when the app is closed. Your saved locations and alarm settings stay on your device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Allow'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDndDisclosure() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.do_not_disturb_on_outlined, color: Colors.teal),
        title: const Text('Enable auto silent mode?'),
        content: const Text(
          'Do Not Disturb access is used only for features you choose, such as mosque geofencing, prayer-time silent mode, and manual silent timers. Salah Master restores normal mode when the rule ends.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
  }

  Future<void> requestBatteryOptimization() async {
    await Permission.ignoreBatteryOptimizations.request();
  }

  Future<void> requestFullScreenIntent() async {
    if (!(await FullScreenIntentHelper.canUseFullScreenIntent())) {
      await FullScreenIntentHelper.openSettings();
    }
  }

  Future<void> requestAudioPermission() async {
    await Permission.audio.request();
  }

  Future<void> requestExactAlarm() async {
    if (await isExactAlarmGranted()) return;
    try {
      debugPrint('[PermissionHelper] Opening exact alarm settings.');
      await dbChannel.invokeMethod('openExactAlarmSettings');
    } catch (e) {
      debugPrint('[PermissionHelper] Native exact alarm intent failed: $e');
      await Permission.scheduleExactAlarm.request();
    }
  }

  Future<void> requestDndPermission() async {
    bool isDndGranted = false;
    try {
      isDndGranted =
          await dbChannel.invokeMethod('isDndPermissionGranted') ?? false;
    } catch (_) {}

    if (!isDndGranted) {
      await dbChannel.invokeMethod('requestDndPermission');
    }
  }

  Future<void> requestLocationAlways() async {
    final foreground = await Permission.locationWhenInUse.status;
    if (!foreground.isGranted) {
      await Permission.locationWhenInUse.request();
    }

    if (await Permission.locationWhenInUse.isGranted) {
      await Permission.locationAlways.request();
    }
  }

  void showSmartPermissionDialog({VoidCallback? onRetry}) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        icon:
            const Icon(Icons.admin_panel_settings_outlined, color: Colors.teal),
        title: const Text('Finish permission setup'),
        content: const Text(
          'Some features still need permission. Without them, prayer alarms, location-based jamaat alarms, mosque auto silent mode, or lock-screen alarm popups may not work reliably.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Later'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onRetry?.call();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Future<void> openMissingPermissionSettings() async {
    if (!(await Permission.locationWhenInUse.isGranted)) {
      await Permission.locationWhenInUse.request();
      return;
    }
    if (!(await Permission.locationAlways.isGranted)) {
      await _requestBackgroundLocationWithDisclosure();
      return;
    }
    if (!(await Permission.notification.isGranted)) {
      await Permission.notification.request();
      return;
    }
    if (!(await isExactAlarmGranted())) {
      await requestExactAlarm();
      return;
    }
    if (!(await FullScreenIntentHelper.canUseFullScreenIntent())) {
      await requestFullScreenIntent();
      return;
    }
    if (!(await Permission.ignoreBatteryOptimizations.isGranted)) {
      await requestBatteryOptimization();
      return;
    }

    bool isDndGranted = false;
    try {
      isDndGranted =
          await dbChannel.invokeMethod('isDndPermissionGranted') ?? false;
    } catch (_) {}

    if (!isDndGranted) {
      await requestDndPermission();
      return;
    }

    await openAppSettings();
  }

  Future<bool> isBatteryOptimizationGranted() async =>
      Permission.ignoreBatteryOptimizations.isGranted;
  Future<bool> isFullScreenGranted() async =>
      FullScreenIntentHelper.canUseFullScreenIntent();
  Future<bool> isDndGranted() async {
    try {
      return await dbChannel.invokeMethod('isDndPermissionGranted') ?? false;
    } catch (e) {
      debugPrint('[PermissionHelper] DND check failed: $e');
      return false;
    }
  }

  Future<bool> isExactAlarmGranted() async {
    try {
      return await dbChannel.invokeMethod('isExactAlarmGranted') ?? false;
    } catch (e) {
      debugPrint('[PermissionHelper] Exact alarm check failed: $e');
      return Permission.scheduleExactAlarm.isGranted;
    }
  }

  Future<bool> isNotificationGranted() async =>
      Permission.notification.isGranted;
  Future<bool> isLocationGranted() async => Permission.locationAlways.isGranted;
  Future<bool> isAudioPermissionGranted() async => Permission.audio.isGranted;
}

class _PermissionReason extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _PermissionReason({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.teal, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(body, style: textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
