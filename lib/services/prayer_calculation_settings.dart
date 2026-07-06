import 'package:shared_preferences/shared_preferences.dart';

const String prayerMadhabPreferenceKey = 'prayer_madhab';
const String defaultPrayerMadhabCode = 'hanafi';

const String prayerCalculationMethodKey = 'prayer_calculation_method';
const String defaultCalculationMethod = 'muslim_world_league';

// ==================== MADHAB ====================

String prayerMadhabLabel(String code) {
  return switch (code) {
    'shafi' => 'Shafi / Maliki / Hanbali',
    _ => 'Hanafi',
  };
}

Future<String> getSavedPrayerMadhabCode() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString(prayerMadhabPreferenceKey);
  if (saved == null) {
    await prefs.setString(prayerMadhabPreferenceKey, defaultPrayerMadhabCode);
    return defaultPrayerMadhabCode;
  }
  return saved;
}

Future<void> savePrayerMadhabCode(String code) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(prayerMadhabPreferenceKey, code);
}

// ==================== CALCULATION METHOD ====================

Future<String> getSavedCalculationMethod() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString(prayerCalculationMethodKey);
  if (saved == null) {
    await prefs.setString(prayerCalculationMethodKey, defaultCalculationMethod);
    return defaultCalculationMethod;
  }
  return saved;
}

Future<void> saveCalculationMethod(String method) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(prayerCalculationMethodKey, method);
}

String getCalculationMethodLabel(String code) {
  switch (code) {
    case 'muslim_world_league':
      return 'Muslim World League';
    case 'egyptian':
      return 'Egyptian General Authority';
    case 'karachi':
      return 'Karachi';
    case 'umm_al_qura':
      return 'Umm Al-Qura (Makkah)';
    case 'dubai':
      return 'Dubai';
    case 'qatar':
      return 'Qatar';
    case 'kuwait':
      return 'Kuwait';
    default:
      return 'Muslim World League';
  }
}
