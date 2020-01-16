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
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.viewpager.widget.ViewPager
import com.bro.brocast.adapters.BroViewPager
import com.bro.brocast.adapters.PagerBrodapter
import com.bro.brocast.adapters.SlidingTabLayout
import com.bro.brocast.api.LoginAPI
import kotlinx.android.synthetic.main.activity_login.*
import se.simbio.encryption.Encryption

class LoginActivity: AppCompatActivity() {

    var encryption: Encryption? = null

    var bromotion: EditText? = null
    var broName: EditText? = null
    var broPassword: EditText? = null

    var vpPager: BroViewPager? = null
    var mSlidingTabLayout: SlidingTabLayout? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_login)

        // We also create an encryption instance in the register activity and these are
        // separate instances. We will keep it like this because we assume that uses will always
        // (almost always) take 1 of these 2 paths when they open their app.
        // If this is not the case, than whatever, 2 instances.
        encryption =
            Encryption.getDefault(secretBroCastKey, saltyBroCastSalt, ByteArray(16))

        buttonLoginBro.setOnClickListener(clickLoginListener)
        buttonForgotPass.setOnClickListener(clickLoginListener)
        LoginAPI.pressedLogin = false

        bromotion = findViewById(R.id.broNameLoginEmotion) as EditText
        broName = findViewById(R.id.broNameLogin) as EditText
        broPassword = findViewById(R.id.passwordLogin) as EditText

        bromotion!!.setOnFocusChangeListener(focusChangeListener)
        broName!!.setOnFocusChangeListener(focusChangeListener)
        broPassword!!.setOnFocusChangeListener(focusChangeListener)

        bromotion!!.setRawInputType(InputType.TYPE_CLASS_TEXT)
        bromotion!!.setTextIsSelectable(true)
        bromotion!!.setTextSize(20f)

        bromotion!!.addTextChangedListener(object : TextWatcher {
            // We assume the emoji length is always 2
            override fun afterTextChanged(s: Editable) {
                // TODO @Skools: Code reuse in the Login, Register en FindBro application with the bromotion input
                if (s.length > 1 ) {
                    if (s.toString().endsWith("❤")
                        || s.toString().endsWith("!")
                        || s.toString().endsWith("?")
                    ) {
                        // An emoji was entered and the last was a heart (or ?/!)
                        // It is too long, so we remove only 1
                        s.delete(0, 1)
                    }
                }
                if (s.length > 2) {
                    if (s.toString().startsWith("❤")
                        || s.toString().startsWith("!")
                        || s.toString().startsWith("?")
                    ) {
                        s.delete(0, 1)
                    } else {
                        s.delete(0, 2)
                    }
                }
            }

            override fun beforeTextChanged(s: CharSequence, start: Int, count: Int, after: Int ) {
            }

            override fun onTextChanged(s: CharSequence, start: Int, before: Int, count: Int) {
            }
        })
        vpPager = findViewById(R.id.vpPager_login) as BroViewPager
        val adapterViewPager = PagerBrodapter(supportFragmentManager)
        adapterViewPager.broTextField = bromotion

        // TODO @Skools: We set the pagerBrodapter twice. See if you can fix this.
        vpPager!!.adapter = adapterViewPager
        vpPager!!.pagerBrodapter = adapterViewPager

        mSlidingTabLayout = findViewById(R.id.sliding_tabs_login)

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
            bromotion!!.showSoftInputOnFocus = false
        }

        broName!!.requestFocus()

        vpPager!!.visibility = View.GONE
        mSlidingTabLayout!!.visibility = View.GONE
    }

    private val focusChangeListener = View.OnFocusChangeListener { view, b ->
        when (view.getId()) {
            R.id.broNameLoginEmotion -> {
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
            R.id.broNameLogin -> {
                if (b) {
                    println("focus on the broname field")
                    // The user clicked on the other field so we make the emotion keyboard invisible
                    vpPager!!.visibility = View.INVISIBLE
                    mSlidingTabLayout!!.visibility = View.INVISIBLE
                }
            }
            R.id.passwordLogin -> {
                if (b) {
                    println("password field touched")
                    // We don't want the user to see the emotion keyboard when this field is active
                    vpPager!!.visibility = View.INVISIBLE
                    mSlidingTabLayout!!.visibility = View.INVISIBLE
                }
            }
        }
    }

    private val clickLoginListener = View.OnClickListener { view ->
        when (view.getId()) {
            R.id.buttonLoginBro -> {
                if (!LoginAPI.pressedLogin) {
                    LoginAPI.pressedLogin = true
                    val broName = broName!!.text.toString()
                    val bromotion = bromotion!!.text.toString()
                    val password = broPassword!!.text.toString()
                    val passwordEncrypt = encryption!!.encryptOrNull(password)
                    println("bro $broName wants to login!")

                    if (broName != "" && bromotion != "" && password != "") {
                        // We call the Login functionality of the API with the loginActivity class
                        LoginAPI.loginBro(
                            broName, bromotion, passwordEncrypt, applicationContext, this@LoginActivity, null)
                    } else {
                        Toast.makeText(applicationContext, "On of the fields is not filled in, please fill it in.", Toast.LENGTH_SHORT).show()
                        LoginAPI.pressedLogin = false
                    }
                }
            }
            R.id.buttonForgotPass -> {
                // TODO @Sander: implement the 'forgot pass' screen
            }
        }
    }
}