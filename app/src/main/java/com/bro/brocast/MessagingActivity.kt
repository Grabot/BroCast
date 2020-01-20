package com.bro.brocast

import android.os.Build
import android.os.Bundle
import android.text.InputType
import android.view.View
import android.widget.EditText
import android.widget.RelativeLayout
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.viewpager.widget.ViewPager
import com.beust.klaxon.JsonObject
import com.bro.brocast.adapters.BroViewPager
import com.bro.brocast.adapters.MessagesAdapter
import com.bro.brocast.adapters.PagerBrodapter
import com.bro.brocast.adapters.SlidingTabLayout
import com.bro.brocast.api.GetMessagesAPI
import com.bro.brocast.api.SendMessagesAPI
import com.bro.brocast.keyboards.BroBoard
import com.bro.brocast.objects.Message
import kotlinx.android.synthetic.main.activity_messaging.*


class MessagingActivity: AppCompatActivity() {

    val messages: ArrayList<Message> = ArrayList()
    private lateinit var broMessageList: RecyclerView

    var broName: String? = ""
    var bromotion: String? = ""
    var brosBro: String? = ""
    var brosBromotion: String? = ""

    var broTextField: EditText? = null

    var broBoard: BroBoard? = null

    // A simple solution to determine how many message should be loaded.
    var page: Int = 1

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_messaging)

        val intent = intent
        broName = intent.getStringExtra("broName")
        bromotion = intent.getStringExtra("bromotion")
        brosBro = intent.getStringExtra("brosBro")
        brosBromotion = intent.getStringExtra("brosBromotion")

        // Creates a vertical Layout Manager
        broMessageList = findViewById(R.id.broMessages)
        broTextField = findViewById(R.id.broMessageField) as EditText

        broTextField!!.setOnClickListener(clickButtonListener)

        broTextField!!.setRawInputType(InputType.TYPE_CLASS_TEXT)
        broTextField!!.setTextIsSelectable(true)
        broTextField!!.setTextSize(20f)
        // TODO @Skools: set the minimum SDK to this version (LOLLIPOP).
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            broTextField!!.requestFocus()
            broTextField!!.showSoftInputOnFocus = false
        }

        val layoutMgr = LinearLayoutManager(this)
        broMessageList.layoutManager = layoutMgr

        GetMessagesAPI.messagesAdapter = MessagesAdapter(messages)
        broMessages.adapter = GetMessagesAPI.messagesAdapter

        sendBroMessage.setOnClickListener(clickButtonListener)

        loadMessages()

        broMessageList.addOnScrollListener(object : RecyclerView.OnScrollListener() {
            override fun onScrollStateChanged(recyclerView: RecyclerView, newState: Int) {
                super.onScrollStateChanged(recyclerView, newState)
                if (!recyclerView.canScrollVertically(1)) {
                    page = 2
                    loadMessages()
                }
            }
        })

        broBoard = BroBoard(this, supportFragmentManager, broTextField!!)
    }

    private val clickButtonListener = View.OnClickListener { view ->
        when (view.getId()) {
            R.id.sendBroMessage -> {
                val message = broTextField!!.text.toString()
                // Simple check to make sure the user cannot send an empty message.
                // This check is also done in the backend, but also here.
                if (message != "") {
                    println("bro $broName wants to send a message to $brosBro. The message is $message")

                    val jsonObj = JsonObject()
                    jsonObj["message"] = message

                    SendMessagesAPI.sendMessages(
                        broName!!,
                        bromotion!!,
                        brosBro!!,
                        brosBromotion!!,
                        jsonObj,
                        applicationContext,
                        this@MessagingActivity
                    )

                    // clear the input field
                    broTextField!!.text.clear()
                }
            }
            R.id.broMessageField -> {
                // We want to make the keyboard visible if it isn't yet.
                if (!broBoard!!.visible) {
                    broBoard!!.makeVisible()
                }
            }
        }
    }

    fun loadMessages() {
        GetMessagesAPI.getMessages(broName!!, bromotion!!, brosBro!!, brosBromotion!!, page, applicationContext)
    }

    override fun onBackPressed() {
        // We want to make the keyboard invisible if it isn't yet.
        if (broBoard!!.visible) {
            broBoard!!.makeInvisible()
        } else {
            super.onBackPressed()
        }
    }
}
