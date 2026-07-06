package com.butterflydevs.salahmaster

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent

class WidgetUpdater(private val context: Context) {

    private val widgetPrefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)

    fun updateDataAndRefresh(
        hijriDate: String,
        widgetTitle: String,
        eventName: String,
        eventDays: String,
        sunriseText: String,
        sunsetText: String,
        prayerTimesMap: Map<String, Long>
    ) {
        // ১. home_widget preferences-এ ডেটা সেভ করা
        widgetPrefs.edit().apply {
            putString("hijri_date", hijriDate)
            putString("widget_title", widgetTitle)
            putString("event_name", eventName)
            putString("event_days", eventDays)
            putString("sunrise_text", sunriseText)
            putString("sunset_text", sunsetText)

            // লুপ চালিয়ে সব নামাজের টাইমস্ট্যাম্প সেভ করা
            prayerTimesMap.forEach { (key, value) ->
                putLong(key, value)
            }
            apply()
        }

        // ২. সরাসরি Native Broadcast পাঠিয়ে উইজেট রিফ্রেশ ট্রিগার করা
        val updateIntent = Intent(context, IslamicWidgetProvider::class.java).apply {
            action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
        }
        val ids = AppWidgetManager.getInstance(context).getAppWidgetIds(
            ComponentName(context, IslamicWidgetProvider::class.java)
        )
        updateIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
        context.sendBroadcast(updateIntent)
    }
}