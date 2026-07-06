package com.butterflydevs.salahmaster.alarm_service

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.os.Build
import android.widget.Toast

class ManualSilentReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        // Do Not Disturb (DND) Access চেক করা (অ্যান্ড্রয়েড ৬.০+)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !notificationManager.isNotificationPolicyAccessGranted) {
            return
        }

        try {
            // ১. ফোনকে আবার আগের মতো নরমাল (Ringer) মুডে ফিরিয়ে আনা
            //audioManager.ringerMode = AudioManager.RINGER_MODE_NORMAL
            
            // ২. নোটিফিকেশন প্যানেল থেকে কাউন্টডাউন নোটিফিকেশনটি রিমুভ করা (ID: 88888)
            notificationManager.cancel(88888)

            // ৩. নচ ওভারলে ভিউ এবং ব্যাকগ্রাউন্ড কাউন্টডাউন টাইমারটি সম্পূর্ণ বন্ধ ও রিমুভ করা
            ManualSilentHelper.stopManualSilent(context)

            Toast.makeText(context, "Manual silent period ended. Phone is now in Normal mode.", Toast.LENGTH_LONG).show()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
