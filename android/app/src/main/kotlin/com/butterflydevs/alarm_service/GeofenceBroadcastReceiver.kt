package com.butterflydevs.salahmaster.alarm_service

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.location.Location
import android.media.AudioManager
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import com.butterflydevs.salahmaster.R
import com.butterflydevs.salahmaster.data.SettingsEntity
import com.butterflydevs.salahmaster.database.AppDatabase
import com.google.android.gms.location.Geofence
import com.google.android.gms.location.GeofencingEvent
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import android.provider.Settings
import android.content.ComponentName

class GeofenceBroadcastReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val event = GeofencingEvent.fromIntent(intent) ?: return
        if (event.hasError()) return

        val transitionType = event.geofenceTransition
        val triggeredGeofences = event.triggeringGeofences ?: return

        triggeredGeofences.forEach { geofence ->
            val requestId = geofence.requestId

            // ১. Location Trigger (শুধুমাত্র ENTER-এর জন্য)
            if (requestId.startsWith("loc_") && transitionType == Geofence.GEOFENCE_TRANSITION_ENTER) {
                val newLocationId = requestId.substringAfter("loc_").toInt()
                handleLocationSwitch(context, newLocationId)

                // Location-এ ঢুকলে Normal Mode করা
                setRingerMode(context, isSilent = false)
            }
            // ২. Mosque Trigger (ENTER এবং EXIT উভয়ের জন্য)
            else if (requestId.startsWith("mosque_")) {
                if (transitionType == Geofence.GEOFENCE_TRANSITION_ENTER) {
                    // মসজিদে প্রবেশ করলে Silent Mode করা
                    setRingerMode(context, isSilent = true)
                }
                else if (transitionType == Geofence.GEOFENCE_TRANSITION_EXIT) {
                    // মসজিদ থেকে বের হলে Normal Mode করা
                    setRingerMode(context, isSilent = false)
                }
            }
        }
    }

    private fun setRingerMode(context: Context, isSilent: Boolean) {
        val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val prefs = context.getSharedPreferences("GeofencePrefs", Context.MODE_PRIVATE)

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                if (!notificationManager.isNotificationPolicyAccessGranted) return
            }

            if (isSilent) {
                // ১. সাইলেন্ট করার আগে বর্তমান স্টেট সেভ করা
                prefs.edit().apply {
                    putInt("saved_ringer_mode", audioManager.ringerMode)
                    putInt("saved_ring_vol", audioManager.getStreamVolume(AudioManager.STREAM_RING))
                    putInt("saved_music_vol", audioManager.getStreamVolume(AudioManager.STREAM_MUSIC))
                    putInt("saved_notif_vol", audioManager.getStreamVolume(AudioManager.STREAM_NOTIFICATION))
                }.apply()

                // ২. সাইলেন্ট মোডে নেওয়া
                audioManager.ringerMode = AudioManager.RINGER_MODE_SILENT
                audioManager.setStreamVolume(AudioManager.STREAM_RING, 0, 0)
                audioManager.setStreamVolume(AudioManager.STREAM_NOTIFICATION, 0, 0)
                audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, 0, 0) // মিডিয়া মিউট
                
                Log.d("RingerMode", "Saved states and set Silent")

            } else {
                // ৩. সেভ করা স্টেট রিস্টোর করা
                val savedRingerMode = prefs.getInt("saved_ringer_mode", AudioManager.RINGER_MODE_NORMAL)
                val savedRingVol = prefs.getInt("saved_ring_vol", audioManager.getStreamMaxVolume(AudioManager.STREAM_RING) / 2)
                val savedMusicVol = prefs.getInt("saved_music_vol", audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC) / 2)
                val savedNotifVol = prefs.getInt("saved_notif_vol", audioManager.getStreamMaxVolume(AudioManager.STREAM_NOTIFICATION) / 2)

                audioManager.ringerMode = savedRingerMode
                audioManager.setStreamVolume(AudioManager.STREAM_RING, savedRingVol, 0)
                audioManager.setStreamVolume(AudioManager.STREAM_NOTIFICATION, savedNotifVol, 0)
                audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, savedMusicVol, 0)

                Log.d("RingerMode", "Restored previous volumes")
            }
        } catch (e: Exception) {
            Log.e("RingerMode", "Error: ${e.message}")
        }
    }

    private fun handleLocationSwitch(context: Context, newLocationId: Int) {
        CoroutineScope(Dispatchers.IO).launch {
            val db = AppDatabase.getInstance(context)
            val scheduler = AlarmScheduler()

            val settings = db.settingsDao().getSettings()
            val oldLocationId = settings?.currentLocationId

            if (oldLocationId != newLocationId) {
                if (oldLocationId != null) {
                    scheduler.cancelAllByLocation(context, oldLocationId)
                }

                val newLoc = db.locationDao().getById(newLocationId) ?: return@launch

                val updatedSettings = SettingsEntity(
                    id = 1,
                    currentLocation = newLoc.name,
                    currentLocationId = newLoc.id,
                    enable = true
                )
                db.settingsDao().update(updatedSettings)

                scheduler.scheduleAllByLocation(context, newLocationId)
                showLocationChangeAlert(context, newLoc.name)
            }
        }
    }

    private fun showLocationChangeAlert(context: Context, locationName: String) {
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channelId = "location_change_channel"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(channelId, "Alerts", NotificationManager.IMPORTANCE_LOW)
            notificationManager.createNotificationChannel(channel)
        }

        val notification = NotificationCompat.Builder(context, channelId)
            .setContentTitle("Location Changed")
            .setContentText("You are at $locationName now.")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setAutoCancel(true)
            .build()

        notificationManager.notify(2, notification)
    }
}