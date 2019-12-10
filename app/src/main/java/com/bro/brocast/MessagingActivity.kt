package com.bro.brocast

import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.beust.klaxon.JsonArray
import com.beust.klaxon.Parser
import com.bro.brocast.adapters.MessagesAdapter
import com.bro.brocast.api.BroCastAPI
import com.bro.brocast.api.GetMessagesAPI
import com.bro.brocast.objects.Message
import com.google.gson.JsonObject
import kotlinx.android.synthetic.main.activity_messaging.*
import okhttp3.ResponseBody
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response


class MessagingActivity: AppCompatActivity() {

    val messages: ArrayList<Message> = ArrayList()
    private lateinit var broMessageList: RecyclerView

    var broName: String = ""
    var brosBro: String = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_messaging)

        val intent = intent
        broName = intent.getStringExtra("broName")
        brosBro = intent.getStringExtra("brosBro")

        // Creates a vertical Layout Manager
        broMessageList = findViewById(R.id.broMessages)

        val layoutMgr = LinearLayoutManager(this)
        // TODO @Sander: fix this damn scroll thing. I've got no idea how it works
//        layoutMgr.scrollToPosition(0)
        broMessageList.layoutManager = layoutMgr

        println("animals " + messages.size)
        GetMessagesAPI.messagesAdapter = MessagesAdapter(messages)
        broMessages.adapter = GetMessagesAPI.messagesAdapter

        sendBroMessage.setOnClickListener(clickButtonListener)

        loadMessages()

        broMessageList.addOnScrollListener(object : RecyclerView.OnScrollListener() {
            override fun onScrollStateChanged(recyclerView: RecyclerView, newState: Int) {
                super.onScrollStateChanged(recyclerView, newState)
                if (!recyclerView.canScrollVertically(1)) {
                    println("bottom of the thingy")
                }
            }
        })
    }

    private fun loadMessages() {
        GetMessagesAPI.getMessages(broName, brosBro, applicationContext)
    }

    private val clickButtonListener = View.OnClickListener { view ->
        when (view.getId()) {
            R.id.sendBroMessage -> {
                val message = broMessageField.text.toString()
                println("bro $broName wants to send a message to $brosBro. The message is $message")

                val jsonObj = JsonObject()
                jsonObj.addProperty("message", message)

                BroCastAPI
                    .service
                    .sendMessage(broName, brosBro, jsonObj)
                    .enqueue(object : Callback<ResponseBody> {
                        override fun onFailure(call: Call<ResponseBody>, t: Throwable) {
                            Toast.makeText(
                                applicationContext,
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
                                    val json: com.beust.klaxon.JsonObject =
                                        parser.parse(stringBuilder) as com.beust.klaxon.JsonObject
                                    val result = json.get("result")
                                    if (result!! == true) {
                                        // When it was successful we only want to re-load the messages.
                                        loadMessages()
                                    } else {
                                        Toast.makeText(
                                            applicationContext,
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
    }

}
