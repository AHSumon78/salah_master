import 'package:alarm/screens/commons/appBar_background.dart';
import 'package:alarm/screens/commons/app_background.dart';
import 'package:alarm/screens/commons/app_card.dart';
import 'package:alarm/services/app_theme_extension.dart';
import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';
    final copy = isBn ? _HelpCopy.bn() : _HelpCopy.en();

    return Scaffold(
      appBar: AppBarCommon(title: copy.title),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _IntroPanel(copy: copy),
            _SectionHeader(title: copy.quickStartTitle),
            _StepTile(
              number: '1',
              icon: Icons.location_on_outlined,
              title: copy.stepLocationTitle,
              body: copy.stepLocationBody,
            ),
            _StepTile(
              number: '2',
              icon: Icons.alarm_add_outlined,
              title: copy.stepAlarmTitle,
              body: copy.stepAlarmBody,
            ),
            _StepTile(
              number: '3',
              icon: Icons.settings_outlined,
              title: copy.stepPermissionTitle,
              body: copy.stepPermissionBody,
            ),
            _SectionHeader(title: copy.featuresTitle),
            _FeatureTile(
              icon: Icons.mosque_outlined,
              title: copy.prayerAlarmTitle,
              body: copy.prayerAlarmBody,
            ),
            _FeatureTile(
              icon: Icons.widgets_outlined,
              title: copy.widgetTitle,
              body: copy.widgetBody,
            ),
            _FeatureTile(
              icon: Icons.do_not_disturb_on_outlined,
              title: copy.autoSilentTitle,
              body: copy.autoSilentBody,
            ),
            _FeatureTile(
              icon: Icons.explore_outlined,
              title: copy.qiblaTitle,
              body: copy.qiblaBody,
            ),
            _SectionHeader(title: copy.permissionsTitle),
            _PermissionTile(
              icon: Icons.notifications_active_outlined,
              title: copy.notificationPermission,
              body: copy.notificationPermissionBody,
            ),
            _PermissionTile(
              icon: Icons.alarm_on_outlined,
              title: copy.exactAlarmPermission,
              body: copy.exactAlarmPermissionBody,
            ),
            _PermissionTile(
              icon: Icons.battery_saver_outlined,
              title: copy.batteryPermission,
              body: copy.batteryPermissionBody,
            ),
            _PermissionTile(
              icon: Icons.fullscreen_outlined,
              title: copy.fullScreenPermission,
              body: copy.fullScreenPermissionBody,
            ),
            _SectionHeader(title: copy.troubleshootingTitle),
            _HelpExpansionTile(
              icon: Icons.alarm_off_outlined,
              title: copy.alarmNotRingingTitle,
              body: copy.alarmNotRingingBody,
            ),
            _HelpExpansionTile(
              icon: Icons.update_outlined,
              title: copy.widgetNotUpdatingTitle,
              body: copy.widgetNotUpdatingBody,
            ),
            _HelpExpansionTile(
              icon: Icons.location_disabled_outlined,
              title: copy.locationWrongTitle,
              body: copy.locationWrongBody,
            ),
            _HelpExpansionTile(
              icon: Icons.volume_off_outlined,
              title: copy.silentNotWorkingTitle,
              body: copy.silentNotWorkingBody,
            ),
            _SectionHeader(title: copy.faqTitle),
            _HelpExpansionTile(
              icon: Icons.access_time_outlined,
              title: copy.prayerTimeFaqTitle,
              body: copy.prayerTimeFaqBody,
            ),
            _HelpExpansionTile(
              icon: Icons.privacy_tip_outlined,
              title: copy.privacyFaqTitle,
              body: copy.privacyFaqBody,
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroPanel extends StatelessWidget {
  final _HelpCopy copy;

  const _IntroPanel({required this.copy});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).iconColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.help_outline, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              copy.introTitle,
              style: Theme.of(context).title.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              copy.introBody,
              style: Theme.of(context).subtitle.copyWith(height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final String number;
  final IconData icon;
  final String title;
  final String body;

  const _StepTile({
    required this.number,
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        minLeadingWidth: 48,
        leading: _NumberedIcon(number: number, icon: icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(body),
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).iconColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(body),
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).iconColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(body),
        ),
        trailing: const Icon(Icons.check_circle_outline, color: Colors.teal),
      ),
    );
  }
}

class _HelpExpansionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _HelpExpansionTile({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ExpansionTile(
        leading: Icon(icon, color: Theme.of(context).iconColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        childrenPadding: const EdgeInsets.fromLTRB(72, 0, 16, 16),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              body,
              style: Theme.of(context).subtitle.copyWith(height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberedIcon extends StatelessWidget {
  final String number;
  final IconData icon;

  const _NumberedIcon({required this.number, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Theme.of(context).iconColor, size: 21),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
              ),
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpCopy {
  final String title;
  final String introTitle;
  final String introBody;
  final String quickStartTitle;
  final String stepLocationTitle;
  final String stepLocationBody;
  final String stepAlarmTitle;
  final String stepAlarmBody;
  final String stepPermissionTitle;
  final String stepPermissionBody;
  final String featuresTitle;
  final String prayerAlarmTitle;
  final String prayerAlarmBody;
  final String widgetTitle;
  final String widgetBody;
  final String autoSilentTitle;
  final String autoSilentBody;
  final String qiblaTitle;
  final String qiblaBody;
  final String permissionsTitle;
  final String notificationPermission;
  final String notificationPermissionBody;
  final String exactAlarmPermission;
  final String exactAlarmPermissionBody;
  final String batteryPermission;
  final String batteryPermissionBody;
  final String fullScreenPermission;
  final String fullScreenPermissionBody;
  final String troubleshootingTitle;
  final String alarmNotRingingTitle;
  final String alarmNotRingingBody;
  final String widgetNotUpdatingTitle;
  final String widgetNotUpdatingBody;
  final String locationWrongTitle;
  final String locationWrongBody;
  final String silentNotWorkingTitle;
  final String silentNotWorkingBody;
  final String faqTitle;
  final String prayerTimeFaqTitle;
  final String prayerTimeFaqBody;
  final String privacyFaqTitle;
  final String privacyFaqBody;

  const _HelpCopy({
    required this.title,
    required this.introTitle,
    required this.introBody,
    required this.quickStartTitle,
    required this.stepLocationTitle,
    required this.stepLocationBody,
    required this.stepAlarmTitle,
    required this.stepAlarmBody,
    required this.stepPermissionTitle,
    required this.stepPermissionBody,
    required this.featuresTitle,
    required this.prayerAlarmTitle,
    required this.prayerAlarmBody,
    required this.widgetTitle,
    required this.widgetBody,
    required this.autoSilentTitle,
    required this.autoSilentBody,
    required this.qiblaTitle,
    required this.qiblaBody,
    required this.permissionsTitle,
    required this.notificationPermission,
    required this.notificationPermissionBody,
    required this.exactAlarmPermission,
    required this.exactAlarmPermissionBody,
    required this.batteryPermission,
    required this.batteryPermissionBody,
    required this.fullScreenPermission,
    required this.fullScreenPermissionBody,
    required this.troubleshootingTitle,
    required this.alarmNotRingingTitle,
    required this.alarmNotRingingBody,
    required this.widgetNotUpdatingTitle,
    required this.widgetNotUpdatingBody,
    required this.locationWrongTitle,
    required this.locationWrongBody,
    required this.silentNotWorkingTitle,
    required this.silentNotWorkingBody,
    required this.faqTitle,
    required this.prayerTimeFaqTitle,
    required this.prayerTimeFaqBody,
    required this.privacyFaqTitle,
    required this.privacyFaqBody,
  });

  factory _HelpCopy.en() {
    return const _HelpCopy(
      title: 'Help & Guide',
      introTitle: 'Use Salah Master with confidence',
      introBody:
          'This guide explains the setup, permissions, home widget, prayer alarms, and common fixes for reliable daily use.',
      quickStartTitle: 'Quick Start',
      stepLocationTitle: 'Choose your location',
      stepLocationBody:
          'Add or select a location from the home screen. Prayer times and related alarms are calculated from the selected location.',
      stepAlarmTitle: 'Review prayer alarms',
      stepAlarmBody:
          'Prayer alarms appear in the home list. Tap a time or sound to edit it, and use the switch to enable or disable ringing.',
      stepPermissionTitle: 'Grant required permissions',
      stepPermissionBody:
          'Open Settings and grant alarm, notification, battery, full-screen, and Do Not Disturb access for the best reliability.',
      featuresTitle: 'Main Features',
      prayerAlarmTitle: 'Prayer time alarms',
      prayerAlarmBody:
          'Fajr, Dhuhr, Asr, Maghrib, and Isha can be scheduled from calculated prayer times for your location.',
      widgetTitle: 'Home screen widget',
      widgetBody:
          'The widget shows the current prayer status, countdown, Hijri date, sunrise, and sunset. It refreshes at prayer-time changes.',
      autoSilentTitle: 'Auto silent modes',
      autoSilentBody:
          'Location-based and prayer-time based silent modes can help keep the phone quiet during mosque or prayer time.',
      qiblaTitle: 'Qibla and utilities',
      qiblaBody:
          'Use the utility tools for Qibla direction, mosque location, Hijri calendar, duas, and Islamic event reminders.',
      permissionsTitle: 'Permissions',
      notificationPermission: 'Notifications',
      notificationPermissionBody:
          'Needed to show alarm alerts, reminders, and background update messages.',
      exactAlarmPermission: 'Alarms & reminders',
      exactAlarmPermissionBody:
          'Needed for exact prayer alarms and widget refresh events, especially on Android 12 and newer.',
      batteryPermission: 'Battery background access',
      batteryPermissionBody:
          'Allow background activity or disable battery optimization so scheduled alarms are not stopped by the phone.',
      fullScreenPermission: 'Full-screen alert',
      fullScreenPermissionBody:
          'Allows the alarm screen to appear clearly when the phone is locked or the display is off.',
      troubleshootingTitle: 'Troubleshooting',
      alarmNotRingingTitle: 'Alarm is not ringing',
      alarmNotRingingBody:
          'Check that the alarm switch is on, notification permission is granted, battery optimization is disabled, and Alarms & reminders permission is allowed.',
      widgetNotUpdatingTitle: 'Widget is not updating',
      widgetNotUpdatingBody:
          'Open the app once after changing permissions. Make sure Alarms & reminders and battery background access are allowed, then remove and add the widget again if needed.',
      locationWrongTitle: 'Prayer time looks wrong',
      locationWrongBody:
          'Select the correct location from the home screen. If location permission was denied, grant it and reopen the app.',
      silentNotWorkingTitle: 'Auto silent is not working',
      silentNotWorkingBody:
          'Grant Do Not Disturb access, location permission, and background activity permission. Some phone brands require manually enabling background activity in app settings.',
      faqTitle: 'FAQ',
      prayerTimeFaqTitle: 'How are prayer times calculated?',
      prayerTimeFaqBody:
          'The app calculates prayer times from your selected coordinates using the Muslim World League method with Hanafi Asr settings.',
      privacyFaqTitle: 'Is my location shared?',
      privacyFaqBody:
          'Location is used for prayer time and mosque automation features. The app stores required settings locally on your device.',
    );
  }

  factory _HelpCopy.bn() {
    return const _HelpCopy(
      title: 'সাহায্য ও গাইড',
      introTitle: 'সালাহ মাস্টার সহজে ব্যবহার করুন',
      introBody:
          'এই গাইডে সেটআপ, পারমিশন, হোম উইজেট, নামাজের অ্যালার্ম এবং সাধারণ সমস্যার সমাধান দেওয়া আছে।',
      quickStartTitle: 'শুরু করার ধাপ',
      stepLocationTitle: 'লোকেশন নির্বাচন করুন',
      stepLocationBody:
          'হোম স্ক্রিন থেকে লোকেশন যোগ বা নির্বাচন করুন। নির্বাচিত লোকেশন অনুযায়ী নামাজের সময় ও অ্যালার্ম হিসাব হবে।',
      stepAlarmTitle: 'নামাজের অ্যালার্ম দেখুন',
      stepAlarmBody:
          'হোম লিস্টে নামাজের অ্যালার্ম দেখা যাবে। সময় বা সাউন্ডে ট্যাপ করে পরিবর্তন করুন, আর সুইচ দিয়ে চালু বা বন্ধ করুন।',
      stepPermissionTitle: 'প্রয়োজনীয় পারমিশন দিন',
      stepPermissionBody:
          'Settings থেকে alarm, notification, battery, full-screen এবং Do Not Disturb access দিন, যাতে অ্যালার্ম ঠিকমতো কাজ করে।',
      featuresTitle: 'প্রধান ফিচার',
      prayerAlarmTitle: 'নামাজের সময়ের অ্যালার্ম',
      prayerAlarmBody:
          'আপনার লোকেশন অনুযায়ী ফজর, যোহর, আসর, মাগরিব এবং এশার অ্যালার্ম সেট করা যায়।',
      widgetTitle: 'হোম স্ক্রিন উইজেট',
      widgetBody:
          'উইজেটে বর্তমান ওয়াক্ত, কাউন্টডাউন, হিজরি তারিখ, সূর্যোদয় ও সূর্যাস্ত দেখা যায়। ওয়াক্ত পরিবর্তনের সময় এটি রিফ্রেশ হয়।',
      autoSilentTitle: 'অটো সাইলেন্ট মোড',
      autoSilentBody:
          'লোকেশন বা নামাজের সময় অনুযায়ী ফোন সাইলেন্ট করার সুবিধা আছে, যেন মসজিদ বা নামাজের সময় ফোন শান্ত থাকে।',
      qiblaTitle: 'কিবলা ও ইউটিলিটি',
      qiblaBody:
          'কিবলা, মসজিদ লোকেশন, হিজরি ক্যালেন্ডার, দোয়া এবং ইসলামিক ইভেন্ট রিমাইন্ডার ব্যবহার করতে পারবেন।',
      permissionsTitle: 'পারমিশন',
      notificationPermission: 'নোটিফিকেশন',
      notificationPermissionBody:
          'অ্যালার্ম, রিমাইন্ডার এবং ব্যাকগ্রাউন্ড আপডেট মেসেজ দেখানোর জন্য দরকার।',
      exactAlarmPermission: 'Alarms & reminders',
      exactAlarmPermissionBody:
          'নির্ভুল নামাজের অ্যালার্ম এবং উইজেট রিফ্রেশের জন্য দরকার, বিশেষ করে Android 12 বা তার পরের ভার্সনে।',
      batteryPermission: 'ব্যাকগ্রাউন্ড ব্যাটারি অ্যাক্সেস',
      batteryPermissionBody:
          'Allow background activity চালু করুন বা battery optimization বন্ধ করুন, যাতে ফোন scheduled alarm বন্ধ না করে।',
      fullScreenPermission: 'ফুল-স্ক্রিন অ্যালার্ট',
      fullScreenPermissionBody:
          'ফোন লক বা স্ক্রিন বন্ধ থাকলেও অ্যালার্ম স্ক্রিন দেখানোর জন্য দরকার।',
      troubleshootingTitle: 'সমস্যার সমাধান',
      alarmNotRingingTitle: 'অ্যালার্ম বাজছে না',
      alarmNotRingingBody:
          'অ্যালার্ম সুইচ চালু আছে কিনা, notification permission, battery optimization এবং Alarms & reminders permission ঠিক আছে কিনা দেখুন।',
      widgetNotUpdatingTitle: 'উইজেট আপডেট হচ্ছে না',
      widgetNotUpdatingBody:
          'পারমিশন পরিবর্তনের পর একবার অ্যাপ খুলুন। Alarms & reminders এবং background activity allowed আছে কিনা দেখুন। দরকার হলে উইজেট remove করে আবার add করুন।',
      locationWrongTitle: 'নামাজের সময় ভুল দেখাচ্ছে',
      locationWrongBody:
          'হোম স্ক্রিন থেকে সঠিক লোকেশন নির্বাচন করুন। Location permission denied থাকলে allow করে অ্যাপ আবার খুলুন।',
      silentNotWorkingTitle: 'অটো সাইলেন্ট কাজ করছে না',
      silentNotWorkingBody:
          'Do Not Disturb access, location permission এবং background activity permission দিন। কিছু ফোনে app settings থেকে manually background activity allow করতে হয়।',
      faqTitle: 'সাধারণ প্রশ্ন',
      prayerTimeFaqTitle: 'নামাজের সময় কীভাবে হিসাব হয়?',
      prayerTimeFaqBody:
          'নির্বাচিত coordinates থেকে Muslim World League method এবং Hanafi Asr settings ব্যবহার করে সময় হিসাব করা হয়।',
      privacyFaqTitle: 'আমার লোকেশন কি শেয়ার হয়?',
      privacyFaqBody:
          'লোকেশন নামাজের সময় ও মসজিদ automation ফিচারের জন্য ব্যবহার হয়। প্রয়োজনীয় সেটিংস ডিভাইসেই local ভাবে রাখা হয়।',
    );
  }
}
