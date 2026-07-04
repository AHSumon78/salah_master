package com.butterflydevs.salahmaster.alarm_service

import android.app.KeyguardManager
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.butterflydevs.salahmaster.R
import android.content.Intent
import android.content.BroadcastReceiver
import android.content.IntentFilter
import android.widget.Toast

class AlarmActivity : AppCompatActivity() {
    private var receiverRegistered = false
    private val autoStopReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
       
            Toast.makeText(context, "Auto Stop Broadcast Received!", Toast.LENGTH_SHORT).show()
            finish()

        }
    }
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)  
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {

                registerReceiver(
                    autoStopReceiver,
                    IntentFilter("AUTO_STOP_ALARM"),
                    RECEIVER_NOT_EXPORTED
                )

            } else {

                registerReceiver(
                    autoStopReceiver,
                    IntentFilter("AUTO_STOP_ALARM")
                )
            }
        receiverRegistered = true
        setupLockScreen()                   
        setContentView(R.layout.activity_alarm)

        val alarmId = intent.getIntExtra("ALARM_ID", -1)
        val alarmTitle = intent.getStringExtra("ALARM_TITLE") ?: "Alarm"

        val tvTitle = findViewById<TextView>(R.id.tvPrayerName)
        val btnStop = findViewById<Button>(R.id.btnStop)
        val btnSnooze = findViewById<Button>(R.id.btnSnooze)

        tvTitle.text = "It's time for $alarmTitle"

        btnStop.setOnClickListener {
            stopAlarm(alarmId)
        }
        btnSnooze.setOnClickListener {

                val snoozeIntent = Intent(this, SnoozeReceiver::class.java).apply {
                    putExtra("ALARM_ID", alarmId)
                    putExtra("ALARM_TITLE", alarmTitle)
                }
                sendBroadcast(snoozeIntent)

                // ২. গুরুত্বপূর্ণ: অ্যালার্ম সার্ভিসটি বন্ধ করুন (এটিই নোটিফিকেশন সরাবে)
                val serviceIntent = Intent(this, AlarmService::class.java)
                stopService(serviceIntent)

                // ৩. নোটিফিকেশন ম্যানুয়ালি ক্যানসেল করুন
                val nm = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
                if (alarmId != -1) {
                    nm.cancel(alarmId)
                } else {
                    nm.cancelAll()
                }

                finish() // অ্যাক্টিভিটি বন্ধ করুন
            }
    }

    private fun setupLockScreen() {
        // অ্যান্ড্রয়েড ও (৮.১) এবং তার পরের ভার্সনের জন্য
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)

            // কিবোর্ড বা সিকিউরিটি লক ডিসমিস করার জন্য
            val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
            keyguardManager.requestDismissKeyguard(this, null)
        } else {
            // পুরাতন ভার্সনের জন্য ফ্ল্যাগ ব্যবহার
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                        WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
                        WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                        WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                        WindowManager.LayoutParams.FLAG_ALLOW_LOCK_WHILE_SCREEN_ON or
                        WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
            )
        }

        // স্ক্রিন যেন স্লিপ মোডে না যায়
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }

    private fun stopAlarm(id: Int) {

        val prefs = getSharedPreferences("alarm_state", Context.MODE_PRIVATE)
        prefs.edit().putBoolean("user_action_taken_$id", true).apply()
        // সাউন্ড বন্ধ করা
        SoundHelper.stopSound()

        val serviceIntent = Intent(this, AlarmService::class.java)
        stopService(serviceIntent)

        

        val nm = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
     
              if (id != -1) {
                    nm.cancel(id)
                } else {
                    nm.cancelAll()
                }
        

        finish()
    }

    // ইউজার যাতে দুর্ঘটনাবশত ব্যাক বাটন চেপে অ্যালার্ম বন্ধ না করে দেয়
    @Deprecated("Deprecated in Java")
    override fun onBackPressed() {
        // কিছু করার দরকার নেই অথবা সুপার কল করবেন না
    }

    override fun onDestroy() {
        super.onDestroy()
        // অ্যাক্টিভিটি কোনোভাবে ডেস্ট্রয় হলে সাউন্ড বন্ধ নিশ্চিত করা
        if (receiverRegistered) {
            unregisterReceiver(autoStopReceiver)
            receiverRegistered = false
        }
        
        
    }
    
}