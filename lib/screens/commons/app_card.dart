import 'package:alarm/services/app_theme_extension.dart';
import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // নিচের দিকে ১ পিক্সেল মার্জিন দিয়েছি যাতে শ্যাডো লাইনটি বোঝা যায়
      margin: const EdgeInsets.only(bottom: 0.5, top: 0.5),

      // প্যাডিং ডিফল্টভাবে একদম জিরো করে দেওয়া হয়েছে
      padding: padding ?? EdgeInsets.zero,

      decoration: BoxDecoration(
        // Perfect Rectangle এর জন্য BorderRadius জিরো
        borderRadius: BorderRadius.zero,

        color: Theme.of(context).cardBackground, // লাইট মোডে সলিড সাদা

        // boxShadow: [
        //   BoxShadow(
        //     // খুব হালকা একটি শ্যাডো যা নিচের দিকে একটি লাইনের মতো মনে হবে
        //     color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
        //     offset: const Offset(0, 1),
        //     blurRadius: 0.5, // ব্লার খুব কম রাখা হয়েছে যাতে লাইনটি শার্প থাকে
        //   )
        // ],
      ),
      child: child,
    );
  }
}
