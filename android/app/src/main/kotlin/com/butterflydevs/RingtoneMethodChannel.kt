package com.butterflydevs.salahmaster

import android.app.Activity
import android.content.Intent
import android.media.RingtoneManager
import android.net.Uri
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.butterflydevs.salahmaster.alarm_service.SoundHelper

class RingtoneMethodChannel(private val activity: Activity) {

    private val CHANNEL_RINGTONE = "com.butterflydevs.salahmaster/ringtone"
    private val CHANNEL_SOUND = "com.butterflydevs.salahmaster/sound"

    private var ringtoneResult: MethodChannel.Result? = null
    private val REQUEST_CODE_RINGTONE = 1111

    fun register(flutterEngine: FlutterEngine) {

        // ১. রিংটোন মেথড চ্যানেল
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_RINGTONE).setMethodCallHandler { call, result ->
            if (call.method == "openSystemRingtonePicker") {
                ringtoneResult = result
                val intent = Intent(RingtoneManager.ACTION_RINGTONE_PICKER).apply {
                     putExtra(RingtoneManager.EXTRA_RINGTONE_TYPE, RingtoneManager.TYPE_ALARM)
                     putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_DEFAULT, true)
                    putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_SILENT, false)
                }
                activity.startActivityForResult(intent, REQUEST_CODE_RINGTONE)
            } else {
                result.notImplemented()
            }
        }

        // ২. সাউন্ড কন্ট্রোল মেথড চ্যানেল (আপনি যেটি যোগ করতে বলেছিলেন)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_SOUND).setMethodCallHandler { call, result ->
            when (call.method) {
                "playSound" -> {
                    val soundName = call.argument<String>("soundName")
                    // এখানে SoundHelper কল করা হলো
                    SoundHelper.playAlarmSound(context=activity,soundName=soundName)
                    result.success(null)
                }
                "stopSound" -> {
                    SoundHelper.stopSound()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == REQUEST_CODE_RINGTONE) {
            if (resultCode == Activity.RESULT_OK) {
                val uri = data?.getParcelableExtra<Uri>(RingtoneManager.EXTRA_RINGTONE_PICKED_URI)
                ringtoneResult?.success(uri?.toString())
            } else {
                ringtoneResult?.success(null)
            }
        }
    }
}