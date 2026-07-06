package com.butterflydevs.salahmaster

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.os.Build
import android.os.SystemClock
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class IslamicWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        // onUpdate এর ভেতরে একদম শুরুতে বসাবেন
        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val savedLanguage = prefs.getString("flutter.app_language_code", "en") ?: "en"
        LocaleHelper.updateNativeLocale(context, savedLanguage)

        for (appWidgetId in appWidgetIds) {

            val views = RemoteViews(
                context.packageName,
                R.layout.widget_layout
            )

            // Top Row
            val hijriDate =
                widgetData.getString(
                    "hijri_date",
                    "🌙 Hijri Date"
                ) ?: "🌙 Hijri Date"

            val eventName =
                widgetData.getString(
                    "event_name",
                    "No Event"
                ) ?: "No Event"

            val eventDays =
                widgetData.getString(
                    "event_days",
                    ""
                ) ?: ""

            views.setTextViewText(
                R.id.widget_hijri_date,
                hijriDate
            )

            views.setTextViewText(
                R.id.widget_event_days,
                "$eventName\n$eventDays"
            )

            // Prayer Name
            // 🔥 ফিক্সড: এখানে নতুন করে views ডিক্লেয়ার না করে এবং সঠিক লেআউট ও মেথড ব্যবহার করা হয়েছে
            // ৩টি আলাদা পার্টের জন্য নেটিভ ফরম্যাট কনফার্ম করা
            views.setCharSequence(R.id.widget_gregorian_date_only, "setFormat12Hour", "📅 dd MMM")
            views.setCharSequence(R.id.widget_gregorian_date_only, "setFormat24Hour", "📅 dd MMM")

            views.setCharSequence(R.id.widget_gregorian_time_only, "setFormat12Hour", "hh:mm:ss")
            views.setCharSequence(R.id.widget_gregorian_time_only, "setFormat24Hour", "HH:mm:ss")

            views.setCharSequence(R.id.widget_gregorian_ampm_only, "setFormat12Hour", "a")
            views.setCharSequence(R.id.widget_gregorian_ampm_only, "setFormat24Hour", "")

            appWidgetManager.updateAppWidget(appWidgetId, views)

            // Sunrise / Sunset
            val sunrise =
                widgetData.getString(
                    "sunrise_text",
                    "--:--"
                ) ?: "--:--"

            val sunset =
                widgetData.getString(
                    "sunset_text",
                    "--:--"
                ) ?: "--:--"

            views.setTextViewText(
                R.id.widget_sunrise,
                sunrise
            )

            views.setTextViewText(
                R.id.widget_sunset,
                sunset
            )
            // লুপের ভেতরে views ইনিশিয়ালাইজ করার পর এই লাইনগুলো বসিয়ে দিন:

            // 🔥 ১. সূর্যোদয় এবং সূর্যাস্তের লেবেল দুটিকে কারেন্ট ভাষা অনুযায়ী ফোর্স করা
            views.setTextViewText(R.id.tv_sunrise_label, context.getString(R.string.widget_sunrise_label))
            views.setTextViewText(R.id.tv_sunset_label, context.getString(R.string.widget_sunset_label))

            val currentTime = System.currentTimeMillis()

            val fajrTime = widgetData.getLong("fajr_time", 0)
            val sunriseTime = widgetData.getLong("sunrise_time", 0)
            val dhuhrTime = widgetData.getLong("dhuhr_time", 0)
            val asrTime = widgetData.getLong("asr_time", 0)
            val maghribTime = widgetData.getLong("maghrib_time", 0)
            val ishaTime = widgetData.getLong("isha_time", 0)
            val nextFajrTime = widgetData.getLong("next_fajr_time", 0)

            val titleResId: Int
            val targetMillis: Long

            when {
                currentTime < fajrTime -> {
                    titleResId = R.string.next_fajr
                    targetMillis = fajrTime
                }

                currentTime < sunriseTime -> {
                    titleResId = R.string.fajr_ends
                    targetMillis = sunriseTime
                }

                currentTime < sunriseTime + (20 * 60 * 1000) -> {
                    titleResId = R.string.sunrise_time
                    targetMillis = sunriseTime + (20 * 60 * 1000)
                }

                currentTime < dhuhrTime - (15 * 60 * 1000) -> {
                    titleResId = R.string.next_dhuhr
                    targetMillis = dhuhrTime
                }

                currentTime < dhuhrTime -> {
                    titleResId = R.string.zawal_time
                    targetMillis = dhuhrTime
                }

                currentTime < asrTime -> {
                    titleResId = R.string.dhuhr_ends
                    targetMillis = asrTime
                }

                currentTime < maghribTime -> {
                    titleResId = R.string.asr_ends
                    targetMillis = maghribTime
                }

                currentTime < ishaTime -> {
                    titleResId = R.string.maghrib_ends
                    targetMillis = ishaTime
                }

                else -> {
                    titleResId = R.string.isha_ends
                    targetMillis = nextFajrTime
                }
            }
            
            // 🔥 কারেন্ট ল্যাঙ্গুয়েজ অনুযায়ী strings.xml থেকে ওয়াক্তের নাম সেট হবে
            views.setTextViewText(R.id.widget_title_text, context.getString(titleResId))

            val remainingTime =
                maxOf(0L, targetMillis - currentTime)

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                views.setChronometerCountDown(R.id.prayer_countdown, true)
                views.setChronometer(
                    R.id.prayer_countdown,
                    SystemClock.elapsedRealtime() + remainingTime,
                    null,
                    true
                )
            } else {
                // ওল্ড অ্যান্ড্রয়েড ভার্সনের জন্য কাউন্ট-আপ ব্যাকআপ
                views.setChronometer(
                    R.id.prayer_countdown,
                    SystemClock.elapsedRealtime() - remainingTime,
                    null,
                    true
                )
            }

            // 📢 (এখানে থাকা অতিরিক্ত views.setChronometer কোডটি ফেলে দেওয়া হয়েছে)

            appWidgetManager.updateAppWidget(
                appWidgetId,
                views
            )
        }
    }
}
