package com.bro.brocast.api

import android.content.Context
import android.content.Intent
import android.widget.Toast
import com.beust.klaxon.JsonObject
import com.beust.klaxon.Parser
import com.bro.brocast.*
import okhttp3.ResponseBody
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response


object LoginAPI {

    var pressedLogin: Boolean = false

    fun loginBro(
        broName: String,
        bromotion: String,
        password: String,
        context: Context,
        loginActivity: LoginActivity?,
        openingActivity: OpeningActivity?
    ) {
        // TODO @Skools: This can be called from 2 separate activities, I didn't know how to
        //  fix it neatly, so I pass both arguments with them being nullable. The one that
        //  isn't null should be used. Find a way to solve this better
        BroCastAPI
            .service
            .loginBro(broName, bromotion, password)
            .enqueue(object : Callback<ResponseBody> {
                override fun onFailure(call: Call<ResponseBody>, t: Throwable) {
                    // The BroCast Backend server is not running
                    Toast.makeText(
                        context,
                        "The BroCast server is not responding. " +
                                "We appologize for the inconvenience, please try again later",
                        Toast.LENGTH_SHORT
                    ).show()
                    // We will empty the stored login when this fails.
                    val sharedPreferences = context.getSharedPreferences(
                        context.getString(R.string.preference_file_key),
                        Context.MODE_PRIVATE
                    )
                    val editor = sharedPreferences.edit()
                    // The bro is logged out so we will empty the stored bro data
                    // and return to the home screen
                    editor.putString("BRONAME", "")
                    editor.putString("BROMOTION", "")
                    editor.putString("PASSWORD", "")
                    editor.apply()
                    pressedLogin = false
                    failedLogin(openingActivity, broName, context)
                }
                override fun onResponse(
                    call: Call<ResponseBody>,
                    response: Response<ResponseBody>
                ) {
                    pressedLogin = false
                    if (response.isSuccessful) {
                        val msg = response.body()?.string()
                        if (msg != null) {
                            val parser: Parser = Parser.default()
                            val stringBuilder: StringBuilder = StringBuilder(msg)
                            val json: JsonObject = parser.parse(stringBuilder) as JsonObject
                            val result = json.get("result")
                            if (result!! == true) {
                                Toast.makeText(
                                    context,
                                    "you just logged in!",
                                    Toast.LENGTH_SHORT
                                ).show()
                                val sharedPreferences = context.getSharedPreferences(
                                    context.getString(R.string.preference_file_key),
                                    Context.MODE_PRIVATE
                                )
                                val editor = sharedPreferences.edit()
                                // We check if this is a different phone. If it is we change the token
                                val token: String = sharedPreferences.getString("REGISTRATION_TOKEN", "")!!
                                val current_token = json.get("token")
                                if (token != current_token) {
                                    UpdateTokenAPI.updateToken(broName, bromotion, token, context)
                                }
                                editor.putString("BRONAME", broName)
                                editor.putString("BROMOTION", bromotion)
                                // There seems to be an issue with storing password because of newline characters.
                                // We concatenate it with an ending that we will remove when we load the password
                                editor.putString("PASSWORD", "$password:broCastPasswordEnd")
                                editor.apply()
                                successfulLogin(loginActivity, openingActivity, broName, bromotion, context)
                            } else {
                                val reason: String = json.get("reason").toString()
                                Toast.makeText(
                                    context,
                                    reason,
                                    Toast.LENGTH_SHORT
                                ).show()
                                failedLogin(openingActivity, broName, context)
                            }
                        }
                    } else {
                        Toast.makeText(
                            context,
                            "The BroCast server is not responding. " +
                                    "We appologize for the inconvenience, please try again later",
                            Toast.LENGTH_SHORT
                        ).show()
                        failedLogin(openingActivity, broName, context)
                    }
                }
            })
    }

    fun successfulLogin(loginActivity: LoginActivity?, openingActivity: OpeningActivity?, broName: String, bromotion: String, context: Context) {
        val successIntent = if (loginActivity != null) {
            Intent(loginActivity, BroCastHome::class.java)
        } else {
            Intent(openingActivity, BroCastHome::class.java)
        }
        successIntent.putExtra("broName", broName)
        successIntent.putExtra("bromotion", bromotion)
        // Because this is called outside of the activity you need to indicate that it is ok to start a new activity
        successIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(successIntent)
    }

    fun failedLogin(openingActivity: OpeningActivity?, broName: String, context: Context) {
        if (openingActivity != null) {
            val successIntent = Intent(openingActivity, MainActivity::class.java)
            successIntent.putExtra("broName", broName)
            // Because this is called outside of the activity you need to indicate that it is ok to start a new activity
            successIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(successIntent)
        }
    }
}