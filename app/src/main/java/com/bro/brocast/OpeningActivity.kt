package com.bro.brocast

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.beust.klaxon.JsonObject
import com.beust.klaxon.Parser
import com.bro.brocast.api.BroCastAPI
import com.bro.brocast.api.LoginAPI
import okhttp3.ResponseBody
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class OpeningActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.opening_screen)

        val sharedPreferences = getSharedPreferences(getString(R.string.preference_file_key), Context.MODE_PRIVATE)
        val broName: String = sharedPreferences.getString("BRONAME", "")!!
        val password: String = sharedPreferences.getString("PASSWORD", "")!!.
            replace(":broCastPasswordEnd", "")

        // If a broName and password are stored in the shared preferences than the bro has
        // previously made or logged in with an account for which he knows the login information
        // We automatically log in if this is the case.
        if (broName != "" && password != "") {
            println("Welcome back br $broName we will start the autmoatic login")
            LoginAPI.loginBro(broName, password, applicationContext, null, this@OpeningActivity)
        } else {
            startActivity(
                Intent(
                    this@OpeningActivity, MainActivity::class.java)
            )
        }
    }

}