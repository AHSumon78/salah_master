package com.butterflydevs.salahmaster

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import androidx.core.app.NotificationCompat
import java.text.SimpleDateFormat
import java.util.*
import kotlin.math.roundToInt

data class DynamicIslamicEvent(
    val name: String,
    val nameBn: String,
    val hijriMonth: Int,
    val hijriDay: Int
)

class IslamicEventHelper(private val context: Context) {

    private val sharedPrefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

    private val islamicEvents = listOf(
        DynamicIslamicEvent("Islamic New Year", "হিজরি নববর্ষ", 1, 1),
        DynamicIslamicEvent("Ashura\n(10 Muharram)", "আশূরা\n(১০ মুহাররাম)", 1, 10),
        DynamicIslamicEvent("Eid-e-Miladunnabi", "ঈদে মিলাদুন্নবী", 3, 12),
        DynamicIslamicEvent("Shab-e-Meraj", "শবে মেরাজ", 7, 27),
        DynamicIslamicEvent("Shab-e-Barat", "শবে বরাত", 8, 15),
        DynamicIslamicEvent("Ramadan Begins", "রমজান শুরু", 9, 1),
        DynamicIslamicEvent("Shab-e-Qadr", "শবে কদর", 9, 27),
        DynamicIslamicEvent("Eid-ul-Fitr", "ঈদুল ফিতর", 10, 1),
        DynamicIslamicEvent("Hajj (Arafah Day)", "আরাফাহ দিবস (হজ)", 12, 9),
        DynamicIslamicEvent("Eid-ul-Azha", "ঈদুল আজহা", 12, 10),
        DynamicIslamicEvent("Ayyam al-Bid", "আইয়ামে বীজ", 0, 13),
        DynamicIslamicEvent("Ayyam al-Bid", "আইয়ামে বীজ", 0, 14),
        DynamicIslamicEvent("Ayyam al-Bid", "আইয়ামে বীজ", 0, 15)
    )

    private fun estimateGregorianDate(
        hijriMonth: Int, hijriDay: Int, curYear: Int, curMonth: Int, curDay: Int
    ): Calendar {
        var targetMonth = hijriMonth
        if (targetMonth == 0) {
            targetMonth = curMonth
            if (hijriDay < curDay) {
                targetMonth = curMonth + 1
                if (targetMonth > 12) targetMonth = 1
            }
        }

        val now = Calendar.getInstance()
        val hijriYearInDays = 354.367
        val hijriMonthInDays = 29.53

        var bestEstimate = Calendar.getInstance().apply {
            set(now.get(Calendar.YEAR) + 1, Calendar.DECEMBER, 31)
        }
        var minDiff = Int.MAX_VALUE

        for (yearOffset in listOf(-1, 0, 1, 2)) {
            val testHijriYear = curYear + yearOffset
            val totalDaysFromToday = ((testHijriYear - curYear) * hijriYearInDays +
                    (targetMonth - curMonth) * hijriMonthInDays +
                    (hijriDay - curDay))

            val estimatedDate = Calendar.getInstance().apply {
                time = now.time
                add(Calendar.DAY_OF_YEAR, totalDaysFromToday.roundToInt())
            }

            val diff = ((estimatedDate.timeInMillis - now.timeInMillis) / (1000 * 60 * 60 * 24)).toInt()

            if (diff >= 0 && diff < minDiff) {
                minDiff = diff
                bestEstimate = estimatedDate
            }
        }
        return bestEstimate
    }

    // 🛠️ ফিক্স ১: মেথডে প্যারামিটার হিসেবে adjustment যুক্ত করা হলো
    fun calculateCountdown(curYear: Int, curMonth: Int, curDay: Int, passedAdjustment: Int): Map<String, Any> {
        val isBn = sharedPrefs.getString("flutter.app_language_code", "en") == "bn"

        var closestEvent = islamicEvents.first()
        var minDays = 9999
        var todayEventFound: DynamicIslamicEvent? = null

        for (event in islamicEvents) {
            var targetMonth = event.hijriMonth
            val targetDay = event.hijriDay

            if (event.hijriMonth == 0) {
                if (curMonth == 9 || curDay > 15) continue
                targetMonth = if (curDay < 16) {
                    if (targetDay < curDay) (curMonth + 1).let { if (it > 12) 1 else it } else curMonth
                } else {
                    (curMonth + 1).let { if (it > 12) 1 else it }
                }
            }

            val targetDate = estimateGregorianDate(targetMonth, targetDay, curYear, curMonth, curDay)
            val today = Calendar.getInstance().apply {
                set(Calendar.HOUR_OF_DAY, 0)
                set(Calendar.MINUTE, 0)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }
            val destDate = Calendar.getInstance().apply {
                time = targetDate.time
                set(Calendar.HOUR_OF_DAY, 0)
                set(Calendar.MINUTE, 0)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }

            val difference = ((destDate.timeInMillis - today.timeInMillis) / (1000 * 60 * 60 * 24)).toInt()

            if (difference in 0 until minDays) {
                minDays = difference
                closestEvent = event
            }

            if (difference == 0) {
                todayEventFound = event
            }
        }

        val eventNameDisplay = if (isBn) closestEvent.nameBn else closestEvent.name
        val daysDisplay = when (minDays) {
            0 -> {
                if (todayEventFound != null) {
                    val todayDateStr = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
                    val lastNotifiedDate = sharedPrefs.getString("last_event_notified_date", "")
                    val lastNotifiedEvent = sharedPrefs.getString("last_event_notified_name", "")

                    if (lastNotifiedDate != todayDateStr || lastNotifiedEvent != todayEventFound.name) {
                        val notifTitle = if (isBn) todayEventFound.nameBn else todayEventFound.name
                        val notifBody = if (isBn) "আজ $notifTitle" else "$notifTitle is today"
                        
                        triggerNotification(notifTitle, notifBody)

                        sharedPrefs.edit().apply {
                            putString("last_event_notified_date", todayDateStr)
                            putString("last_event_notified_name", todayEventFound.name)
                            apply()
                        }
                    }
                }
                if (isBn) "আজ" else "Today"
            }
            else -> if (isBn) "${toBanglaNumber(minDays.toString())} দিন বাকি" else "In $minDays Days"
        }

        return mapOf(
            "name" to eventNameDisplay,
            "days" to daysDisplay,
            "minDays" to minDays,
            "adjustment" to passedAdjustment // 🌟 পাস করা অ্যাডজাস্টমেন্ট রিটার্ন করা হচ্ছে
        )
    }

    // 🛠️ ফিক্স ২: অল ইভেন্ট মেথডেও প্যারামিটার হিসেবে adjustment পাস করা হলো
    fun getAllSortedEvents(curYear: Int, curMonth: Int, curDay: Int, passedAdjustment: Int): List<Map<String, Any>> {
        val isBn = sharedPrefs.getString("flutter.app_language_code", "en") == "bn"
        val today = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }

        return islamicEvents.map { event ->
            var targetMonth = event.hijriMonth
            val targetDay = event.hijriDay

            if (event.hijriMonth == 0) {
                targetMonth = if (curDay < 16) {
                    if (targetDay < curDay) (curMonth + 1).let { if (it > 12) 1 else it } else curMonth
                } else {
                    (curMonth + 1).let { if (it > 12) 1 else it }
                }
            }

            val targetDate = estimateGregorianDate(targetMonth, targetDay, curYear, curMonth, curDay)
            val destDate = Calendar.getInstance().apply {
                time = targetDate.time
                set(Calendar.HOUR_OF_DAY, 0)
                set(Calendar.MINUTE, 0)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }
            val daysLeft = ((destDate.timeInMillis - today.timeInMillis) / (1000 * 60 * 60 * 24)).toInt()

            mapOf(
                "name" to if (isBn) event.nameBn else event.name,
                "daysLeft" to daysLeft,
                "day" to targetDate.get(Calendar.DAY_OF_MONTH),
                "month" to targetDate.get(Calendar.MONTH) + 1,
                "year" to targetDate.get(Calendar.YEAR)
            )
        }.sortedBy { it["daysLeft"] as Int }
    }

    private fun triggerNotification(title: String, body: String) {
        val channelId = "islamic_event_channel"
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(channelId, "Islamic Events", NotificationManager.IMPORTANCE_HIGH).apply {
                description = "Islamic event notifications"
            }
            notificationManager.createNotificationChannel(channel)
        }

        val notification = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(context.applicationInfo.icon)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .build()

        notificationManager.notify(500, notification)
    }

    private fun toBanglaNumber(input: String): String {
        val banglaDigits = charArrayOf('০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯')
        return input.map { if (it.isDigit()) banglaDigits[it - '0'] else it }.joinToString("")
    }
}