package com.bro.brocast.api

import android.content.Context
import android.content.Intent
import android.widget.Toast
import com.beust.klaxon.JsonObject
import com.beust.klaxon.Parser
import com.bro.brocast.BroCastHome
import com.bro.brocast.R
import com.bro.brocast.RegisterActivity
import okhttp3.ResponseBody
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

object RegisterAPI {

    var pressedRegister: Boolean = false

    fun registerBro(broName: String, password: String, registerActivity: RegisterActivity?, context: Context ) {
        BroCastAPI
            .service
            .registerBro(broName, password)
            .enqueue(object : Callback<ResponseBody> {
                override fun onFailure(call: Call<ResponseBody>, t: Throwable) {
                    pressedRegister = false
                    failedRegistration("The BroCast server is not responding. \n" +
                            "We appologize for the inconvenience, please try again later", context)

                }
                override fun onResponse(call: Call<ResponseBody>, response: Response<ResponseBody>) {
                    pressedRegister = false
                    if (response.isSuccessful) {
                        val msg = response.body()?.string()
                        if (msg != null) {
                            val parser: Parser = Parser.default()
                            val stringBuilder: StringBuilder = StringBuilder(msg)
                            val json: JsonObject = parser.parse(stringBuilder) as JsonObject
                            val result = json.get("result")
                            if (result!! == true) {
                                val sharedPreferences = context.getSharedPreferences(context.getString(R.string.preference_file_key), Context.MODE_PRIVATE)
                                val editor = sharedPreferences.edit()
                                editor.putString("BRONAME", broName)
                                // There seems to be an issue with storing password because of newline characters.
                                // We concatenate it with an ending that we will remove when we load the password
                                editor.putString("PASSWORD", "$password:broCastPasswordEnd")
                                editor.apply()
                                successfulRegistration(broName, json.get("message").toString(), registerActivity, context)
                            } else {
                                failedRegistration("That broName is already taken, please select another one", context)
                            }
                        } else {
                            failedRegistration("Something went wrong, we apologize for the inconvenience", context)
                        }
                    } else {
                        failedRegistration("Something went wrong, we apologize for the inconvenience", context)
                    }
                }
            })
    }

    fun successfulRegistration(broName: String, reason: String, registerActivity: RegisterActivity?, context: Context) {
        Toast.makeText(
            context,
            "you just logged in! \n$reason",
            Toast.LENGTH_SHORT
        ).show()
        val successIntent = Intent(registerActivity, BroCastHome::class.java)
        successIntent.putExtra("broName", broName)
        successIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(successIntent)
    }

    fun failedRegistration(reason: String, context: Context) {
        Toast.makeText(
            context,
            reason,
            Toast.LENGTH_SHORT
        ).show()
    }
}
