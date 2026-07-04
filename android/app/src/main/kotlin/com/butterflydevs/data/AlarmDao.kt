package com.butterflydevs.salahmaster.data
import com.butterflydevs.salahmaster.data.AlarmEntity
import com.butterflydevs.salahmaster.data.LocationEntity
import com.butterflydevs.salahmaster.data.SettingsEntity
import com.butterflydevs.salahmaster.data.MosqueEntity
import com.butterflydevs.salahmaster.data.LocationWithAlarms


import androidx.room.*

@Dao
interface AlarmDao {

    @Insert
    fun insert(alarm: AlarmEntity):Long

    @Update
    fun update(alarm: AlarmEntity): Int

    @Delete
    fun delete(alarm: AlarmEntity):Int

    @Query("DELETE FROM alarm WHERE id = :id")
    fun deleteById(id: Int):Int

    @Query("SELECT * FROM alarm WHERE locationId = :locId ORDER BY hour, minute")
    fun getAlarmsByLocation(locId: Int): List<AlarmEntity>

    @Query("DELETE FROM alarm WHERE locationId = :locId")
    fun deleteByLocation(locId: Int): Int
    @Query("SELECT * FROM alarm WHERE id = :id LIMIT 1")
    fun getAlarmById(id: Int): AlarmEntity?
}
@Dao
interface LocationDao {

    @Insert
    fun insert(location: LocationEntity): Long

    @Update
    fun update(location: LocationEntity): Int

    @Delete
    fun delete(location: LocationEntity):Int

    @Query("SELECT * FROM location WHERE id != 10")
    fun getAll(): List<LocationEntity>

    @Query("SELECT * FROM location WHERE id = 10")
    fun getGeneral(): List<LocationEntity>

    @Query("SELECT * FROM location WHERE id = :id")
    fun getById(id: Int): LocationEntity?
}
@Dao
interface SettingsDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(settings: SettingsEntity):Long

    @Update
    fun update(settings: SettingsEntity):Int

    @Query("SELECT * FROM settings WHERE id = 1 LIMIT 1")
    fun getSettings(): SettingsEntity?

    @Query("DELETE FROM settings")
    fun clear(): Int
}
@Dao
interface MosqueDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(mosque: MosqueEntity):Long

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insertAll(list: List<MosqueEntity>):List<Long>

    @Update
    fun update(mosque: MosqueEntity): Int

    @Delete
    fun delete(mosque: MosqueEntity):Int

    @Query("SELECT * FROM mosques ORDER BY name ASC")
    fun getAll(): List<MosqueEntity>

    @Query("DELETE FROM mosques WHERE id = :id")
    fun deleteById(id: Int): Int
}

@Dao
interface LocationWithAlarmsDao {

    @Transaction
    @Query("SELECT * FROM location")
    fun getLocationsWithAlarms(): List<LocationWithAlarms>
}