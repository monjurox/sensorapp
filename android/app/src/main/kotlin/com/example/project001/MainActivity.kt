package com.example.project001

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.net.wifi.WifiManager
import android.os.BatteryManager
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.telephony.TelephonyManager
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.net.InetAddress
import java.net.NetworkInterface
import java.util.Date

class MainActivity: FlutterActivity() {
    private val CHANNEL_DEVICE = "com.project001/device"
    private val CHANNEL_BATTERY = "com.project001/battery"
    private val CHANNEL_NETWORK = "com.project001/network"
    private val CHANNEL_SENSOR = "com.project001/sensor"
    
    // Sensor variables
    private lateinit var sensorManager: SensorManager
    private var stepCounterSensor: Sensor? = null
    private var stepDetectorSensor: Sensor? = null
    private var totalSteps = 0
    private var lastStepCount = 0
    private var stepDetectorCount = 0
    private var lastActivity = "Still"
    private var lastUpdateTime = System.currentTimeMillis()
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Initialize sensors
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        
        // Check available sensors
        checkAvailableSensors()
        
        // Get step counter sensor if available
        stepCounterSensor = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)
        stepDetectorSensor = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_DETECTOR)
        
        Log.d("MainActivity", "Step counter available: ${stepCounterSensor != null}")
        Log.d("MainActivity", "Step detector available: ${stepDetectorSensor != null}")
    }
    
    override fun onResume() {
        super.onResume()
        
        // Register step counter sensor listener
        stepCounterSensor?.let {
            sensorManager.registerListener(stepCounterListener, it, SensorManager.SENSOR_DELAY_NORMAL)
        }
        
        // Register step detector sensor listener
        stepDetectorSensor?.let {
            sensorManager.registerListener(stepDetectorListener, it, SensorManager.SENSOR_DELAY_NORMAL)
        }
    }
    
    override fun onPause() {
        super.onPause()
        
        // Unregister sensor listeners to save battery
        sensorManager.unregisterListener(stepCounterListener)
        sensorManager.unregisterListener(stepDetectorListener)
    }
    
    // Step counter listener (total steps since last boot)
    private val stepCounterListener = object : SensorEventListener {
        override fun onSensorChanged(event: SensorEvent) {
            if (event.sensor.type == Sensor.TYPE_STEP_COUNTER) {
                val currentSteps = event.values[0].toInt()
                
                // If this is the first reading, initialize
                if (lastStepCount == 0) {
                    lastStepCount = currentSteps
                }
                
                // Calculate steps taken since last reading
                val stepsTaken = currentSteps - lastStepCount
                if (stepsTaken > 0) {
                    totalSteps += stepsTaken
                    lastStepCount = currentSteps
                    lastUpdateTime = System.currentTimeMillis()
                    
                    // Update activity based on recent steps
                    updateActivityDetection()
                    
                    Log.d("StepCounter", "Total steps: $totalSteps, Current: $currentSteps")
                }
            }
        }
        
        override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
            // Handle accuracy changes if needed
        }
    }
    
    // Step detector listener (individual step detection)
    private val stepDetectorListener = object : SensorEventListener {
        override fun onSensorChanged(event: SensorEvent) {
            if (event.sensor.type == Sensor.TYPE_STEP_DETECTOR && event.values[0] == 1.0f) {
                stepDetectorCount++
                lastUpdateTime = System.currentTimeMillis()
                
                // Update activity based on recent step detection
                updateActivityDetection()
                
                Log.d("StepDetector", "Step detected! Count: $stepDetectorCount")
            }
        }
        
        override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
            // Handle accuracy changes if needed
        }
    }
    
    private fun updateActivityDetection() {
        val currentTime = System.currentTimeMillis()
        val timeSinceLastUpdate = currentTime - lastUpdateTime
        
        // Simple activity detection logic
        lastActivity = when {
            // If steps detected in last 2 seconds, probably walking
            timeSinceLastUpdate < 2000 -> "Walking"
            // If steps detected in last 10 seconds, probably moving
            timeSinceLastUpdate < 10000 -> "Moving"
            // Otherwise, still
            else -> "Still"
        }
    }
    
    private fun checkAvailableSensors() {
        val sensors = sensorManager.getSensorList(Sensor.TYPE_ALL)
        Log.d("SensorCheck", "=== Available Sensors ===")
        for (sensor in sensors) {
            Log.d("SensorCheck", "Sensor: ${sensor.name}, Type: ${sensor.type}")
        }
        Log.d("SensorCheck", "=========================")
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Device Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_DEVICE).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDeviceInfo" -> {
                    val deviceInfo = getDeviceInfo()
                    result.success(deviceInfo)
                }
                "getCellularInfo" -> {
                    val cellularInfo = getCellularInfo()
                    result.success(cellularInfo)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // Battery Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_BATTERY).setMethodCallHandler { call, result ->
            when (call.method) {
                "getBatteryInfo" -> {
                    val batteryInfo = getBatteryInfo()
                    result.success(batteryInfo)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // Network Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NETWORK).setMethodCallHandler { call, result ->
            when (call.method) {
                "getNetworkInfo" -> {
                    val networkInfo = getNetworkInfo()
                    result.success(networkInfo)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // Sensor Channel - NOW RETURNS REAL DATA
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_SENSOR).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSensorData" -> {
                    val sensorData = getSensorData()
                    result.success(sensorData)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // Permission Channel - UPDATED WITH ACTIVITY PERMISSION HANDLERS
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.project001/permissions").setMethodCallHandler { call, result ->
            when (call.method) {
                "checkLocationPermission" -> {
                    val hasPermission = ContextCompat.checkSelfPermission(
                        this,
                        Manifest.permission.ACCESS_FINE_LOCATION
                    ) == PackageManager.PERMISSION_GRANTED
                    result.success(hasPermission)
                }
                "requestLocationPermission" -> {
                    ActivityCompat.requestPermissions(
                        this,
                        arrayOf(Manifest.permission.ACCESS_FINE_LOCATION),
                        1001
                    )
                    result.success(true)
                }
                "checkPhonePermission" -> {
                    val hasPermission = ContextCompat.checkSelfPermission(
                        this,
                        Manifest.permission.READ_PHONE_STATE
                    ) == PackageManager.PERMISSION_GRANTED
                    result.success(hasPermission)
                }
                "requestPhonePermission" -> {
                    ActivityCompat.requestPermissions(
                        this,
                        arrayOf(Manifest.permission.READ_PHONE_STATE),
                        1002
                    )
                    result.success(true)
                }
                "checkActivityPermission" -> {
                    val hasPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        ContextCompat.checkSelfPermission(
                            this,
                            Manifest.permission.ACTIVITY_RECOGNITION
                        ) == PackageManager.PERMISSION_GRANTED
                    } else {
                        ContextCompat.checkSelfPermission(
                            this,
                            Manifest.permission.BODY_SENSORS
                        ) == PackageManager.PERMISSION_GRANTED
                    }
                    result.success(hasPermission)
                }
                "requestActivityPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        ActivityCompat.requestPermissions(
                            this,
                            arrayOf(Manifest.permission.ACTIVITY_RECOGNITION),
                            1003
                        )
                    } else {
                        ActivityCompat.requestPermissions(
                            this,
                            arrayOf(Manifest.permission.BODY_SENSORS),
                            1003
                        )
                    }
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    // Get device information
    private fun getDeviceInfo(): Map<String, Any> {
        return mapOf<String, Any>(
            "deviceModel" to Build.MODEL,
            "androidVersion" to Build.VERSION.RELEASE,
            "deviceName" to getDeviceName(),
            "manufacturer" to Build.MANUFACTURER,
            "product" to Build.PRODUCT,
            "brand" to Build.BRAND,
            "hardware" to Build.HARDWARE,
            "sdkVersion" to Build.VERSION.SDK_INT
        )
    }
    
    // Get device name
    private fun getDeviceName(): String {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N_MR1) {
            Settings.Global.getString(contentResolver, "device_name") ?: Build.MODEL
        } else {
            Build.MODEL
        }
    }
    
    // Get battery information
    private fun getBatteryInfo(): Map<String, Any> {
        val batteryStatus: Intent? = IntentFilter(Intent.ACTION_BATTERY_CHANGED).let { ifilter ->
            applicationContext.registerReceiver(null, ifilter)
        }
        
        val level: Int = batteryStatus?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
        val scale: Int = batteryStatus?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1
        val batteryPct: Int = if (level != -1 && scale != -1) {
            (level * 100 / scale.toFloat()).toInt()
        } else {
            0
        }
        
        val temperature: Int = batteryStatus?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, 0) ?: 0
        val temperatureCelsius: Float = temperature / 10.0f
        
        val health: Int = batteryStatus?.getIntExtra(BatteryManager.EXTRA_HEALTH, BatteryManager.BATTERY_HEALTH_UNKNOWN) ?: BatteryManager.BATTERY_HEALTH_UNKNOWN
        
        val status: Int = batteryStatus?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
        val isCharging: Boolean = status == BatteryManager.BATTERY_STATUS_CHARGING || status == BatteryManager.BATTERY_STATUS_FULL
        
        return mapOf<String, Any>(
            "batteryLevel" to batteryPct,
            "batteryTemperature" to temperatureCelsius,
            "batteryHealth" to health,
            "isCharging" to isCharging,
            "chargePlug" to (batteryStatus?.getIntExtra(BatteryManager.EXTRA_PLUGGED, -1) ?: -1),
            "voltage" to (batteryStatus?.getIntExtra(BatteryManager.EXTRA_VOLTAGE, 0) ?: 0),
            "technology" to (batteryStatus?.getStringExtra(BatteryManager.EXTRA_TECHNOLOGY) ?: "Unknown")
        )
    }
    
    // Get network information
    private fun getNetworkInfo(): Map<String, Any> {
        val wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        val wifiInfo = wifiManager.connectionInfo
        
        val ssid = if (wifiInfo.ssid != "<unknown ssid>" && wifiInfo.ssid.isNotEmpty()) {
            wifiInfo.ssid.removeSurrounding("\"")
        } else {
            "Not Connected"
        }
        
        val rssi = wifiInfo.rssi
        val localIp = getLocalIpAddress() ?: "0.0.0.0"
        
        return mapOf<String, Any>(
            "wifiSSID" to ssid,
            "wifiRSSI" to rssi,
            "localIP" to localIp,
            "macAddress" to (wifiInfo.macAddress ?: "Unknown"),
            "networkType" to "Wi-Fi",
            "linkSpeed" to wifiInfo.linkSpeed,
            "frequency" to wifiInfo.frequency
        )
    }
    
    // Get local IP address
    private fun getLocalIpAddress(): String? {
        try {
            val interfaces = NetworkInterface.getNetworkInterfaces()
            while (interfaces.hasMoreElements()) {
                val intf = interfaces.nextElement()
                if (intf.name.contains("wlan") || intf.name.contains("eth") || intf.name.contains("ap")) {
                    val addrs = intf.inetAddresses
                    while (addrs.hasMoreElements()) {
                        val addr = addrs.nextElement()
                        if (!addr.isLoopbackAddress && addr is InetAddress) {
                            val sAddr = addr.hostAddress ?: continue
                            val isIPv4 = sAddr.indexOf(':') < 0
                            if (isIPv4) {
                                return sAddr
                            }
                        }
                    }
                }
            }
        } catch (ex: Exception) {
            Log.e("Network", "Error getting IP address: ${ex.message}")
        }
        return null
    }
    
    // Get cellular information
    private fun getCellularInfo(): Map<String, Any> {
        val telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        
        val carrierName = telephonyManager.networkOperatorName ?: "Unknown"
        
        return mapOf<String, Any>(
            "carrierName" to carrierName,
            "cellularSignal" to 0,
            "simState" to telephonyManager.simState,
            "networkOperator" to (telephonyManager.networkOperator ?: "Unknown"),
            "phoneType" to telephonyManager.phoneType,
            "networkCountry" to (telephonyManager.networkCountryIso ?: "Unknown")
        )
    }
    
    // Get sensor data - NOW RETURNS REAL DATA
    private fun getSensorData(): Map<String, Any> {
        return mapOf<String, Any>(
            "stepCount" to totalSteps,
            "stepDetectorCount" to stepDetectorCount,
            "detectedActivity" to lastActivity,
            "lastUpdate" to lastUpdateTime,
            "hasStepCounter" to (stepCounterSensor != null),
            "hasStepDetector" to (stepDetectorSensor != null),
            "timestamp" to Date().toString()
        )
    }
}