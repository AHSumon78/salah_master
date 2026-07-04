package com.butterflydevs.salahmaster

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.plugin.common.EventChannel

class CompassStreamHandler(
    private val context: Context
) : EventChannel.StreamHandler, SensorEventListener {

    private var eventSink: EventChannel.EventSink? = null

    private val sensorManager =
        context.getSystemService(Context.SENSOR_SERVICE) as SensorManager

    private val accelerometer =
        sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)

    private val magnetometer =
        sensorManager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD)

    private var gravity = FloatArray(3)
    private var geomagnetic = FloatArray(3)

    override fun onListen(
        arguments: Any?,
        events: EventChannel.EventSink?
    ) {
        eventSink = events

        sensorManager.registerListener(
            this,
            accelerometer,
            SensorManager.SENSOR_DELAY_GAME
        )

        sensorManager.registerListener(
            this,
            magnetometer,
            SensorManager.SENSOR_DELAY_GAME
        )
    }

    override fun onCancel(arguments: Any?) {
        sensorManager.unregisterListener(this)
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event == null) return

        when (event.sensor.type) {

            Sensor.TYPE_ACCELEROMETER -> {
                gravity = event.values.clone()
            }

            Sensor.TYPE_MAGNETIC_FIELD -> {
                geomagnetic = event.values.clone()
            }
        }

        val rotationMatrix = FloatArray(9)
        val inclinationMatrix = FloatArray(9)

        val success = SensorManager.getRotationMatrix(
            rotationMatrix,
            inclinationMatrix,
            gravity,
            geomagnetic
        )

        if (!success) return

        val orientation = FloatArray(3)

        SensorManager.getOrientation(
            rotationMatrix,
            orientation
        )

        var azimuth =
            Math.toDegrees(orientation[0].toDouble()).toFloat()

        azimuth = (azimuth + 360) % 360

        eventSink?.success(
            mapOf(
                "heading" to azimuth,
                "accuracy" to event.accuracy
            )
        )
    }

    override fun onAccuracyChanged(
        sensor: Sensor?,
        accuracy: Int
    ) {
        // optional
    }
}