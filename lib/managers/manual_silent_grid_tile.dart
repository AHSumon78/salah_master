import 'dart:async';
import 'package:alarm/l10n/generated/app_localizations.dart';
import 'package:alarm/services/NativeDB.dart';
import 'package:alarm/services/app_theme_extension.dart';
import 'package:flutter/material.dart';
// 🔥 আপনার প্রজেক্টের সঠিক পাথ অনুযায়ী NativeDB এবং থিম এক্সটেনশন ইমপোর্ট করুন
// import 'package:alarm/database/native_db.dart';
// import 'package:alarm/services/app_theme_extension.dart';

class ManualSilentGridTile extends StatefulWidget {
  const ManualSilentGridTile({super.key});

  @override
  State<ManualSilentGridTile> createState() => _ManualSilentGridTileState();
}

class _ManualSilentGridTileState extends State<ManualSilentGridTile> {
  // আপনার অরিজিনাল ভেরিয়েবলসমূহ হুবহু রাখা হলো
  bool _isManualSilent = false;
  int _selectedMinutes = 10;
  final ValueNotifier<String> _remainingTimeNotifier =
      ValueNotifier<String>("");
  Timer? _countdownTimer;
  DateTime? _endTime;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _remainingTimeNotifier.dispose();
    super.dispose();
  }

  // ⏱️ আপনার অরিজিনাল কাউন্টডাউন লজিক
  void _startLocalCountdown(int minutes) {
    _countdownTimer?.cancel();
    _endTime = DateTime.now().add(Duration(minutes: minutes));
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final difference = _endTime!.difference(now);
      if (difference.isNegative) {
        timer.cancel();
        setState(() {
          _isManualSilent = false;
        });
        _remainingTimeNotifier.value = "";
      } else {
        final m = difference.inMinutes;
        final s = difference.inSeconds % 60;
        _remainingTimeNotifier.value =
            "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
      }
    });
  }

  // 🔄 আপনার অরিজিনাল টগল লজিক
  void _toggleManualSilent(bool value) async {
    if (value) {
      try {
        // NativeDB কল করা হচ্ছে আপনার আগের কোড অনুযায়ী
        await NativeDB.startManualSilent(minutes: _selectedMinutes);
        setState(() {
          _isManualSilent = true;
        });
        _startLocalCountdown(_selectedMinutes);
      } catch (e) {
        debugPrint("Error starting manual silent: $e");
      }
    } else {
      try {
        await NativeDB.stopManualSilent();
        _countdownTimer?.cancel();
        setState(() {
          _isManualSilent = false;
        });
        _remainingTimeNotifier.value = "";
      } catch (e) {
        debugPrint("Error stopping manual silent: $e");
      }
    }
  }

  // 🕋 আপনার কাস্টম পপ-আপ ডায়ালগ লজিক
  void _showManualSilentPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setPopupState) {
            final lang = AppLocalizations.of(context)!;
            return AlertDialog(
              backgroundColor: Theme.of(context).appBackground,
              title: Row(
                children: [
                  Icon(
                    _isManualSilent
                        ? Icons.do_not_disturb_on
                        : Icons.volume_up_outlined,
                    color: Theme.of(context).iconColor,
                  ),
                  const SizedBox(width: 10),
                  Text(lang.manualSilent, style: Theme.of(context).title),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isManualSilent) ...[
                    Text("Phone is currently silenced.",
                        style: Theme.of(context).subtitle),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text("Time Remaining: ",
                            style: Theme.of(context).subtitle),
                        ValueListenableBuilder<String>(
                          valueListenable: _remainingTimeNotifier,
                          builder: (context, timeValue, child) {
                            return Text(
                              timeValue,
                              style: Theme.of(context).time,
                            );
                          },
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(lang.manualSilentDescription,
                        style: Theme.of(context).subtitle),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(lang.silenceDuration,
                            style: Theme.of(context).subtitle),
                        DropdownButton<int>(
                          value: _selectedMinutes,
                          dropdownColor: Theme.of(context).cardColor,
                          underline: const SizedBox(),
                          icon: Icon(Icons.arrow_drop_down,
                              color: Theme.of(context).iconColor),
                          style: Theme.of(context).time,
                          items: [10, 15, 30, 60, 120]
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text("$e ${lang.minutes} "),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedMinutes = val);
                              setPopupState(() {});
                            }
                          },
                        ),
                      ],
                    ),
                  ]
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(lang.cancel,
                      style: TextStyle(color: Theme.of(context).iconColor)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).iconColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _toggleManualSilent(!_isManualSilent);
                  },
                  child: Text(
                    _isManualSilent ? lang.stopSilent : lang.start,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 📱 আপনার অরিজিনাল গ্রিড টাইল UI বিল্ডার
  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    return Material(
      color: _isManualSilent
          ? Colors.teal.withValues(alpha: 0.12)
          : Theme.of(context).cardBackground,
      // বর্ডার রেডিয়াস গ্রিডের শেপ পারফেক্ট রাখার জন্য যুক্ত করা হলো
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showManualSilentPopup(context),
        splashColor: Colors.teal.withValues(alpha: 0.15),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: _isManualSilent
                  ? Colors.teal.withValues(alpha: 0.6)
                  : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    _isManualSilent
                        ? Icons.do_not_disturb_on
                        : Icons.volume_up_outlined,
                    color: Theme.of(context).iconColor,
                    size: 22,
                  ),
                  // if (_isManualSilent)
                  //   const SizedBox(
                  //     width: 12,
                  //     height: 12,
                  //     child: CircularProgressIndicator(
                  //       strokeWidth: 1.8,
                  //       valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                  //     ),
                  //   )
                  // else
                  //   Icon(Icons.add_circle_outline,
                  //       color: Theme.of(context).iconColor),
                ],
              ),
              Text(
                lang.quickSilent,
                style: Theme.of(context)
                    .title
                    .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              _isManualSilent
                  ? ValueListenableBuilder<String>(
                      valueListenable: _remainingTimeNotifier,
                      builder: (context, timeValue, child) {
                        return Text(
                          timeValue,
                          style: Theme.of(context).time,
                        );
                      },
                    )
                  : Text(lang.tapToSilence, style: Theme.of(context).caption),
            ],
          ),
        ),
      ),
    );
  }
}
