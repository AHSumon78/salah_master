package com.butterflydevs.salahmaster.alarm_service
import android.app.*
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.*
import android.util.Log
import android.widget.Toast

// সঠিক পাথগুলো আপনার প্রজেক্ট অনুযায়ী চেক করে নিন
import com.butterflydevs.salahmaster.database.AppDatabase
import com.butterflydevs.salahmaster.data.AlarmPrefs


// Google Play Services Imports

// Coroutines
import kotlinx.coroutines.*

// 'as AndroidLocation' alias টি সরিয়ে দিয়ে সরাসরি Location ইমপোর্ট করা হয়েছে

import android.os.PowerManager
import android.os.Handler
import android.os.Looper

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val id = intent.getIntExtra("ALARM_ID", 0)
        val isSnooze = intent.getBooleanExtra("IS_SNOOZE", false)

        val serviceIntent = Intent(context, AlarmService::class.java).apply {
            putExtra("ALARM_ID", id)
            putExtra("IS_SNOOZE", isSnooze)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(serviceIntent)
        } else {
            context.startService(serviceIntent)
        }
    }
}
class AlarmService : Service() {
    private val handler = Handler(Looper.getMainLooper())

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {

        val id = intent?.getIntExtra("ALARM_ID", 0) ?: 0

        val isSnooze = intent?.getBooleanExtra("IS_SNOOZE", false) ?: false



        val db = AppDatabase.getInstance(this)



        CoroutineScope(Dispatchers.IO).launch {

            val alarm = db.alarmDao().getAlarmById(id)



            if (alarm != null && alarm.isActive) {



                val prefs = getSharedPreferences("alarm_state", Context.MODE_PRIVATE)



                val retryKey = "retry_count_$id"

                var retryCount = prefs.getInt(retryKey, 0)



                val displayTitle =

                    if (isSnooze) "${alarm.title} (Snooze)" else alarm.title



                val notification = NotificationHelper.showNotification(

                    this@AlarmService,

                    alarm.id,

                    displayTitle

                )



                startForeground(alarm.id, notification)



                val pm = getSystemService(POWER_SERVICE) as PowerManager



                val wakeLock = pm.newWakeLock(

                    PowerManager.FULL_WAKE_LOCK or

                            PowerManager.ACQUIRE_CAUSES_WAKEUP or

                            PowerManager.ON_AFTER_RELEASE,

                    "alarm:wakelock"

                )



                wakeLock.acquire(10 * 60 * 1000L)



                // ================= PLAY SOUND =================

                SoundHelper.playAlarmSound(this@AlarmService, alarm.sound){



                    val actionTaken = prefs.getBoolean("user_action_taken_$id", false)

                    retryCount = prefs.getInt(retryKey, 0)

                    val snooze_times = prefs.getInt(AlarmPrefs.SNOOZE_TIME, 3)

                    if (!actionTaken && retryCount < snooze_times) {
                        val snoozeMinutes =
                            prefs.getInt(AlarmPrefs.SNOOZE, 5)

                        val triggerTime =
                            System.currentTimeMillis() +
                                    (snoozeMinutes * 60 * 1000L)



                        retryCount++



                        prefs.edit()

                            .putInt(retryKey, retryCount)

                            .apply()



                        val snoozeIntent = Intent(this@AlarmService, AlarmReceiver::class.java).apply {

                            putExtra("ALARM_ID", alarm.id)

                            putExtra("ALARM_TITLE", alarm.title)

                            putExtra("IS_SNOOZE", true)

                            putExtra("AUTO_SNOOZE", true)

                        }



                        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager



                        val snoozePending = PendingIntent.getBroadcast(

                            this@AlarmService,

                            alarm.id + 90000 + retryCount,

                            snoozeIntent,

                            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE

                        )



                        alarmManager.setExactAndAllowWhileIdle(

                            AlarmManager.RTC_WAKEUP,

                             triggerTime,

                            snoozePending

                        )

                    }



                    // reset after max 3

                    if (retryCount >= 3) {

                        prefs.edit()

                            .remove(retryKey)

                            .apply()

                    }



                }



                // ================= DAILY RESCHEDULE =================

                if (!isSnooze && alarm.daysMask > 0) {

                    AlarmScheduler().schedule(this@AlarmService, alarm)

                }

                if(alarm.daysMask==0){
                    val updatedAlarm = alarm.copy(
                                        title = alarm.title,
                                        hour = alarm.hour,
                                        minute = alarm.minute,
                                        isActive = false,
                                        isDaily = alarm.isDaily,
                                        daysMask = alarm.daysMask,
                                        sound = alarm.sound,
                                        locationId = alarm.locationId
                                    )
                   
                     db.alarmDao().update(updatedAlarm)

                }



                withContext(Dispatchers.Main) {

                    Toast.makeText(

                        this@AlarmService,

                        displayTitle,

                        Toast.LENGTH_LONG

                    ).show()

                }



            } else {

                stopSelf()

            }

        }



        return START_NOT_STICKY

    }
  override fun onBind(intent: Intent?): IBinder? = null



    override fun onDestroy() {

        SoundHelper.stopSound()

        super.onDestroy()

    }
}

class SnoozeReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val id = intent.getIntExtra("ALARM_ID", -1)
        val title = intent.getStringExtra("ALARM_TITLE") ?: "Alarm"

        // ১. বর্তমান সাউন্ড ও ভাইব্রেশন বন্ধ করা
        SoundHelper.stopSound()

        // ✅ foreground service stop
        val serviceIntent = Intent(context, AlarmService::class.java)
        context.stopService(serviceIntent)

        // ২. নোটিফিকেশন রিমুভ করা
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        nm.cancel(id)

        val prefs = context.getSharedPreferences("AppPrefs", Context.MODE_PRIVATE)

        // ===================== SNOOZE LIMIT LOGIC =====================
        val key = "snooze_count_$id"
        val count = prefs.getInt(key, 0)
        val maxSnoozeLimit = prefs.getInt(AlarmPrefs.SNOOZE_TIME, 3) 

        if (count >= maxSnoozeLimit) {
            Toast.makeText(context, "Max snooze limit reached", Toast.LENGTH_SHORT).show()
            return
        }

        prefs.edit().putInt(key, count + 1).apply()
        // =============================================================
        
        val snoozeMinutes = prefs.getInt("snooze_duration", 5)

        // ৩. স্নুজ শিডিউল করা
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val nextIntent = Intent(context, AlarmReceiver::class.java).apply {
            putExtra("ALARM_ID", id)
            putExtra("ALARM_TITLE", "$title (Snoozed)")
            putExtra("IS_SNOOZE", true)
        }

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            id + 5000,
            nextIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val snoozeTime = System.currentTimeMillis() + (snoozeMinutes * 60 * 1000L)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                snoozeTime,
                pendingIntent
            )
        } else {
            alarmManager.setExact(
                AlarmManager.RTC_WAKEUP,
                snoozeTime,
                pendingIntent
            )
        }
        

        Toast.makeText(
            context,
            "Snoozed for $snoozeMinutes minutes ($count/$maxSnoozeLimit)",
            Toast.LENGTH_SHORT
        ).show()
    }
}
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
            intent.action == "android.intent.action.QUICKBOOT_POWERON") {
            SyncManager.scheduleMosqueSync(context)

            Log.d("AlarmApp", "BootReceiver triggered. Rescheduling alarms based on settings...")

            val db = AppDatabase.getInstance(context)
            val scheduler = AlarmScheduler()

            CoroutineScope(Dispatchers.IO).launch {
                try {
                    // ১. সেটিংস থেকে currentLocationId আনা
                    val settings = db.settingsDao().getSettings()
                    val currentLocationId = settings?.currentLocationId ?: -1

                    // ২. currentLocationId-এর অ্যালার্মগুলো আনা
                    val locationAlarms = if (currentLocationId != -1) {
                        db.alarmDao().getAlarmsByLocation(currentLocationId)
                    } else {
                        emptyList()
                    }

                    // ৩. 10 (General) লোকেশনের অ্যালার্মগুলো আনা
                    val generalAlarms = db.alarmDao().getAlarmsByLocation(10)

                    // ৪. দুটি লিস্ট একত্রিত করা
                    val allAlarms = locationAlarms + generalAlarms

                    // ৫. অ্যালার্ম শিডিউল করা
                    for (alarm in allAlarms) {
                        if (alarm.isActive) {
                            scheduler.schedule(context, alarm)
                        }
                    }
                    Log.d("AlarmApp", "All active location and general alarms rescheduled successfully.")
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }
    }
}




class StopAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val id = intent.getIntExtra("ALARM_ID", -1)

        // ১. ফ্ল্যাগ সেট করুন যাতে অটো-স্নুজ না হয়
        val prefs = context.getSharedPreferences("alarm_state", Context.MODE_PRIVATE)
        prefs.edit().putBoolean("user_action_taken_$id", true).apply()

        // ২. সাউন্ড ও সার্ভিস বন্ধ করা
        SoundHelper.stopSound()
        val serviceIntent = Intent(context, AlarmService::class.java)
        context.stopService(serviceIntent)

        // ৩. নোটিফিকেশন রিমুভ করা
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (id != -1) nm.cancel(id) else nm.cancelAll()
    }
}
