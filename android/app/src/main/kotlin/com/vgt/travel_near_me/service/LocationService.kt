package com.vgt.travel_near_me.service

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service 
import android.content.Intent
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Build
import android.os.Handler
import android.os.IBinder
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import com.vgt.travel_near_me.MainActivity
import com.vgt.travel_near_me.R

import com.vgt.travel_near_me.helper.SharedHelper
import com.vgt.travel_near_me.utils.LocationUtils

class LocationService : Service(), LocationListener {

    private var locationManager: LocationManager? = null

    private var sharedHelper: SharedHelper? = null

    private var gpsLocationListener: LocationListener? = null

    override fun onCreate() {
        super.onCreate()
        locationManager = getSystemService(LOCATION_SERVICE) as LocationManager
        gpsLocationListener = LocationService()
        sharedHelper = SharedHelper()
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            return
        }
        locationManager?.requestLocationUpdates(LocationManager.GPS_PROVIDER, 10 * 1000L, 0f, gpsLocationListener as LocationService)

    }

    override fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
        val input = intent.getStringExtra("inputExtra")

        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(this,
                0, notificationIntent, PendingIntent.FLAG_IMMUTABLE)

        val notification: Notification = NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID)
                .setContentTitle("Location Service")
                .setContentText(input)
                .setSmallIcon(R.drawable.notification_icon_push)
                .setContentIntent(pendingIntent)
                .build()
        startForeground(NOTIFICATION_ID, notification)


        val handler = Handler()
        // val delay = 1200000 // 20 min
        val delay = 30000   // 0.5 min
        handler.postDelayed(object : Runnable {
            override fun run() {
                getLocation()
                handler.postDelayed(this, delay.toLong())
            }
        }, delay.toLong())

        return START_STICKY
    }

    private fun getLocation( ) {
        if (ActivityCompat.checkSelfPermission(
                        applicationContext, Manifest.permission.ACCESS_FINE_LOCATION
                ) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(
                        applicationContext, Manifest.permission.ACCESS_COARSE_LOCATION
                ) != PackageManager.PERMISSION_GRANTED
        ) {
            // Handle the case when location permissions are not granted
        }else {
            val locationGPS: Location? =
                    locationManager?.getLastKnownLocation(LocationManager.GPS_PROVIDER)
            if (locationGPS != null) {
                val lat1 = locationGPS.latitude
                val long1 = locationGPS.longitude
                println("Lat1: $lat1, Long1: $long1")
                val lat2 = sharedHelper?.getLatLong(applicationContext,"end_lat")!!.toDouble()
                val long2 =  sharedHelper?.getLatLong(applicationContext,"end_long")!!.toDouble()
                println("Lat2: $lat2, Long2: $long2")

                val distance = LocationUtils.calculateDistance(lat1, long1, lat2, long2)
                println("Distance between Two Location: $distance km")
                if(distance.toInt() < 3 ){
                    createNotificationChannel();
                    println("Lat2: $distance")
                }
            } else {
                // Handle the case when the location is not available
            }
        }
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                    NOTIFICATION_CHANNEL_ID,
                    "Foreground Service Channel",
                    NotificationManager.IMPORTANCE_DEFAULT
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }

    override fun onLocationChanged(location: Location) {
        println("Location: $location")
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onDestroy() {
        super.onDestroy()
        gpsLocationListener?.let { locationManager?.removeUpdates(it) }
    }

    companion object {
        const val NOTIFICATION_CHANNEL_ID = "ForegroundServiceChannel"

        const val NOTIFICATION_ID = 1

    }
}