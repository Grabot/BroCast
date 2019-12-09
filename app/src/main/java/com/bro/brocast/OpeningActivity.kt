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
            automaticLogin(broName, password)
        } else {
            startActivity(
                Intent(
                    this@OpeningActivity, MainActivity::class.java)
            )
        }
    }

    fun automaticLogin(broName: String, password: String) {
        LoginAPI.loginBro(broName, password, applicationContext, null, this@OpeningActivity)
//        BroCastAPI
//            .service
//            .loginBro(broName, password)
//            .enqueue(object : Callback<ResponseBody> {
//                override fun onFailure(call: Call<ResponseBody>, t: Throwable) {
//                    // The server is not responding. show an error and display the main screen
//                    Toast.makeText(
//                        applicationContext,
//                        "The BroCast server is not responding. " +
//                                "We appologize for the inconvenience, please try again later",
//                        Toast.LENGTH_SHORT
//                    ).show()
//                    val sharedPreferences = getSharedPreferences(getString(R.string.preference_file_key), Context.MODE_PRIVATE)
//                    val editor = sharedPreferences.edit()
//                    // The bro is logged out so we will empty the stored bro data
//                    // and return to the home screen
//                    editor.putString("BRONAME", "")
//                    editor.putString("PASSWORD", "")
//                    editor.apply()
//                    startActivity(
//                        Intent(
//                            this@OpeningActivity, MainActivity::class.java)
//                    )
//                }
//                override fun onResponse(call: Call<ResponseBody>, response: Response<ResponseBody>) {
//                    if (response.isSuccessful) {
//                        val msg = response.body()?.string()
//                        if (msg != null) {
//                            val parser: Parser = Parser.default()
//                            val stringBuilder: StringBuilder = StringBuilder(msg)
//                            val json: JsonObject = parser.parse(stringBuilder) as JsonObject
//                            val result = json.get("result")
//                            if (result!! == true) {
//                                Toast.makeText(
//                                    applicationContext,
//                                    "you just logged in!",
//                                    Toast.LENGTH_SHORT
//                                ).show()
//                                val successIntent = Intent(this@OpeningActivity, BroCastHome::class.java).apply {
//                                    putExtra("broName", broName)
//                                }
//                                val sharedPreferences = getSharedPreferences(getString(R.string.preference_file_key), Context.MODE_PRIVATE)
//                                val editor = sharedPreferences.edit()
//                                editor.putString("BRONAME", broName)
//                                editor.putString("PASSWORD", "$password:broCastPasswordEnd")
//                                editor.apply()
//                                startActivity(successIntent)
//                            } else {
//                                // The login failed. We show the main screen and empty the preferences.
//                                val sharedPreferences = getSharedPreferences(getString(R.string.preference_file_key), Context.MODE_PRIVATE)
//                                val editor = sharedPreferences.edit()
//                                // The bro is logged out so we will empty the stored bro data
//                                // and return to the home screen
//                                editor.putString("BRONAME", "")
//                                editor.putString("PASSWORD", "")
//                                editor.apply()
//                                startActivity(
//                                    Intent(
//                                        this@OpeningActivity, MainActivity::class.java)
//                                )
//                            }
//                        } else {
//                            // There was an empty message from the server so we will show the main screen
//                            TODO("implement action if it arrives here")
//                        }
//                    } else {
//                        Toast.makeText(
//                            applicationContext,
//                            "The server is down, we're sorry for the inconvenience. Please try again later!",
//                            Toast.LENGTH_SHORT
//                        ).show()
//                        startActivity(
//                            Intent(
//                                this@OpeningActivity, MainActivity::class.java)
//                        )
//                    }
//                }
//            })
    }
}