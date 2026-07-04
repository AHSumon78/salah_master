package com.butterflydevs.salahmaster.database

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.sqlite.db.SupportSQLiteDatabase
import com.butterflydevs.salahmaster.data.*
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

@Database(
    entities = [AlarmEntity::class, LocationEntity::class, SettingsEntity::class, MosqueEntity::class],
    version = 2,
    exportSchema = false
)
abstract class AppDatabase : RoomDatabase() {

    abstract fun alarmDao(): AlarmDao
    abstract fun locationDao(): LocationDao
    abstract fun settingsDao(): SettingsDao
    abstract fun mosqueDao(): MosqueDao
    suspend fun insertAlarmWhenLoaction(loactionId:Int){

        val prayerNames = listOf("Fajr", "Dhuhr", "Asr", "Maghrib", "Isha")
        val times = listOf(
            Pair(5, 0), Pair(13, 15), Pair(16, 30), Pair(18, 45), Pair(20, 0)
        )

        for (i in prayerNames.indices) {
            alarmDao().insert(
                AlarmEntity(
                    title = prayerNames[i],
                    hour = times[i].first,
                    minute = times[i].second,
                    isActive = false,
                    isDaily = true,
                    daysMask = 127,
                    sound = "azan1",
                    locationId = loactionId
                )
            )
        }
    }

    companion object {
        @Volatile
        public var INSTANCE: AppDatabase? = null

        fun getInstance(context: Context): AppDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    AppDatabase::class.java,
                    "salah_db"
                )
                    .addCallback(object : RoomDatabase.Callback() {
                        override fun onCreate(db: SupportSQLiteDatabase) {
                            super.onCreate(db)

                            // 🔥 সমাধান: launch ব্লকের ভেতরে suspend ফাংশন কল করতে হবে
                            CoroutineScope(Dispatchers.IO).launch {
                                // যেহেতু INSTANCE তৈরি হতে সময় নিতে পারে, তাই একটু চেক করে নেওয়া ভালো
                                INSTANCE?.let { database ->
                                    insertDefaultData(database.locationDao(), database.alarmDao(),database.settingsDao())
                                }
                            }
                        }
                    })
                    .build()
                INSTANCE = instance
                instance
            }
        }

        // এটি অবশ্যই companion object এর ভেতরে অথবা বাইরে suspend হিসেবে থাকবে
        private suspend fun insertDefaultData(locationDao: LocationDao, alarmDao: AlarmDao,settingsDao: SettingsDao ) {
            val homeId = locationDao.insert(
                LocationEntity(
                    name = "Home",
                    latitude = 24.85885433,
                    longitude = 88.282536003,
                    diameter = 500.0,
                    preAlarmMinutes = 0
                )
            ).toInt()
            val workId = locationDao.insert(
                LocationEntity(
                    name = "Office",
                    latitude = 24.36365177,
                    longitude = 88.63240607,
                    diameter = 500.0,
                    preAlarmMinutes = 0
                )
            ).toInt()
            val generallId = locationDao.insert(
                LocationEntity(
                    id = 10,
                    name = "General",
                    latitude = 0.0,
                    longitude = 0.0,
                    diameter = 0.0,
                    preAlarmMinutes = 0
                )
            ).toInt()
            val ids = listOf(homeId,workId)


            val prayerNames = listOf("Fajr", "Dhuhr", "Asr", "Maghrib", "Isha")
            val times = listOf(
                Pair(5, 0), Pair(13, 15), Pair(16, 30), Pair(18, 45), Pair(20, 0)
            )
            alarmDao.insert(AlarmEntity(
                title = "Morning Rising",
                hour = 6,
                minute = 0,
                isActive = false,
                isDaily = true,
                daysMask = 127,
                sound = "",
                locationId = generallId
            ))
            for(j in ids.indices) {
                for (i in prayerNames.indices) {
                    alarmDao.insert(
                        AlarmEntity(
                            title = prayerNames[i],
                            hour = times[i].first,
                            minute = times[i].second,
                            isActive = false,
                            isDaily = true,
                            daysMask = 127,
                            sound = "azan1",
                            locationId = ids[j]
                        )
                    )
                }
            }
            settingsDao.insert(
                SettingsEntity(
                    id = 1,
                    currentLocation = "Home",
                    currentLocationId = homeId,
                    enable = true
                )
            )
        }
    }
}