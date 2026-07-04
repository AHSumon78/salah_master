import 'package:alarm/l10n/generated/app_localizations.dart';
import 'package:alarm/services/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:adhan_dart/adhan_dart.dart';

// ---------------------------------------------------------------------------
// Pre-computed, immutable sun/moon data — calculated once outside the widget.
// ---------------------------------------------------------------------------
class SunMoonData {
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime fajrTime;
  final bool isDayTime;
  final double targetProgress;
  final String sunriseText;
  final String sunsetText;
  final String fajrTimeText;

  const SunMoonData({
    required this.sunrise,
    required this.sunset,
    required this.fajrTime,
    required this.isDayTime,
    required this.targetProgress,
    required this.sunriseText,
    required this.sunsetText,
    required this.fajrTimeText,
  });

  static SunMoonData compute(
    double latitude,
    double longitude, {
    Madhab madhab = Madhab.hanafi,
  }) {
    final now = DateTime.now();
    final fmt = DateFormat('hh:mm a');

    final coords = Coordinates(latitude, longitude);
    final params = CalculationMethodParameters.muslimWorldLeague()
      ..madhab = madhab;

    final pt = PrayerTimes(
      coordinates: coords,
      date: now,
      calculationParameters: params,
      precision: true,
    );

    final sunrise = pt.sunrise.toLocal();
    final sunset = pt.maghrib.toLocal();
    final fajrTime = pt.fajr.toLocal();
    final nextSunrise = sunrise.add(const Duration(days: 1));
    bool isDayTime;
    double targetProgress;

    if (now.isAfter(sunrise) && now.isBefore(sunset)) {
      isDayTime = true;
      final total = sunset.difference(sunrise).inSeconds.toDouble();
      final passed = now.difference(sunrise).inSeconds.toDouble();
      targetProgress = (passed / total).clamp(0.0, 1.0);
    } else {
      isDayTime = false;
      final DateTime nightStart = now.isAfter(sunset)
          ? sunset
          : sunset.subtract(const Duration(days: 1));
      final DateTime nightEnd = now.isAfter(sunset) ? nextSunrise : sunrise;
      final total = nightEnd.difference(nightStart).inSeconds.toDouble();
      final passed = now.difference(nightStart).inSeconds.toDouble();
      targetProgress = (passed / total).clamp(0.0, 1.0);
    }

    return SunMoonData(
      sunrise: sunrise,
      sunset: sunset,
      fajrTime: fajrTime,
      isDayTime: isDayTime,
      targetProgress: targetProgress,
      sunriseText: fmt.format(sunrise),
      sunsetText: fmt.format(sunset),
      fajrTimeText: fmt.format(fajrTime),
    );
  }
}

// ---------------------------------------------------------------------------
// Isolated sun/moon tracker — animates independently, never causes list rebuilds
// ---------------------------------------------------------------------------

class SunMoonTracker extends StatefulWidget {
  final SunMoonData data;

  const SunMoonTracker({super.key, required this.data});

  @override
  State<SunMoonTracker> createState() => _SunMoonTrackerState();
}

class _SunMoonTrackerState extends State<SunMoonTracker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  void _initAnimation() {
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2700),
    );

    _anim = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeInOutSine,
    );

    _ctrl.animateTo(widget.data.targetProgress);
  }

  // এই মেথডটি প্রতিবার পেইজে ফিরে আসলে অ্যানিমেশন রিস্টার্ট করবে

  void _restartAnimation() {
    if (!mounted) return;

    _ctrl.stop();

    _ctrl.animateTo(
      widget.data.targetProgress,
      duration: const Duration(milliseconds: 3000),
      curve: Curves.easeOutExpo,
    );
  }

  @override
  void didUpdateWidget(SunMoonTracker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.targetProgress != widget.data.targetProgress) {
      _restartAnimation();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final d = widget.data;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) {
          final t = _anim.value;

          Color filterColor;
          Color? iconTint;

          if (d.isDayTime) {
            if (t < 0.15) {
              filterColor = Colors.orangeAccent.withValues(alpha: 0.3);
            } else if (t > 0.92) {
              filterColor = Colors.deepOrange.withValues(alpha: 0.6);
              iconTint = Colors.deepOrange.withValues(alpha: 0.8);
            } else {
              filterColor = Colors.blue.withValues(alpha: 0.1);
            }
          } else {
            filterColor = t > 0.85
                ? const Color.fromARGB(255, 98, 113, 199).withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: 0.45);
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              const double imageSectionHeight = 250.0;

              return Container(
                height: imageSectionHeight, // <--- এখানে হাইট সেট করুন
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      d.isDayTime
                          ? 'assets/images/f_day.png'
                          : 'assets/images/f_night.png',
                    ),
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    colorFilter:
                        ColorFilter.mode(filterColor, BlendMode.darken),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 14.0, horizontal: 0.0),
                  child: Stack(
                    children: [
                      Positioned(
                        top: imageSectionHeight *
                            0.16, // ঘড়ির জন্য ওপর থেকে একটু জায়গা ছেড়ে দিচ্ছি
                        bottom: imageSectionHeight * 0.19,
                        left: 0,
                        right: 0,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth;
                            final height = constraints.maxHeight;
                            final double iconSize = d.isDayTime ? 74 : 30;
                            const double edgePadding = 8;
                            final double baselineOffset = d.isDayTime ? 25: 4;
                            const double x0 = edgePadding;
                            final double y0 =
                                height - (iconSize / 2) + baselineOffset;
                            final double x3 = width - edgePadding;
                            final double y3 = y0;

                            final double spread = width * 0.4;
                            final double x1 = (width / 2) - spread;
                            final double x2 = (width / 2) + spread;
                            const double controlY = -70;

                            final double cx = (1 - t) * (1 - t) * (1 - t) * x0 +
                                3 * (1 - t) * (1 - t) * t * x1 +
                                3 * (1 - t) * t * t * x2 +
                                t * t * t * x3;
                            final double cy = (1 - t) * (1 - t) * (1 - t) * y0 +
                                3 * (1 - t) * (1 - t) * t * controlY +
                                3 * (1 - t) * t * t * controlY +
                                t * t * t * y3;

                            return SizedBox(
                              height: height,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned.fill(
                                    child: RepaintBoundary(
                                      child: CustomPaint(
                                        painter: _CubicCurvePainter(
                                          x0,
                                          y0,
                                          x1,
                                          controlY,
                                          x2,
                                          controlY,
                                          x3,
                                          y3,
                                          t,
                                          d.isDayTime,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: cx - (iconSize / 2),
                                    top: cy - (iconSize / 2),
                                    child: ClipRect(
                                      clipper:
                                          _HorizonClipper(cy, y0, iconSize),
                                      child: Image.asset(
                                        d.isDayTime
                                            ? 'assets/icons/f_sun.png'
                                            : 'assets/icons/output_moon1.png',
                                        width: iconSize,
                                        height: iconSize,
                                        color: iconTint,
                                        colorBlendMode: iconTint != null
                                            ? BlendMode.srcIn
                                            : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      // ২. ওপরের সেকশন: বড় ডিজিটাল ঘড়ি এবং কাউন্টডাউন (এটি ওপরে ভেসে থাকবে)
                      // Positioned(
                      //   top: 50, // ইমেজের ওপর থেকে পজিশন
                      //   left: 0,
                      //   right: 0,
                      //   child: Column(
                      //     children: [
                      //       Row(
                      //         mainAxisAlignment: MainAxisAlignment.center,
                      //         children: [
                      //           Text(
                      //             DateFormat('hh:mm').format(now),
                      //             style: const TextStyle(
                      //               fontSize: 60, // একটু বড় করলাম
                      //               fontWeight: FontWeight.w200,
                      //               color: Colors.white,
                      //               letterSpacing: -2,
                      //             ),
                      //           ),
                      //           Text(
                      //             DateFormat('a').format(now),
                      //             style: const TextStyle(
                      //                 color: Colors.white70,
                      //                 fontWeight: FontWeight.bold),
                      //           ),
                      //           const SizedBox(width: 8),
                      //         ],
                      //       ),
                      //       // const Text(
                      //       //   "Next: Asr in 01h 20m",
                      //       //   style: TextStyle(
                      //       //       color: Colors.amberAccent,
                      //       //       fontWeight: FontWeight.w500),
                      //       // ),
                      //     ],
                      //   ),
                      // ),

                      // ৩. একদম নিচের রো: Sunrise এবং Sunset টাইম
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _TimeColumn(
                                  label: l.sunrise,
                                  time: d.sunriseText,
                                  alignment: CrossAxisAlignment.start),
                              _CenterColumn(
                                  isDayTime: d.isDayTime,
                                  sunset: d.sunsetText,
                                  fajr: d.fajrTimeText),
                              _TimeColumn(
                                  label: l.sunset,
                                  time: d.sunsetText,
                                  alignment: CrossAxisAlignment.end),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _TimeColumn extends StatelessWidget {
  final String label;
  final String time;
  final CrossAxisAlignment alignment;

  const _TimeColumn({
    required this.label,
    required this.time,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 4.0,
                color: Colors.black54,
                offset: Offset(2.0, 2.0),
              ),
            ],
          ),
        ),
        Text(
          // 🔥 অ্যাপের ল্যাঙ্গুয়েজ বাংলা হলে সংখ্যা বাংলা হবে, ইংরেজি হলে ইংরেজিই থাকবে
          formatTimeByLanguage(context, time),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 4.0,
                color: Colors.black54,
                offset: Offset(2.0, 2.0),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CenterColumn extends StatelessWidget {
  final bool isDayTime;
  final String sunset;
  final String fajr;

  const _CenterColumn({
    required this.isDayTime,
    required this.sunset,
    required this.fajr,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      children: [
        Text(
          isDayTime ? l.iftar : l.sehri,
          style: Theme.of(context).title.copyWith(
            color: Colors.white,
            shadows: [
              const Shadow(
                blurRadius: 4.0,
                color: Colors.black54,
                offset: Offset(2.0, 2.0),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          // 🔥 এখানেও অ্যাপের ল্যাঙ্গুয়েজ অনুযায়ী কন্ডিশনাল টাইমটি ফরম্যাট হবে
          formatTimeByLanguage(context, isDayTime ? sunset : fajr),
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 4.0,
                color: Colors.black54,
                offset: Offset(2.0, 2.0),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String formatTimeByLanguage(BuildContext context, String englishTime) {
  // অ্যাপের বর্তমান ভাষা যদি বাংলা না হয়, তবে যেভাবে আছে সেভাবেই রিটার্ন করবে
  if (Localizations.localeOf(context).languageCode != 'bn') {
    return englishTime;
  }

  // বাংলা ভাষার জন্য শুধু সংখ্যাগুলোকে পরিবর্তন করবে, AM/PM ঠিক রাখবে
  final Map<String, String> banglaDigits = {
    '0': '০',
    '1': '১',
    '2': '২',
    '3': '৩',
    '4': '৪',
    '5': '৫',
    '6': '৬',
    '7': '৭',
    '8': '৮',
    '9': '৯',
  };

  String result = '';
  for (int i = 0; i < englishTime.length; i++) {
    final char = englishTime[i];
    if (banglaDigits.containsKey(char)) {
      result += banglaDigits[char]!;
    } else {
      result += char; // AM, PM, কোলন বা স্পেস অপরিবর্তিত থাকবে
    }
  }

  return result;
}

class _CubicCurvePainter extends CustomPainter {
  final double x0, y0, x1, y1, x2, y2, x3, y3;
  final double animationValue;
  final bool isDayTime;

  const _CubicCurvePainter(
    this.x0,
    this.y0,
    this.x1,
    this.y1,
    this.x2,
    this.y2,
    this.x3,
    this.y3,
    this.animationValue,
    this.isDayTime,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDayTime
          ? Colors.yellow.withValues(alpha: 0.2)
          : Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(x0, y0)
      ..cubicTo(x1, y1, x2, y2, x3, y3);

    for (final metric in path.computeMetrics()) {
      canvas.drawPath(
          metric.extractPath(0, metric.length * animationValue), paint);
    }
  }

  @override
  bool shouldRepaint(_CubicCurvePainter old) =>
      old.animationValue != animationValue || old.isDayTime != isDayTime;
}

class _HorizonClipper extends CustomClipper<Rect> {
  final double currentY;
  final double horizonY;
  final double iconSize;

  const _HorizonClipper(this.currentY, this.horizonY, this.iconSize);

  @override
  Rect getClip(Size size) {
    final clipH =
        (horizonY - currentY + (iconSize / 2)).clamp(0.0, size.height);
    return Rect.fromLTRB(0, 0, size.width, clipH);
  }

  @override
  bool shouldReclip(_HorizonClipper old) =>
      old.currentY != currentY || old.horizonY != horizonY;
}
