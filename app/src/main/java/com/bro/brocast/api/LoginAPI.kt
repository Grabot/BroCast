package com.bro.brocast.api

import android.content.Context
import android.content.Intent
import android.widget.Toast
import com.beust.klaxon.JsonObject
import com.beust.klaxon.Parser
import com.bro.brocast.BroCastHome
import com.bro.brocast.LoginActivity
import com.bro.brocast.R
import okhttp3.ResponseBody
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response


object LoginAPI {

    fun loginBro(
        broName: String,
        password: String,
        context: Context,
        activity: LoginActivity
    ) {
        BroCastAPI
            .service
            .loginBro(broName, password)
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
                    editor.putString("PASSWORD", "")
                    editor.apply()
                }
                override fun onResponse(
                    call: Call<ResponseBody>,
                    response: Response<ResponseBody>
                ) {
//                    pressedLogin = false
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
                                editor.putString("BRONAME", broName)
                                // There seems to be an issue with storing password because of newline characters.
                                // We concatenate it with an ending that we will remove when we load the password
                                editor.putString("PASSWORD", "$password:broCastPasswordEnd")
                                editor.apply()
                                val successIntent = Intent(activity, BroCastHome::class.java).apply {
                                    putExtra("broName", broName)
                                }
                                // Because this is called outside of the activity you need to indicate that it is ok to start a new activity
                                successIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                context.startActivity(successIntent)
                            } else {
                                val reason: String = json.get("reason").toString()
                                Toast.makeText(
                                    context,
                                    reason,
                                    Toast.LENGTH_SHORT
                                ).show()
                            }
                        }

                    } else {
                        TODO("Sander: the bro will come back to the login screen, show which error occured")
                    }
                }
            })
    }
}