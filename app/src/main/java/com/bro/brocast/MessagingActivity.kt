package com.bro.brocast

import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.bro.brocast.objects.Message
import com.bro.brocast.objects.MessagesAdapter
import kotlinx.android.synthetic.main.activity_messaging.*

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

        addMessages()

        // Creates a vertical Layout Manager
        broMessageList = findViewById(R.id.broMessages)

        val layoutMgr = LinearLayoutManager(this)
        layoutMgr.stackFromEnd = true
        broMessageList.layoutManager = layoutMgr

        println("animals " + messages.size)
        messagesAdapter = MessagesAdapter(messages)
        broMessages.adapter = messagesAdapter

        sendBroMessage.setOnClickListener(clickButtonListener)

        broMessageList.scrollToPosition(messagesAdapter.itemCount - 1)

    }

    private val clickButtonListener = View.OnClickListener { view ->
        when (view.getId()) {
            R.id.sendBroMessage -> {
                val potentialBro = broMessageField.text.toString()
            }
        }
    }

    private fun addMessages() {
        messages.add(Message(true, "hello Bro"))
        messages.add(Message(true, "how are you doing?"))
        messages.add(Message(false, "Heey Bro, nice to hear from you!"))
        messages.add(Message(false, "I'm terrible"))
        messages.add(Message(false, "I cannot express my emotions properly via chat apps"))
        messages.add(Message(false, "I'm crying right now and you can't tell"))
        messages.add(Message(true, "I was thinking the same the other day bro"))
        messages.add(Message(true, "If only there was some sort of app that let's you chat with your emotions, rather than just text"))
        messages.add(Message(false, "I think that that is impossible"))
        messages.add(Message(false, "But I will continue to hope"))
        messages.add(Message(true, "Me to Bro"))
        messages.add(Message(true, "Smiley face"))
    }

}
