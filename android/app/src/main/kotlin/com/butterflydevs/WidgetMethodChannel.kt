package com.butterflydevs.salahmaster

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.os.Build
import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class WidgetMethodChannel(
    private val context: Context,
    flutterEngine: FlutterEngine
) {

    companion object {
        private const val CHANNEL = "widget_channel"
    }

    init {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "addWidget" -> {

                    val manager = AppWidgetManager.getInstance(context)

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
                        manager.isRequestPinAppWidgetSupported
                    ) {

                        val provider = ComponentName(
                            context,
                            IslamicWidgetProvider::class.java
                        )

                        manager.requestPinAppWidget(
                            provider,
                            null,
                            null
                        )

                        result.success(true)

                    } else {
                        result.success(false)
                    }
                }

                else -> result.notImplemented()
            }
        }
    }
}