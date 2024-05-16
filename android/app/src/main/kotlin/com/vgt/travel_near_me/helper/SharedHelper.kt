package com.vgt.travel_near_me.helper

import android.content.Context
import android.content.SharedPreferences

class SharedHelper {
    private var sharedPreferences: SharedPreferences? = null
    private var editor: SharedPreferences.Editor? = null
 

    fun getToken(context: Context, key: String?): String? {
        sharedPreferences = context.getSharedPreferences("Cache", Context.MODE_PRIVATE)
        return sharedPreferences!!.getString(key, "")
    }


    fun setToken(context: Context, key: String?, value: String) {
        sharedPreferences = context.getSharedPreferences("Cache", Context.MODE_PRIVATE)
        editor = sharedPreferences!!.edit()
        editor?.putString(key, value)
        editor?.commit()
    }
    
    fun setStartLatLong(context: Context,lat: String,long:String) {
        sharedPreferences = context.getSharedPreferences("Cache", Context.MODE_PRIVATE)
        editor = sharedPreferences!!.edit()
        editor?.putString("start_lat", lat)
        editor?.putString("start_long", long)
        editor?.commit()
    }
    
    fun setEndLatLong(context: Context,lat: String,long:String) {
        sharedPreferences = context.getSharedPreferences("Cache", Context.MODE_PRIVATE)
        editor = sharedPreferences!!.edit()
        editor?.putString("end_lat", lat)
        editor?.putString("end_long", long)
        editor?.commit()
    }
    fun getLatLong(context: Context, key: String?): String? {
        sharedPreferences = context.getSharedPreferences("Cache", Context.MODE_PRIVATE)
        return sharedPreferences!!.getString(key,"" )
    }
     
}