package com.bro.brocast.api

import android.content.Context
import android.widget.Toast
import com.beust.klaxon.JsonObject
import com.beust.klaxon.Parser
import okhttp3.ResponseBody
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

object UpdateTokenAPI {

    fun updateToken(bro: String, token: String, context: Context) {
        BroCastAPI
            .service
            .updateToken(bro, token)
            .enqueue(object : Callback<ResponseBody> {
                override fun onFailure(call: Call<ResponseBody>, t: Throwable) {
                    // The BroCast Backend server is not running
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
                            val json: JsonObject = parser.parse(stringBuilder) as JsonObject
                            val result = json.get("result")
                            if (result!! == true) {

                            } else {
                                Toast.makeText(
                                    context,
                                    "The BroCast server is not responding. " +
                                            "We appologize for the inconvenience, please try again later",
                                    Toast.LENGTH_SHORT
                                ).show()
                            }
                        }
                    } else {
                        TODO("something went wrong?")
                    }
                }
            })
    }

}
