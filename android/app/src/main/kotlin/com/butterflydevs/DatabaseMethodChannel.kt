package com.butterflydevs.salahmaster

import android.content.Context
import com.butterflydevs.salahmaster.data.AlarmEntity
import com.butterflydevs.salahmaster.data.MosqueEntity
import com.butterflydevs.salahmaster.data.LocationEntity
import com.butterflydevs.salahmaster.data.SettingsEntity
import com.butterflydevs.salahmaster.database.AppDatabase
import com.butterflydevs.salahmaster.alarm_service.AlarmScheduler
import com.butterflydevs.salahmaster.alarm_service.SilentScheduler
import com.butterflydevs.salahmaster.alarm_service.ManualSilentHelper
import com.butterflydevs.salahmaster.alarm_service.GeofenceHelper
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.butterflydevs.salahmaster.data.AlarmPrefs
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

import android.app.AlarmManager
import android.app.NotificationManager
import android.content.Intent
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import android.util.Log

import android.content.SharedPreferences


import android.net.Uri


//import io.fluidsonic.graphql.Type.Context 


class DatabaseMethodChannel(
    private val context: Context,
    private val db: AppDatabase
) {
    private val CHANNEL = "com.butterflydevs.salahmaster/db"

    fun register(flutterEngine: FlutterEngine) {

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                 val sharedPreferences =
                    context.getSharedPreferences("AppPrefs", Context.MODE_PRIVATE)

                when (call.method) {

                    // =========================
                    // LOCATION
                    // =========================
                    // ১. insertLocation কেস
                    "insertLocation" -> {

                        val name = call.argument<String>("name") ?: run {
                            result.error("ERROR", "name null", null)
                            return@setMethodCallHandler
                        }

                        val lat = call.argument<Double>("lat") ?: 0.0
                        val lon = call.argument<Double>("lon") ?: 0.0
                        val diameter = call.argument<Double>("diameter") ?: 0.0
                        val preAlarm = call.argument<Int>("preAlarm") ?: 0

                        CoroutineScope(Dispatchers.Main).launch {
                            try {
                                val id = withContext(Dispatchers.IO) {
                                    val insertedId = db.locationDao().insert(
                                        LocationEntity(
                                            name = name,
                                            latitude = lat,
                                            longitude = lon,
                                            diameter = diameter,
                                            preAlarmMinutes = preAlarm
                                        )
                                    )

                                    // alarm insert
                                    db.insertAlarmWhenLoaction(insertedId.toInt())

                                    // geofence
                                    val allLocations = db.locationDao().getAll()
                                    GeofenceHelper(context).registerAllGeofences(allLocations)

                                    insertedId
                                }

                                // 👇 guaranteed after ALL work done
                                result.success(id)

                            } catch (e: Exception) {
                                result.error("DB_ERROR", e.message, null)
                            }
                        }
                    }

// ২. updateLocation কেস
                    "updateLocation" -> {
                        val id = call.argument<Int>("id") ?: run {
                            result.error("ERROR", "id null", null)
                            return@setMethodCallHandler
                        }

                        val name = call.argument<String>("name") ?: ""
                        val lat = call.argument<Double>("lat") ?: 0.0
                        val lon = call.argument<Double>("lon") ?: 0.0
                        val diameter = call.argument<Double>("diameter") ?: 0.0
                        val preAlarm = call.argument<Int>("preAlarm") ?: 0

                        CoroutineScope(Dispatchers.IO).launch {
                            try {
                                // ডাটাবেজ আপডেট করা
                                db.locationDao().update(
                                    LocationEntity(
                                        id = id,
                                        name = name,
                                        latitude = lat,
                                        longitude = lon,
                                        diameter = diameter,
                                        preAlarmMinutes = preAlarm
                                    )
                                )

                                // আপডেট হওয়ার পর সব লোকেশন আবার আনা
                                val allLocations = db.locationDao().getAll()

                                // জিওফেন্স আপডেট করা (এটি আগের জিওফেন্স ওভাররাইট করে দেবে)
                                val helper = GeofenceHelper(context)
                                helper.registerAllGeofences(allLocations)

                               
                                withContext(Dispatchers.Main) {
                                    result.success(true)
                                }

                            } catch (e: Exception) {
                                withContext(Dispatchers.Main) {
                                    result.error("DB_ERROR", e.message, null)
                                }
                            }
                        }
                    }
                    "updateLocationSwitch" -> {
                        // Flutter থেকে পাঠানো লোকেশন আইডি রিসিভ করা
                        val newLocationId = call.argument<Int>("id") ?: run {
                            result.error("ERROR", "Location ID is missing", null)
                            return@setMethodCallHandler
                        }

                        // Coroutine Scope ব্যবহার করছি কারণ ডাটাবেজ/হ্যান্ডলার অপারেশন IO থ্রেডে হওয়া নিরাপদ
                        CoroutineScope(Dispatchers.IO).launch {
                            try {
                                val scheduler = AlarmScheduler()
                                scheduler.handleLocationSwitch(context, newLocationId)

                                // কাজ শেষ হলে মেইন থ্রেডে সাকসেস পাঠানো
                                withContext(Dispatchers.Main) {
                                    result.success(true)
                                }
                            } catch (e: Exception) {
                                withContext(Dispatchers.Main) {
                                    result.error("SWITCH_ERROR", e.message, null)
                                }
                            }
                        }
                    }

                    "getLocations" -> {
                        CoroutineScope(Dispatchers.IO).launch {
                            try {
                                val locations = db.locationDao().getAll()

                                // এখানে আমরা Entity-এর হুবহু নামগুলো ব্যবহার করছি
                                val resultList = locations.map { entity ->
                                    mapOf(
                                        "id" to entity.id,
                                        "name" to entity.name,
                                        "latitude" to entity.latitude,
                                        "longitude" to entity.longitude,
                                        "diameter" to entity.diameter,
                                        "preAlarmMinutes" to entity.preAlarmMinutes
                                    )
                                }

                                withContext(Dispatchers.Main) {
                                    result.success(resultList)
                                }
                            } catch (e: Exception) {
                                withContext(Dispatchers.Main) {
                                    result.error("DB_ERROR", e.message, null)
                                }
                            }
                        }
                    }
                    "deleteLocation" -> {
                        val id = call.argument<Int>("id") ?: run {
                            result.error("ERROR", "Location ID is required", null)
                            return@setMethodCallHandler
                        }

                        CoroutineScope(Dispatchers.IO).launch {
                            try {
                                // আইডি দিয়ে লোকেশনটি খুঁজে বের করা
                                val location = db.locationDao().getById(id)
                                if (location != null) {
                                    db.locationDao().delete(location)
                                    withContext(Dispatchers.Main) {
                                        result.success(true)
                                    }
                                } else {
                                    withContext(Dispatchers.Main) {
                                        result.error("NOT_FOUND", "Location not found", null)
                                    }
                                }
                            } catch (e: Exception) {
                                withContext(Dispatchers.Main) {
                                    result.error("DB_ERROR", e.message, null)
                                }
                            }
                        }
                    }
                    "getLocationById" -> {
                        val id = call.argument<Int>("id") ?: 0
                        CoroutineScope(Dispatchers.IO).launch {
                            try {
                                // আপনার DAO মেথডটির নাম getById, তাই এখানে সেটিই ব্যবহার করতে হবে
                                val location = db.locationDao().getById(id)

                                withContext(Dispatchers.Main) {
                                    if (location != null) {
                                        val locationMap = mapOf(
                                            "id" to location.id,
                                            "name" to location.name,
                                            "latitude" to location.latitude,
                                            "longitude" to location.longitude,
                                            "diameter" to location.diameter,
                                            "preAlarmMinutes" to location.preAlarmMinutes
                                        )
                                        result.success(locationMap)
                                    } else {
                                        result.success(null)
                                    }
                                }
                            } catch (e: Exception) {
                                withContext(Dispatchers.Main) {
                                    result.error("DB_ERROR", e.message, null)
                                }
                            }
                        }
                    }

                    // =========================
                    // ALARM
                    // =========================daysMask = 127,
                    "insertAlarm" -> {
                        val title = call.argument<String>("title") ?: return@setMethodCallHandler
                        val hour = call.argument<Int>("hour") ?: 0
                        val minute = call.argument<Int>("minute") ?: 0
                        val isActive = call.argument<Boolean>("isActive") ?: false
                        val isDaily = call.argument<Boolean>("isDaily") ?: true
                        val daysMask = call.argument<Int>("daysMask") ?: 0
                        val sound = call.argument<String>("sound") ?: "alarm.mp3"
                        val locationId = call.argument<Int>("locationId") ?: 0

                        CoroutineScope(Dispatchers.IO).launch {
                            try {
                                // ১. প্রথমে Entity অবজেক্টটি তৈরি করুন
                                val alarmToInsert = AlarmEntity(
                                    title = title,
                                    hour = hour,
                                    minute = minute,
                                    isActive = isActive,
                                    isDaily = isDaily,
                                    daysMask = daysMask,
                                    sound = sound,
                                    locationId = locationId
                                )

                                // ২. ডাটাবেসে ইনসার্ট করুন এবং জেনারেট হওয়া ID টি নিন
                                val newId = db.alarmDao().insert(alarmToInsert).toInt()

                                // ৩. ID সহ অবজেক্টটি আপডেট করুন শিডিউলারের জন্য
                                val finalAlarm = alarmToInsert.copy(id = newId)

                                val scheduler = AlarmScheduler()

                                // এখানে 'updatedAlarm' এর বদলে 'finalAlarm' ব্যবহার করা হয়েছে
                                if (finalAlarm.isActive) {
                                    // যদি অ্যালার্ম একটিভ থাকে, শিডিউল করুন
                                    scheduler.schedule(context, finalAlarm)
                                } else {
                                    // যদি ইনঅ্যাক্টিভ থাকে, ক্যানসেল করুন
                                    scheduler.cancel(context, finalAlarm.id)
                                }

                                withContext(Dispatchers.Main) {
                                    result.success(true)
                                }

                            } catch (e: Exception) {
                                withContext(Dispatchers.Main) {
                                    result.error("DB_ERROR", e.message, null)
                                }
                            }
                        }
                    }

                    "getGeneralAlarm" -> { // অথবা আপনার মেথড নাম অনুযায়ী
                            val locId = call.argument<Int>("locationId") ?: 0
                            CoroutineScope(Dispatchers.IO).launch {
                                try {
                                    val alarms = db.alarmDao().getAlarmsByLocation(locId)

                                    // 🔥 গুরুত্বপূর্ণ: AlarmEntity-কে Map-এ রূপান্তর করতে হবে
                                    val resultList = alarms.map { alarm ->
                                        mapOf(
                                            "id" to alarm.id,
                                            "title" to alarm.title,
                                            "hour" to alarm.hour,
                                            "minute" to alarm.minute,
                                            "isActive" to alarm.isActive,
                                            "isDaily" to alarm.isDaily,
                                            "daysMask" to alarm.daysMask,
                                            "sound" to alarm.sound,
                                            "locationId" to alarm.locationId
                                        )
                                    }

                                    withContext(Dispatchers.Main) {
                                        result.success(resultList) // এখন আর এরর দিবে না
                                    }
                                } catch (e: Exception) {
                                    withContext(Dispatchers.Main) {
                                        result.error("DB_ERROR", e.message, null)
                                    }
                                }
                            }
                        }
                    "getAlarmsByLocation" -> { // অথবা আপনার মেথড নাম অনুযায়ী
                        val locId = call.argument<Int>("locationId") ?: 0
                        CoroutineScope(Dispatchers.IO).launch {
                            try {
                                val alarms = db.alarmDao().getAlarmsByLocation(locId)

                                // 🔥 গুরুত্বপূর্ণ: AlarmEntity-কে Map-এ রূপান্তর করতে হবে
                                val resultList = alarms.map { alarm ->
                                    mapOf(
                                        "id" to alarm.id,
                                        "title" to alarm.title,
                                        "hour" to alarm.hour,
                                        "minute" to alarm.minute,
                                        "isActive" to alarm.isActive,
                                        "isDaily" to alarm.isDaily,
                                        "daysMask" to alarm.daysMask,
                                        "sound" to alarm.sound,
                                        "locationId" to alarm.locationId
                                    )
                                }

                                withContext(Dispatchers.Main) {
                                    result.success(resultList) // এখন আর এরর দিবে না
                                }
                            } catch (e: Exception) {
                                withContext(Dispatchers.Main) {
                                    result.error("DB_ERROR", e.message, null)
                                }
                            }
                        }
                    }

                    "updateAlarm" -> {

                        val id = call.argument<Int>("id") ?: run {
                            result.error("ERROR", "Alarm ID is required for update", null)
                            return@setMethodCallHandler
                        }

                        val title = call.argument<String>("title") ?: ""
                        val hour = call.argument<Int>("hour") ?: 0
                        val minute = call.argument<Int>("minute") ?: 0
                        val isActive = call.argument<Boolean>("isActive") ?: false
                        val isDaily = call.argument<Boolean>("isDaily") ?: true
                        val daysMask = call.argument<Int>("daysMask") ?: 0
                        val sound = call.argument<String>("sound") ?: "alarm.mp3"
                        val locationId = call.argument<Int>("locationId") ?: 0

                        CoroutineScope(Dispatchers.IO).launch {
                            try {

                                val oldAlarm = db.alarmDao().getAlarmById(id)

                                if (oldAlarm != null) {

                                    val updatedAlarm = oldAlarm.copy(
                                        title = title,
                                        hour = hour,
                                        minute = minute,
                                        isActive = isActive,
                                        isDaily = isDaily,
                                        daysMask = daysMask,
                                        sound = sound,
                                        locationId = locationId
                                    )

                                    // DB update
                                    db.alarmDao().update(updatedAlarm)

                                    // 🔥 schedule update (IMPORTANT PART)
                                    val scheduler = AlarmScheduler()

                                    if (updatedAlarm.isActive) {
                                       
                                        scheduler.schedule(context, updatedAlarm)
                                    } else {
                                        
                                        scheduler.cancel(context, updatedAlarm.id)
                                    }

                                    withContext(Dispatchers.Main) {
                                        result.success(true)
                                    }

                                } else {
                                    withContext(Dispatchers.Main) {
                                        result.error("NOT_FOUND", "Alarm not found", null)
                                    }
                                }

                            } catch (e: Exception) {
                                withContext(Dispatchers.Main) {
                                    result.error("DB_ERROR", e.message, null)
                                }
                            }
                        }
                    }
                    "getAlarmById" -> {
                        val id = call.argument<Int>("id") ?: 0

                        CoroutineScope(Dispatchers.IO).launch {
                            try {
                                val alarm = db.alarmDao().getAlarmById(id)

                                withContext(Dispatchers.Main) {
                                    if (alarm != null) {
                                     
                                        val alarmMap = mapOf(
                                            "id" to alarm.id,
                                            "title" to alarm.title,
                                            "hour" to alarm.hour,
                                            "minute" to alarm.minute,
                                            "isActive" to alarm.isActive,
                                            "isDaily" to alarm.isDaily,
                                            "daysMask" to alarm.daysMask,
                                            "sound" to alarm.sound,
                                            "locationId" to alarm.locationId
                                        )
                                        result.success(alarmMap)
                                    } else {
                                        result.success(null)
                                    }
                                }
                            } catch (e: Exception) {
                                withContext(Dispatchers.Main) {
                                    result.error("DB_ERROR", e.message, null)
                                }
                            }
                        }
                    }
                    "deleteAlarm" -> {
                        val id = call.argument<Int>("id") ?: run {
                            result.error("ERROR", "Alarm ID null", null)
                            return@setMethodCallHandler
                        }

                        CoroutineScope(Dispatchers.IO).launch {
                            try {
                                // DAO-র deleteById মেথড সরাসরি কল করা হচ্ছে
                                db.alarmDao().deleteById(id)

                                withContext(Dispatchers.Main) {
                                    result.success(true)
                                }
                            } catch (e: Exception) {
                                withContext(Dispatchers.Main) {
                                    result.error("DB_ERROR", e.message, null)
                                }
                            }
                        }
                    }
                    "getSettings" -> {
                        CoroutineScope(Dispatchers.IO).launch {
                            try {
                                // DAO থেকে সেটিংস আনা
                                val settings = db.settingsDao().getSettings()

                                if (settings != null) {
                                    // ফ্লাটার মডেলের Key গুলোর সাথে মিলিয়ে Map তৈরি
                                    val settingsMap = mapOf(
                                        "id" to settings.id,
                                        "currentLocationId" to settings.currentLocationId,
                                        "currentLocation" to settings.currentLocation,
                                        "enable" to if (settings.enable) 1 else 0 // SQLite এর জন্য বুলিয়ানকে ইন্টিজারে রূপান্তর (যদি প্রয়োজন হয়)
                                    )
                                    withContext(Dispatchers.Main) {
                                        result.success(settingsMap)
                                    }
                                } else {
                                    withContext(Dispatchers.Main) {
                                        result.success(null)
                                    }
                                }
                            } catch (e: Exception) {
                                withContext(Dispatchers.Main) {
                                    result.error("DB_ERROR", e.message, null)
                                }
                            }
                        }
                    }

                    "updateSettings" -> {
                        // ফ্লাটার থেকে আসা আইডি (সাধারণত ১ হবে)
                        val id = call.argument<Int>("id") ?: 1
                        val locationId = call.argument<Int>("currentLocationId") ?: 0
                        val location = call.argument<String>("currentLocation") ?: ""
                        val enableArg = call.argument<Any>("enable")

                        // বুলিয়ান হ্যান্ডেলিং (ফ্লাটার থেকে ১/০ বা true/false দুইটাই আসতে পারে)
                        val isEnabled = when (enableArg) {
                            is Boolean -> enableArg
                            is Int -> enableArg == 1
                            else -> true
                        }

                        CoroutineScope(Dispatchers.IO).launch {
                            try {
                                val settingsEntity = SettingsEntity(
                                    id = id,
                                    currentLocationId = locationId,
                                    currentLocation = location,
                                    enable = isEnabled
                                )

                                // DAO এর insert মেথড ব্যবহার করছি কারণ @Insert(onConflict = REPLACE) দেওয়া আছে
                                db.settingsDao().update(settingsEntity)

                                withContext(Dispatchers.Main) {
                                    result.success(true)
                                }
                            } catch (e: Exception) {
                                withContext(Dispatchers.Main) {
                                    result.error("DB_ERROR", e.message, null)
                                }
                            }
                        }
                    }
                    // =========================
// MOSQUE
// =========================
                    "insertMosques" -> {
                        val mosquesData = call.argument<List<Map<String, Any>>>("mosques") ?: emptyList()

                        CoroutineScope(Dispatchers.IO).launch {
                            try {
                                val entities = mosquesData.map { data ->
                                    MosqueEntity(
                                        // id পাঠানো হলে সেটি ব্যবহার হবে, না হলে 0 (Auto-generate)
                                        id = (data["id"] as? Int) ?: 0,
                                        name = data["name"] as String,
                                        lat = data["lat"] as Double,
                                        lon = data["lon"] as Double
                                    )
                                }
                                db.mosqueDao().insertAll(entities)

                                // 👉 জিওফেন্স আপডেট করা (এটি আগের জিওফেন্স ওভাররাইট করে দেবে)
                                val allLocations = db.locationDao().getAll()
                                val helper = GeofenceHelper(context)
                                helper.registerAllGeofences(allLocations)

                                withContext(Dispatchers.Main) {
                                    result.success(true)
                                }
                            } catch (e: Exception) {
                                withContext(Dispatchers.Main) {
                                    result.error("DB_ERROR", e.message, null)
                                }
                            }
                        }
                    }

                    "getMosques" -> {
                        CoroutineScope(Dispatchers.IO).launch {
                            try {
                                val mosques = db.mosqueDao().getAll()

                                // 🌟 ডাটাবেজ থেকে কতগুলো মসজিদ পাওয়া গেল তা প্রিন্ট করার জন্য

                                val resultList = mosques.map { entity ->

                                    mapOf(
                                        "id" to entity.id,
                                        "name" to entity.name,
                                        "lat" to entity.lat,
                                        "lon" to entity.lon
                                    )
                                }

                                withContext(Dispatchers.Main) {
                                    result.success(resultList)
                                }
                            } catch (e: Exception) {
                                // 🌟 কোনো এরর হলে তা দেখার জন্য
                                android.util.Log.e("MethodChannel", "Error fetching mosques: ${e.message}")
                                withContext(Dispatchers.Main) {
                                    result.error("DB_ERROR", e.message, null)
                                }
                            }
                        }
                    }

                    "deleteMosque" -> {
                        val id = call.argument<Int>("id") ?: 0
                        CoroutineScope(Dispatchers.IO).launch {
                            try {
                                db.mosqueDao().deleteById(id)
                                withContext(Dispatchers.Main) {
                                    result.success(true)
                                }
                            } catch (e: Exception) {
                                withContext(Dispatchers.Main) {
                                    result.error("DB_ERROR", e.message, null)
                                }
                            }
                        }
                    }
                  "isDndPermissionGranted" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            try {
                                val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                                result.success(notificationManager.isNotificationPolicyAccessGranted)
                            } catch (e: Exception) {
                                Log.e("DND", "Error checking DND permission: ${e.message}")
                                result.success(false)
                            }
                        } else {
                            result.success(true) // Android M এর নিচে DND permission লাগে না
                        }
                    }

                    "requestDndPermission" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            try {
                                val intent = Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS).apply {
                                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                }
                                context.startActivity(intent)
                                result.success(true)
                            } catch (e: Exception) {
                                Log.e("DND", "Failed to open DND settings: ${e.message}")
                                result.error("DND_ERROR", "Could not open DND settings", e.message)
                            }
                        } else {
                            result.success(false) // পুরনো ভার্সনে প্রয়োজন নেই
                        }
                    }
                    "saveDefaultAlarmSettings" -> {

                        try {

                            sharedPreferences.edit().apply {

                                putBoolean(AlarmPrefs.VIBRATION, true)
                                putBoolean(AlarmPrefs.GRADUAL, true)
                                putInt(AlarmPrefs.SNOOZE_TIME,3)
                                putInt(AlarmPrefs.SNOOZE, 5)
                                putInt(AlarmPrefs.AUTO_STOP, 10)
                                putBoolean(AlarmPrefs.PRE_ALARM, true)
                                putBoolean(AlarmPrefs.MISSED, true)
                                putBoolean(AlarmPrefs.AUTO_SILENT,true)
                                putBoolean(AlarmPrefs.AUTO_SILENT_SCHEDULE,false)

                                apply()
                            }

                            result.success(true)

                        } catch (e: Exception) {

                            result.error(
                                "SAVE_ERROR",
                                "Failed to save default settings",
                                e.message
                            )
                        }
                    }

                    // ==================== GET SETTINGS ====================
                    "getAlarmSettings" -> {

                        try {

                            val data = hashMapOf<String, Any>(
                                AlarmPrefs.VIBRATION to sharedPreferences.getBoolean(AlarmPrefs.VIBRATION, true),
                                AlarmPrefs.GRADUAL to sharedPreferences.getBoolean(AlarmPrefs.GRADUAL, true),
                                AlarmPrefs.SNOOZE_TIME to sharedPreferences.getInt(AlarmPrefs.SNOOZE_TIME,3),
                                AlarmPrefs.SNOOZE to sharedPreferences.getInt(AlarmPrefs.SNOOZE, 5),
                                AlarmPrefs.AUTO_STOP to sharedPreferences.getInt(AlarmPrefs.AUTO_STOP, 10),
                                AlarmPrefs.PRE_ALARM to sharedPreferences.getBoolean(AlarmPrefs.PRE_ALARM, true),
                                AlarmPrefs.MISSED to sharedPreferences.getBoolean(AlarmPrefs.MISSED, true),
                                AlarmPrefs.AUTO_SILENT to sharedPreferences.getBoolean(AlarmPrefs.AUTO_SILENT,true),
                                AlarmPrefs.AUTO_SILENT_SCHEDULE to sharedPreferences.getBoolean(AlarmPrefs.AUTO_SILENT_SCHEDULE,false)
                            )

                            result.success(data)

                        } catch (e: Exception) {

                            result.error(
                                "GET_ERROR",
                                "Failed to get settings",
                                e.message
                            )
                        }
                    }
                    "updateAlarmSettings" -> {

                        try {

                            val key = call.argument<String>("key")
                            val value = call.argument<Any>("value")

                            if (key == null || value == null) {
                                result.error("INVALID", "Key or value missing", null)
                                return@setMethodCallHandler
                            }

                            val editor = sharedPreferences.edit()

                            when (value) {

                                is Boolean -> editor.putBoolean(key, value)
                                is Int -> editor.putInt(key, value)
                                is String -> editor.putString(key, value)

                                else -> {
                                    result.error("INVALID_TYPE", "Unsupported type", null)
                                    return@setMethodCallHandler
                                }
                            }

                            editor.apply()

                            result.success(true)

                        } catch (e: Exception) {

                            result.error(
                                "UPDATE_ERROR",
                                "Failed to update settings",
                                e.message
                            )
                        }
                    }
                    "startManualSilent" -> {
                        val minutes = call.argument<Int>("minutes") ?: 10
                        ManualSilentHelper.startManualSilent(context, minutes)
                        result.success(true)
                    }
                    "stopManualSilent" -> {
                        ManualSilentHelper.stopManualSilent(context)
                        result.success(true)
                    }
                    "scheduleAllSilentTimes" -> {
                        CoroutineScope(Dispatchers.IO).launch {

                            try {
                                // Database থেকে সরাসরি currentLocationId নেওয়া
                                val settingsDao = db.settingsDao()
                                
                                val settings = settingsDao.getSettings()
                                val locationId = settings?.currentLocationId ?: 1  // ডিফল্ট 1

                                SilentScheduler.scheduleAllSilentTimes(context, db.alarmDao(), locationId)
                                
                                withContext(Dispatchers.Main) {
                                    result.success(true)
                                }
                            } catch (e: Exception) {
                                withContext(Dispatchers.Main) {
                                    result.error("DB_ERROR", e.message, null)
                                }
                            }
                        }
                }

                    "cancelAllSilentTimes" -> {
                        CoroutineScope(Dispatchers.IO).launch {

                        try {
                            
                            val settingsDao = db.settingsDao()
                            
                            val settings = settingsDao.getSettings()
                            val locationId = settings?.currentLocationId ?: 1   // ডিফল্ট ১

                            SilentScheduler.cancelAllSilentAlarms(context, db.alarmDao(), locationId)
                            
                        withContext(Dispatchers.Main) {
                                    result.success(true)
                                }
                            } catch (e: Exception) {
                                withContext(Dispatchers.Main) {
                                    result.error("DB_ERROR", e.message, null)
                                }
                            }
                        }
                    }
                  "isExactAlarmGranted" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        try {
                            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
                            result.success(alarmManager.canScheduleExactAlarms())
                        } catch (e: Exception) {
                            Log.e("ExactAlarm", "Error checking exact alarm permission: ${e.message}")
                            result.success(false)
                        }
                    } else {
                        result.success(true)
                    }
                }
                  "openExactAlarmSettings" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        try {
                            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
                            if (alarmManager.canScheduleExactAlarms()) {
                                result.success(true)
                                return@setMethodCallHandler
                            }

                            val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                                data = Uri.parse("package:${context.packageName}")
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            }
                            context.startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("INTENT_ERROR", e.message, null)
                        }
                    } else {
                        // অ্যান্ড্রয়েড ১২ এর নিচের ভার্সন হলে এই পারমিশন লাগে না, তাই সরাসরি true রিটার্ন করবে
                        result.success(true) 
                    }
                }

                    else -> result.notImplemented()
                }
            }
    }
}
