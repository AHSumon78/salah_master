package com.butterflydevs.salahmaster // ⚠️ আপনার নিজস্ব প্যাকেজ নাম দিবেন

import android.app.Activity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class LanguageMethodChannel(private val activity: Activity) {

    private val CHANNEL_LANGUAGE = "com.butterflydevs.salahmaster/language"

    fun register(flutterEngine: FlutterEngine) {
        
        // ল্যাঙ্গুয়েজ শিফট মেথড চ্যানেল
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_LANGUAGE).setMethodCallHandler { call, result ->
            if (call.method == "changeLanguage") {
                val arguments = call.arguments as? Map<*, *>
                val languageCode = arguments?.get("code") as? String

                if (languageCode != null) {
                    // পূর্বে তৈরি করা LocaleHelper ক্লাসটি কল করে নেটিভ Locale আপডেট করা হলো
                    LocaleHelper.updateNativeLocale(activity, languageCode)
                    result.success(true)
                } else {
                    result.error("INVALID_ARGUMENT", "Language code is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}