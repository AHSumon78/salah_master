package com.butterflydevs.salahmaster.alarm_service

import android.content.Context
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.util.Log
import android.content.Intent

object SoundHelper {

    private var mediaPlayer: MediaPlayer? = null
    private var vibrator: Vibrator? = null

    private val handler = Handler(Looper.getMainLooper())

    private var volumeRunnable: Runnable? = null
    private var stopRunnable: Runnable? = null

    /**
     * @param soundName অ্যালার্মের সাউন্ড ফাইলের নাম বা URI
     */
    fun playAlarmSound(
        context: Context,
        soundName: String? = null,
        enableVibration: Boolean = false,
        gradualVolumeIncrease: Boolean = false,
        autoStopMinutes: Int = 10,
        onAutoStop: (() -> Unit)? = null
    ) {

        if (mediaPlayer?.isPlaying == true) return

        try {

            // ==================== SHARED PREFERENCES SETTINGS ====================
            val prefs = context.getSharedPreferences("AppPrefs", Context.MODE_PRIVATE)

            val vibrationEnabled = prefs.getBoolean("vibration", enableVibration)
            val gradualEnabled = prefs.getBoolean("gradual_volume_increase", gradualVolumeIncrease)
            val autoStop = prefs.getInt("auto_stop_alarm", autoStopMinutes)

            val maxVolume = 1f
            var currentVolume = 0.1f       // start at 0
            val step = 0.05f// smaller step = smoother
            val delay = 300L  

            // ==================== VIBRATION ====================
            if (vibrationEnabled) {
                startVibration(context)
            }

            // ==================== SOUND URI ====================
            val uri: Uri = if (!soundName.isNullOrEmpty()) {

                if (soundName.startsWith("content://")) {
                    Uri.parse(soundName)
                } else {

                    val resId = context.resources.getIdentifier(
                        soundName,
                        "raw",
                        context.packageName
                    )

                    if (resId != 0) {
                        Uri.parse("android.resource://${context.packageName}/$resId")
                    } else {
                        RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                    }
                }

            } else {
                RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            }

            // ==================== MEDIA PLAYER ====================
            mediaPlayer = MediaPlayer().apply {

                setDataSource(context, uri)

                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build()
                )

                isLooping = true
                prepare()

                // ==================== GRADUAL VOLUME ====================
                if (gradualEnabled) {

                    setVolume(currentVolume, currentVolume)

                    volumeRunnable = object : Runnable {
                        override fun run() {

                            currentVolume += step

                            if (currentVolume >maxVolume) {
                                currentVolume = maxVolume
                            }

                            try {
                                mediaPlayer?.setVolume(currentVolume, currentVolume)
                            } catch (_: Exception) {}

                            if (currentVolume < maxVolume) {
                                handler.postDelayed(this, delay)
                            }
                        }
                    }

                    handler.post(volumeRunnable!!)

                } else {
                    setVolume(1f, 1f)
                }

                start()
            }

            // ==================== AUTO STOP ====================
            stopRunnable = Runnable {
                  val intent = Intent("AUTO_STOP_ALARM")
                context.sendBroadcast(intent)
                stopSound()
               
                onAutoStop?.invoke() 
            }

            handler.postDelayed(
                stopRunnable!!,
                autoStop * 60 * 1000L
            )

        } catch (e: Exception) {
            Log.e("SoundHelper", "MediaPlayer Error: ${e.message}")
        }
    }

    // ==================== VIBRATION ====================
    private fun startVibration(context: Context) {

        vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {

            val vm = context.getSystemService(
                Context.VIBRATOR_MANAGER_SERVICE
            ) as VibratorManager

            vm.defaultVibrator

        } else {
            context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }

        val pattern = longArrayOf(
            0, 400, 200, 600, 250, 400, 180, 700, 300, 450
        )

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator?.vibrate(VibrationEffect.createWaveform(pattern, 0))
        } else {
            vibrator?.vibrate(pattern, 0)
        }
    }

    // ==================== STOP ====================
    fun stopSound() {

        volumeRunnable?.let { handler.removeCallbacks(it) }
        stopRunnable?.let { handler.removeCallbacks(it) }

        try {

            mediaPlayer?.let {
                if (it.isPlaying) it.stop()
                it.release()
            }

        } catch (e: Exception) {
            Log.e("SoundHelper", "Stop Error: ${e.message}")
        }

        mediaPlayer = null
        vibrator?.cancel()
        vibrator = null
    }
}