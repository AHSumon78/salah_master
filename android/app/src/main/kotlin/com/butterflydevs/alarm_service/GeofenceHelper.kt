package com.butterflydevs.salahmaster.alarm_service

import android.annotation.SuppressLint
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.location.Location
import com.butterflydevs.salahmaster.data.LocationEntity
import com.butterflydevs.salahmaster.data.MosqueEntity
import com.butterflydevs.salahmaster.database.AppDatabase
import com.google.android.gms.location.Geofence
import com.google.android.gms.location.GeofencingRequest
import com.google.android.gms.location.LocationServices
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import android.content.SharedPreferences
import com.butterflydevs.salahmaster.data.AlarmPrefs



class GeofenceHelper(val context: Context) {
    private val geofencingClient = LocationServices.getGeofencingClient(context)

    // ১. ফাংশনটিকে suspend করা হয়েছে
    @SuppressLint("MissingPermission")
    suspend fun registerAllGeofences(locations: List<LocationEntity>) {
        val prefs = context.getSharedPreferences("AppPrefs", Context.MODE_PRIVATE)
        val isAutoSilentEnabled = prefs.getBoolean(AlarmPrefs.AUTO_SILENT, true)
        if (locations.isEmpty()) return

        // ২. ডাটাবেজ থেকে সমস্ত মসজিদ আনা (নন-ব্লকিং)
        val allMosques = withContext(Dispatchers.IO) {
            try {
                AppDatabase.getInstance(context).mosqueDao().getAll()
            } catch (e: Exception) {
                emptyList<MosqueEntity>()
            }
        }

        // ৩. সেটিংস থেকে ইউজারের বর্তমান লোকেশন বের করা (নন-ব্লকিং)
        val (currentLat, currentLon) = withContext(Dispatchers.IO) {
            try {
                val db = AppDatabase.getInstance(context)
                val settings = db.settingsDao().getSettings()
                if (settings != null) {
                    val currentLoc = db.locationDao().getById(settings.currentLocationId)
                    Pair(currentLoc?.latitude ?: 23.8103, currentLoc?.longitude ?: 90.4125)
                } else {
                    Pair(23.8103, 90.4125)
                }
            } catch (e: Exception) {
                Pair(23.8103, 90.4125)
            }
        }

        val geofenceList = mutableListOf<Geofence>()

        // ৪. Location Entity এর জন্য Geofence (১০০% অগ্রাধিকার)
        locations.forEach { loc ->
            geofenceList.add(
                Geofence.Builder()
                    .setRequestId("loc_${loc.id}")
                    .setCircularRegion(loc.latitude, loc.longitude, loc.diameter.toFloat())
                    .setExpirationDuration(Geofence.NEVER_EXPIRE)
                    .setTransitionTypes(Geofence.GEOFENCE_TRANSITION_ENTER)
                    .setNotificationResponsiveness(5000)
                    .build()
            )
        }

        // ৫. মসজিদগুলোর জন্য স্লট হিসাব করা
        val maxGeofences = 100
        val availableMosqueSlots = maxGeofences - locations.size

        if (availableMosqueSlots > 0 && allMosques.isNotEmpty()) {
            val userLocation = Location("").apply {
                latitude = currentLat
                longitude = currentLon
            }

            // মসজিদগুলোকে দূরত্বের ভিত্তিতে সাজানো
            val sortedMosques = withContext(Dispatchers.Default) {
                allMosques.map { mosque: MosqueEntity ->
                    val mosqueLoc = Location("").apply {
                        latitude = mosque.lat
                        longitude = mosque.lon
                    }
                    val distance = userLocation.distanceTo(mosqueLoc)
                    Pair(mosque, distance)
                }.sortedBy { it.second }
                    .map { it.first }
            }
            


            if (isAutoSilentEnabled) {
            val selectedMosques: List<MosqueEntity> = sortedMosques.take(availableMosqueSlots)

            // নির্বাচিত মসজিদগুলো জিওফেন্স লিস্টে যুক্ত করা
            selectedMosques.forEach { mosque ->
                geofenceList.add(
                    Geofence.Builder()
                        .setRequestId("mosque_${mosque.id}")
                        .setCircularRegion(mosque.lat, mosque.lon, 40f)
                        .setExpirationDuration(Geofence.NEVER_EXPIRE)
                        .setTransitionTypes(
                            Geofence.GEOFENCE_TRANSITION_ENTER or
                                    Geofence.GEOFENCE_TRANSITION_EXIT
                        )
                        .setNotificationResponsiveness(5000)
                        .build()
                )
            }
        }
    }

        if (geofenceList.isEmpty()) return

        val request = GeofencingRequest.Builder()
            .setInitialTrigger(GeofencingRequest.INITIAL_TRIGGER_ENTER)
            .addGeofences(geofenceList)
            .build()

        // ৬. আগের জিওফেন্সগুলো ক্লিয়ার করে নতুনগুলো যুক্ত করা
        withContext(Dispatchers.Main) {
            geofencingClient.removeGeofences(geofencePendingIntent)
                .addOnSuccessListener {
                    geofencingClient.addGeofences(request, geofencePendingIntent)
                }
        }
    }

    private val geofencePendingIntent: PendingIntent by lazy {
        val intent = Intent(context, GeofenceBroadcastReceiver::class.java)
        PendingIntent.getBroadcast(
            context, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
        )
    }
    suspend fun removeMosqueGeofences(mosqueIds: List<Int>) {
        if (mosqueIds.isEmpty()) return

        // মসজিদগুলোর requestId তৈরি করা, যেমন: "mosque_1", "mosque_2"
        val requestIds = mosqueIds.map { "mosque_$it" }

        return suspendCancellableCoroutine { continuation ->
            geofencingClient.removeGeofences(requestIds)
                .addOnSuccessListener {
                    continuation.resume(Unit)
                }
                .addOnFailureListener { e ->
                    continuation.resumeWithException(e)
                }
        }
    }
}