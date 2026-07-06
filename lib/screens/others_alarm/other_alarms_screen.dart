import 'package:alarm/l10n/generated/app_localizations.dart';
import 'package:alarm/screens/commons/appBar_background.dart';
import 'package:alarm/screens/commons/app_background.dart';
import 'package:alarm/screens/commons/app_card.dart';
import 'package:alarm/screens/commons/common_switch.dart';
import 'package:alarm/screens/others_alarm/alarm_form_screen.dart';
import 'package:alarm/services/NativeDB.dart';
import 'package:alarm/managers/SoundManager.dart';
import 'package:alarm/services/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:alarm/models/Alarm.dart';
import 'package:intl/intl.dart';

class OtherAlarmsScreen extends StatefulWidget {
  const OtherAlarmsScreen({super.key});

  @override
  State<OtherAlarmsScreen> createState() => _OtherAlarmsScreenState();
}

class _OtherAlarmsScreenState extends State<OtherAlarmsScreen> {
  List<Alarm> _otherAlarms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAlarms();
  }

  Future<void> _fetchAlarms() async {
    setState(() => _isLoading = true);
    try {
      final allAlarms = await NativeDB.getGeneralAlarms();
      _sortAlarms(allAlarms);

      if (mounted) {
        setState(() {
          _otherAlarms = allAlarms;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching alarms: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _sortAlarms(List<Alarm> alarms) {
    alarms.sort((a, b) {
      if (a.alarmTime.hour != b.alarmTime.hour) {
        return a.alarmTime.hour.compareTo(b.alarmTime.hour);
      }
      return a.alarmTime.minute.compareTo(b.alarmTime.minute);
    });
  }

  Future<void> _addOrEditAlarm({Alarm? alarmToEdit}) async {
    final result = await showModalBottomSheet<Alarm>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.75,
        child: AlarmFormScreen(initialAlarm: alarmToEdit),
      ),
    );

    if (result != null && mounted) {
      if (alarmToEdit == null) {
        await NativeDB.insertAlarm(result);
      } else {
        result.id = alarmToEdit.id;
        await NativeDB.updateAlarm(result);
      }
      await _fetchAlarms(); // Refresh list
    }
  }

  Future<void> _deleteAlarm(Alarm alarm) async {
    if (alarm.id == null) return;
    final l = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteAlarm),
        content: Text(l.deleteAlarmAlert),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await NativeDB.deleteAlarm(alarm.id!);
      setState(() {
        _otherAlarms.removeWhere((a) => a.id == alarm.id);
      });
    }
  }

  Future<void> _selectSound(BuildContext context, Alarm alarm) async {
    final String? selected = await SoundManager.selectSound(context);
    if (selected != null && selected != alarm.sound && mounted) {
      setState(() => alarm.sound = selected);
      await NativeDB.updateAlarm(alarm);
    }
  }

  Future<void> _onToggleAlarm(Alarm alarm, bool newValue) async {
    setState(() => alarm.isActive = newValue);
    await NativeDB.updateAlarm(alarm);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBarCommon(title: l.othersAlarm),
      body: AppBackground(
        child: RefreshIndicator(
          onRefresh: _fetchAlarms,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _otherAlarms.isEmpty
                  ? _buildEmptyState()
                  : CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 0),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final alarm = _otherAlarms[index];
                                return _buildAlarmCard(alarm);
                              },
                              childCount: _otherAlarms.length,
                            ),
                          ),
                        ),
                      ],
                    ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton(
          onPressed: () => _addOrEditAlarm(),
          backgroundColor: Colors.teal.withValues(alpha: 0.6),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAlarmCard(Alarm alarm) {
    final soundName = SoundManager.getSoundName(alarm.sound);

    return RepaintBoundary(
      child: Opacity(
        opacity: alarm.isActive ? 1.0 : 0.8,
        child: AppCard(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => _addOrEditAlarm(alarmToEdit: alarm),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  alarm.title ?? 'Unnamed Alarm',
                                  style: Theme.of(context).title,
                                ),
                              ),
                              Text(
                                DateFormat(
                                        'hh:mm a',
                                        Localizations.localeOf(context)
                                                    .languageCode ==
                                                'bn'
                                            ? 'bn_BD'
                                            : 'en_US' // 🔥 বাংলা লোকাল সম্পূর্ণ সাপোর্ট করার ট্রিক
                                        )
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
                              const SizedBox(
                                width: 40,
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () => _selectSound(context, alarm),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.teal.shade100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.music_note,
                                  size: 14, color: Colors.teal),
                              const SizedBox(width: 4),
                              Text(
                                soundName,
                                style: Theme.of(context).subtitle,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                CommonSwitch(
                  value: alarm.isActive,
                  onChanged: (v) => _onToggleAlarm(alarm, v),
                  activeColor: Colors.teal,
                ),
                IconButton(
                  icon:
                      const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => _deleteAlarm(alarm),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(l.noAlarmsSet,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(l.addNewAlarm, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
