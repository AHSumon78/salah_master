package com.butterflydevs.salahmaster.alarm_service

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.util.Log
import com.butterflydevs.salahmaster.data.AlarmEntity
import java.util.Calendar
import com.butterflydevs.salahmaster.database.AppDatabase
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch
import com.butterflydevs.salahmaster.data.AlarmPrefs
import com.butterflydevs.salahmaster.data.SettingsEntity
import com.butterflydevs.salahmaster.MainActivity
import android.widget.Toast
import kotlinx.coroutines.withContext


class AlarmScheduler {

    suspend fun schedule(
        context: Context,
        alarm: AlarmEntity,
        skipToday: Boolean = false
    ) {
        if (!alarm.isActive) return

        val db = AppDatabase.getInstance(context)
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        val location = db.locationDao().getById(alarm.locationId)
        val preAlarmMinutes = location?.preAlarmMinutes ?: 0

        val intent = Intent(context, AlarmReceiver::class.java).apply {
            putExtra("ALARM_ID", alarm.id)
            putExtra("ALARM_TITLE", alarm.title)
            putExtra("ALARM_SOUND", alarm.sound)
            putExtra("IS_DAILY", alarm.isDaily)
            putExtra("DAYS_MASK", alarm.daysMask)
        }

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            alarm.id,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val showIntent = Intent(context, AlarmActivity::class.java).apply {
            putExtra("ALARM_ID", alarm.id)
            putExtra("ALARM_TITLE", alarm.title)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_NO_USER_ACTION
        }

        val showPendingIntent = PendingIntent.getActivity(
            context,
            alarm.id,
            showIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val time = getNextAlarmTimeInMillis(
            alarm.hour,
            alarm.minute,
            alarm.daysMask,
            preAlarmMinutes,
            skipToday
        )

        val alarmClockInfo = AlarmManager.AlarmClockInfo(time, showPendingIntent)
        alarmManager.setAlarmClock(alarmClockInfo, pendingIntent)

        // --- Toast Logic Start ---
        val now = System.currentTimeMillis()
        val diff = time - now
        val minutes = (diff / 1000) / 60
        val hours = minutes / 60
        val remainingMinutes = minutes % 60
        
        val displayText = when {
            diff <= 0 -> "${alarm.title} is due"
            hours > 0 -> "${alarm.title} will ring in ${hours}h ${remainingMinutes}m"
            else -> "${alarm.title} will ring in ${minutes} minutes"
        }

        withContext(Dispatchers.Main) {
            Toast.makeText(context, displayText, Toast.LENGTH_SHORT).show()
        }
        // --- Toast Logic End ---

        var pref = context.getSharedPreferences(AlarmPrefs.PREFS, Context.MODE_PRIVATE)
        val autoSilent = pref.getBoolean(AlarmPrefs.AUTO_SILENT_SCHEDULE, true)

        if (alarm.locationId == 10 || !autoSilent) {
            AlarmScheduler.schedulePreAlarm(
                context = context,
                alarm = alarm,
                triggerTime = time,
                alarmManager = alarmManager
            )
        }
    }

    private fun getNextAlarmTimeInMillis(hour: Int, minute: Int, daysMask: Int, preAlarmMinutes: Int,skipToday: Boolean ): Long {
        val now = Calendar.getInstance()
        
        // টার্গেট টাইম সেট করা
        val targetCalendar = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, hour)
            set(Calendar.MINUTE, minute)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
            // লোকেশনের preAlarmMinutes বিয়োগ করা হচ্ছে
            add(Calendar.MINUTE, -preAlarmMinutes)

        }

        // যদি ইউজার কোনো দিনই সিলেক্ট না করে থাকে (daysMask == 0), তবে নরমাল পরবর্তী ২৪ ঘণ্টার লজিক চলবে
        val effectiveMask = if (daysMask == 0) 127 else daysMask

        // আগামী ৭ দিনের লুপ চালিয়ে প্রথম ম্যাচিং দিনটি খুঁজে বের করা
        for (i in 0..7) {
            if (skipToday && i == 0) {
                continue
            }
            val testCalendar = targetCalendar.clone() as Calendar
            testCalendar.add(Calendar.DAY_OF_YEAR, i)

            val dayIndex = getBitmaskIndex(testCalendar.get(Calendar.DAY_OF_WEEK))
            val isDayEnabled = (effectiveMask and (1 shl dayIndex)) != 0

            if (isDayEnabled) {
                // যদি দিনটি আজই হয় (i == 0), তবে চেক করতে হবে অলরেডি সময় পার হয়ে গেছে কি না
                if (i == 0 && testCalendar.before(now)) {
                    continue // আজ সময় পার হয়ে গেলে এই লুপ স্কিপ করে পরের দিনগুলোতে খুঁজবে
                }
                return testCalendar.timeInMillis
            }
        }
        return targetCalendar.timeInMillis
    }                           
    private fun getBitmaskIndex(calendarDayOfWeek: Int): Int {
        return when (calendarDayOfWeek) {
            Calendar.SATURDAY  -> 6
            Calendar.SUNDAY    -> 5
            Calendar.MONDAY    -> 4
            Calendar.TUESDAY   -> 3
            Calendar.WEDNESDAY -> 2
            Calendar.THURSDAY  -> 1
            Calendar.FRIDAY    -> 0
            else -> 0
        }
    }

    fun cancel(context: Context, alarmId: Int) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        // ১. মূর অ্যালার্ম (Main Alarm) ক্যান্সেল করা
        val mainIntent = Intent(context, AlarmReceiver::class.java)
        val mainPendingIntent = PendingIntent.getBroadcast(
            context, 
            alarmId, 
            mainIntent,
            PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
        )
        mainPendingIntent?.let { 
            alarmManager.cancel(it) 
            it.cancel() // PendingIntent-টিকেও মেমোরি থেকে রিলিজ করা
            Log.d("AlarmScheduler", "🛑 Main alarm cancelled for ID: $alarmId")
        }

        // ২. প্রি-অ্যালার্ম নোটিফিকেশন (Pre-Alarm) ক্যান্সেল করা
        val preIntent = Intent(context, PreAlarmReceiver::class.java)
        val prePendingIntent = PendingIntent.getBroadcast(
            context, 
            alarmId + 99999, // শিডিউল করার সময় যে আইডি দিয়েছিলেন
            preIntent,
            PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
        )
        prePendingIntent?.let { 
            alarmManager.cancel(it) 
            it.cancel() 
            Log.d("AlarmScheduler", "🛑 Pre-alarm notification cancelled for ID: $alarmId")
        }
    }                   
    suspend fun scheduleAllByLocation(context: Context, locationId: Int) {
        val db = AppDatabase.getInstance(context)

        // ঐ লোকেশনের সব অ্যালার্ম ডাটাবেজ থেকে নিয়ে আসা
        val alarms = db.alarmDao().getAlarmsByLocation(locationId)

        for (alarm in alarms) {
            if (alarm.isActive) {
                schedule(context, alarm) // আপনার তৈরি করা আগের schedule ফাংশনটি কল হবে
            }
        }
        Log.d("AlarmScheduler", "✅ All active alarms for Location $locationId have been scheduled.")
    }

    // ২. একটি লোকেশনের আন্ডারে থাকা সকল অ্যালার্ম ক্যানসেল করার ফাংশন
    suspend fun cancelAllByLocation(context: Context, locationId: Int) {
        val db = AppDatabase.getInstance(context)

        // ঐ লোকেশনের সব অ্যালার্ম ডাটাবেজ থেকে নিয়ে আসা
        val alarms = db.alarmDao().getAlarmsByLocation(locationId)

        for (alarm in alarms) {
            cancel(context, alarm.id) // আপনার তৈরি করা আগের cancel ফাংশনটি কল হবে
        }
        Log.d("AlarmScheduler", "🚫 All alarms for Location $locationId have been cancelled.")
    }
    fun cancelById(context: Context, alarmId: Int) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        // ================= ১. মেইন অ্যালার্ম ক্যানসেল করা =================
        val mainIntent = Intent(context, AlarmReceiver::class.java)
        val mainPendingIntent = PendingIntent.getBroadcast(
            context,
            alarmId, // মেইন অ্যালার্ম আইডি
            mainIntent,
            PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
        )

        if (mainPendingIntent != null) {
            alarmManager.cancel(mainPendingIntent)
            mainPendingIntent.cancel()
            Log.d("AlarmScheduler", "🚫 Main Alarm $alarmId has been cancelled.")
        }

        // ================= ২. প্রি-অ্যালার্ম ক্যানসেল করা =================
        val preIntent = Intent(context, PreAlarmReceiver::class.java)
        val prePendingIntent = PendingIntent.getBroadcast(
            context,
            alarmId + 99999, // প্রি-অ্যালার্ম সিডিউল করার সময় ব্যবহৃত ইউনিক আইডি
            preIntent,
            PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
        )

        if (prePendingIntent != null) {
            alarmManager.cancel(prePendingIntent)
            prePendingIntent.cancel()
            Log.d("AlarmScheduler", "🚫 Pre-Alarm for Alarm $alarmId has been cancelled.")
        }
    }

    suspend fun handleLocationSwitch(context: Context, newLocationId: Int) {
        CoroutineScope(Dispatchers.IO).launch {
            val db = AppDatabase.getInstance(context)

            val settings = db.settingsDao().getSettings()
            val oldLocationId = settings?.currentLocationId

            
                if (oldLocationId != null) {
                    cancelAllByLocation(context, oldLocationId)
                }

                val newLoc = db.locationDao().getById(newLocationId) ?: return@launch

                val updatedSettings = SettingsEntity(
                    id = 1,
                    currentLocation = newLoc.name,
                    currentLocationId = newLoc.id,
                    enable = true
                )
                db.settingsDao().update(updatedSettings)

                scheduleAllByLocation(context, newLocationId)
            
        }
    }
    // suspend fun schedulePreAlarm(
    //         context: Context,
    //         alarm: AlarmEntity,
    //         triggerTime: Long,
    //         alarmManager: AlarmManager,
    //         isJammat : Boolean = false
    //     ) {

    //         val prefs =
    //             context.getSharedPreferences(
    //                 AlarmPrefs.PREFS,
    //                 Context.MODE_PRIVATE
    //             )

    //         if (!prefs.getBoolean(AlarmPrefs.PRE_ALARM, false))
    //             return

    //         val now = System.currentTimeMillis()

    //         val diff = triggerTime - now

    //         val preTime = triggerTime - (10 * 60 * 1000L)

    //         val preIntent = Intent(
    //             context,
    //             PreAlarmReceiver::class.java
    //         ).apply {

    //             putExtra("ALARM_ID", alarm.id)
    //             putExtra("ALARM_TITLE", alarm.title)
    //             putExtra("TRIGGER_TIME", triggerTime)
    //             putExtra("IS_JAMMAT", isJammat)
    //         }

    //         if (diff <= 10 * 60 * 1000L) {

    //             context.sendBroadcast(preIntent)
    //             return
    //         }

    //         val pendingIntent =
    //             PendingIntent.getBroadcast(
    //                 context,
    //                 alarm.id + 99999,
    //                 preIntent,
    //                 PendingIntent.FLAG_UPDATE_CURRENT or
    //                         PendingIntent.FLAG_IMMUTABLE
    //             )

    //         alarmManager.setExactAndAllowWhileIdle(
    //             AlarmManager.RTC_WAKEUP,
    //             preTime,
    //             pendingIntent
    //         )
    //     }

    

    companion object {

        private const val REQ_CODE = 2002

        suspend fun schedulePreAlarm(
            context: Context,
            alarm: AlarmEntity,
            triggerTime: Long,
            alarmManager: AlarmManager,
            isJammat: Boolean = false
        ) {

            val prefs = context.getSharedPreferences(
                AlarmPrefs.PREFS,
                Context.MODE_PRIVATE
            )

            if (!prefs.getBoolean(AlarmPrefs.PRE_ALARM, false))
                return

            val now = System.currentTimeMillis()
            val diff = triggerTime - now
            val preTime = triggerTime - (10 * 60 * 1000L)

            val preIntent = Intent(
                context,
                PreAlarmReceiver::class.java
            ).apply {
                putExtra("ALARM_ID", alarm.id)
                putExtra("ALARM_TITLE", alarm.title)
                putExtra("TRIGGER_TIME", triggerTime)
                putExtra("IS_JAMMAT", isJammat)
            }

            if (diff <= 10 * 60 * 1000L) {
                context.sendBroadcast(preIntent)
                return
            }

            val pendingIntent = PendingIntent.getBroadcast(
                context,
                alarm.id + 99999,
                preIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or
                        PendingIntent.FLAG_IMMUTABLE
            )

            val showIntent = Intent(
                context,
                MainActivity::class.java
            )

            val showPendingIntent = PendingIntent.getActivity(
                context,
                alarm.id + 99999,
                showIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or
                        PendingIntent.FLAG_IMMUTABLE
            )

            val alarmClockInfo = AlarmManager.AlarmClockInfo(
                preTime,
                showPendingIntent
            )

            alarmManager.setAlarmClock(
                alarmClockInfo,
                pendingIntent
            )
        }
    }

}