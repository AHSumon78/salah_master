import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Salah Master'**
  String get appName;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help & Guide'**
  String get help;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @alarmBehavior.
  ///
  /// In en, this message translates to:
  /// **'ALARM BEHAVIOR'**
  String get alarmBehavior;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @gradualVolumeIncrease.
  ///
  /// In en, this message translates to:
  /// **'Gradual Volume Increase'**
  String get gradualVolumeIncrease;

  /// No description provided for @snoozeLimit.
  ///
  /// In en, this message translates to:
  /// **'Snooze Limit'**
  String get snoozeLimit;

  /// No description provided for @times.
  ///
  /// In en, this message translates to:
  /// **'Times'**
  String get times;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @min.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get min;

  /// No description provided for @snoozeDuration.
  ///
  /// In en, this message translates to:
  /// **'Snooze Duration'**
  String get snoozeDuration;

  /// No description provided for @autoStopAlarm.
  ///
  /// In en, this message translates to:
  /// **'Auto Stop Alarm'**
  String get autoStopAlarm;

  /// No description provided for @displayAndAccess.
  ///
  /// In en, this message translates to:
  /// **'DISPLAY & ACCESS'**
  String get displayAndAccess;

  /// No description provided for @locationPermission.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationPermission;

  /// No description provided for @locationPermissionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Required for prayer times, qibla, nearby mosques, and location alarms'**
  String get locationPermissionSubtitle;

  /// No description provided for @notificationPermission.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationPermission;

  /// No description provided for @notificationPermissionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Required to show prayer alarm and reminder alerts'**
  String get notificationPermissionSubtitle;

  /// No description provided for @batteryOptimization.
  ///
  /// In en, this message translates to:
  /// **'Battery Optimization'**
  String get batteryOptimization;

  /// No description provided for @batteryOptimizationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Required For Accuracy'**
  String get batteryOptimizationSubtitle;

  /// No description provided for @alarmsAndRemindersPermission.
  ///
  /// In en, this message translates to:
  /// **'Alarms & reminders'**
  String get alarmsAndRemindersPermission;

  /// No description provided for @alarmsAndRemindersPermissionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Required for accurate prayer alarms and widget refresh'**
  String get alarmsAndRemindersPermissionSubtitle;

  /// No description provided for @fullScreenIntent.
  ///
  /// In en, this message translates to:
  /// **'Full Screen Intent'**
  String get fullScreenIntent;

  /// No description provided for @fullScreenIntentsubtitle.
  ///
  /// In en, this message translates to:
  /// **'Full Screen Alarm Popup'**
  String get fullScreenIntentsubtitle;

  /// No description provided for @granted.
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get granted;

  /// No description provided for @grant.
  ///
  /// In en, this message translates to:
  /// **'Grant'**
  String get grant;

  /// No description provided for @doNotDisturbAccess.
  ///
  /// In en, this message translates to:
  /// **'Do Not Disturb Access'**
  String get doNotDisturbAccess;

  /// No description provided for @doNotDisturbAccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Silent mode override'**
  String get doNotDisturbAccessSubtitle;

  /// No description provided for @audioFilesPermission.
  ///
  /// In en, this message translates to:
  /// **'Audio files'**
  String get audioFilesPermission;

  /// No description provided for @audioFilesPermissionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Required only when choosing a custom alarm sound'**
  String get audioFilesPermissionSubtitle;

  /// No description provided for @userManual.
  ///
  /// In en, this message translates to:
  /// **'User Manual'**
  String get userManual;

  /// No description provided for @prayerTimeTracking.
  ///
  /// In en, this message translates to:
  /// **'Prayer Time Tracking'**
  String get prayerTimeTracking;

  /// No description provided for @prayerTimeTrackingDescription.
  ///
  /// In en, this message translates to:
  /// **'travel'**
  String get prayerTimeTrackingDescription;

  /// No description provided for @autoSilent.
  ///
  /// In en, this message translates to:
  /// **'Auto Silent'**
  String get autoSilent;

  /// No description provided for @autoSilentDescription.
  ///
  /// In en, this message translates to:
  /// **'Auto Silent Description'**
  String get autoSilentDescription;

  /// No description provided for @alarmSound.
  ///
  /// In en, this message translates to:
  /// **'Alarm Sound'**
  String get alarmSound;

  /// No description provided for @alarmSoundDescription.
  ///
  /// In en, this message translates to:
  /// **'Alarm sound Description'**
  String get alarmSoundDescription;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'ADVANCED'**
  String get advanced;

  /// No description provided for @preAlarmReminder.
  ///
  /// In en, this message translates to:
  /// **'Pre-Alarm Reminder'**
  String get preAlarmReminder;

  /// No description provided for @loactionBaseAutoSilent.
  ///
  /// In en, this message translates to:
  /// **'Location Base Auto Silent'**
  String get loactionBaseAutoSilent;

  /// No description provided for @loactionBaseAutoSilentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically silent phone near mosque'**
  String get loactionBaseAutoSilentSubtitle;

  /// No description provided for @prayerTimeBaseAutoSilent.
  ///
  /// In en, this message translates to:
  /// **'Prayer Time Base Auto Silent'**
  String get prayerTimeBaseAutoSilent;

  /// No description provided for @prayerTimeBaseAutoSilentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically silent phone at prayer time'**
  String get prayerTimeBaseAutoSilentSubtitle;

  /// No description provided for @qiblaFinder.
  ///
  /// In en, this message translates to:
  /// **'Qibla Finder'**
  String get qiblaFinder;

  /// No description provided for @adjust.
  ///
  /// In en, this message translates to:
  /// **'Try to Adjust'**
  String get adjust;

  /// No description provided for @south.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get south;

  /// No description provided for @north.
  ///
  /// In en, this message translates to:
  /// **'N'**
  String get north;

  /// No description provided for @east.
  ///
  /// In en, this message translates to:
  /// **'E'**
  String get east;

  /// No description provided for @west.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get west;

  /// No description provided for @qiblaDirection.
  ///
  /// In en, this message translates to:
  /// **'Qibla Direction'**
  String get qiblaDirection;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @heading.
  ///
  /// In en, this message translates to:
  /// **'Heading'**
  String get heading;

  /// No description provided for @alarmsLocations.
  ///
  /// In en, this message translates to:
  /// **'Alarms Locations'**
  String get alarmsLocations;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @office.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get office;

  /// No description provided for @locationsUses.
  ///
  /// In en, this message translates to:
  /// **'Locations Uses'**
  String get locationsUses;

  /// No description provided for @locationsUsesDescription.
  ///
  /// In en, this message translates to:
  /// **'• You can add and edit your locations.\n\n• For different Locations there are different set of alarms.\n\n• When you enter at specific location then these alarm will be active only automatic.'**
  String get locationsUsesDescription;

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get understood;

  /// No description provided for @nearbymosquesList.
  ///
  /// In en, this message translates to:
  /// **'Nearby Mosques List'**
  String get nearbymosquesList;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @find.
  ///
  /// In en, this message translates to:
  /// **'Find'**
  String get find;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @sunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunrise;

  /// No description provided for @sunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get sunset;

  /// No description provided for @sehri.
  ///
  /// In en, this message translates to:
  /// **'Sehri'**
  String get sehri;

  /// No description provided for @quickSilent.
  ///
  /// In en, this message translates to:
  /// **'Quick Silent'**
  String get quickSilent;

  /// No description provided for @azkar.
  ///
  /// In en, this message translates to:
  /// **'Azkar'**
  String get azkar;

  /// No description provided for @dua.
  ///
  /// In en, this message translates to:
  /// **'Dua & Supplication'**
  String get dua;

  /// No description provided for @fajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get fajr;

  /// No description provided for @dhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get dhuhr;

  /// No description provided for @asr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get asr;

  /// No description provided for @maghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get maghrib;

  /// No description provided for @isha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get isha;

  /// No description provided for @othersAlarm.
  ///
  /// In en, this message translates to:
  /// **'Others Alarms'**
  String get othersAlarm;

  /// No description provided for @noAlarmsSet.
  ///
  /// In en, this message translates to:
  /// **'No Alarm Set'**
  String get noAlarmsSet;

  /// No description provided for @addNewAlarm.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add new alarm'**
  String get addNewAlarm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @addAlarm.
  ///
  /// In en, this message translates to:
  /// **'Add Alarm'**
  String get addAlarm;

  /// No description provided for @editAlarm.
  ///
  /// In en, this message translates to:
  /// **'Edit Alarm'**
  String get editAlarm;

  /// No description provided for @label.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get label;

  /// No description provided for @alrmSound.
  ///
  /// In en, this message translates to:
  /// **'Alarm Sound'**
  String get alrmSound;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get sunday;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get tuesday;

  /// No description provided for @wednestday.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get wednestday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get friday;

  /// No description provided for @once.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get once;

  /// No description provided for @workingdays.
  ///
  /// In en, this message translates to:
  /// **'Workingdays'**
  String get workingdays;

  /// No description provided for @ringPrayer.
  ///
  /// In en, this message translates to:
  /// **'Ring Prayer Alarm '**
  String get ringPrayer;

  /// No description provided for @before.
  ///
  /// In en, this message translates to:
  /// **'before'**
  String get before;

  /// No description provided for @minute.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minute;

  /// No description provided for @manualSilent.
  ///
  /// In en, this message translates to:
  /// **'Manual Silent'**
  String get manualSilent;

  /// No description provided for @manualSilentDescription.
  ///
  /// In en, this message translates to:
  /// **'Select how long you want to silence your phone:'**
  String get manualSilentDescription;

  /// No description provided for @silenceDuration.
  ///
  /// In en, this message translates to:
  /// **'Silence Duration'**
  String get silenceDuration;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @stopSilent.
  ///
  /// In en, this message translates to:
  /// **'Stop Silent'**
  String get stopSilent;

  /// No description provided for @tapToSilence.
  ///
  /// In en, this message translates to:
  /// **'Tap to silence'**
  String get tapToSilence;

  /// No description provided for @everyday.
  ///
  /// In en, this message translates to:
  /// **'Everyday'**
  String get everyday;

  /// No description provided for @weekend.
  ///
  /// In en, this message translates to:
  /// **'Weekend'**
  String get weekend;

  /// No description provided for @deleteAlarm.
  ///
  /// In en, this message translates to:
  /// **'Delete Alarm?'**
  String get deleteAlarm;

  /// No description provided for @deleteAlarmAlert.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this alarm?'**
  String get deleteAlarmAlert;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @aligned.
  ///
  /// In en, this message translates to:
  /// **'Aligned ✅'**
  String get aligned;

  /// No description provided for @km.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get km;

  /// No description provided for @iftar.
  ///
  /// In en, this message translates to:
  /// **'Iftar'**
  String get iftar;

  /// No description provided for @ends.
  ///
  /// In en, this message translates to:
  /// **'ends'**
  String get ends;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next:'**
  String get next;

  /// No description provided for @forbidden.
  ///
  /// In en, this message translates to:
  /// **'Sunrise Time'**
  String get forbidden;

  /// No description provided for @jawal.
  ///
  /// In en, this message translates to:
  /// **'Zawal Time'**
  String get jawal;

  /// No description provided for @forbiddenTime.
  ///
  /// In en, this message translates to:
  /// **'Forbidden'**
  String get forbiddenTime;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get live;

  /// No description provided for @prayer.
  ///
  /// In en, this message translates to:
  /// **'PRAYER'**
  String get prayer;

  /// No description provided for @widgetUpdate.
  ///
  /// In en, this message translates to:
  /// **'Notify When Widgets Update'**
  String get widgetUpdate;

  /// Drawer menu item
  ///
  /// In en, this message translates to:
  /// **'Add Home Screen Widget'**
  String get addHomeScreenWidget;

  /// No description provided for @addHomeScreenWidgetDescription.
  ///
  /// In en, this message translates to:
  /// **'Quickly access prayer times from your home screen'**
  String get addHomeScreenWidgetDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
