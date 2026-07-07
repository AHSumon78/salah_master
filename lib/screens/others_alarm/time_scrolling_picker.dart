import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/app_theme_extension.dart';

class TimeScrollingPicker extends StatelessWidget {
  final FixedExtentScrollController hourCtrl;
  final FixedExtentScrollController minuteCtrl;
  final FixedExtentScrollController periodCtrl;
  final bool isAm;
  final VoidCallback onTimeChanged;

  const TimeScrollingPicker({
    super.key,
    required this.hourCtrl,
    required this.minuteCtrl,
    required this.periodCtrl,
    required this.isAm,
    required this.onTimeChanged,
  });

  //static const Color _selBg = Colors.teal;

  @override
  Widget build(BuildContext context) {
    const double itemH = 54.0;
    const double totalH = itemH * 5.0;
    const double selTop = itemH * 2;

    return SizedBox(
      height: totalH,
      child: Stack(
        children: [
          Positioned(
            top: selTop,
            left: 0,
            right: 0,
            height: itemH,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).appBarColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildScrollWheel(
                  controller: hourCtrl,
                  onChanged: (idx) {
                    HapticFeedback.selectionClick();
                    onTimeChanged();
                  },
                  builder: (idx) {
                    final h12 = idx % 12;
                    final display = h12 == 0 ? '12' : h12.toString();
                    bool isSel = false;
                    try {
                      if (hourCtrl.hasClients) {
                        isSel = (hourCtrl.selectedItem % 12) == h12;
                      }
                    } catch (_) {}
                    return _DrumItem(label: display, selected: isSel);
                  },
                ),
                Text(':', style: Theme.of(context).time.copyWith(fontSize: 32)),
                _buildScrollWheel(
                  controller: minuteCtrl,
                  onChanged: (idx) {
                    HapticFeedback.selectionClick();
                    onTimeChanged();
                  },
                  builder: (idx) {
                    final m = idx % 60;
                    bool isSel = false;
                    try {
                      if (minuteCtrl.hasClients) {
                        isSel = (minuteCtrl.selectedItem % 60) == m;
                      }
                    } catch (_) {}
                    return _DrumItem(
                        label: m.toString().padLeft(2, '0'), selected: isSel);
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ListWheelScrollView(
                    controller: periodCtrl,
                    itemExtent: itemH,
                    perspective: 0.003,
                    diameterRatio: 2.5,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (idx) {
                      HapticFeedback.selectionClick();
                      onTimeChanged();
                    },
                    children: [
                      _DrumItem(label: 'AM', selected: isAm),
                      _DrumItem(label: 'PM', selected: !isAm),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollWheel({
    required FixedExtentScrollController controller,
    required ValueChanged<int> onChanged,
    required Widget Function(int) builder,
  }) {
    return Expanded(
      flex: 3,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 54,
        perspective: 0.003,
        diameterRatio: 2.5,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            return AnimatedBuilder(
              animation: controller,
              builder: (context, child) => builder(index),
            );
          },
        ),
      ),
    );
  }
}

class _DrumItem extends StatelessWidget {
  final String label;
  final bool selected;
  const _DrumItem({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Text(
        label,
        style: selected
            ? TextStyle(
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                fontWeight: const FontWeight(500),
                fontSize: 25)
            : theme.time.copyWith(
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
      ),
    );
  }
}

class OptionRow extends StatelessWidget {
  final IconData icon;
  final Widget child;
  final VoidCallback? onTap;
  const OptionRow({super.key, required this.icon, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: const Color(0xFF938F99)),
      // child এর ভেতরে থাকা টেক্সট অটোমেটিক theme.title বা theme.subtitle পাবে
      title: DefaultTextStyle(
        style: Theme.of(context).title,
        child: child,
      ),
    );
  }
}

class GSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const GSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: const Color(0xFFD0BCFF),
        activeTrackColor: const Color(0xFF381E72),
      );
}
