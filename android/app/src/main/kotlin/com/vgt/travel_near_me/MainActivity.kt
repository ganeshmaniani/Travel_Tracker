// MainActivity.kt
package com.vgt.travel_near_me

import android.Manifest
import android.annotation.TargetApi
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.widget.Toast
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.vgt.travel_near_me.helper.SharedHelper
import com.vgt.travel_near_me.service.LocationService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.vgt.travel_near_me/service"
    private var sharedHelper: SharedHelper? = SharedHelper()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler(::onMethodCall)
    }

    private fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val argument: Map<String, Any>? = call.arguments()!!

        when (call.method) {
            "run" -> {
                println("Service Start")
                if (checkPermissions()) {
                    startService()
                    val startLat = argument?.get("start_lat") as String
                    val startLong = argument["start_long"] as String
                    val endLat = argument["end_lat"] as String
                    val endLong = argument["end_long"] as String
                    sharedHelper?.setStartLatLong(this, startLat, startLong)
                    sharedHelper?.setEndLatLong(this, endLat, endLong)
                    result.success("Success")
                    showToast(this, "Have a nice day")
                } else {
//                    requestPermissions()
                }
            }

            "stop" -> {
                println("Service Stop")
                stopService()
                result.success("Success")
                showToast(this, "Good to Go...!")
            }

            else -> result.notImplemented()
        }
    }

    private fun startService() {
        val serviceIntent = Intent(this, LocationService::class.java)
        serviceIntent.putExtra("inputExtra", "Location Capture Service")
        ContextCompat.startForegroundService(this, serviceIntent)
    }

    private fun stopService() {
        val serviceIntent = Intent(this, LocationService::class.java)
        stopService(serviceIntent)
    }

    private fun showToast(context: Context, message: String) {
        Toast.makeText(context, message, Toast.LENGTH_SHORT).show()
    }

    @TargetApi(Build.VERSION_CODES.TIRAMISU)
    private fun checkPermissions(): Boolean {
        return ActivityCompat.checkSelfPermission(
            this,
            Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED &&
                ActivityCompat.checkSelfPermission(
                    this,
                    Manifest.permission.ACCESS_COARSE_LOCATION
                ) == PackageManager.PERMISSION_GRANTED &&
                ActivityCompat.checkSelfPermission(
                    this,
                    Manifest.permission.ACCESS_BACKGROUND_LOCATION
                ) == PackageManager.PERMISSION_GRANTED &&
                ActivityCompat.checkSelfPermission(
                    this,
                    Manifest.permission.POST_NOTIFICATIONS
                ) == PackageManager.PERMISSION_GRANTED
    }

    @TargetApi(Build.VERSION_CODES.Q)
    private fun requestPermissions() {
        ActivityCompat.requestPermissions(
            this,
            arrayOf(
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.ACCESS_COARSE_LOCATION,
                Manifest.permission.ACCESS_BACKGROUND_LOCATION,
                Manifest.permission.POST_NOTIFICATIONS
            ),
            1
        )
    }
}
