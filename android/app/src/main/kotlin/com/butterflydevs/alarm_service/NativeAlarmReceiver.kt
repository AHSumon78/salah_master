package com.butterflydevs.salahmaster.alarm_service

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.butterflydevs.salahmaster.PrayerTimeHelper
import com.butterflydevs.salahmaster.IslamicEventHelper
import com.butterflydevs.salahmaster.HijriRepository
import com.butterflydevs.salahmaster.WidgetUpdater
import com.butterflydevs.salahmaster.PrayerAlarmScheduler
import kotlinx.coroutines.runBlocking
import java.text.SimpleDateFormat
import java.util.*

class NativeAlarmReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action
        Log.d("NativeAlarmReceiver", "Received action: $action")

        if (action == "com.butterflydevs.salahmaster.UPDATE_WIDGET" || action == Intent.ACTION_BOOT_COMPLETED) {

            // ১. SharedPreferences থেকে কনফিগারেশন রিড করা
            val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val latStr = prefs.getString("flutter.lat", null)
            val lngStr = prefs.getString("flutter.lng", null)

            val lat = latStr?.toDoubleOrNull() ?: 24.3745
            val lng = lngStr?.toDoubleOrNull() ?: 88.6042
            val localeCode = prefs.getString("flutter.app_language_code", "en") ?: "en"
            val isBn = localeCode == "bn"

            val now = System.currentTimeMillis()

            // ২. PrayerTimeHelper দিয়ে ওয়াক্তের সময় বের করা
            val prayerTimeHelper = PrayerTimeHelper(lat, lng, context)
            val stringPrayerTimes = prayerTimeHelper.getTodayPrayerTimes()

            val calendar = Calendar.getInstance()
            val pt = prayerTimeHelper.getRawPrayerTimes(calendar)

            val tomorrowCal = Calendar.getInstance().apply { add(Calendar.DAY_OF_YEAR, 1) }
            val tomorrowPt = prayerTimeHelper.getRawPrayerTimes(tomorrowCal)

            val fajr = pt.fajr.time
            val sunrise = pt.sunrise.time
            val dhuhr = pt.dhuhr.time
            val asr = pt.asr.time
            val maghrib = pt.maghrib.time
            val isha = pt.isha.time
            val nextFajr = tomorrowPt.fajr.time

            val sunriseEnd = sunrise + (20 * 60 * 1000)
            val zawalStart = dhuhr - (15 * 60 * 1000)

            // ৩. উইজেট টাইটেল সেট করা
            val displayTitle = when {
                now < fajr -> if (isBn) "পরবর্তী ওয়াক্ত: ফজর" else "Next: Fajr"
                now < sunrise -> if (isBn) "ফজর ওয়াক্ত" else "Fajr Time"
                now < sunriseEnd -> if (isBn) "নিষিদ্ধ সময়" else "Forbidden Time"
                now < zawalStart -> if (isBn) "পরবর্তী ওয়াক্ত: জোহর" else "Next: Dhuhr"
                now < dhuhr -> if (isBn) "নিষিদ্ধ সময় (জাওয়াল)" else "Forbidden (Zawal)"
                now < asr -> if (isBn) "জোহর ওয়াক্ত" else "Dhuhr Time"
                now < maghrib -> if (isBn) "আছর ওয়াক্ত" else "Asr Time"
                now < isha -> if (isBn) "মাগরিব ওয়াক্ত" else "Maghrib Time"
                now < nextFajr -> if (isBn) "এশা ওয়াক্ত" else "Isha Time"
                else -> if (isBn) "পরবর্তী ওয়াক্ত: ফজর" else "Next: Fajr"
            }

            // ৪. নেক্সট অ্যালার্ম ট্রিগার টাইম ক্যালকুলেশন
            val nextTargetTime: Long = when {
                now < fajr -> fajr + 3000
                now < sunrise -> sunrise + 3000
                now < sunriseEnd -> sunriseEnd + 3000
                now < zawalStart -> zawalStart + 3000
                now < dhuhr -> dhuhr + 3000
                now < asr -> asr + 3000
                now < maghrib -> maghrib + 3000
                now < isha -> isha + 3000
                now < nextFajr -> nextFajr + 3000
                else -> nextFajr + 3000
            }

            // ৫. দিন/রাত ক্যালকুলেশন (যা রেপোজিটরিতে পাস করা হবে)
            var isNight = true
            if (now in (sunrise + 1)..<maghrib) isNight = false

            val referenceCalendar = Calendar.getInstance()
            // মাগরিবের পর হলে ইসলামিক ক্যালেন্ডার অনুযায়ী পরের দিন হয়ে যাবে
            if (now > maghrib) {
                referenceCalendar.add(Calendar.DAY_OF_YEAR, 1)
            }

            // ভাষা অনুযায়ী বারের নাম এবং দিন/রাত টেক্সট তৈরি করা
            val daysBn = mapOf(
                "Saturday" to "শনিবার", "Sunday" to "রবিবার", "Monday" to "সোমবার",
                "Tuesday" to "মঙ্গলবার", "Wednesday" to "বুধবার", "Thursday" to "বৃহস্পতিবার", "Friday" to "শুক্রবার"
            )
            val dayFormatEn = SimpleDateFormat("EEEE", Locale.US)
            val dayNameEn = dayFormatEn.format(referenceCalendar.time)

            val dayName = if (isBn) (daysBn[dayNameEn] ?: dayNameEn) else {
                val localFormat = SimpleDateFormat("EEEE", Locale(localeCode))
                localFormat.format(referenceCalendar.time)
            }

            val dayNightStatus = if (isNight) {
                if (isBn) "$dayName রাত" else "$dayName Night"
            } else {
                if (isBn) "$dayName দিন" else dayName
            }

            // HijriRepository থেকে ক্লিন অবজেক্ট ডাটা নিয়ে আসা
            val hijriResult = runBlocking {
                HijriRepository.getFormattedHijriData(
                    context = context,
                    isBn = isBn,
                    localeCode = localeCode,
                    isNight = isNight
                )
            }

            // রেপোজিটরির ম্যাপ থেকে স্ট্রাকচারাল ডাটা রিড করা
            val curDayStr = hijriResult["day"] as? String ?: "1"
            val curYearStr = hijriResult["year"] as? String ?: "1447"

            val curDay = curDayStr.toIntOrNull() ?: 1
            val curYear = curYearStr.toIntOrNull() ?: 1447

            val monthMap = hijriResult["month"] as? Map<*, *>
            val curMonth = monthMap?.get("number") as? Int ?: 1
            val rawMonthNameEn = monthMap?.get("en") as? String ?: "Muharram"

            // 👑 ট্রিকি পার্ট: ভাষা চেকের আগেই এপিআই-এর ডটওয়ালা নামকে একদম ক্লিন করে নেওয়া হলো
            val cleanMonthNameEn = rawMonthNameEn
                .replace("ū", "u")
                .replace("ī", "i")
                .replace("Ḥ", "H")
                .replace("ḥ", "h")
                .replace("ā", "a")
                .replace("Dhū al", "Dhul")
                .replace("al-", "al ")
                .trim()

            // 🗓️ ডার্ট সাইডের মতো হুবহু ২ লাইনের সুন্দর উইজেট টেক্সট জেনারেশন
            val formattedHijri = if (isBn) {
                val hijriMonthsBn = mapOf(
                    "Muharram" to "মুহাররম", "Safar" to "সফর", "Rabi' al-awwal" to "রবিউল আউয়াল",
                    "Rabi' ath-thani" to "রবিউস সানি", "Jumada al-ula" to "জুমাদাল উলা", "Jumada al-akhirah" to "জুমাদাল আখিরা",
                    "Rajab" to "রজব", "Sha'ban" to "শাবান", "Ramadan" to "রমজান", "Shawwal" to "শাওয়াল",
                    "Dhu al-Qi'dah" to "জিলকদ", "Dhu al-Hijjah" to "জিলহজ্জ"
                )
                // এখন cleanMonthNameEn-এর সাথে কি (Key) নিখুঁতভাবে ম্যাচ করবে!
                val monthBn = hijriMonthsBn[cleanMonthNameEn] ?: cleanMonthNameEn

                // সংখ্যা বাংলায় রূপান্তর
                val banglaDigits = charArrayOf('০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯')
                fun String.toBanglaNum(): String = this.map { if (it.isDigit()) banglaDigits[it - '0'] else it }.joinToString("")

                "${curDayStr.toBanglaNum()} $monthBn ${curYearStr.toBanglaNum()} হিজরি\n$dayNightStatus"
            } else {
                "$curDayStr $cleanMonthNameEn $curYearStr AH\n$dayNightStatus"
            }

            // ৬. ইসলামিক ইভেন্ট কাউন্টডাউন
            val eventHelper = IslamicEventHelper(context)
            val widgetAdjustment = prefs.getInt("flutter.hijri_adjustment", -1)
            val eventData = eventHelper.calculateCountdown(curYear, curMonth, curDay,widgetAdjustment)

            val eventName = eventData["name"]?.toString() ?: (if (isBn) "কোনো ইভেন্ট নেই" else "No Event")
            val eventDays = eventData["days"]?.toString() ?: "0"

            // ७. উইজেট ডাটা ম্যাপ প্রিপারেশন
            val sunriseText = stringPrayerTimes["Sunrise"] ?: "--:--"
            val sunsetText = stringPrayerTimes["Maghrib"] ?: "--:--"

            val prayerTimesMap = mapOf(
                "fajr_time" to fajr, "sunrise_time" to sunrise, "dhuhr_time" to dhuhr,
                "asr_time" to asr, "maghrib_time" to maghrib, "isha_time" to isha, "next_fajr_time" to nextFajr
            )

            // ৮. উইজেট আপডেট এবং রিফ্রেশ
            val widgetUpdater = WidgetUpdater(context)
            widgetUpdater.updateDataAndRefresh(
                hijriDate = formattedHijri,
                widgetTitle = displayTitle,
                eventName = eventName,
                eventDays = eventDays,
                sunriseText = sunriseText,
                sunsetText = sunsetText,
                prayerTimesMap = prayerTimesMap
            )

            // ৯. পরবর্তী উইজেট আপডেটের শিডিউল ট্রিগার
            val alarmScheduler = PrayerAlarmScheduler(context)
            alarmScheduler.scheduleNextAlarm(nextTargetTime)
        }
    }
}