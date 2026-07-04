//package com.example.salahschedule
//
//import android.content.Context
//import android.content.Intent
//import android.app.*
//import android.os.Build
//import android.util.Log
//import android.widget.Toast
//import io.flutter.embedding.engine.FlutterEngine
//import io.flutter.plugin.common.MethodChannel
//import java.util.*
//
//class NativeAlarmEngine(
//    private val context: Context,
//    flutterEngine: FlutterEngine
//) {
//
//    private val CHANNEL = "com.example.salahschedule/native_alarm"
//
//    init {
//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
//            .setMethodCallHandler { call, result ->
//
//                when (call.method) {
//
//                    // 🔥 1. Schedule Alarm
//                    "scheduleAlarm" -> {
//                        val prayerName = call.argument<String>("prayerName") ?: "Salah"
//                        val hour = call.argument<Int>("hour") ?: 0
//                        val minute = call.argument<Int>("minute") ?: 0
//                        val requestCode = call.argument<Int>("requestCode") ?: 0
//
//                        scheduleAlarm(prayerName, hour, minute, requestCode)
//
//                        result.success("Alarm Scheduled")
//                    }
//
//                    // 🔥 2. Stop Alarm
//                    "stopAlarm" -> {
//                        SoundHelper.stopSound()
//                        result.success("Stopped")
//                    }
//
//                    // 🔥 3. Trigger test alarm
//                    "testAlarm" -> {
//                        NotificationHelper.showSalahNotification(context, "Test Alarm")
//                        SoundHelper.playAlarmSound(context)
//                        result.success("Test triggered")
//                    }
//
//                    else -> result.notImplemented()
//                }
//            }
//    }
//
//    // 🔥 ACTUAL ALARM SET
//    private fun scheduleAlarm(
//        prayerName: String,
//        hour: Int,
//        minute: Int,
//        requestCode: Int
//    ) {
//
//        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
//
//        val intent = Intent(context, AlarmReceiver::class.java).apply {
//            putExtra("PRAYER_NAME", prayerName)
//        }
//
//        val pendingIntent = PendingIntent.getBroadcast(
//            context,
//            requestCode,
//            intent,
//            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
//        )
//
//        val calendar = Calendar.getInstance().apply {
//            set(Calendar.HOUR_OF_DAY, hour)
//            set(Calendar.MINUTE, minute)
//            set(Calendar.SECOND, 0)
//        }
//
//        // 🔥 if time passed → next day
//        if (calendar.timeInMillis < System.currentTimeMillis()) {
//            calendar.add(Calendar.DAY_OF_MONTH, 1)
//        }
//
//        val alarmInfo = AlarmManager.AlarmClockInfo(
//            calendar.timeInMillis,
//            pendingIntent
//        )
//
//        alarmManager.setAlarmClock(alarmInfo, pendingIntent)
//
//        Log.d("NativeAlarm", "Alarm set for $prayerName at $hour:$minute")
//    }
//}