package com.butterflydevs.salahmaster 
import android.content.Context
import android.content.res.Configuration
import java.util.Locale

object LocaleHelper {

    fun updateNativeLocale(context: Context, langCode: String) {
        val locale = Locale(langCode)
        Locale.setDefault(locale)

        val config = Configuration(context.resources.configuration)
        config.setLocale(locale)

        // ১. কারেন্ট কনটেক্সটের (Activity) রিসোর্স আপডেট
        context.resources.updateConfiguration(config, context.resources.displayMetrics)
        
        // ২. অ্যাপ্লিকেশন কনটেক্সটের রিসোর্স আপডেট (ব্যাকগ্রাউন্ড সার্ভিস/অ্যালার্মের জন্য অতি প্রয়োজনীয়)
        context.applicationContext.resources.updateConfiguration(config, context.applicationContext.resources.displayMetrics)
    }
}