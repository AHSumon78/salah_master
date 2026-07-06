import 'package:flutter/material.dart';


class AppText {
  static TextStyle title(BuildContext context) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary(context),
      letterSpacing: 0.2,
    );
  }

  static TextStyle subtitle(BuildContext context) {
    return TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary(context),
      height: 1.3,
    );
  }

  static TextStyle time(BuildContext context) {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: AppColors.accent(context),
      letterSpacing: 0.3,
    );
  }

  static TextStyle chip(BuildContext context) {
    return TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary(context),
    );
  }

  static TextStyle caption(BuildContext context) {
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.muted(context),
    );
  }
}

class AppColors {
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color textPrimary(BuildContext context) =>
      isDark(context) ? Colors.white : Colors.black87;

  static Color textSecondary(BuildContext context) =>
      isDark(context) ? Colors.white70 : Colors.black54;

  static Color muted(BuildContext context) =>
      isDark(context) ? Colors.white60 : Colors.black45;

  static Color accent(BuildContext context) =>
      isDark(context) ? Colors.tealAccent : Colors.teal;
}