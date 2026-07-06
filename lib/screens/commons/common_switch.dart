import 'package:flutter/material.dart';

class CommonSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double scale; // সাইজ কন্ট্রোল করার জন্য (ডিফল্ট ০.৮)
  final Color? activeColor; // থম্বের কালার (যদি কাস্টম দিতে চান)
  final Color? activeTrackColor; // পেছনের ট্র্যাকের কালার

  const CommonSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.scale = 0.8, // মোস্ট স্ট্যান্ডার্ড মিডিয়াম সাইজ ডিফল্ট রাখা হলো
    this.activeColor,
    this.activeTrackColor,
  });

  @override
  Widget build(BuildContext context) {
    // অ্যাপের থিম থেকে প্রাইমারি বা টিল কালার ডিফল্ট হিসেবে নেওয়ার জন্য:
    final defaultActiveColor = activeColor ?? Colors.teal;
    final defaultTrackColor =
        activeTrackColor ?? defaultActiveColor.withValues(alpha: 0.3);

    return Transform.scale(
      scale: scale,
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: defaultActiveColor,
        activeTrackColor: defaultTrackColor,
        // লাইট/ডার্ক মোডে ইন-অ্যাক্টিভ বা বন্ধ থাকা অবস্থার কালার সুন্দর দেখানোর জন্য:
        inactiveThumbColor: Colors.grey.shade400,
        inactiveTrackColor: Colors.grey.shade200,
        thumbIcon:
            WidgetStateProperty.resolveWith<Icon?>((Set<WidgetState> states) {
          // এটি একটি খালি বা একদম ছোট সাইজের আইকন রিটার্ন করবে,
          // যার ফলে ফ্লুটার বাধ্য হয়ে অন/অফ দুই অবস্থাতেই থাম্বের সাইজ সমান (বড়) রাখবে।
          return const Icon(
            IconData(
                0x0000), // ০x০০০০ মানে হলো একটি একদম খালি বা ব্ল্যাঙ্ক ক্যারেক্টার (Blank/Empty Icon)
            size: 0,
          );
        }),
      ),
    );
  }
}
