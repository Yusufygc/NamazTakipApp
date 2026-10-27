package com.namaztakip.namaz_takip

import android.content.Context
import android.content.Intent
import android.hardware.GeomagneticField
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.net.Uri
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val shareChannelName = "com.namaztakip.app/share"
    private val compassChannelName = "com.namaztakip.app/compass"
    private val homeWidgetChannelName = "com.namaztakip.app/home_widget"
    private var shareChannel: MethodChannel? = null
    private var pendingSharedText: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        extractSharedText(intent)?.let { shared ->
            pendingSharedText = shared
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, shareChannelName)
        shareChannel = channel
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "takeInitialSharedText" -> {
                    val value = pendingSharedText
                    pendingSharedText = null
                    result.success(value)
                }
                "openUrl" -> {
                    val url = call.argument<String>("url")
                    val parsed = url?.let { Uri.parse(it.trim()) }
                    val scheme = parsed?.scheme?.lowercase()
                    // Yalnızca http ve https; file:, tel:, intent: gibi şemalar açılmaz.
                    if (parsed == null || (scheme != "http" && scheme != "https") ||
                        parsed.host.isNullOrEmpty()
                    ) {
                        result.success(false)
                    } else {
                        try {
                            val viewIntent = Intent(Intent.ACTION_VIEW, parsed).apply {
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(viewIntent)
                            result.success(true)
                        } catch (_: Exception) {
                            result.success(false)
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }

        // Kıble pusulası için cihaz yönelim (azimuth) sensör akışı
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, compassChannelName)
            .setStreamHandler(object : EventChannel.StreamHandler {
                private var sensorManager: SensorManager? = null
                private var listener: SensorEventListener? = null

                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    val sm = getSystemService(Context.SENSOR_SERVICE) as? SensorManager
                    val rotationSensor = sm?.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
                    if (sm == null || rotationSensor == null) {
                        // Sessiz kalmak yerine Dart'a açık hata: sayfa elle çevirmeye geçer.
                        events?.error("NO_SENSOR", "Cihazda yön (pusula) sensörü yok", null)
                        return
                    }
                    sensorManager = sm

                    // Sensör manyetik kuzeyi verir; konum biliniyorsa manyetik sapma
                    // eklenerek gerçek kuzeye çevrilir (Kıble açısı gerçek kuzeye göredir).
                    val args = arguments as? Map<*, *>
                    val latitude = (args?.get("latitude") as? Number)?.toDouble()
                    val longitude = (args?.get("longitude") as? Number)?.toDouble()
                    val declination = if (latitude != null && longitude != null) {
                        GeomagneticField(
                            latitude.toFloat(),
                            longitude.toFloat(),
                            0f,
                            System.currentTimeMillis()
                        ).declination.toDouble()
                    } else {
                        0.0
                    }
                    Log.d("Pusula", "manyetik sapma: $declination derece")
                    val rotationMatrix = FloatArray(9)
                    val orientation = FloatArray(3)
                    val sensorListener = object : SensorEventListener {
                        override fun onSensorChanged(event: SensorEvent?) {
                            if (event?.sensor?.type == Sensor.TYPE_ROTATION_VECTOR) {
                                SensorManager.getRotationMatrixFromVector(rotationMatrix, event.values)
                                SensorManager.getOrientation(rotationMatrix, orientation)
                                val magneticDeg = Math.toDegrees(orientation[0].toDouble())
                                events?.success(CompassMath.trueHeading(magneticDeg, declination))
                            }
                        }

                        override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
                    }
                    listener = sensorListener
                    sm.registerListener(sensorListener, rotationSensor, SensorManager.SENSOR_DELAY_UI)
                }

                override fun onCancel(arguments: Any?) {
                    listener?.let { sensorManager?.unregisterListener(it) }
                    listener = null
                }
            })

        // Telefon ana ekran widget'ı güncelleme ve sabitleme kanalı
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, homeWidgetChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "updateWidget" -> {
                        val args = call.arguments as? Map<*, *>
                        if (args != null) {
                            NamazHomeWidgetProvider.saveSnapshotAndRefresh(applicationContext, args)
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                    }
                    "requestPinWidget" -> {
                        val ok = NamazHomeWidgetProvider.requestPin(applicationContext)
                        result.success(ok)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        extractSharedText(intent)?.let { shared ->
            val channel = shareChannel
            if (channel != null) {
                channel.invokeMethod("onSharedText", shared)
            } else {
                pendingSharedText = shared
            }
        }
    }

    private fun extractSharedText(intent: Intent?): String? {
        if (intent == null) return null
        if (intent.action == Intent.ACTION_SEND && intent.type?.startsWith("text/") == true) {
            val text = intent.getStringExtra(Intent.EXTRA_TEXT)?.trim()
            if (!text.isNullOrEmpty()) {
                intent.removeExtra(Intent.EXTRA_TEXT)
                return text
            }
        }
        return null
    }
}
