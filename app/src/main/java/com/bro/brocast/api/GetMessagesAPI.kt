package com.bro.brocast.api

import android.content.Context
import android.widget.Toast
import com.beust.klaxon.JsonArray
import com.beust.klaxon.JsonObject
import com.beust.klaxon.Parser
import com.bro.brocast.adapters.MessagesAdapter
import com.bro.brocast.objects.Message
import okhttp3.ResponseBody
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

object GetMessagesAPI {

    lateinit var messagesAdapter: MessagesAdapter

    fun getMessages(broName: String, brosBro: String, context: Context) {
        BroCastAPI
            .service
            .getMessages(broName, brosBro, 0)
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
                                val messageList = json.get("message_list") as JsonArray<*>
                                messagesAdapter.clearmessages()
                                for (message in messageList) {
                                    val m = message as JsonObject
                                    val sender = m.get("sender") as Boolean
                                    val body = m.get("body") as String
                                    messagesAdapter.appendMessage(Message(sender, body))
                                }
                                messagesAdapter.notifyDataSetChanged()
                            }
                        }
                    }
                }
            })
    }
}