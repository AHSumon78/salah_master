


package com.butterflydevs.salahmaster.alarm_service

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import com.butterflydevs.salahmaster.data.AlarmDao
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.util.Calendar

object SilentScheduler {

    private const val SILENT_REQUEST_CODE = 99500

    fun scheduleNextSilentTime(
        context: Context,
        alarmDao: AlarmDao,
        locationId: Int
    ) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        CoroutineScope(Dispatchers.IO).launch {
            val alarms = alarmDao.getAlarmsByLocation(locationId)
            if (alarms.isEmpty()) return@launch

            val now = Calendar.getInstance()
            var nextTriggerTime = Long.MAX_VALUE
            var targetAlarmId = -1

            // 🔍 লুপ চালিয়ে শুধুমাত্র সবচেয়ে কাছের (Next Closest) সময়টি বের করা হচ্ছে
            alarms.forEach { alarm ->
                val calendar = Calendar.getInstance().apply {
                    set(Calendar.HOUR_OF_DAY, alarm.hour)
                    set(Calendar.MINUTE, alarm.minute)
                    set(Calendar.SECOND, 0)
                    set(Calendar.MILLISECOND, 0)

                    if (before(now)) {
                        add(Calendar.DAY_OF_YEAR, 1) // সময় পার হয়ে গেলে আগামীকালের হিসাব
                    }
                }

                val timeInMillis = calendar.timeInMillis
                if (timeInMillis < nextTriggerTime) {
                    nextTriggerTime = timeInMillis
                    targetAlarmId = alarm.id
                }
            }

            if (targetAlarmId != -1 && nextTriggerTime != Long.MAX_VALUE) {
                val intent = Intent(context, AutoSilentSchedulerReceiver::class.java).apply {
                    putExtra("REQUEST_CODE", SILENT_REQUEST_CODE)
                    putExtra("LOCATION_ID", locationId)
                    putExtra("ALARM_ID", targetAlarmId)
                    addFlags(Intent.FLAG_RECEIVER_FOREGROUND) // 🌟 ওএস-কে হাই প্রায়োরিটি পুশ দেবে
                }

                val pendingIntent = PendingIntent.getBroadcast(
                    context,
                    SILENT_REQUEST_CODE,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )

                // 👑 setExactAndAllowWhileIdle ব্যবহার—যা ডিলে মুক্ত এবং ডোজ মোড ব্রেক করতে পারে
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        nextTriggerTime,
                        pendingIntent
                    )
                } else {
                    alarmManager.setExact(
                        AlarmManager.RTC_WAKEUP,
                        nextTriggerTime,
                        pendingIntent
                    )
                }
            }
        }
    }

    fun cancelSilentAlarm(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, AutoSilentSchedulerReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            SILENT_REQUEST_CODE,
            intent,
            PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
        )

        pendingIntent?.let {
            alarmManager.cancel(it)
            it.cancel()
        }
    }
}