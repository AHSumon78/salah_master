package com.butterflydevs.salahmaster.data
import androidx.room.*
@Entity(tableName = "location")
data class LocationEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Int = 0,

    val name: String,
    val latitude: Double,
    val longitude: Double,
    val diameter: Double,
    val preAlarmMinutes: Int
)
@Entity(
    tableName = "alarm",
    foreignKeys = [
        ForeignKey(
            entity = LocationEntity::class,
            parentColumns = ["id"],
            childColumns = ["locationId"],
            onDelete = ForeignKey.CASCADE
        )
    ],
    indices = [Index("locationId")]
)
data class AlarmEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Int = 0,

    val title: String,
    val hour: Int,
    val minute: Int,

    val isActive: Boolean,
    val isDaily: Boolean,
    val daysMask: Int = 0, 
    val sound: String,

    val locationId: Int   // 🔥 MAIN FIX
)

@Entity(tableName = "settings")
data class SettingsEntity(
    @PrimaryKey
    val id: Int = 1,

    val currentLocation: String,
    val currentLocationId: Int,
    val enable: Boolean
)

@Entity(
    tableName = "mosques",
    indices = [Index(value = ["name", "lat", "lon"], unique = true)]
)
data class MosqueEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Int = 0,

    val name: String,
    val lat: Double,
    val lon: Double
)


data class LocationWithAlarms(
    @Embedded val location: LocationEntity,

    @Relation(
        parentColumn = "id",
        entityColumn = "locationId"
    )
    val alarms: List<AlarmEntity>
)