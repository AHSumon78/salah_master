package com.butterflydevs.salahmaster.alarm_service

import android.app.Notification
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Color
import androidx.core.app.NotificationCompat

import com.butterflydevs.salahmaster.R
import com.butterflydevs.salahmaster.alarm_service.AlarmActivity
object NotificationHelper {
    fun showNotification(context: Context, id: Int, title: String): Notification {
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        // ১. ফুল স্ক্রিন ইনটেন্ট
        val fullScreenIntent = Intent(context, AlarmActivity::class.java).apply {
            putExtra("ALARM_ID", id)
            putExtra("ALARM_TITLE", title)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_NO_USER_ACTION
        }
        val fullScreenPendingIntent = PendingIntent.getActivity(
            context, id, fullScreenIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // ২. Snooze বাটন ইনটেন্ট (এটি মিসিং ছিল)
        val snoozeIntent = Intent(context, SnoozeReceiver::class.java).apply {
            putExtra("ALARM_ID", id)
            putExtra("ALARM_TITLE", title)
        }

        val snoozePendingIntent = PendingIntent.getBroadcast(
            context,
            id + 5000, // ইউনিক রিকোয়েস্ট কোড
            snoozeIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // ৩. Dismiss/Stop বাটন ইনটেন্ট
        val stopIntent = Intent(context, StopAlarmReceiver::class.java).apply {
            putExtra("ALARM_ID", id)
        }

        val stopPendingIntent = PendingIntent.getBroadcast(
            context,
            id,
            stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // ৪. সোয়াইপ করে সরিয়ে দিলে (DeleteIntent) যা হবে
        val deletePendingIntent = PendingIntent.getBroadcast(
            context,
            id + 1000,
            stopIntent, // StopAlarmReceiver ই কল হবে সাউন্ড বন্ধ করতে
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // ৫. ফাইনাল নোটিফিকেশন বিল্ডার
        val notification = NotificationCompat.Builder(context, "ALARM_CHANNEL_ID")
            .setSmallIcon(R.mipmap.ic_launcher) // আপনার অ্যাপের আইকন দিন
            .setContentTitle("Alarm")
            .setContentText("It's time for $title")
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setFullScreenIntent(fullScreenPendingIntent, true) // লক স্ক্রিনে পপ-আপ হবে
            .addAction(R.drawable.ic_snooze, "Snooze", snoozePendingIntent)
            .addAction(R.drawable.ic_stop, "Stop", stopPendingIntent)
            .setDeleteIntent(deletePendingIntent) // সোয়াইপ করলে সাউন্ড অফ হবে
            .setOngoing(true) // যাতে সহজে ইউজার কাটতে না পারে
            .setAutoCancel(true)
            .setColor(Color.parseColor("#1A1A1A"))
            .setColorized(true)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .build()
        notificationManager.notify(id, notification)
        return notification
    }
}