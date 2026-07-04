import 'package:alarm/services/app_theme_extension.dart';
import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final bool safeArea;

  const AppBackground({
    super.key,
    required this.child,
    this.safeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget content = Container(
      decoration: BoxDecoration(
        color: Theme.of(context).appBackground,
        // gradient: LinearGradient(
        //   colors: isDark
        //       ? const [Color(0xFF0F2027), Color(0xFF2C5364)]
        //       : const [Color(0xFFE0F7FA), Color(0xFFB2DFDB)],
        //   begin: Alignment.topCenter,
        //   end: Alignment.bottomCenter,
        // ),
      ),
      child: child,
    );

    // optional SafeArea
    if (safeArea) {
      content = SafeArea(child: content);
    }

    return content;
  }
}
