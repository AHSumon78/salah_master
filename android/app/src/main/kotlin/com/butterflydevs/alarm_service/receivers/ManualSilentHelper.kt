package com.butterflydevs.salahmaster.alarm_service

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.media.AudioManager
import android.os.Build
import android.os.CountDownTimer
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.TextView
import android.widget.Toast
import androidx.core.app.NotificationCompat


object ManualSilentHelper {

    private const val REQUEST_CODE = 77777
    private const val NOTIFICATION_ID = 88888
    private const val CHANNEL_ID = "silent_mode_channel"

    private var countdownTimer: CountDownTimer? = null
    private var notchView: View? = null

    /**
     * ফোনকে নির্দিষ্ট মিনিটের জন্য সাইলেন্ট করার ফাংশন
     */
    /**
     * ফোনকে নির্দিষ্ট মিনিটের জন্য সাইলেন্ট করার ফাংশন
     */
    fun startManualSilent(context: Context, minutes: Int) {
        val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val prefs = context.getSharedPreferences("AppPrefs", Context.MODE_PRIVATE)

        // সাইলেন্ট করার আগে বর্তমান সবগুলো স্টেট সেভ করা
        prefs.edit()
            .putInt("previous_ringer_mode", audioManager.ringerMode)
            .putInt("previous_ring_volume", audioManager.getStreamVolume(AudioManager.STREAM_RING))
            .putInt("previous_media_volume", audioManager.getStreamVolume(AudioManager.STREAM_MUSIC))
            .putInt("previous_notif_volume", audioManager.getStreamVolume(AudioManager.STREAM_NOTIFICATION))
            .apply()

        // ডিএনডি পারমিশন চেক
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !notificationManager.isNotificationPolicyAccessGranted) {
            Toast.makeText(context, "Please grant Do Not Disturb Access permission first", Toast.LENGTH_LONG).show()
            return
        }

        try {
            // ১. ফোনকে সাইলেন্ট মোডে নেওয়া এবং সব চ্যানেল মিউট করা
            audioManager.ringerMode = AudioManager.RINGER_MODE_SILENT
            audioManager.setStreamVolume(AudioManager.STREAM_RING, 0, 0)
            audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, 0, 0)
            audioManager.setStreamVolume(AudioManager.STREAM_NOTIFICATION, 0, 0)

            val durationMillis = minutes * 60 * 1000L
            val endTime = System.currentTimeMillis() + durationMillis

            // ২. SharedPreferences-এ স্টেট সেভ করা
            prefs.edit().apply {
                putBoolean("is_manual_silent", true)
                putLong("manual_silent_end_time", endTime)
            }.apply()

            // ৩. AlarmManager সেট করা
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val intent = Intent(context, ManualSilentReceiver::class.java)
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                REQUEST_CODE,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, endTime, pendingIntent)
            } else {
                alarmManager.setExact(AlarmManager.RTC_WAKEUP, endTime, pendingIntent)
            }

            // ৪. নোটিফিকেশন এবং নচ ওভারলে দেখানো
            showCountdownNotification(context, notificationManager, endTime)
            showNotchCountdown(context, durationMillis)

            Toast.makeText(context, "Phone silenced for $minutes minutes", Toast.LENGTH_SHORT).show()

        } catch (e: Exception) {
            Toast.makeText(context, "Error: ${e.message}", Toast.LENGTH_SHORT).show()
        }
    }

    /**
     * ইউজার যদি সময়ের আগেই অথবা অ্যালার্মের মাধ্যমে সাইলেন্ট বন্ধ করে
     */
    fun stopManualSilent(context: Context) {
        val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val prefs = context.getSharedPreferences("AppPrefs", Context.MODE_PRIVATE)

        // সেভ করা ডাটাগুলো রিড করা (না থাকলে ডিফল্ট অর্ধেক ভলিউম)
        val previousRingerMode = prefs.getInt("previous_ringer_mode", AudioManager.RINGER_MODE_NORMAL)
        val previousRingVolume = prefs.getInt("previous_ring_volume", audioManager.getStreamMaxVolume(AudioManager.STREAM_RING) / 2)
        val previousMediaVolume = prefs.getInt("previous_media_volume", audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC) / 2)
        val previousNotifVolume = prefs.getInt("previous_notif_volume", audioManager.getStreamMaxVolume(AudioManager.STREAM_NOTIFICATION) / 2)

        // ১. ফোন আগের মোডে ফেরানো
        audioManager.ringerMode = previousRingerMode
        audioManager.setStreamVolume(AudioManager.STREAM_RING, previousRingVolume, 0)
        audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, previousMediaVolume, 0)
        audioManager.setStreamVolume(AudioManager.STREAM_NOTIFICATION, previousNotifVolume, 0)

        // ২. প্রিফারেন্স ক্লিয়ার করা
        prefs.edit().apply {
            putBoolean("is_manual_silent", false)
            remove("manual_silent_end_time")
            remove("previous_ringer_mode")
            remove("previous_ring_volume")
            remove("previous_media_volume")
            remove("previous_notif_volume")
        }.apply()

        // ৩. অ্যালার্ম ক্যানসেল করা
        val intent = Intent(context, ManualSilentReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            REQUEST_CODE,
            intent,
            PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
        )
        
        pendingIntent?.let {
            alarmManager.cancel(it)
            it.cancel()
        }

        // ৪. UI ক্লিনআপ
        notificationManager.cancel(NOTIFICATION_ID)
        removeNotchCountdown(context)

        Toast.makeText(context, "Manual silent disabled", Toast.LENGTH_SHORT).show()
    }

    /**
     * নোটিফিকেশন প্যানেলে লাইভ কাউন্টডাউন শো করার হেল্পার ফাংশন (বড় ফন্ট প্রেজেন্টেশন)
     */
    private fun showCountdownNotification(context: Context, notificationManager: NotificationManager, endTime: Long) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Silent Mode Notifications",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows live countdown for silent mode"
            }
            notificationManager.createNotificationChannel(channel)
        }

        val timeoutDuration = endTime - System.currentTimeMillis()

        // বড় করে ও স্পষ্টভাবে কাউন্টডাউন দেখানোর জন্য টাইটেল এবং ক্রোনোমিটার লজিক অপ্টিমাইজ করা হয়েছে
        val notificationBuilder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_lock_silent_mode)
            .setContentTitle("Silent Mode Active")
            .setContentText("Remaining time is ticking below") 
            .setSubText("Silent Time") // ছোট টেক্সটগুলো সাব-টেক্সটে সরানো হয়েছে
            .setWhen(endTime)
            .setUsesChronometer(true)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setTimeoutAfter(timeoutDuration)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            notificationBuilder.setChronometerCountDown(true)
        }

        notificationManager.notify(NOTIFICATION_ID, notificationBuilder.build())
    }

    /**
     * নচের নিচে কাস্টম ফ্লোটিং কাউন্টডাউন উইন্ডো পুশ করার ফাংশন
     */
    private fun showNotchCountdown(context: Context, durationMillis: Long) {
        // ওল্ড ভিউ বা টাইমার রানিং থাকলে আগে ক্লিয়ার করে নেওয়া
        removeNotchCountdown(context)

        // সিস্টেম ওভারলে পারমিশন চেক (Android 6.0+)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !android.provider.Settings.canDrawOverlays(context)) {
            return // পারমিশন না থাকলে কাস্টম নচ ভিউ শো হবে না
        }

        val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        
        // কাস্টম টেক্সট ভিউ জেনারেট করা
        val countdownTextView = TextView(context).apply {
            text = ""
            setBackgroundColor(0xBB000000.toInt()) // হালকা স্বচ্ছ কালো ব্যাকগ্রাউন্ড
            setTextColor(0xFFFFFFFF.toInt())       // ফুল হোয়াইট টেক্সট
            textSize = 14f                        // ফন্টের সাইজ
            setPadding(24, 10, 24, 10)
            gravity = Gravity.CENTER
        }
        
        notchView = countdownTextView

        // উইন্ডো প্যারামিটার সেটআপ (নচের পজিশন অনুযায়ী)
        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) 
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY 
            else 
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.CENTER_HORIZONTAL // নচের ঠিক মাঝে সেট করতে
            y = 12 // নচ থেকে সামান্য নিচে পজিশন সেটআপ
        }

        // স্ক্রিনে উইন্ডো যুক্ত করা
        windowManager.addView(countdownTextView, params)

        // কাউন্টডাউন টাইমার স্টার্ট (১ সেকেন্ড পর পর টেক্সট আপডেট হবে)
        countdownTimer = object : CountDownTimer(durationMillis, 1000) {
            override fun onTick(millisUntilFinished: Long) {
                val minutesRemaining = (millisUntilFinished / 1000) / 60
                val secondsRemaining = (millisUntilFinished / 1000) % 60
                countdownTextView.text = String.format("%02d:%02d", minutesRemaining, secondsRemaining)
            }

            override fun onFinish() {
                removeNotchCountdown(context)
            }
        }.start()
    }

    /**
     * নচ ভিউ এবং টাইমার বন্ধ করার হেল্পার ফাংশন
     */
    private fun removeNotchCountdown(context: Context) {
        countdownTimer?.cancel()
        countdownTimer = null

        notchView?.let {
            try {
                val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
                windowManager.removeView(it)
            } catch (e: Exception) {
                e.printStackTrace()
            }
            notchView = null
        }
    }
}
