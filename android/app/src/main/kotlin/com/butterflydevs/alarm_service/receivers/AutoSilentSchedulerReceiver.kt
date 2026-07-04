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

        CoroutineScope(Dispatchers.IO).launch {

            val db = AppDatabase.getInstance(context)

            SilentScheduler.scheduleAllSilentTimes(
                context = context,
                alarmDao = db.alarmDao(),
                locationId = locationId
            )
        }
    }
}