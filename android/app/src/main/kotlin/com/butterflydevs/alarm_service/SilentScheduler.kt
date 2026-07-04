package com.butterflydevs.salahmaster.alarm_service

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import com.butterflydevs.salahmaster.data.AlarmDao
import com.butterflydevs.salahmaster.alarm_service.AlarmScheduler

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.util.Calendar
import com.butterflydevs.salahmaster.MainActivity


object SilentScheduler {

    private const val BASE_SILENT_REQUEST_CODE = 99000

    fun scheduleAllSilentTimes(
        context: Context,
        alarmDao: AlarmDao,
        locationId: Int
    ) {

        val alarmManager =
            context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        CoroutineScope(Dispatchers.IO).launch {

            val alarms = alarmDao.getAlarmsByLocation(locationId)

            val now = Calendar.getInstance()

            alarms.forEach { alarm ->

                val calendar = Calendar.getInstance().apply {
                    set(Calendar.HOUR_OF_DAY, alarm.hour)
                    set(Calendar.MINUTE, alarm.minute)
                    set(Calendar.SECOND, 0)
                    set(Calendar.MILLISECOND, 0)

                    if (before(now)) {
                        add(Calendar.DAY_OF_YEAR, 1)
                    }
                }

                val triggerTime = calendar.timeInMillis

                val requestCode = BASE_SILENT_REQUEST_CODE + alarm.id

                val intent = Intent(
                    context,
                    AutoSilentSchedulerReceiver::class.java
                ).apply {
                    putExtra("REQUEST_CODE", requestCode)
                    putExtra("LOCATION_ID", locationId)
                }

                val pendingIntent = PendingIntent.getBroadcast(
                    context,
                    requestCode,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or
                            PendingIntent.FLAG_IMMUTABLE
                )

                // Prevent duplicate alarms
                alarmManager.cancel(pendingIntent)

                val showIntent = Intent(context, MainActivity::class.java)

                val showPendingIntent = PendingIntent.getActivity(
                    context,
                    requestCode,
                    showIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )

                alarmManager.setAlarmClock(
                    AlarmManager.AlarmClockInfo(
                        triggerTime,
                        showPendingIntent
                    ),
                    pendingIntent
                )

                // 10 minutes before silent notification
                AlarmScheduler.schedulePreAlarm(
                    context = context,
                    alarm = alarm,
                    triggerTime = triggerTime,
                    alarmManager = alarmManager,
                    isJammat = true
                )
            }
        }
    }

    fun cancelAllSilentAlarms(
        context: Context,
        alarmDao: AlarmDao,
        locationId: Int
    ) {

        val alarmManager =
            context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        CoroutineScope(Dispatchers.IO).launch {

            val alarms = alarmDao.getAlarmsByLocation(locationId)

            alarms.forEach { alarm ->

                val requestCode = BASE_SILENT_REQUEST_CODE + alarm.id

                // Silent Alarm
                val silentIntent = Intent(
                    context,
                    AutoSilentSchedulerReceiver::class.java
                )

                val silentPendingIntent = PendingIntent.getBroadcast(
                    context,
                    requestCode,
                    silentIntent,
                    PendingIntent.FLAG_NO_CREATE or
                            PendingIntent.FLAG_IMMUTABLE
                )

                silentPendingIntent?.let {
                    alarmManager.cancel(it)
                    it.cancel()
                }

                // Cancel Pre Alarm Reminder
                val preIntent = Intent(
                    context,
                    PreAlarmReceiver::class.java
                )

                val prePendingIntent = PendingIntent.getBroadcast(
                    context,
                    alarm.id + 99999,
                    preIntent,
                    PendingIntent.FLAG_NO_CREATE or
                            PendingIntent.FLAG_IMMUTABLE
                )

                prePendingIntent?.let {
                    alarmManager.cancel(it)
                    it.cancel()
                }
            }
        }
    }
}