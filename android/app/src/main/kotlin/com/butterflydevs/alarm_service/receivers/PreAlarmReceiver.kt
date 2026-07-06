package com.butterflydevs.salahmaster.alarm_service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service

import android.os.Handler
import android.os.IBinder
import android.os.Looper
import androidx.core.app.NotificationCompat
// 🔥 নোটিফিকেশনের ছোট আইকনের জন্য আপনার প্রজেক্টের R ক্লাস ইমপোর্ট (প্যাকেজ নাম অনুযায়ী চেঞ্জ হতে পারে)
import com.butterflydevs.salahmaster.R
import android.media.RingtoneManager
import android.media.AudioAttributes
class PreAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {

        val id = intent.getIntExtra("ALARM_ID", 0)
        val title = intent.getStringExtra("ALARM_TITLE") ?: "Alarm"
        val triggerTime = intent.getLongExtra("TRIGGER_TIME", 0L)
        val isJammat =
            intent.getBooleanExtra("IS_JAMMAT", false)

        val serviceIntent = Intent(context, PreAlarmService::class.java).apply {
            putExtra("ALARM_ID", id)
            putExtra("ALARM_TITLE", title)
            putExtra("TRIGGER_TIME", triggerTime)
            putExtra("IS_JAMMAT", isJammat)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(serviceIntent)
        } else {
            context.startService(serviceIntent)
        }
    }
}
class PreAlarmService : Service() {

    private val handler = Handler(Looper.getMainLooper())
    private var runnable: Runnable? = null

    private var alarmId: Int = 0
    private var title: String = ""
    private var triggerTime: Long = 0
    private var isjammat: Boolean = false

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {

        alarmId = intent?.getIntExtra("ALARM_ID", 0) ?: 0
        title = intent?.getStringExtra("ALARM_TITLE") ?: "Alarm"
        isjammat = intent?.getBooleanExtra("IS_JAMMAT",false) ?: false

        // triggerTime এখন current time থেকে 10 min + preAlarmOffset বাদ দিয়ে আসবে
        triggerTime = intent?.getLongExtra("TRIGGER_TIME", 0L) ?: 0L

        startForeground(alarmId + 1000, createNotification("Starting..."))

        startCountdown(IS_JAMMAT = isjammat)

        return START_NOT_STICKY
    }

    private fun startCountdown(IS_JAMMAT: Boolean = false) {

        runnable = object : Runnable {
            override fun run() {

                val remaining = triggerTime - System.currentTimeMillis()

                if (remaining <= 0) {
                    stopSelf()
                    return
                }

                val minutes = (remaining / 1000) / 60
                val seconds = (remaining / 1000) % 60

                val text = if (IS_JAMMAT) {
                    "Get ready! Jama'ah starts in ${minutes}m ${seconds}s"
                } else {
                    "Alarm in ${minutes}m ${seconds}s"
                }
                val notification = createNotification(text)

                val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                nm.notify(alarmId + 1000, notification)

                handler.postDelayed(this, 1000)
            }
        }

        handler.post(runnable!!)
    }

    private fun createNotification(content: String): Notification {

        val channelId = "pre_alarm_channel"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Pre Alarm",
                NotificationManager.IMPORTANCE_HIGH
            )
            channel.enableVibration(true)
            //channel.vibrationPattern = longArrayOf(0, 500, 250, 500)

            val soundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
            
            channel.setSound(
                soundUri,
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                    .build()
            )

            val nm = getSystemService(NotificationManager::class.java)
            nm.createNotificationChannel(channel)
        }
        val ignoreIntent = Intent(this, IgnoreAlarmReceiver::class.java).apply {
            putExtra("ALARM_ID", alarmId)
        }
        val ignorePendingIntent = PendingIntent.getBroadcast(
            this,
            alarmId + 88888, // ইউনিক রিকোয়েস্ট কোড
            ignoreIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val soundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)


        return NotificationCompat.Builder(this, channelId)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(content)
            .setSound(soundUri)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .addAction(
                R.drawable.ic_stop, // আপনার প্রজেক্টের যেকোনো ক্লোজ বা ক্রস আইকন
                "Ignore This Time",
                ignorePendingIntent
            )
            .build()
    }

    override fun onDestroy() {
        runnable?.let { handler.removeCallbacks(it) }
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}