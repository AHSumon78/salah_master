package com.butterflydevs.salahmaster

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import com.butterflydevs.salahmaster.alarm_service.NativeAlarmReceiver
class PrayerAlarmScheduler(private val context: Context) {

    private val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

    companion object {
        const val PRAYER_ALARM_ID = 9001 // সবসময়ের জন্য ফিক্সড ইউনিক আইডি
    }

    fun scheduleNextAlarm(triggerAtMillis: Long) {
        val now = System.currentTimeMillis()

        // যদি টার্গেট টাইম অলরেডি পার হয়ে যায়, তবে সেট করার দরকার নেই
        if (triggerAtMillis <= now) {
            Log.w("PrayerAlarmScheduler", "Target time is in the past. Skipping alarm.")
            return
        }

        val intent = Intent(context, NativeAlarmReceiver::class.java).apply {
            action = "com.butterflydevs.salahmaster.UPDATE_WIDGET"
            putExtra("TARGET_TIME", triggerAtMillis)
        }

        // FLAG_UPDATE_CURRENT ব্যবহার করার ফলে আগের অ্যালার্মটি ওএস অটোমেটিক রিপ্লেস/ক্যান্সেল করে দেবে
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            PRAYER_ALARM_ID,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                // Doze Mode বা ফোন স্লিপে থাকলেও এক্সাক্ট টাইমে ওয়েক-আপ নিশ্চিত করতে
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    triggerAtMillis,
                    pendingIntent
                )
            } else {
                alarmManager.setExact(
                    AlarmManager.RTC_WAKEUP,
                    triggerAtMillis,
                    pendingIntent
                )
            }
            Log.d("PrayerAlarmScheduler", "Next single alarm scheduled successfully at: $triggerAtMillis")
        } catch (e: SecurityException) {
            Log.e("PrayerAlarmScheduler", "Exact alarm permission missing on Android 12+: $e")
        }
    }

    fun cancelAlarm() {
        val intent = Intent(context, NativeAlarmReceiver::class.java).apply {
            action = "com.butterflydevs.salahmaster.UPDATE_WIDGET"
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context, PRAYER_ALARM_ID, intent, PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
        )
        if (pendingIntent != null) {
            alarmManager.cancel(pendingIntent)
            pendingIntent.cancel()
        }
    }
}