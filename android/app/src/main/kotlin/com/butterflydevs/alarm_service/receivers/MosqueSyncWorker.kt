package com.butterflydevs.salahmaster.alarm_service

import android.annotation.SuppressLint
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.location.Location
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.google.android.gms.location.LocationServices
import java.net.HttpURLConnection
import java.net.URL
import java.net.URLEncoder
import kotlin.coroutines.resume
import kotlinx.coroutines.suspendCancellableCoroutine
import org.json.JSONObject

// 🔥 আপনার প্রজেক্টের ডাটাবেজ, মডেল এবং হেল্পার পাথ (প্রয়োজনে আপনার প্যাকেজ নাম অনুযায়ী চেঞ্জ করে নেবেন)
import com.butterflydevs.salahmaster.R
import com.butterflydevs.salahmaster.database.AppDatabase
import com.butterflydevs.salahmaster.data.MosqueEntity
// GeofenceHelper যদি অন্য ফোল্ডারে থাকে তবে তার সঠিক পাথ দিন, যেমন: com.butterflydevs.salahmaster.helpers.GeofenceHelper
import com.butterflydevs.salahmaster.alarm_service.GeofenceHelper 

class MosqueSyncWorker(appContext: Context, workerParams: WorkerParameters) :
    CoroutineWorker(appContext, workerParams) {

    private val db = AppDatabase.getInstance(appContext)
    private val sharedPreferences = appContext.getSharedPreferences("LocationPrefs", Context.MODE_PRIVATE)

    override suspend fun doWork(): Result {
        Log.d("MosqueSyncWorker", "Worker started...")

        try {
            val userLocation = getCurrentGPSLocation() ?: return Result.retry() // লোকেশন না পেলে আবার ট্রাই করবে

            val presentLat = userLocation.latitude
            val presentLon = userLocation.longitude

            // SharedPreferences থেকে পুরোনো লোকেশন আনা
            val oldLat = sharedPreferences.getFloat("old_lat", -1000f).toDouble()
            val oldLon = sharedPreferences.getFloat("old_lon", -1000f).toDouble()

            val isFirstTime = oldLat == -1000.0 || oldLon == -1000.0
            var shouldFetch = false

            if (isFirstTime) {
                shouldFetch = true
            } else {
                val oldLocation = Location("").apply { latitude = oldLat; longitude = oldLon }
                val presentLocation = Location("").apply { latitude = presentLat; longitude = presentLon }
                val distance = oldLocation.distanceTo(presentLocation)

                if (distance > 5000f) { // ৫ কিমি এর বেশি হলে
                    shouldFetch = true
                }
            }

            if (shouldFetch) {
                if (!isFirstTime) {
                        // আপনার পুরোনো ডিলিট লজিক (Keep as it is)
                        val allMosques = db.mosqueDao().getAll()
                        val mosqueIdsToDelete = allMosques.filter { !it.name.startsWith("$") }.map { it.id }
                        
                        allMosques.filter { !it.name.startsWith("$") }.forEach { db.mosqueDao().delete(it) }

                        if (mosqueIdsToDelete.isNotEmpty()) {
                            GeofenceHelper(applicationContext).removeMosqueGeofences(mosqueIdsToDelete)
                        }
                    }
                val isSuccess = fetchAndSaveMosques(presentLat, presentLon)

                if (isSuccess) {
                    showSyncNotification("New mosques are synced for new areas")
                    
                    // লোকেশন আপডেট সেভ
                    sharedPreferences.edit().apply {
                        putFloat("old_lat", presentLat.toFloat())
                        putFloat("old_lon", presentLon.toFloat())
                        apply()
                    }

                    
                } else {
                    // ইন্টারনেট না থাকলে বা ফেইল করলে WorkManager কে বলব পরে আবার ট্রাই করতে
                    return Result.retry()
                }
            }

            // Geofence রেজিস্ট্রেশন
            val locations = db.locationDao().getAll()
            GeofenceHelper(applicationContext).registerAllGeofences(locations)

            return Result.success()

        } catch (e: Exception) {
            Log.e("MosqueSyncWorker", "Error: ${e.message}")
            return Result.failure()
        }
    }

    // আপনার বিদ্যমান getCurrentGPSLocation এবং fetchAndSaveMosques মেথডগুলো 
    // হুবহু এখানে পেস্ট করে দিন (Reuse)
    @SuppressLint("MissingPermission")
    private suspend fun getCurrentGPSLocation(): Location? = suspendCancellableCoroutine { cont ->
        val fusedLocationClient = LocationServices.getFusedLocationProviderClient(applicationContext)
        fusedLocationClient.lastLocation
            .addOnSuccessListener { location: Location? ->
                cont.resume(location)
            }
            .addOnFailureListener {
                cont.resume(null)
            }
    }

    private suspend fun fetchAndSaveMosques(lat: Double, lon: Double): Boolean {
        return try {

            val query = """
        [out:json][timeout:25];
        (
          node(around:4500, $lat, $lon)["amenity"="place_of_worship"]["religion"="muslim"];
          way(around:4500, $lat, $lon)["amenity"="place_of_worship"]["religion"="muslim"];
        );
        out center;
    """.trimIndent()

            val url = URL("https://overpass-api.de/api/interpreter")
            val connection = url.openConnection() as HttpURLConnection

            connection.requestMethod = "POST"
            connection.setRequestProperty("User-Agent", "Flutter_Mosque_App/1.0")
            connection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded")

            connection.connectTimeout = 15000
            connection.readTimeout = 15000

            connection.doOutput = true

            // 🔥 send raw query safely
            val body = "data=" + URLEncoder.encode(query, "UTF-8")

            connection.outputStream.use { os ->
                os.write(body.toByteArray())
                os.flush()
            }

            val responseCode = connection.responseCode

            if (responseCode == 200) {

                val response = connection.inputStream.bufferedReader().readText()
                val json = JSONObject(response)
                val elements = json.getJSONArray("elements")

                val mosquesList = mutableListOf<MosqueEntity>()

                for (i in 0 until elements.length()) {
                    val element = elements.getJSONObject(i)
                    val tags = element.optJSONObject("tags")
                    val name = tags?.optString("name") ?: "Unnamed Mosque"

                    val latCoord = element.optDouble("lat", 0.0).takeIf { it != 0.0 }
                        ?: element.optJSONObject("center")?.optDouble("lat") ?: 0.0

                    val lonCoord = element.optDouble("lon", 0.0).takeIf { it != 0.0 }
                        ?: element.optJSONObject("center")?.optDouble("lon") ?: 0.0

                    android.util.Log.d("FetchMosque", "Fetched Mosque -> Name: $name | Lat: $latCoord | Lon: $lonCoord")

                    // 🌟 আইডি 0 রেখে অবজেক্ট তৈরি করা হলো, যাতে Room নিজেই ইউনিক আইডি তৈরি করে
                    mosquesList.add(
                        MosqueEntity(

                            name = name as String,
                            lat = latCoord as Double,
                            lon = lonCoord as Double
                        )
                    )
                }

                if (mosquesList.isNotEmpty()) {
                    try {
                        // 🌟 ডাটাবেজে সেভ করা হচ্ছে
                        val insertedIds = db.mosqueDao().insertAll(mosquesList)

                         if (mosquesList.size < 5) {
                            Log.e(
                                "FetchMosque",
                                "❌ Less than 5 mosques found. Count = ${mosquesList.size}"
                            )
                            false
                        }
                        else{
                            true
                        }
                    } catch (e: Exception) {
                        // 🌟 যদি ডাটাবেজে ইনসার্ট করার সময় কোনো সমস্যা হয় তবে লগ দেখাবে
                        android.util.Log.e("FetchMosque", "Error saving mosques: ${e.message}")
                        e.printStackTrace()
                        false
                    }
                } else {
                    false
                }

            } else {
                false
            }

        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    private fun showSyncNotification(message: String) {
    // getSystemService এর আগে applicationContext দিন
    val notificationManager = applicationContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    val channelId = "mosque_sync_channel"

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        val channel = NotificationChannel(channelId, "Mosque Sync Alert", NotificationManager.IMPORTANCE_MIN)
        notificationManager.createNotificationChannel(channel)
    }

    // Builder এর ভেতরে applicationContext দিন
    val notification = NotificationCompat.Builder(applicationContext, channelId)
        .setContentTitle("New Area")
        .setContentText(message)
        .setSmallIcon(R.mipmap.ic_launcher)
        .setPriority(NotificationCompat.PRIORITY_MIN)
        .build()

    notificationManager.notify(4, notification)
}

    private fun createServiceNotification(): Notification {
        val channelId = "service_channel"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(channelId, "Service", NotificationManager.IMPORTANCE_LOW)
           applicationContext.getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        }
        return NotificationCompat.Builder(applicationContext, channelId)
            .setContentTitle("Syncing Mosques...")
            .setSmallIcon(R.mipmap.ic_launcher)
            .build()
    }

   
}