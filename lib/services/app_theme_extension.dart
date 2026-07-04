import 'package:flutter/material.dart';

extension AppTextExtension on ThemeData {
  TextStyle get title {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: brightness == Brightness.dark ? Colors.white : Colors.black87,
      letterSpacing: 0.2,
    );
  }

  TextStyle get subtitle {
    return TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: brightness == Brightness.dark ? Colors.white70 : Colors.black54,
      height: 1.3,
    );
  }

  TextStyle get time {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: brightness == Brightness.dark ? Colors.tealAccent : Colors.teal,
      letterSpacing: 0.3,
    );
  }

  TextStyle get chip {
    return TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: brightness == Brightness.dark ? Colors.white70 : Colors.black54,
    );
  }

  TextStyle get caption {
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: brightness == Brightness.dark ? Colors.white60 : Colors.black45,
    );
  }

  Color get appBackground {
    return brightness == Brightness.dark
        ? const Color(0xFF0F2027)
        : const Color(0xFFF3F3F3);
  }

  Color get appBarColor {
    return brightness == Brightness.dark
        ? const Color(0xFF0F2027)
        : const Color(0xFFF3F3F3);
  }

  // কার্ড বা কন্টেইনারের ভেতরের ব্যাকগ্রাউন্ড কালার
  Color get cardBackground {
    return brightness == Brightness.dark
        ? const Color.fromARGB(255, 8, 17, 21)
        : const Color(0xFFFFFFFF);
  }

  // ডিভাইডার বা বর্ডার লাইনের কালার
  Color get customDivider {
    return brightness == Brightness.dark
        ? const Color(0xFF49454F)
        : const Color(0xFFE0E0E0);
  }

  Color get textColor {
    return brightness == Brightness.dark ? Colors.white : Colors.black87;
  }

  Color get iconColor {
    //return Colors.teal.shade700;
    return brightness == Brightness.dark
        ? Colors.white70 // Dark mode-e shundor soft white
        : Colors.black54;
  }

  Color get arabicColor {
    final Color targetTeal = brightness == Brightness.dark
        ? Colors.tealAccent
        : Colors.teal.shade600;
    return Color.lerp(textColor, targetTeal, 0.5)!;
  }

  Color get dayColor {
    final Color targetTeal = brightness == Brightness.dark
        ? Colors.teal.shade600
        : Colors.tealAccent;
    return Color.lerp(textColor, targetTeal, 0.5)!;
  }

  // ১. বোতামটি সিলেক্ট হলে তার ব্যাকগ্রাউন্ড কালার কেমন হবে
  Color get navSelectedBackground {
    return brightness == Brightness.dark
        ? const Color(0xFF1F404D) // Dark mode-e ektu deep slate-teal tile
        : const Color(0xFF26A69A).withValues(
            alpha: 0.3); // Light mode-e khub soft structural transparent teal
  }

  // ২. সিলেক্টেড আইকনের কালার (আইকন যেন টেক্সট ডিজাইনের সাথে ফুটে ওঠে)
  Color get navSelectedIconColor {
    return brightness == Brightness.dark
        ? Colors.tealAccent // Dark mode-e bright glowing accent
        : const Color(0xFF00796B); // Light mode-e perfectly readable deep teal
  }

  // ৩. বটম বারের নিজস্ব মেইন কন্টেইনার ব্যাকগ্রাউন্ড কালার (গ্লাস ইফেক্ট আরও চমৎকার করতে)
  Color get navBarBackground {
    return brightness == Brightness.dark
        ? const Color(0xFF0F2027).withValues(alpha: 0.4)
        : const Color(0xFFFFFFFF).withValues(alpha: 0.4);
  }
}
