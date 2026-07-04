import 'package:alarm/l10n/generated/app_localizations.dart';
import 'package:alarm/models/Alarm.dart';
import 'package:alarm/screens/commons/app_card.dart';
import 'package:alarm/managers/SoundManager.dart';
import 'package:alarm/screens/commons/common_switch.dart';
import 'package:alarm/services/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AlarmCard extends StatelessWidget {
  final Alarm alarm;
  final VoidCallback onTapTime;
  final VoidCallback onTapSound;
  final ValueChanged<bool> onToggle;

  const AlarmCard({
    required super.key,
    required this.alarm,
    required this.onTapTime,
    required this.onTapSound,
    required this.onToggle,
  });

  static IconData _prayerIcon(String title) {
    final t = title.toLowerCase();
    if (t.contains('fajr')) return Icons.nights_stay;
    if (t.contains('dhuhr')) return Icons.wb_sunny;
    if (t.contains('asr')) return Icons.cloud;
    if (t.contains('maghrib')) return Icons.brightness_3;
    if (t.contains('isha')) return Icons.dark_mode;
    return Icons.alarm;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final soundName = SoundManager.getSoundName(alarm.sound);
    final displaySound = (soundName.length > 15)
        ? '${soundName.substring(0, 12)}...'
        : soundName;

    return RepaintBoundary(
      child: Opacity(
        opacity: alarm.isActive ? 1.0 : 0.8,
        child: AppCard(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: onTapTime,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 4.0),
                          child: Row(
                            children: [
                              Icon(
                                _prayerIcon(alarm.title ?? ''),
                                size: 18,
                                color: Theme.of(context).iconColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  getLocalizedPrayerName(
                                      l, alarm.title ?? 'Unnamed Alarm'),
                                  style: Theme.of(context).title,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                DateFormat(
                                        'hh:mm a',
                                        Localizations.localeOf(context)
                                            .languageCode)
                                    .format(
                                  DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day,
                                    alarm.alarmTime.hour,
                                    alarm.alarmTime.minute,
                                  ),
                                ),
                                style: Theme.of(context).time,
                              ),
                              const Spacer(flex: 1),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                CommonSwitch(
                  value: alarm.isActive,
                  onChanged: onToggle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // ধরি databasePrayerName = "Fajr" (যা ডাটাবেজ থেকে এসেছে)

  String getLocalizedPrayerName(AppLocalizations l, String databasePrayerName) {
    switch (databasePrayerName) {
      case 'Fajr':
        return l.fajr; // বাংলায় 'ফজর', ইংরেজিতে 'Fajr'
      case 'Dhuhr':
        return l.dhuhr; // বাংলায় 'যোহর', ইংরেজিতে 'Dhuhr'
      case 'Asr':
        return l.asr; // বাংলায় 'আসর', ইংরেজিতে 'Asr'
      case 'Maghrib':
        return l.maghrib; // বাংলায় 'মাগরিব', ইংরেজিতে 'Maghrib'
      case 'Isha':
        return l.isha; // বাংলায় 'এশা', ইংরেজিতে 'Isha'
      default:
        return databasePrayerName; // যদি কোনোটার সাথে না মিলে তবে ডাটাবেজের নামটাই দেখাবে
    }
  }
}

// ---------------------------------------------------------------------------
// Skeleton card
// ---------------------------------------------------------------------------
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      width: 120, height: 20, color: Colors.grey.shade300),
                  const SizedBox(height: 10),
                  Container(width: 80, height: 15, color: Colors.grey.shade200),
                ],
              ),
            ),
            Container(width: 40, height: 25, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}
