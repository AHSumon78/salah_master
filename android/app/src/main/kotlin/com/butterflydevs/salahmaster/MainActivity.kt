package com.butterflydevs.salahmaster

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log
import com.butterflydevs.salahmaster.data.AlarmPrefs
// আপনার প্রজেক্টের সঠিক পাথ অনুযায়ী এগুলো চেক করুন
import com.butterflydevs.salahmaster.database.AppDatabase
import com.butterflydevs.salahmaster.DatabaseMethodChannel
import com.butterflydevs.salahmaster.WidgetMethodChannel

import com.butterflydevs.salahmaster.FullScreenIntentHelper
import com.butterflydevs.salahmaster.alarm_service.AlarmScheduler
import com.butterflydevs.salahmaster.alarm_service.SyncManager
import com.butterflydevs.salahmaster.RingtoneMethodChannel
import com.butterflydevs.salahmaster.LanguageMethodChannel
import com.butterflydevs.salahmaster.CompassStreamHandler



import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import android.content.SharedPreferences
import android.Manifest
import android.content.pm.PackageManager
import android.app.PendingIntent
import android.provider.Settings
import android.media.AudioAttributes
import android.media.AudioManager
import io.flutter.plugin.common.EventChannel


class MainActivity : FlutterActivity() {
    companion object {
        private const val REQ_CODE = 2002
    }

    private lateinit var db: AppDatabase
    private lateinit var ringtoneMethodChannel: RingtoneMethodChannel
    private lateinit var languageMethodChannel: LanguageMethodChannel
    private val fullScreenHelper by lazy { FullScreenIntentHelper(this) }

    override fun onCreate(savedInstanceState: Bundle?) {
        db = AppDatabase.getInstance(this)
        // ১. super.onCreate() সবার আগে কল করতে হবে।
        super.onCreate(savedInstanceState)

        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
    
    // ফ্লাটার সাইডে যদি SharedPreferences-এ key-র নাম 'flutter.language_code' দিয়ে থাকেন:
    val savedLanguage = prefs.getString("flutter.app_language_code", "en") ?: "en"
    
    // অ্যাপ চালুর শুরুতেই নেটিভ Locale সেট করে দেওয়া
    LocaleHelper.updateNativeLocale(this, savedLanguage)
        // ২. এরপরে ডাটাবেজ লোড করুন

        // ৩. বাকি কাজগুলো করুন
        CoroutineScope(Dispatchers.IO).launch {
            try {
                db.settingsDao().getSettings()
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
        volumeControlStream = android.media.AudioManager.STREAM_MUSIC
        createNotificationChannel(this)
        SyncManager.scheduleMosqueSync(this)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // মেথড চ্যানেল রেজিস্টার করুন
        DatabaseMethodChannel(this, db).register(flutterEngine)

        ringtoneMethodChannel = RingtoneMethodChannel(this)
        languageMethodChannel = LanguageMethodChannel(this)
        ringtoneMethodChannel.register(flutterEngine)
        languageMethodChannel.register(flutterEngine)
        WidgetMethodChannel(
            this,
            flutterEngine
        )
        fullScreenHelper.register(flutterEngine)
         EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "qibla_compass_stream"
        ).setStreamHandler(
            CompassStreamHandler(this)
        )
        val CHANNEL = "com.butterflydevs.salahmaster/channel"

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "startAlarmAndService") {
                try {
                    val sharedPreferences = getSharedPreferences("AppPrefs", Context.MODE_PRIVATE)
                    val isFirstRun = sharedPreferences.getBoolean("is_first_time", true)

                    if (isFirstRun) {
                        sharedPreferences.edit().apply {
                            putBoolean(AlarmPrefs.VIBRATION, true)
                            putBoolean(AlarmPrefs.GRADUAL, true)
                            putInt(AlarmPrefs.SNOOZE_TIME,3)
                            putInt(AlarmPrefs.SNOOZE, 5)
                            putInt(AlarmPrefs.AUTO_STOP, 5)
                            putBoolean(AlarmPrefs.PRE_ALARM, true)
                            putBoolean(AlarmPrefs.MISSED, true)
                            putBoolean(AlarmPrefs.AUTO_SILENT,true)
                        }.apply()
                        // পারমিশন চেক করা হচ্ছে
                        Log.d("AlarmTest", "is First time")
                        val hasPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            Log.d("AlarmTest", "Permission granted. Starting service and alarm...")
                            androidx.core.content.ContextCompat.checkSelfPermission(
                                this,
                                android.Manifest.permission.POST_NOTIFICATIONS
                            ) == android.content.pm.PackageManager.PERMISSION_GRANTED
                        } else {
                            true // Android 12 বা তার নিচের ভার্সনের জন্য পারমিশনের প্রয়োজন নেই
                        }

                        if (hasPermission) {
                            // সার্ভিসটি সাথে সাথে চালু করা
                           






                            // SharedPreferences-এ ফ্ল্যাগ আপডেট করা যাতে পরবর্তীতে আর রান না হয়
                            sharedPreferences.edit().putBoolean("is_first_time", false).apply()

                            // অ্যালার্ম শিডিউলার চালু করা (প্রথম ট্রিগার হবে সাথে সাথে)
                            //AlarmScheduler().start10MinuteAlarm(this, isInitial = isFirstRun)

                            result.success("Service and alarm started successfully")
                        } else {
                            result.success("No permission, but ran the check")
                        }
                    } else {
                        // 🌟 এখানেও পারমিশন চেক করা হলো
                        val hasPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            androidx.core.content.ContextCompat.checkSelfPermission(
                                this,
                                android.Manifest.permission.POST_NOTIFICATIONS
                            ) == android.content.pm.PackageManager.PERMISSION_GRANTED
                        } else {
                            true
                        }

                        if (hasPermission) {
                            // পরবর্তীতে অ্যাপ খুললে অ্যালার্ম আছে কিনা চেক করার জন্য
                            

                            // যদি অ্যালার্মটি আগে থেকে না থাকে (অ্যান্ড্রয়েড সিস্টেম বা অন্য কোনো কারণে বন্ধ হয়ে গেলে)
                            
                                Log.d("AlarmTest", "Alarm is missing. Starting service and alarm again...")

                                // সার্ভিসটি আবার চালু করা
                               

                                

                                result.success("Alarm was missing and has been restarted")
                           
                        } else {
                            result.success("No permission, please grant permission first")
                        }
                    }
                } catch (e: Exception) {
                    result.error("ERROR_STARTING", e.localizedMessage, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        // আলাদা ক্লাসে onActivityResult ডেলিগেট করে দেওয়া হলো
        ringtoneMethodChannel.onActivityResult(requestCode, resultCode, data)
    }

    private fun createNotificationChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelId = "ALARM_CHANNEL_ID"
            val name = "Alarm Notifications"
            val descriptionText = "This channel is used for high-priority alarm alerts"

            // ১. গুরুত্ব সেট করা (IMPORTANCE_HIGH মানে এটি পপ-আপ হবে এবং স্ক্রিন অন করবে)
            val importance = NotificationManager.IMPORTANCE_HIGH

            val channel = NotificationChannel(channelId, name, importance).apply {
                description = descriptionText

                // ২. DND (Do Not Disturb) মোড বাইপাস করা - এটি অত্যন্ত জরুরি
                setBypassDnd(true)

                // ৩. সিস্টেমের ডিফল্ট সাউন্ড অফ রাখা (যেহেতু আপনি কাস্টম সাউন্ড বা SoundHelper ইউজ করছেন)
                

                // ৪. ভিজ্যুয়াল এলার্টস
                enableLights(true)
                lightColor = android.graphics.Color.RED
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 500, 250, 500) // কাস্টম ভাইব্রেশন প্যাটার্ন
                setSound(null,null)
               
                lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC

                // ৬. ব্যাজ শো করা
                setShowBadge(true)
            }

            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            // ৭. চ্যানেলটি তৈরি করা
            notificationManager.createNotificationChannel(channel)
        }
    }
}