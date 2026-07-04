package com.butterflydevs.salahmaster.alarm_service
import android.content.Context
import androidx.work.*
import java.util.concurrent.TimeUnit
object SyncManager {
    fun scheduleMosqueSync(context: Context) {
        val workManager = WorkManager.getInstance(context)
        
        val constraints = Constraints.Builder()
            .setRequiredNetworkType(NetworkType.CONNECTED)
            .build()

        // ১. তাতক্ষণিক চেক (One-Time Work) - অ্যাপ খুললেই এটি রান হবে
        val immediateRequest = OneTimeWorkRequestBuilder<MosqueSyncWorker>()
            .setConstraints(constraints)
            .build()
        
        // এটি একবারই রান করবে
        workManager.enqueueUniqueWork(
            "MosqueSyncImmediate",
            ExistingWorkPolicy.REPLACE, // প্রতিবার অ্যাপ খুললে এটি একবার চেক করবে
            immediateRequest
        )

        // ২. ১৫ মিনিটের পিরিওডিক লুপ - এটি ব্যাকগ্রাউন্ডে চলতে থাকবে
        val periodicRequest = PeriodicWorkRequestBuilder<MosqueSyncWorker>(15, TimeUnit.MINUTES)
            .setConstraints(constraints)
            .setBackoffCriteria(BackoffPolicy.EXPONENTIAL, 1, TimeUnit.MINUTES)
            .build()

        workManager.enqueueUniquePeriodicWork(
            "MosqueSyncWork",
            ExistingPeriodicWorkPolicy.KEEP, // অলরেডি শিডিউল থাকলে কিছু করবে না
            periodicRequest
        )
    }
}