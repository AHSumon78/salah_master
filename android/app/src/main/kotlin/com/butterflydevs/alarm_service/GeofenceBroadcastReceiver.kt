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

        try {
            // ১. DND পারমিশন চেক (Android 6.0+)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                if (!notificationManager.isNotificationPolicyAccessGranted) {
                    val intent = Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    context.startActivity(intent)
                    return
                }
            }

            if (isSilent) {
                // ২. রিংগার মোড পরিবর্তন (Layer 1)
                // সরাসরি সাইলেন্ট ট্রাই করবে, সিকিউরিটি এরর খেলে ভাইব্রেট মোড ট্রাই করবে
                try {
                    audioManager.ringerMode = AudioManager.RINGER_MODE_SILENT
                } catch (e: Exception) {
                    audioManager.ringerMode = AudioManager.RINGER_MODE_VIBRATE
                }

                // ৩. ভলিউম মিউট করা (Layer 2) - এটিই আসল কাজ করবে যদি উপরেরটি ফেইল করে
                // STREAM_RING সেট করলে অনেক ফোনে নোটিফিকেশনও অটোমেটিক জিরো হয়
                audioManager.setStreamVolume(AudioManager.STREAM_RING, 0, 0)
                audioManager.setStreamVolume(AudioManager.STREAM_NOTIFICATION, 0, 0)
                audioManager.setStreamVolume(AudioManager.STREAM_SYSTEM, 0, 0)

                // ৪. আধুনিক অ্যান্ড্রয়েডে মিউট করা (Layer 3) - Android 7.0+
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    audioManager.adjustStreamVolume(AudioManager.STREAM_RING, AudioManager.ADJUST_MUTE, 0)
                    audioManager.adjustStreamVolume(AudioManager.STREAM_NOTIFICATION, AudioManager.ADJUST_MUTE, 0)
                }

                Log.d("RingerMode", "Silent enabled using Triple Layer protection")

            } else {
                // ৫. নরমাল মোডে ফেরানো
                audioManager.ringerMode = AudioManager.RINGER_MODE_NORMAL

                // মিউট তুলে দেওয়া
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    audioManager.adjustStreamVolume(AudioManager.STREAM_RING, AudioManager.ADJUST_UNMUTE, 0)
                    audioManager.adjustStreamVolume(AudioManager.STREAM_NOTIFICATION, AudioManager.ADJUST_UNMUTE, 0)
                }

                // ভলিউম আগের অবস্থায় (৫০%) ফিরিয়ে আনা
                val maxRing = audioManager.getStreamMaxVolume(AudioManager.STREAM_RING)
                val seventyFivePercent = (maxRing * 0.75).toInt()
                audioManager.setStreamVolume(AudioManager.STREAM_RING, seventyFivePercent, 0)

                Log.d("RingerMode", "Normal mode restored")
            }
        } catch (e: Exception) {
            Log.e("RingerMode", "Critical Error: ${e.message}")
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