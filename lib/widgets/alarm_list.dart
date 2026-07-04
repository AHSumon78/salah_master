// lib/widgets/alarm_list.dart
import 'package:flutter/material.dart';
import 'package:alarm/models/Alarm.dart';

class AlarmList extends StatelessWidget {
  final List<Alarm> alarms;
  final List<Map<String, String>> availableSounds;
  final Function(Alarm, bool) onToggle;
  final Function(Alarm) onEdit;
  final Function(Alarm) onDelete;
  final Function(BuildContext, Alarm) onSelectTime;
  final Function(BuildContext, Alarm) onSelectSound;

  const AlarmList({
    super.key,
    required this.alarms,
    required this.availableSounds,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onSelectTime,
    required this.onSelectSound,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: alarms.length,
      itemBuilder: (context, index) {
        final alarm = alarms[index];
        return _AlarmCard(
          alarm: alarm,
          availableSounds: availableSounds,
          onToggle: onToggle,
          onSelectTime: onSelectTime,
          onSelectSound: onSelectSound,
          onDelete: onDelete,
          onEdit: () => onEdit(alarm),
        );
      },
    );
  }
}

class _AlarmCard extends StatelessWidget {
  final Alarm alarm;
  final List<Map<String, String>> availableSounds;
  final Function(Alarm, bool) onToggle;
  final Function(BuildContext, Alarm) onSelectTime;
  final Function(BuildContext, Alarm) onSelectSound;
  final Function(Alarm) onDelete;
  final VoidCallback onEdit; // Now it's a simple callback for the edit button

  const _AlarmCard({
    required this.alarm,
    required this.availableSounds,
    required this.onToggle,
    required this.onSelectTime,
    required this.onSelectSound,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final currentSoundName = availableSounds.firstWhere(
        (s) => s['file'] == alarm.sound,
        orElse: () => {'name': 'Unknown', 'file': ''})['name'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alarm.title ?? 'Unnamed Alarm',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade800,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => onSelectTime(context, alarm),
                    child: Text(
                      alarm.alarmTime.format(context),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Colors.teal,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => onSelectSound(context, alarm),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.music_note,
                            size: 18, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          currentSoundName ?? 'Default',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                        Icon(Icons.arrow_drop_down,
                            size: 18, color: Colors.grey[600]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: 0.85,
                  child: Switch(
                    value: alarm.isActive,
                    onChanged: (bool newValue) => onToggle(alarm, newValue),
                    activeThumbColor: Colors.teal,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red.shade400),
                  onPressed: () => onDelete(alarm),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
