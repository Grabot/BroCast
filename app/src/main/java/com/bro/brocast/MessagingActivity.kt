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
    private lateinit var messagesAdapter: MessagesAdapter

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
        messagesAdapter = MessagesAdapter(messages)
        broMessages.adapter = messagesAdapter

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
        BroCastAPI
            .service
            .getMessages(broName, brosBro)
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
                            // TODO @Sander: find out a way to send jsonObject as post call as well as get call.
                            val json: com.beust.klaxon.JsonObject =
                                parser.parse(stringBuilder) as com.beust.klaxon.JsonObject
                            val result = json.get("result")
                            if (result!! == true) {
                                val messageList = json.get("message_list") as JsonArray<*>
                                // TODO @Skools: add a check that will exclude the logged in bro. We will do this client side instead of server side to not do too much on the server side
                                messagesAdapter.clearmessages()
                                for (message in messageList) {
                                    val m = message as com.beust.klaxon.JsonObject
                                    val sender = m.get("sender") as Boolean
                                    val body = m.get("body") as String
                                    messagesAdapter.appendMessage(Message(sender, body))
                                }
                                messagesAdapter!!.notifyDataSetChanged()
                            }
                        }
                    }
                }
            })
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
