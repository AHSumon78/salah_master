import 'dart:ui';
import 'package:alarm/screens/home_screen.dart';
import 'package:alarm/screens/maps/locations_list_screen.dart';
import 'package:alarm/screens/maps/MosqueLocatorScreen.dart';
import 'package:alarm/screens/others_alarm/other_alarms_screen.dart';
import 'package:alarm/screens/utilities/qibla_finder.dart';
import 'package:alarm/services/app_theme_extension.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  final List<IconData> icons = [
    Icons.home,
    Icons.alarm,
    Icons.explore,
    Icons.location_on,
    Icons.mosque,
  ];

  final List<String> labels = [
    "Home",
    "Alarm",
    "Qibla",
    "Places",
    "Mosque",
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    setState(() {
      _currentPageIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent, // পুরো স্ক্রিন স্বচ্ছ
      body: Stack(
        children: [
          // ১. সবার নিচে ব্যাকগ্রাউন্ড গ্রেডিয়েন্ট
          // Positioned.fill(
          //   child: Container(
          //     decoration: const BoxDecoration(
          //       gradient: LinearGradient(
          //         colors: [Color(0xFF0F2027), Color(0xFF2C5364)],
          //         begin: Alignment.topCenter,
          //         end: Alignment.bottomCenter,
          //       ),
          //     ),
          //   ),
          // ),

          // ২. পেজ ভিউ (কন্টেন্ট)। এটি এখন পুরো স্ক্রিন জুড়ে আছে।
          Positioned.fill(
            bottom: -15,
            child: PageView(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) =>
                  setState(() => _currentPageIndex = index),
              children: const [
                HomeScreen(),
                OtherAlarmsScreen(),
                QiblaFinderScreen(),
                LocationsListScreen(),
                MosqueLocatorScreen(),
              ],
            ),
          ),

          // ৩. আপনার কাস্টম বটম বার (সবার উপরে ভাসমান বা Floating)
          Positioned(
            left: 12,
            right: 12,
            bottom: 20, // নিচ থেকে ২০ পিক্সেল উপরে ভাসবে
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter:
                    ImageFilter.blur(sigmaX: 2, sigmaY: 2), // ব্লার কমানো হয়েছে
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).navBarBackground,
                    // হালকা স্বচ্ছ সাদা
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.05),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(icons.length, (index) {
                      final isSelected = _currentPageIndex == index;
                      return GestureDetector(
                        onTap: () => _onTap(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).navSelectedBackground
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                icons[index],
                                color: isSelected
                                    ? Theme.of(context).navSelectedIconColor
                                    : Theme.of(context).iconColor,
                              ),
                              // if (isSelected) ...[
                              //   const SizedBox(width: 6),
                              //   Text(
                              //     labels[index],
                              //     style: Theme.of(context).title,
                              //   ),
                              // ]
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
