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
import android.widget.Button
import android.widget.EditText
import android.widget.ImageButton
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.bro.brocast.api.LoginAPI
import com.bro.brocast.keyboards.BroBoard
import kotlinx.android.synthetic.main.activity_login.*
import se.simbio.encryption.Encryption

class LoginActivity: AppCompatActivity() {

    var encryption: Encryption? = null

    var bromotion: EditText? = null
    var broName: EditText? = null
    var broPassword: EditText? = null

    var broBoard: BroBoard? = null

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

        var bromotion_length: Int = 0
        bromotion!!.addTextChangedListener(object : TextWatcher {
            // We assume the emoji length is always 2
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

        val questionButton = findViewById<Button>(R.id.button_question)
        val exclamationButton = findViewById<Button>(R.id.button_exclamation)
        val backButton = findViewById<ImageButton>(R.id.button_back)
        val searchEmojiButton = findViewById<ImageButton>(R.id.button_search_emoji)

        broBoard = BroBoard(this, supportFragmentManager, bromotion!!, questionButton, exclamationButton, backButton)

        bromotion!!.showSoftInputOnFocus = false
        broName!!.requestFocus()
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
                        if (!broBoard!!.visible) {
                            broBoard!!.makeVisible()
                        }
                    }, 100)
                }
            }
            R.id.broNameLogin -> {
                if (b) {
                    println("focus on the broname field")
                    // The user clicked on the other field so we make the emotion keyboard invisible
                    if (broBoard!!.visible) {
                        broBoard!!.makeInvisible()
                    }
                }
            }
            R.id.passwordLogin -> {
                if (b) {
                    println("password field touched")
                    // We don't want the user to see the emotion keyboard when this field is active
                    if (broBoard!!.visible) {
                        broBoard!!.makeInvisible()
                    }
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
        }
    }
}