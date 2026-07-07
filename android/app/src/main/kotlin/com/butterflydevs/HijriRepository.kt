package com.butterflydevs.salahmaster

import android.content.Context
import android.os.Build
import android.util.Log
import com.batoulapps.adhan.CalculationMethod
import com.batoulapps.adhan.Coordinates
import com.batoulapps.adhan.PrayerTimes
import com.batoulapps.adhan.data.DateComponents
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.OkHttpClient
import okhttp3.Request
import org.json.JSONObject
import org.json.JSONArray
import java.text.SimpleDateFormat
import java.time.chrono.HijrahDate
import java.time.format.DateTimeFormatter
import java.util.*
import java.util.concurrent.TimeUnit
import kotlin.collections.HashMap

object HijriRepository {

    private val client = OkHttpClient.Builder()
        .connectTimeout(7, TimeUnit.SECONDS)
        .readTimeout(7, TimeUnit.SECONDS)
        .build()

    // হিজরি মাসের বাংলা নাম ডিকশনারি
    private val hijriMonthsBn = mapOf(
        "Muharram" to "মুহাররম", "Safar" to "সফর", "Rabi' al-awwal" to "রবিউল আউয়াল",
        "Rabi' ath-thani" to "রবিউস সানি", "Jumada al-ula" to "জুমাদাল উলা", "Jumada al-akhirah" to "জুমাদাল আখিরা",
        "Rajab" to "রজব", "Sha'ban" to "শাবান", "Ramadan" to "রমজান", "Shawwal" to "শাওয়াল",
        "Dhu al-Qi'dah" to "জিলকদ", "Dhu al-Hijjah" to "জিলহজ্জ"
    )
    private val hijriMonthNamesEn = listOf(
        "Muharram",
        "Safar",
        "Rabi' al-awwal",
        "Rabi' ath-thani",
        "Jumada al-ula",
        "Jumada al-akhirah",
        "Rajab",
        "Sha'ban",
        "Ramadan",
        "Shawwal",
        "Dhu al-Qi'dah",
        "Dhu al-Hijjah"
    )

    // সপ্তাহের দিনের বাংলা নাম ডিকশনারি
    private val daysBn = mapOf(
        "Saturday" to "শনিবার", "Sunday" to "রবিবার", "Monday" to "সোমবার",
        "Tuesday" to "মঙ্গলবার", "Wednesday" to "বুধবার", "Thursday" to "বৃহস্পতিবার", "Friday" to "শুক্রবার"
    )

    // 🛠️ ফিক্সড: ইংরেজি সংখ্যা থেকে বাংলা সংখ্যায় কনভার্ট করার সঠিক লজিক
    private fun String.toBanglaNum(): String {
        val banglaDigits = charArrayOf('০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯')
        return this.map { if (it.isDigit()) banglaDigits[it - '0'] else it }.joinToString("")
    }

    suspend fun getFormattedHijriData(
        context: Context,
        isBn: Boolean,
        localeCode: String,
        isNight: Boolean
    ): Map<String, Any> = withContext(Dispatchers.IO) {

        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        // 🌟 ফিক্স: ডার্ট সাইডের সাথে মিলিয়ে ডিফল্ট ভ্যালু -1 রিড করা হচ্ছে
        val adjustment = prefs.getInt("flutter.hijri_adjustment", -1)
        val referenceCalendar = Calendar.getInstance()

        // ১. মাগরিবের পর দিন চেঞ্জ করার Adhan SDK লজিক
        try {
            val lat = prefs.getFloat("flutter.lat", 24.3745f).toDouble()
            val lng = prefs.getFloat("flutter.lng", 88.6042f).toDouble()

            val coords = Coordinates(lat, lng)
            val dateComponents = DateComponents.from(referenceCalendar.time)
            val params = CalculationMethod.KARACHI.parameters

            val pt = PrayerTimes(coords, dateComponents, params)
            val maghribTime = pt.maghrib

            if (Date().after(maghribTime)) {
                referenceCalendar.add(Calendar.DAY_OF_YEAR, 1)
            }
        } catch (e: Exception) {
            Log.d("HijriFetch", "Location/Maghrib calculation failed: ${e.message}")
        }

        // ২. হিজরি অ্যাডজাস্টমেন্ট যোগ করা
        referenceCalendar.add(Calendar.DAY_OF_YEAR, adjustment)
        val referenceDate = referenceCalendar.time

        // দিন বা রাতের স্ট্যাটাস সহ ডের নাম ফরম্যাট করা
        val dayFormatEn = SimpleDateFormat("EEEE", Locale.US)
        val dayNameEn = dayFormatEn.format(referenceDate)

        val dayName = if (isBn) (daysBn[dayNameEn] ?: dayNameEn) else {
            val localFormat = SimpleDateFormat("EEEE", Locale(localeCode))
            localFormat.format(referenceDate)
        }

        val dayNightStatus = if (isNight) {
            if (isBn) "$dayName রাত" else "$dayName Night"
        } else {
            dayName
        }

        // ৩. ক্যাশ কি (Cache Key) জেনারেশন
        val keyFormat = SimpleDateFormat("yyyy-MM-dd", Locale.US)
        val cacheKey = "${keyFormat.format(referenceDate)}_$adjustment"
        val cachedKey = prefs.getString("flutter.cached_hijri_key", null)
        val cachedJson = prefs.getString("flutter.cached_hijri_data", null)

        var hijriData: Map<String, Any>? = null

        if (cachedKey == cacheKey && cachedJson != null) {
            try {
                hijriData = jsonToMap(JSONObject(cachedJson))
            } catch (e: Exception) {
                Log.e("HijriFetch", "Cache parse failed", e)
            }
        }

        // ৪. ক্যাশে ডাটা না থাকলে নতুন করে API কল (এখানে অ্যাডজাস্ট করা ডেটই পাঠানো হচ্ছে)
        if (hijriData == null) {
            val apiDateFormat = SimpleDateFormat("dd-MM-yyyy", Locale.US)
            val todayStr = apiDateFormat.format(referenceDate)

            try {
                val request = Request.Builder().url("https://api.aladhan.com/v1/gToH/$todayStr").build()
                client.newCall(request).execute().use { response ->
                    if (response.isSuccessful && response.body != null) {
                        val jsonResponse = JSONObject(response.body!!.string())
                        val data = jsonResponse.optJSONObject("data")
                        val hijri = data?.optJSONObject("hijri")

                        if (hijri != null) {
                            hijriData = jsonToMap(hijri)
                            prefs.edit()
                                .putString("flutter.cached_hijri_key", cacheKey)
                                .putString("flutter.cached_hijri_data", hijri.toString())
                                .apply()
                        }
                    }
                }
            } catch (e: Exception) {
                Log.d("HijriFetch", "Online Fetch Failed, using offline fallback: ${e.message}")
            }
        }

        // ৫. ইন্টারনেট না থাকলে অফলাইন ফলব্যাক
        if (hijriData == null) {
            hijriData = getOfflineHijriMap(referenceDate, keyFormat.format(referenceDate))
        }

        // ৬. ফাইনাল ভেরিয়েবল প্রসেসিং
        val resultMap = HashMap<String, Any>()
        
        hijriData?.let {
            // 🌟 ফিক্স: আল-আধান API থেকে "day" অবজেক্ট সরাসরি স্ট্রিং বা ইন্ট আকারে আসতে পারে, তাই টাইপ সেফ করা হলো
            resultMap["day"] = it["day"]?.toString() ?: "1"
            resultMap["year"] = it["year"]?.toString() ?: "1447"
            
            val monthMap = it["month"] as? Map<*, *>
            if (monthMap != null) {
                val m = HashMap<String, Any>()
                m["number"] = monthMap["number"]?.toString()?.toIntOrNull() ?: 1
                m["en"] = monthMap["en"]?.toString() ?: "Muharram"
                m["ar"] = monthMap["ar"]?.toString() ?: ""
                m["days"] = monthMap["days"]?.toString()?.toIntOrNull() ?: 30
                resultMap["month"] = m
            } else {
                val m = HashMap<String, Any>()
                m["number"] = 1
                m["en"] = "Muharram"
                m["ar"] = "المحرم"
                m["days"] = 30
                resultMap["month"] = m
            }
        }

        return@withContext resultMap
    }

    private fun getOfflineHijriMap(referenceDate: Date, cacheKeyDate: String): Map<String, Any> {
        val outMap = HashMap<String, Any>()
        val monthMap = HashMap<String, Any>()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            try {
                val localHijri = HijrahDate.from(
                    java.time.LocalDate.parse(
                        cacheKeyDate,
                        DateTimeFormatter.ofPattern("yyyy-MM-dd")
                    )
                )

                val monthNumber =
                    localHijri.get(java.time.temporal.ChronoField.MONTH_OF_YEAR)

                monthMap["number"] = monthNumber

                // Android Formatter ব্যবহার না করে নিজের list থেকে নাম নেওয়া হচ্ছে
                monthMap["en"] =
                    hijriMonthNamesEn.getOrElse(monthNumber - 1) { "Muharram" }

                monthMap["ar"] = ""

                monthMap["days"] = 30

                outMap["day"] =
                    localHijri.get(java.time.temporal.ChronoField.DAY_OF_MONTH).toString()

                outMap["year"] =
                    localHijri.get(java.time.temporal.ChronoField.YEAR).toString()

            } catch (e: Exception) {
                setStaticFallback(monthMap, outMap)
            }
        } else {
            setStaticFallback(monthMap, outMap)
        }

        outMap["month"] = monthMap
        return outMap
    }

    private fun setStaticFallback(
    monthMap: HashMap<String, Any>,
    outMap: HashMap<String, Any>
        ) {
            monthMap["number"] = 1
            monthMap["en"] = "Muharram"
            monthMap["ar"] = ""
            monthMap["days"] = 30

            outMap["day"] = "1"
            outMap["year"] = "1447"
        }

    private fun jsonToMap(jsonObject: JSONObject): Map<String, Any> {
        val map = HashMap<String, Any>()
        val keys = jsonObject.keys()
        while (keys.hasNext()) {
            val key = keys.next()
            var value = jsonObject.get(key)
            if (value is JSONObject) value = jsonToMap(value)
            else if (value is JSONArray) value = jsonToList(value)
            map[key] = if (value == JSONObject.NULL) "" else value
        }
        return map
    }

    private fun jsonToList(jsonArray: JSONArray): List<Any> {
        val list = ArrayList<Any>()
        for (i in 0 until jsonArray.length()) {
            var value = jsonArray.get(i)
            if (value is JSONObject) value = jsonToMap(value)
            else if (value is JSONArray) value = jsonToList(value)
            if (value != JSONObject.NULL) list.add(value)
        }
        return list
    }
}