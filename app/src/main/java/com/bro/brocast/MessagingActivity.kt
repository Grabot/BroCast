package com.bro.brocast

import android.os.Build
import android.os.Bundle
import android.text.InputType
import android.view.View
import android.widget.EditText
import android.widget.Toast
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

    var vpPager: BroViewPager? = null
    var mSlidingTabLayout: SlidingTabLayout? = null

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

        vpPager = findViewById(R.id.vpPager) as BroViewPager
        val adapterViewPager = PagerBrodapter(supportFragmentManager)
        adapterViewPager.broTextField = broTextField

        // TODO @Skools: We set the pagerBrodapter twice. See if you can fix this.
        vpPager!!.adapter = adapterViewPager
        vpPager!!.pagerBrodapter = adapterViewPager

        mSlidingTabLayout = findViewById(R.id.sliding_tabs) as SlidingTabLayout

        val iconArray = arrayOf(
            R.drawable.tab_smile,
            R.drawable.tab_animals,
            R.drawable.tab_food,
            R.drawable.tab_sports,
            R.drawable.tab_travel,
            R.drawable.tab_objects,
            R.drawable.tab_symbol,
            R.drawable.tab_flags
        )
        mSlidingTabLayout!!.setTabIcons(iconArray)

        mSlidingTabLayout!!.setDistributeEvenly(true)
        mSlidingTabLayout!!.setViewPager(vpPager)


        vpPager!!.addOnPageChangeListener(object : ViewPager.OnPageChangeListener {

            // This method will be invoked when a new page becomes selected.
            override fun onPageSelected(position: Int) {
                // The page which is currently active
            }

            // This method will be invoked when the current page is scrolled
            override fun onPageScrolled(
                position: Int,
                positionOffset: Float,
                positionOffsetPixels: Int
            ) {
                // Code goes here
            }

            // Called when the scroll state changes:
            // SCROLL_STATE_IDLE, SCROLL_STATE_DRAGGING, SCROLL_STATE_SETTLING
            override fun onPageScrollStateChanged(state: Int) {
                // Code goes here
            }
        })

        vpPager!!.visibility = View.GONE
        mSlidingTabLayout!!.visibility = View.GONE
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
                if (vpPager!!.visibility != View.VISIBLE) {
                    vpPager!!.visibility = View.VISIBLE
                    mSlidingTabLayout!!.visibility = View.VISIBLE
                }
            }
        }
    }

    fun loadMessages() {
        GetMessagesAPI.getMessages(broName!!, bromotion!!, brosBro!!, brosBromotion!!, page, applicationContext)
    }

    override fun onBackPressed() {
        // We want to make the keyboard invisible if it isn't yet.
        if (vpPager!!.visibility == View.VISIBLE) {
            vpPager!!.visibility = View.GONE
            mSlidingTabLayout!!.visibility = View.GONE
        } else {
            super.onBackPressed()
        }
    }
}
