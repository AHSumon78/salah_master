package com.butterflydevs.salahmaster

import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import com.batoulapps.adhan.PrayerTimes
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.util.*
import java.util.concurrent.TimeUnit
import com.butterflydevs.salahmaster.alarm_service.NativeAlarmReceiver

class PrayerTimeHijriEventMethodChannel(binaryMessenger: BinaryMessenger, private val context: Context) {
    private val CHANNEL = "com.butterflydevs.salahmaster/prayer_event"
    private var methodChannel: MethodChannel = MethodChannel(binaryMessenger, CHANNEL)
    private val handler = Handler(Looper.getMainLooper())
    private var runnable: Runnable? = null

    // ইভেন্ট এবং নামাজের হেল্পার ক্লাস অবজেক্ট
    private val eventHelper = IslamicEventHelper(context)
    private var prayerTimeHelper: PrayerTimeHelper? = null

    init {
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startPrayerTimer" -> {
                    val lat = call.argument<Double>("lat") ?: 24.3745
                    val lng = call.argument<Double>("lng") ?: 88.6042
                    
                    prayerTimeHelper = PrayerTimeHelper(lat, lng, context)
                    
                    startKotlinPrayerTimer()
                    val intent = Intent(context, NativeAlarmReceiver::class.java).apply {
                        action = "com.butterflydevs.salahmaster.UPDATE_WIDGET"
                    }
                    context.sendBroadcast(intent)
                    result.success(null)
                }
                "stopPrayerTimer" -> {
                    stopKotlinPrayerTimer()
                    result.success(null)
                }
                "getHijriDateRaw" -> {
                    CoroutineScope(Dispatchers.Main).launch {
                        try {
                            val hijriMap = withContext(Dispatchers.IO) {
                                val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                                val isBn = prefs.getBoolean("flutter.isBn", true)
                                val localeCode = prefs.getString("flutter.localeCode", "bn") ?: "bn"
                                val isNight = prefs.getBoolean("flutter.isNight", false)

                                HijriRepository.getFormattedHijriData(context, isBn, localeCode, isNight)
                            }

                            if (hijriMap != null) {
                                result.success(hijriMap)
                            } else {
                                result.error("UNAVAILABLE", "Hijri data fetch failed", null)
                            }
                        } catch (e: Exception) {
                            result.error("EXCEPTION", e.localizedMessage, null)
                        }
                    }
                }
                "getEventData" -> {
                    // 🌟 ফিক্স: ফ্ল্যাটার থেকে পাঠানো ডাইনামিক adjustment ভ্যালু রিসিভ করা
                    val adjustment = call.argument<Int>("adjustment") ?: -1
                    
                    CoroutineScope(Dispatchers.Main).launch {
                        try {
                            val data = withContext(Dispatchers.IO) {
                                val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                                
                                // বাটনে চাপ দিলে যেন কটলিনের SharedPreferences-ও সাথে সাথে আপডেট থাকে
                                prefs.edit().putInt("flutter.hijri_adjustment", adjustment).apply()

                                val isBn = prefs.getBoolean("flutter.isBn", true)
                                val localeCode = prefs.getString("flutter.localeCode", "bn") ?: "bn"
                                val isNight = prefs.getBoolean("flutter.isNight", false)

                                // নতুন অ্যাডজাস্টমেন্ট দিয়ে হিজরি ম্যাপ ফ্রেশ জেনারেট করা
                                val hijriMap = HijriRepository.getFormattedHijriData(context, isBn, localeCode, isNight)

                                val hDay = hijriMap["day"]?.toString()?.toIntOrNull() ?: 1
                                val hYear = hijriMap["year"]?.toString()?.toIntOrNull() ?: 1447
                                
                                val monthMap = hijriMap["month"] as? Map<*, *>
                                val hMonth = monthMap?.get("number")?.toString()?.toIntOrNull() ?: 1

                                // 🌟 ফিক্স: আপডেট করা নতুন adjustment হেল্পার মেথডে পাস করা হলো
                                eventHelper.calculateCountdown(hYear, hMonth, hDay, adjustment)
                            }
                            result.success(data)
                        } catch (e: Exception) {
                            result.error("EVENT_ERROR", e.localizedMessage, null)
                        }
                    }
                }
                "getAllSortedEvents" -> {
                    // 🌟 ফিক্স: ফ্ল্যাটার থেকে পাঠানো ডাইনামিক adjustment ভ্যালু রিসিভ করা
                    val adjustment = call.argument<Int>("adjustment") ?: -1

                    CoroutineScope(Dispatchers.Main).launch {
                        try {
                            val data = withContext(Dispatchers.IO) {
                                val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                                
                                prefs.edit().putInt("flutter.hijri_adjustment", adjustment).apply()

                                val isBn = prefs.getBoolean("flutter.isBn", true)
                                val localeCode = prefs.getString("flutter.localeCode", "bn") ?: "bn"
                                val isNight = prefs.getBoolean("flutter.isNight", false)

                                val hijriMap = HijriRepository.getFormattedHijriData(context, isBn, localeCode, isNight)

                                val hDay = hijriMap["day"]?.toString()?.toIntOrNull() ?: 1
                                val hYear = hijriMap["year"]?.toString()?.toIntOrNull() ?: 1447
                                
                                val monthMap = hijriMap["month"] as? Map<*, *>
                                val hMonth = monthMap?.get("number")?.toString()?.toIntOrNull() ?: 1

                                // 🌟 ফিক্স: আপডেট করা নতুন adjustment হেল্পার মেথডে পাস করা হলো
                                eventHelper.getAllSortedEvents(hYear, hMonth, hDay, adjustment)
                            }
                            result.success(data)
                        } catch (e: Exception) {
                            result.error("EVENT_ERROR", e.localizedMessage, null)
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startKotlinPrayerTimer() {
        stopKotlinPrayerTimer()

        runnable = object : Runnable {
            override fun run() {
                val helper = prayerTimeHelper ?: return
                
                val now = Date()
                val calendar = Calendar.getInstance()

                val pt: PrayerTimes = helper.getRawPrayerTimes(calendar)

                val tomorrowCal = Calendar.getInstance().apply { add(Calendar.DAY_OF_YEAR, 1) }
                val tomorrowPt: PrayerTimes = helper.getRawPrayerTimes(tomorrowCal)

                val fajr = pt.fajr
                val sunrise = pt.sunrise
                val dhuhr = pt.dhuhr
                val asr = pt.asr
                val maghrib = pt.maghrib
                val isha = pt.isha
                val nextFajr = tomorrowPt.fajr

                val sunriseEnd = Date(sunrise.time + TimeUnit.MINUTES.toMillis(20))
                val zawalStart = Date(dhuhr.time - TimeUnit.MINUTES.toMillis(15))

                var waktKey = ""
                var isEnds = false
                var diffMillis: Long = 0

                if (now.after(fajr) && now.before(sunrise)) {
                    waktKey = "fajr"; isEnds = true; diffMillis = sunrise.time - now.time
                } else if (now.after(sunrise) && now.before(sunriseEnd)) {
                    waktKey = "forbidden"; isEnds = false; diffMillis = sunriseEnd.time - now.time
                } else if (now.after(sunriseEnd) && now.before(zawalStart)) {
                    waktKey = "dhuhr"; isEnds = false; diffMillis = dhuhr.time - now.time
                } else if (now.after(zawalStart) && now.before(dhuhr)) {
                    waktKey = "jawal"; isEnds = false; diffMillis = dhuhr.time - now.time
                } else if (now.after(dhuhr) && now.before(asr)) {
                    waktKey = "dhuhr"; isEnds = true; diffMillis = asr.time - now.time
                } else if (now.after(asr) && now.before(maghrib)) {
                    waktKey = "asr"; isEnds = true; diffMillis = maghrib.time - now.time
                } else if (now.after(maghrib) && now.before(isha)) {
                    waktKey = "maghrib"; isEnds = true; diffMillis = isha.time - now.time
                } else if (now.after(isha)) {
                    waktKey = "fajr"; isEnds = false; diffMillis = nextFajr.time - now.time
                } else {
                    waktKey = "fajr"; isEnds = false; diffMillis = fajr.time - now.time
                }

                val hours = TimeUnit.MILLISECONDS.toHours(diffMillis)
                val minutes = TimeUnit.MILLISECONDS.toMinutes(diffMillis) % 60
                val seconds = TimeUnit.MILLISECONDS.toSeconds(diffMillis) % 60
                val countdownStr = String.format(Locale.US, "%02d:%02d:%02d", hours, minutes, seconds)

                val data = mapOf(
                    "wakt_key" to waktKey,
                    "is_ends" to isEnds,
                    "countdown" to countdownStr,
                    "fajr" to fajr.time,
                    "sunrise" to sunrise.time,
                    "dhuhr" to dhuhr.time,
                    "asr" to asr.time,
                    "maghrib" to maghrib.time,
                    "isha" to isha.time,
                    "nextFajr" to nextFajr.time
                )

                methodChannel.invokeMethod("updatePrayerData", data)
                handler.postDelayed(this, 1000)
            }
        }
        handler.post(runnable!!)
    }

    fun stopKotlinPrayerTimer() {
        runnable?.let { handler.removeCallbacks(it) }
        runnable = null
    }
}