package com.butterflydevs.salahmaster.alarm_service
import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.widget.Toast
import com.butterflydevs.salahmaster.database.AppDatabase 
import com.butterflydevs.salahmaster.data.AlarmEntity 
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
class IgnoreAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        val alarmId = intent?.getIntExtra("ALARM_ID", 0) ?: 0
        
        if (alarmId == 0) return

        // ১. প্রি-অ্যালার্ম সার্ভিসটি বন্ধ করার জন্য রিকোয়েস্ট পাঠানো
        val serviceIntent = Intent(context, PreAlarmService::class.java)
        context.stopService(serviceIntent)

        // ২. মেইন আসন্ন অ্যালার্মটি ক্যানসেল করা
        AlarmScheduler().cancelById(context, alarmId)

        // ৩. কোরাটিন ব্যবহার করে ডাটাবেজ থেকে অবজেক্ট নিয়ে নেক্সট শিডিউল করা
        CoroutineScope(Dispatchers.IO).launch {
            val db = AppDatabase.getInstance(context)
            val alarm = db.alarmDao().getAlarmById(alarmId) as? AlarmEntity // আপনার ডাও (Dao) অনুযায়ী গেট করুন
            
            if (alarm != null) {
                // যেহেতু আমরা 'এই বারের মতো' ইগনোর করছি, তাই কোডকে বোঝাতে হবে আজকের সময় পার হয়ে গেছে।
                // আমাদের তৈরি করা getNextAlarmTimeInMillis লজিক স্বয়ংক্রিয়ভাবে পরবর্তী সিলেক্টেড দিন খুঁজে নেবে।
                AlarmScheduler().schedule(context, alarm,skipToday=true)
            }
        }
        
        Toast.makeText(context, "Alarm ignored for this time", Toast.LENGTH_SHORT).show()
    }
}
