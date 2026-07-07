import 'package:alarm/l10n/generated/app_localizations.dart';
import 'package:alarm/screens/commons/appBar_background.dart';
import 'package:alarm/screens/commons/app_background.dart';
import 'package:alarm/screens/others_alarm/time_scrolling_picker.dart';
import 'package:alarm/managers/SoundManager.dart';
import 'package:alarm/services/NativeDB.dart';
import 'package:alarm/services/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:alarm/models/Alarm.dart';

class AlarmFormScreen extends StatefulWidget {
  final Alarm? initialAlarm;
  final bool isQuickEdit; // নতুন প্যারামিটার

  const AlarmFormScreen({
    super.key,
    this.initialAlarm,
    this.isQuickEdit = false, // ডিফল্টভাবে false
  });

  @override
  State<AlarmFormScreen> createState() => _AlarmFormScreenState();
}

class _AlarmFormScreenState extends State<AlarmFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late int _hour;
  late int _minute;
  late String _selectedSound;
  late bool _isActive;
  late bool _isDaily;
  late int _daysMask;
  final int locationId = 10;

  late FixedExtentScrollController _hourCtrl;
  late FixedExtentScrollController _minuteCtrl;
  late FixedExtentScrollController _periodCtrl;

  //static const Color _accent = Color(0xFFD0BCFF);
  static const Color _dim = Color(0xFF938F99);
  static const Color _divider = Color(0xFF49454F);
  // আগের লাইনটি কেটে এটি বসান
  AppLocalizations get l => AppLocalizations.of(context)!;
  List<String> get _weekDays => [
        l.saturday,
        l.sunday,
        l.monday,
        l.tuesday,
        l.wednestday,
        l.thursday,
        l.friday,
      ];

  @override
  void initState() {
    super.initState();
    final t = widget.initialAlarm?.alarmTime ?? TimeOfDay.now();
    _hour = t.hour;
    _minute = t.minute;
    _titleController =
        TextEditingController(text: widget.initialAlarm?.title ?? '');
    _selectedSound = widget.initialAlarm?.sound ?? '';
    _isActive = widget.initialAlarm?.isActive ?? true;
    _isDaily = widget.initialAlarm?.isDaily ?? true;
    _daysMask = widget.initialAlarm?.daysMask ?? 127;

    final h12 = _hour % 12;
    final isPm = _hour >= 12;

    _hourCtrl = FixedExtentScrollController(initialItem: 1200 + h12);
    _minuteCtrl = FixedExtentScrollController(initialItem: 3000 + _minute);
    _periodCtrl = FixedExtentScrollController(initialItem: isPm ? 1 : 0);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _hourCtrl.dispose();
    _minuteCtrl.dispose();
    _periodCtrl.dispose();
    super.dispose();
  }

  bool _isDaySelected(int index) {
    return (_daysMask & (1 << index)) != 0;
  }

  void _toggleDay(int index) {
    setState(() {
      _daysMask ^= (1 << index); // XOR অপারেশন (০ থাকলে ১ হবে, ১ থাকলে ০ হবে)

      // এক্সট্রা বোনাস লজিক: সব দিন সিলেক্ট হলে isDaily অটো ট্রু হবে, অন্যথায় ফলস
      _isDaily = (_daysMask == 127);
    });
  }

  void _updateTime() {
    if (!_hourCtrl.hasClients ||
        !_minuteCtrl.hasClients ||
        !_periodCtrl.hasClients) {
      return;
    }

    final h12 = _hourCtrl.selectedItem % 12;
    final isPm = _periodCtrl.selectedItem == 1;
    setState(() {
      _hour = isPm ? (h12 == 0 ? 12 : h12 + 12) : (h12 == 0 ? 0 : h12);
      _minute = _minuteCtrl.selectedItem % 60;
    });
  }

  Future<void> _selectSound() async {
    final s = await SoundManager.selectSound(context);
    if (s != null && s != _selectedSound && mounted) {
      setState(() => _selectedSound = s);
      widget.initialAlarm?.sound = s;
    }
  }

  void _saveAlarm()async {
    print(_daysMask);
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(Alarm(
        id: widget.initialAlarm?.id,
        title: _titleController.text.trim().isNotEmpty
            ? _titleController.text.trim()
            : 'Alarm',
        alarmTime: TimeOfDay(hour: _hour, minute: _minute),
        sound: _selectedSound,
        isActive: _isActive,
        isDaily: _isDaily,
        daysMask: _daysMask,
        locationId: locationId,
      ));
    }
    await Future.delayed(const Duration(milliseconds: 500)); // 0.5 সেকেন্ডের ডিলে
    await NativeDB.scheduleAllSilentTimes();  }

  String _getSoundName(String p) {
    if (p.isEmpty) return 'Default (Cesium)';
    final f = p.split('/').last;
    final n = f.contains('.') ? f.substring(0, f.lastIndexOf('.')) : f;
    return n.replaceAll('_', ' ');
  }

  bool get _isAm => _hour < 12;

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBarCommon(
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(lang.cancel,
              style: TextStyle(color: Theme.of(context).iconColor)),
        ),
        leadingWidth: 80,
        title: widget.initialAlarm == null ? lang.addAlarm : lang.editAlarm,
        actions: [
          TextButton(
            onPressed: _saveAlarm,
            child: Text(lang.save,
                style: TextStyle(color: Theme.of(context).iconColor)),
          ),
        ],
      ),
      body: AppBackground(
        child: Form(
          key: _formKey,
          child: Material(
            // 👈 Add this widget here
            type: MaterialType.transparency,
            child: ListView(
              children: [
                TimeScrollingPicker(
                  hourCtrl: _hourCtrl,
                  minuteCtrl: _minuteCtrl,
                  periodCtrl: _periodCtrl,
                  isAm: _isAm,
                  onTimeChanged: _updateTime,
                ),
                Container(height: 1, color: _divider),
                OptionRow(
                  icon: Icons.label_outline,
                  child: (!widget.isQuickEdit)
                      ? TextFormField(
                          controller: _titleController,
                          style: Theme.of(context).title,
                          decoration: InputDecoration(
                              hintText: lang.label, border: InputBorder.none),
                        )
                      : Text(
                          _titleController.text,
                          style: Theme.of(context).title,
                        ),
                ),
                Container(height: 1, color: _divider),
                OptionRow(
                  icon: Icons.volume_up_outlined,
                  onTap: _selectSound,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(lang.alarmSound, style: Theme.of(context).title),
                          Text(_getSoundName(_selectedSound),
                              style:
                                  const TextStyle(color: _dim, fontSize: 13)),
                        ],
                      ),
                      const Icon(Icons.chevron_right, color: _dim),
                    ],
                  ),
                ),

                // Repeat অপশনটি কন্ডিশনাল করা হলো
                if (true) ...[
                  Container(height: 1, color: _divider),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lang.repeat, style: Theme.of(context).title),
                        const SizedBox(height: 14),
                       Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _repeatChip(
                              lang.once,
                              _isRepeatSelected('once'),
                              () => _setRepeatMode('once'),
                            ),
                            _repeatChip(
                              lang.everyday,
                              _isRepeatSelected('everyday'),
                              () => _setRepeatMode('everyday'),
                            ),
                            _repeatChip(
                              lang.workingdays,
                              _isRepeatSelected('working'),
                              () => _setRepeatMode('working'),
                            ),
                            _repeatChip(
                              lang.weekend,
                              _isRepeatSelected('weekend'),
                              () => _setRepeatMode('weekend'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(7, (index) {
                            // ইনডেক্স রিভার্স করা হয়েছে কারণ Sat=6 এবং Fri=0
                            final int dayBitIndex = 6 - index;
                            final bool isSelected = _isDaySelected(dayBitIndex);

                            return Material(
                              color: isSelected
                                  ? Theme.of(context).appBarColor
                                  : Colors.transparent,
                              shape: const CircleBorder(),
                              // ক্লিক করার সময় সার্কেলের বাইরে যেন রিফেল ইফেক্ট না যায়
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () => _toggleDay(dayBitIndex),
                                // প্রফেশনাল ফিডব্যাকের জন্য স্প্ল্যাশ কালার যুক্ত করা হলো
                                splashColor: Colors.tealAccent.withValues(alpha: 0.3),
                                highlightColor: Colors.teal.withValues(alpha: 0.1),
                                child: Ink(
                                  width:
                                      38, // ইউজার টাচের সুবিধার জন্য সাইজ সামান্য বাড়ানো হয়েছে
                                  height: 38,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? const Color(0xFF78909C)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.tealAccent.withValues(alpha: 0.5)
                                          : _dim.withValues(alpha: 0.4),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _weekDays[index],
                                      style: TextStyle(
                                        color: isSelected
                                            ? Theme.of(context).textColor
                                            : _dim,
                                        fontWeight: isSelected
                                            ? FontWeight.w800
                                            : FontWeight.normal,
                                        fontSize: 13,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],

                // Delete বাটনটি কন্ডিশনাল করা হলো
                if (widget.initialAlarm != null && !widget.isQuickEdit) ...[
                  const SizedBox(height: 24),
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(null),
                    icon: const Icon(Icons.delete_outline,
                        color: Color(0xFFCF6679)),
                    label: const Text('Delete alarm',
                        style: TextStyle(color: Color(0xFFCF6679))),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _repeatChip(
  String label,
  bool selected,
  VoidCallback onTap,
) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFF78909C)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected
              ? Colors.tealAccent.withValues(alpha: 0.5)
              : _dim.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight:
              selected ? FontWeight.w700 : FontWeight.w500,
          color: selected
              ? Theme.of(context).textColor
              : _dim,
        ),
      ),
    ),
  );
}

  void _setRepeatMode(String mode) {
    setState(() {
      switch (mode) {
        case 'once':
          _daysMask = 0;
          _isDaily = false;
          break;

        case 'everyday':
          _daysMask = 127; // 1111111
          _isDaily = true;
          break;

        case 'working':
          // Sat, Sun off
          // Mon,Tue,Wed,Thu,Fri
          _daysMask = 62; // 0111110
          _isDaily = false;
          break;

        case 'weekend':
          // Sat + Sun
          _daysMask = 65; // 1000001
          _isDaily = false;
          break;
      }
    });
  }
  bool _isRepeatSelected(String mode) {
  switch (mode) {
    case 'once':
      return _daysMask == 0;

    case 'everyday':
      return _daysMask == 127;

    case 'working':
      return _daysMask == 62;

    case 'weekend':
      return _daysMask == 65;

    default:
      return false;
  }
}
}
