package com.bro.brocast.api

import android.content.Context
import android.content.Intent
import android.widget.Toast
import com.beust.klaxon.JsonObject
import com.beust.klaxon.Parser
import com.bro.brocast.BroCastHome
import com.bro.brocast.FindBroActivity
import com.bro.brocast.MainActivity
import okhttp3.ResponseBody
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

object AddBroAPI {

    fun addBro(broName: String, bromotion: String, otherBroName: String, otherBromotion: String, context: Context, findBroActivity: FindBroActivity) {
        BroCastAPI
            .service
            .addBro(broName, bromotion, otherBroName, otherBromotion)
            .enqueue(object : Callback<ResponseBody> {
                override fun onFailure(call: Call<ResponseBody>, t: Throwable) {
                    println("An exception occured with the GET call:: " + t.message)
                    // The BroCast Backend server is not running
                    Toast.makeText(
                        context,
                        "The BroCast server is not responding. " +
                                "We appologize for the inconvenience, please try again later",
                        Toast.LENGTH_SHORT
                    ).show()
                }
                override fun onResponse(
                    call: Call<ResponseBody>,
                    response: Response<ResponseBody>
                ) {
                    if (response.isSuccessful) {
                        val msg = response.body()?.string()
                        if (msg != null) {
                            val parser: Parser = Parser.default()
                            val stringBuilder: StringBuilder = StringBuilder(msg)
                            val json: JsonObject = parser.parse(stringBuilder) as JsonObject
                            val result = json.get("result")
                            if (result!! == true) {
                                println("bro $broName wants to add $otherBroName to his brolist")
                                Toast.makeText(
                                    context,
                                    "bro $broName and bro $otherBroName are now bros",
                                    Toast.LENGTH_SHORT
                                ).show()
                                val successIntent = Intent(findBroActivity, BroCastHome::class.java)
                                successIntent.putExtra("broName", broName)
                                successIntent.putExtra("bromotion", bromotion)
                                // Because this is called outside of the activity you need to indicate that it is ok to start a new activity
                                successIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                context.startActivity(successIntent)
                            } else {
                                Toast.makeText(
                                    context,
                                    "Something went wrong " +
                                            "We appologize for the inconvenience, please try again later",
                                    Toast.LENGTH_SHORT
                                ).show()
                            }
                        }
                    } else {
                        // The BroCast Backend server gave an error
                        Toast.makeText(
                            context,
                            "The BroCast server is down right. " +
                                    "We appologize for the inconvenience, please try again later",
                            Toast.LENGTH_SHORT
                        ).show()
                    }
                }
            })
    }
}
