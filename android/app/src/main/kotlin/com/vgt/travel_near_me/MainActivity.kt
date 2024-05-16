package com.vgt.travel_near_me

import android.content.Context
import android.content.Intent
import android.widget.Toast
import androidx.core.content.ContextCompat
import com.vgt.travel_near_me.helper.SharedHelper
import com.vgt.travel_near_me.service.LocationService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.vgt.travel_near_me/service"
 
    private var sharedHelper: SharedHelper? = SharedHelper()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler(::onMethodCall) 
    }

    private fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val argument: Map<String, Any>? = call.arguments()!!

        try {
            when (call.method) {
                "run" -> {  
                    println("Service Start")
                    startService()
                    val startLat = argument?.get("start_lat") as String
                    val startLong = argument["start_long"] as String
                    val endLat = argument["end_lat"] as String
                    val endLong = argument["end_long"] as String
                    sharedHelper?.setStartLatLong(context,startLat,startLong)
                    sharedHelper?.setEndLatLong(context,endLat,endLong)
                    result.success("Success")
                    showToast(context, "Have a nice day")
                }
 
                "stop" -> {
                    println("Service Stop")
                    stopService()
                    result.success("Success")
                    showToast(context, "Good to Go...!")
                }

                else -> result.notImplemented()
            }
        } catch (_: Exception) {

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

}
