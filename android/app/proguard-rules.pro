
# ============================================================
# ALARM APP - proguard-rules.pro
# ============================================================

# ---- 1. YOUR ALARM CLASSES (most important) ----
-keep class com.butterflydevs.salahmaster.** { *; }
-keepclassmembers class com.butterflydevs.salahmaster.** { *; }

# ---- 2. BROADCAST RECEIVERS (must never be renamed) ----
-keep class com.butterflydevs.salahmaster.alarm_service.AlarmReceiver { *; }
-keep class com.butterflydevs.salahmaster.alarm_service.SnoozeReceiver { *; }
-keep class com.butterflydevs.salahmaster.alarm_service.StopAlarmReceiver { *; }

# ---- 3. SERVICE ----
-keep class com.butterflydevs.salahmaster.alarm_service.AlarmService { *; }

# ---- 4. ACTIVITY ----
-keep class com.butterflydevs.salahmaster.alarm_service.AlarmActivity { *; }

# ---- 5. HELPERS ----
-keep class com.butterflydevs.salahmaster.alarm_service.NotificationHelper { *; }
-keep class com.butterflydevs.salahmaster.alarm_service.SoundHelper { *; }
-keep class com.butterflydevs.salahmaster.alarm_service.AlarmScheduler { *; }

# ---- 6. ROOM DATABASE ----
-keep class com.butterflydevs.salahmaster.alarm_service.AlarmEntity { *; }
-keep class com.butterflydevs.salahmaster.alarm_service.AlarmDao { *; }
-keep class com.butterflydevs.salahmaster.alarm_service.LocationDao { *; }
-keep class com.butterflydevs.salahmaster.alarm_service.AppDatabase { *; }

# Room generated code
-keep class * extends androidx.room.RoomDatabase { *; }
-keep @androidx.room.Entity class * { *; }
-keep @androidx.room.Dao interface * { *; }
-dontwarn androidx.room.**

# ---- 7. ANDROID COMPONENTS (system classes) ----
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.app.Service
-keep public class * extends androidx.appcompat.app.AppCompatActivity
-keep public class * extends android.app.Application

# ---- 8. COROUTINES ----
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-dontwarn kotlinx.coroutines.**

# ---- 9. KOTLIN ----
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}

# ---- 10. GENERAL ANDROID (safe defaults) ----
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keepattributes Signature
-keepattributes Exceptions

# Keep R class
-keepclassmembers class **.R$* {
    public static <fields>;
}