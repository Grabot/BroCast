package com.bro.brocast.api

import android.content.Context
import android.widget.Toast
import com.beust.klaxon.JsonObject
import com.beust.klaxon.Parser
import com.bro.brocast.MessagingActivity
import okhttp3.ResponseBody
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

object SendMessagesAPI {

    fun sendMessages(broName: String, brosBro: String, jsonObj: JsonObject, context: Context, messagingActivity: MessagingActivity) {
        BroCastAPI
            .service
            .sendMessage(broName, brosBro, 0, jsonObj)
            .enqueue(object : Callback<ResponseBody> {
                override fun onFailure(call: Call<ResponseBody>, t: Throwable) {
                    Toast.makeText(
                        context,
                        "The BroCast server is not responding. " +
                                "We appologize for the inconvenience, please try again later",
                        Toast.LENGTH_SHORT
                    ).show()
                }
                override fun onResponse(call: Call<ResponseBody>, response: Response<ResponseBody>) {
                    if (response.isSuccessful) {
                        val msg = response.body()?.string()
                        if (msg != null) {
                            val parser: Parser = Parser.default()
                            val stringBuilder: StringBuilder = StringBuilder(msg)
                            val json: JsonObject =
                                parser.parse(stringBuilder) as JsonObject
                            val result = json.get("result")
                            if (result!! == true) {
                                // When it was successful we only want to re-load the messages.
                                messagingActivity.loadMessages()
                            } else {
                                Toast.makeText(
                                    context,
                                    "Something went wrong " +
                                            "We appologize for the inconvenience, please try again later",
                                    Toast.LENGTH_SHORT
                                ).show()
                            }
                        }
                    }
                }
            })
    }
}
