import 'dart:ui';
import 'package:alarm/services/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppBarCommon extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final double opacity;
  final List<Widget>? actions;
  final Widget? leading;
  final double? leadingWidth;

  const AppBarCommon({
    super.key,
    required this.title,
    this.opacity = 1.0,
    this.actions,
    this.leading,
    this.leadingWidth,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      leading: leading,
      leadingWidth: leadingWidth,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors
            .transparent, // স্ট্যাটাসবার ট্রান্সপারেন্ট থাকবে যাতে গ্রেডিয়েন্ট দেখা যায়
        statusBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark, // ডার্ক মোডে আইকন সাদা, লাইট মোডে কালো
        statusBarBrightness: isDark
            ? Brightness.dark
            : Brightness.light, // iOS এর জন্য সেফটি গার্ড
      ),
      title: Text(
        title,
        style: Theme.of(context).title.copyWith(fontSize: 25),
      ),
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: Theme.of(context).iconColor),
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).appBarColor,
              // gradient: LinearGradient(
              //   stops: const [0.95, 1.0],
              //   colors: isDark
              //       ? [
              //           const Color(0xFF0F2027).withOpacity(0.75),
              //           const Color.fromARGB(255, 59, 115, 237)
              //               .withOpacity(0.55),
              //         ]
              //       : [
              //           const Color.fromARGB(255, 48, 222, 204),
              //           const Color.fromARGB(255, 59, 115, 237)
              //               .withOpacity(0.55),
              //         ],
              //   begin: Alignment.topCenter, // উপর থেকে শুরু হবে 🔥
              //   end: Alignment.bottomCenter, // নিচে গিয়ে শেষ হবে 🔥
              // ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
