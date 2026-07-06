package com.butterflydevs.salahmaster.alarm_service

import android.content.BroadcastReceiver
import com.butterflydevs.salahmaster.alarm_service.ManualSilentHelper
import android.content.Context
import android.content.Intent
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import com.butterflydevs.salahmaster.database.AppDatabase

class AutoSilentSchedulerReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent?) {

        // Silent Mode
        val prefs = context.getSharedPreferences(
            "FlutterSharedPreferences",
            Context.MODE_PRIVATE
        )

        val value = prefs.all["flutter.silent_duration"]

        val duration = when (value) {
            is Int -> value
            is Long -> value.toInt()
            is String -> value.toIntOrNull() ?: 30
            else -> 30
        }

        ManualSilentHelper.startManualSilent(context, duration)

        val locationId = intent?.getIntExtra("LOCATION_ID", -1) ?: -1
        if (locationId == -1) return

        // আপনার AutoSilentSchedulerReceiver-এর অন-রিসিভের একদম শেষ লাইনে এটি যুক্ত করুন:
        CoroutineScope(Dispatchers.IO).launch {
            val db = AppDatabase.getInstance(context)
            // 🔄 কারেন্ট নামাজের কাজ শুরু হতেই পরবর্তী নামাজের জন্য ১টি মাত্র অ্যালার্ম বুক হয়ে যাবে
            SilentScheduler.scheduleNextSilentTime(
                context = context,
                alarmDao = db.alarmDao(),
                locationId = locationId
            )
        }
    }
}