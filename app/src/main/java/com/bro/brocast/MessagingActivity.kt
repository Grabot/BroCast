package com.bro.brocast

import android.os.Build
import android.os.Bundle
import android.text.InputType
import android.view.View
import android.view.View.MeasureSpec
import android.widget.EditText
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentPagerAdapter
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.viewpager.widget.PagerTabStrip
import androidx.viewpager.widget.ViewPager
import com.beust.klaxon.JsonObject
import com.bro.brocast.adapters.MessagesAdapter
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

//        val keyboard = adapterViewPager.getKeyboard()
//        val ic = broTextField!!.onCreateInputConnection(EditorInfo())
//        keyboard.setInputConnection(ic)

        val vpPager = findViewById(R.id.vpPager) as MyViewPager
        val adapterViewPager = MyPagerAdapter(supportFragmentManager)
        adapterViewPager.broTextField = broTextField

        vpPager.adapter = adapterViewPager
        vpPager.addOnPageChangeListener(object : ViewPager.OnPageChangeListener {

            // This method will be invoked when a new page becomes selected.
            override fun onPageSelected(position: Int) {
                Toast.makeText(
                    this@MessagingActivity,
                    "Selected page position: $position", Toast.LENGTH_SHORT
                ).show()
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
//            R.id.broMessageField -> {
//                // We want to make the keyboard visible if it isn't yet.
//                if (keyboard.visibility != View.VISIBLE) {
//                    keyboard.visibility = View.VISIBLE
//                }
//            }
        }
    }

    fun loadMessages() {
        GetMessagesAPI.getMessages(broName!!, bromotion!!, brosBro!!, brosBromotion!!, page, applicationContext)
    }

//    override fun onBackPressed() {
//        // We want to make the keyboard visible if it isn't yet.
//        if (keyboard.visibility == View.VISIBLE) {
//            keyboard.visibility = View.GONE
//        } else {
//            // Here the keyboard is invisible and we go back to the BroCast Home screen
//            val successIntent = Intent(this@MessagingActivity, BroCastHome::class.java)
//            successIntent.putExtra("broName", broName)
//            successIntent.putExtra("bromotion", bromotion)
//            startActivity(successIntent)
//        }
//    }

    class MyPagerAdapter(fragmentManager: FragmentManager) : FragmentPagerAdapter(fragmentManager) {

        var broTextField: EditText? = null

        // Returns total number of pages
        override fun getCount(): Int {
            return NUM_ITEMS
        }

        // Returns the fragment to display for that page
        override fun getItem(position: Int): Fragment {
            when (position) {
                0  -> {
                    var first = FirstFragment.newInstance(0, "Page # 1", broTextField!!)
                    return first
                }
                1 -> {
                    var second = FirstFragment.newInstance(1, "Page # 2", broTextField!!)
                    return second
                }
                2 -> {
                    var third = FirstFragment.newInstance(2, "Page # 3", broTextField!!)
                    return third
                }
                else -> {
                    var first = FirstFragment.newInstance(0, "Page # 1", broTextField!!)
                    return first
                }
            }
        }

        // Returns the page title for the top indicator
        override fun getPageTitle(position: Int): CharSequence? {
            return "Page $position"
        }

        companion object {
            private val NUM_ITEMS = 3
        }
    }
}
