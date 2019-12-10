package com.bro.brocast

import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.beust.klaxon.JsonObject
import com.bro.brocast.adapters.MessagesAdapter
import com.bro.brocast.api.GetMessagesAPI
import com.bro.brocast.api.SendMessagesAPI
import com.bro.brocast.objects.Message
import kotlinx.android.synthetic.main.activity_messaging.*


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

    fun loadMessages() {
        GetMessagesAPI.getMessages(broName, brosBro, applicationContext)
    }

    private val clickButtonListener = View.OnClickListener { view ->
        when (view.getId()) {
            R.id.sendBroMessage -> {
                val message = broMessageField.text.toString()
                println("bro $broName wants to send a message to $brosBro. The message is $message")

                val jsonObj = JsonObject()
                jsonObj["message"] = message

                SendMessagesAPI.sendMessages(broName, brosBro, jsonObj, applicationContext, this@MessagingActivity)
            }
        }
    }

}
