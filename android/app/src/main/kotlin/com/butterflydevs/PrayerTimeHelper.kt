package com.butterflydevs.salahmaster

import android.app.Application
import android.content.Context
import com.batoulapps.adhan.CalculationMethod
import com.batoulapps.adhan.Coordinates
import com.batoulapps.adhan.PrayerTimes
import com.batoulapps.adhan.Madhab
import com.batoulapps.adhan.data.DateComponents
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale
import java.util.Date

class PrayerTimeHelper(
    private val latitude: Double,
    private val longitude: Double,
    context: Context // 'val' বা 'var' ছাড়া শুধু প্যারামিটার হিসেবে নেওয়া হলো
) {
    // এখানে applicationContext লক করে নেওয়া হলো, যা ১০০% মেমোরি সেফ
    private val appContext = context.applicationContext

    private val timeFormatter = SimpleDateFormat("hh:mm a", Locale.getDefault())
    private val dateKeyFormatter = SimpleDateFormat("yyyy-MM-dd", Locale.US)

    fun getTodayPrayerTimes(): Map<String, String> {
        val calendar = Calendar.getInstance()
        val todayKey = dateKeyFormatter.format(calendar.time)

        // আমাদের সেফ appContext ব্যবহার করা হচ্ছে
        val flutterPrefs = appContext.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val cachePrefs = appContext.getSharedPreferences("WidgetDataCache", Context.MODE_PRIVATE)

        val isCached = cachePrefs.contains("${todayKey}_Fajr")

        if (isCached) {
            return mapOf(
                "Fajr" to (cachePrefs.getString("${todayKey}_Fajr", "--:--") ?: "--:--"),
                "Sunrise" to (cachePrefs.getString("${todayKey}_Sunrise", "--:--") ?: "--:--"),
                "Dhuhr" to (cachePrefs.getString("${todayKey}_Dhuhr", "--:--") ?: "--:--"),
                "Asr" to (cachePrefs.getString("${todayKey}_Asr", "--:--") ?: "--:--"),
                "Maghrib" to (cachePrefs.getString("${todayKey}_Maghrib", "--:--") ?: "--:--"),
                "Isha" to (cachePrefs.getString("${todayKey}_Isha", "--:--") ?: "--:--")
            )
        }

        val coordinates = Coordinates(latitude, longitude)
        val dateComponents = DateComponents.from(calendar.time)

        val methodCode = flutterPrefs.getString("flutter.prayer_calculation_method", "muslim_world_league") ?: "muslim_world_league"
        val madhabCode = flutterPrefs.getString("flutter.prayer_madhab", "hanafi") ?: "hanafi"

        val parameters = when (methodCode) {
            "egyptian" -> CalculationMethod.EGYPTIAN.parameters
            "karachi" -> CalculationMethod.KARACHI.parameters
            "umm_al_qura" -> CalculationMethod.UMM_AL_QURA.parameters
            "dubai" -> CalculationMethod.DUBAI.parameters
            "qatar" -> CalculationMethod.QATAR.parameters
            "kuwait" -> CalculationMethod.KUWAIT.parameters
            else -> CalculationMethod.MUSLIM_WORLD_LEAGUE.parameters
        }

        parameters.madhab = if (madhabCode == "shafi") Madhab.SHAFI else Madhab.HANAFI

        val prayerTimes = PrayerTimes(coordinates, dateComponents, parameters)

        val fajrStr = formatTime(prayerTimes.fajr)
        val sunriseStr = formatTime(prayerTimes.sunrise)
        val dhuhrStr = formatTime(prayerTimes.dhuhr)
        val asrStr = formatTime(prayerTimes.asr)
        val maghribStr = formatTime(prayerTimes.maghrib)
        val ishaStr = formatTime(prayerTimes.isha)

        cachePrefs.edit().apply {
            putString("${todayKey}_Fajr", fajrStr)
            putString("${todayKey}_Sunrise", sunriseStr)
            putString("${todayKey}_Dhuhr", dhuhrStr)
            putString("${todayKey}_Asr", asrStr)
            putString("${todayKey}_Maghrib", maghribStr)
            putString("${todayKey}_Isha", ishaStr)
            apply()
        }

        return mapOf(
            "Fajr" to fajrStr, "Sunrise" to sunriseStr, "Dhuhr" to dhuhrStr,
            "Asr" to asrStr, "Maghrib" to maghribStr, "Isha" to ishaStr
        )
    }
    // ... আপনার আগের সব কোড ঠিক থাকবে ...
// ক্লাসের ভেতরে একদম নিচে এই মেথডটি যোগ করুন:

    fun getRawPrayerTimes(calendar: Calendar): PrayerTimes {
        val flutterPrefs = appContext.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val methodCode = flutterPrefs.getString("flutter.prayer_calculation_method", "muslim_world_league") ?: "muslim_world_league"
        val madhabCode = flutterPrefs.getString("flutter.prayer_madhab", "hanafi") ?: "hanafi"

        val coordinates = Coordinates(latitude, longitude)
        val dateComponents = DateComponents.from(calendar.time)

        val parameters = when (methodCode) {
            "egyptian" -> CalculationMethod.EGYPTIAN.parameters
            "karachi" -> CalculationMethod.KARACHI.parameters
            "umm_al_qura" -> CalculationMethod.UMM_AL_QURA.parameters
            "dubai" -> CalculationMethod.DUBAI.parameters
            "qatar" -> CalculationMethod.QATAR.parameters
            "kuwait" -> CalculationMethod.KUWAIT.parameters
            else -> CalculationMethod.MUSLIM_WORLD_LEAGUE.parameters
        }
        parameters.madhab = if (madhabCode == "shafi") Madhab.SHAFI else Madhab.HANAFI

        return PrayerTimes(coordinates, dateComponents, parameters)
    }

    private fun formatTime(date: Date?): String {
        return if (date != null) timeFormatter.format(date) else "--:--"
    }
}