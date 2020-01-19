package com.bro.brocast

import android.content.Context
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.text.Editable
import android.text.InputType
import android.text.TextWatcher
import android.view.View
import android.view.inputmethod.InputMethodManager
import android.widget.EditText
import android.widget.ExpandableListView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.viewpager.widget.ViewPager
import com.bro.brocast.adapters.BroViewPager
import com.bro.brocast.adapters.ExpandableBrodapter
import com.bro.brocast.adapters.PagerBrodapter
import com.bro.brocast.adapters.SlidingTabLayout
import com.bro.brocast.api.AddBroAPI
import com.bro.brocast.api.FindBroAPI
import kotlinx.android.synthetic.main.activity_find_bros.*


class FindBroActivity: AppCompatActivity() {

    var broName: String? = ""
    var bromotion: String? = ""
    var expandableBrodapter: ExpandableBrodapter? = null

    var bromotionField: EditText? = null
    var broNameField: EditText? = null

    var vpPager: BroViewPager? = null
    var mSlidingTabLayout: SlidingTabLayout? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_find_bros)

        val intent = intent
        broName = intent.getStringExtra("broName")
        bromotion = intent.getStringExtra("bromotion")

        val listView = bro_list_view
        expandableBrodapter = ExpandableBrodapter(
            this@FindBroActivity,
            listView,
            FindBroAPI.potentialBros,
            FindBroAPI.body
        )
        listView.setAdapter(expandableBrodapter)

        expandableBrodapter!!.expandableListView.visibility = View.INVISIBLE
        expandableBrodapter!!.expandableListView.setOnChildClickListener(onChildClickListener)

        buttonSearchBros.setOnClickListener(clickButtonListener)

        bromotionField = findViewById(R.id.broNameSearchEmotion) as EditText
        broNameField = findViewById(R.id.broNameBroSearch) as EditText

        bromotionField!!.setRawInputType(InputType.TYPE_CLASS_TEXT)
        bromotionField!!.setTextIsSelectable(true)
        bromotionField!!.setTextSize(20f)

        bromotionField!!.setOnFocusChangeListener(focusChangeListener)
        broNameField!!.setOnFocusChangeListener(focusChangeListener)

        vpPager = findViewById(R.id.vpPager_find) as BroViewPager
        val adapterViewPager = PagerBrodapter(supportFragmentManager)
        adapterViewPager.broTextField = bromotionField

        // TODO @Skools: We set the pagerBrodapter twice. See if you can fix this.
        vpPager!!.adapter = adapterViewPager
        vpPager!!.pagerBrodapter = adapterViewPager

        mSlidingTabLayout = findViewById(R.id.sliding_tabs_find)

        val iconArray = arrayOf(
            R.drawable.tab_most_used,
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

        var bromotion_length: Int = 0
        bromotionField!!.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(s: Editable) {
                // TODO @Skools: Code reuse in the Login, Register en FindBro application with the bromotion input
                s.delete(0, bromotion_length)
            }

            override fun beforeTextChanged(s: CharSequence, start: Int, count: Int, after: Int ) {
                bromotion_length = start
            }

            override fun onTextChanged(s: CharSequence, start: Int, before: Int, count: Int) {
            }
        })
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

        // TODO @Sander: If the user has logged in before autofill the fields.
        // TODO @Skools: set the minimum SDK to this version (LOLLIPOP).
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            bromotionField!!.showSoftInputOnFocus = false
        }

        broNameField!!.requestFocus()

        vpPager!!.visibility = View.GONE
        mSlidingTabLayout!!.visibility = View.GONE
    }

    private val focusChangeListener = View.OnFocusChangeListener { view, b ->
        when (view.getId()) {
            R.id.broNameSearchEmotion -> {
                if (b) {
                    println("focus on bromotion field")
                    try {
                        // We want to show the listview and hide the keyboard.
                        val imm: InputMethodManager =
                            applicationContext.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
                        imm.hideSoftInputFromWindow(
                            this.currentFocus!!.windowToken,
                            0
                        )
                        println("keyboard hidden")
                    } catch (e: Exception) {
                        // This is for the keyboard. If something went wrong
                        // than, whatever! It will not effect the app!
                    }

                    // Incredibly ugly hack to ensure that the keyboard and the
                    // bromotionboard are not visible at the same time.
                    Handler().postDelayed({
                        // We want to make the keyboard visible if it isn't yet.
                        vpPager!!.visibility = View.VISIBLE
                        mSlidingTabLayout!!.visibility = View.VISIBLE
                    }, 100)
                }
            }
            R.id.broNameBroSearch -> {
                if (b) {
                    println("focus on the broname field")
                    // The user clicked on the other field so we make the emotion keyboard invisible
                    if (vpPager!!.visibility == View.VISIBLE) {
                        vpPager!!.visibility = View.GONE
                        mSlidingTabLayout!!.visibility = View.GONE
                    }
                }
            }
        }
    }

    fun notifyAdapter() {
        expandableBrodapter!!.notifyDataSetChanged()
        expandableBrodapter!!.expandableListView.visibility = View.VISIBLE
    }

    private val onChildClickListener = ExpandableListView.OnChildClickListener {
            parent, v, groupPosition, childPosition, id ->
        val bro = FindBroAPI.potentialBros[groupPosition]

        println("bro $broName wants to add ${bro.broName} to his brolist")
        AddBroAPI.addBro(broName!!, bromotion!!, bro.broName, bro.bromotion, applicationContext, this@FindBroActivity)
        false
    }

    private val clickButtonListener = View.OnClickListener { view ->
        when (view.getId()) {
            R.id.buttonSearchBros -> {
                // TODO @Sander: potentially expand it with an emoji search
                val potentialBro = broNameBroSearch.text.toString()
                if (potentialBro == "") {
                    Toast.makeText(this, "No Bro filled in yet", Toast.LENGTH_SHORT).show()
                } else {
                    var potentialBromotion = broNameSearchEmotion.text.toString()
                    if (potentialBromotion == "") {
                        // The backend will look for 'None' to determine whether or not the bromotion should be used.
                        potentialBromotion = "None"
                    }
                    FindBroAPI.findBro(broName!!, bromotion!!, potentialBro, potentialBromotion, applicationContext, this)
                }
            }
        }
    }

    override fun onBackPressed() {
        // We want to make the keyboard visible if it isn't yet.
        if (vpPager!!.visibility == View.VISIBLE) {
            vpPager!!.visibility = View.GONE
            mSlidingTabLayout!!.visibility = View.GONE
        } else {
            super.onBackPressed()
        }
    }
}