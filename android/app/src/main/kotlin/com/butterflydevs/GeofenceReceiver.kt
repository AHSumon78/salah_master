package com.butterflydevs.salahmaster

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.os.Build
import android.app.NotificationManager
import android.util.Log

import com.google.android.gms.location.GeofencingEvent
import com.google.android.gms.location.Geofence

class GeofenceReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {

        Log.d("GEOFENCE", "Receiver Triggered 🚀")

        val geofencingEvent = GeofencingEvent.fromIntent(intent)

        if (geofencingEvent == null) {
            Log.d("GEOFENCE", "Event is NULL ❌")
            return
        }

        if (geofencingEvent.hasError()) {
            Log.d("GEOFENCE", "Geofence Error ❌")
            return
        }

        val transition = geofencingEvent.geofenceTransition

        Log.d("GEOFENCE", "Transition Type: $transition")

        when (transition) {

            Geofence.GEOFENCE_TRANSITION_ENTER -> {
                Log.d("GEOFENCE", "ENTER → Silent ON 🔕")
                setSilent(context, true)
            }

            Geofence.GEOFENCE_TRANSITION_EXIT -> {
                Log.d("GEOFENCE", "EXIT → Silent OFF 🔊")
                setSilent(context, false)
            }

            else -> {
                Log.d("GEOFENCE", "Unknown Transition ❓")
            }
        }
    }

    private fun setSilent(context: Context, silent: Boolean) {

        val audioManager =
            context.getSystemService(Context.AUDIO_SERVICE) as AudioManager

        val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {

            if (!notificationManager.isNotificationPolicyAccessGranted) {
                Log.d("GEOFENCE", "DND Permission NOT granted ❌")
                return
            }

            if (silent) {
                Log.d("GEOFENCE", "Activating DND 🔕")

                // 🔕 DND ON
                notificationManager.setInterruptionFilter(
                    NotificationManager.INTERRUPTION_FILTER_NONE
                )

                // 🔕 Extra safety (ringer silent)
                audioManager.ringerMode = AudioManager.RINGER_MODE_SILENT

            } else {
                Log.d("GEOFENCE", "Disabling DND 🔊")

                // 🔊 DND OFF
                notificationManager.setInterruptionFilter(
                    NotificationManager.INTERRUPTION_FILTER_ALL
                )

                // 🔊 Normal sound
                audioManager.ringerMode = AudioManager.RINGER_MODE_NORMAL
            }
        }
    }
}