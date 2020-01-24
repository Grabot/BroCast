package com.bro.brocast

import android.content.Context
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.text.Editable
import android.text.InputType
import android.text.TextWatcher
import android.view.View
import android.view.View.OnFocusChangeListener
import android.view.inputmethod.InputMethodManager
import android.widget.Button
import android.widget.EditText
import android.widget.ImageButton
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.bro.brocast.api.RegisterAPI
import com.bro.brocast.keyboards.BroBoard
import kotlinx.android.synthetic.main.activity_register.*
import se.simbio.encryption.Encryption


class RegisterActivity : AppCompatActivity() {

    var encryption: Encryption? = null

    var bromotion: EditText? = null
    var broName: EditText? = null
    var broPassword: EditText? = null

    var broBoard: BroBoard? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_register)

        // Initialization of the keys. For anyone reading this, I know you shouldn't compile the
        // keys with the app because it can be decompiled from the apk. But I wanted bros to have
        // their passwords encrypted and the application level and also have the ability to switch
        // phones and log in again. This way their passwords are encrypted before sending to the
        // server and any person who wants to do malice and scans traffic will not be able to read
        // it and he would have to specially target the bro and the app in order to decrypt it,
        // which would be way to much trouble for this simple app. On top of that, most companies
        // (Including Google and Facebook) send their bro/pass in cleartext over https because
        // they don't feel the need to do this. So I think this is already pretty nice of me.
        encryption =
            Encryption.getDefault(secretBroCastKey, saltyBroCastSalt, ByteArray(16))

        buttonRegisterBro.setOnClickListener(clickRegisterListener)
        RegisterAPI.pressedRegister = false

        bromotion = findViewById(R.id.broNameRegisterEmotion) as EditText
        broName = findViewById(R.id.broNameRegister) as EditText
        broPassword = findViewById(R.id.passwordRegister) as EditText

        bromotion!!.setOnFocusChangeListener(focusChangeListener)
        broName!!.setOnFocusChangeListener(focusChangeListener)
        broPassword!!.setOnFocusChangeListener(focusChangeListener)

        bromotion!!.setRawInputType(InputType.TYPE_CLASS_TEXT)
        bromotion!!.setTextIsSelectable(true)
        bromotion!!.setTextSize(20f)

        var bromotion_length: Int = 0
        bromotion!!.addTextChangedListener(object : TextWatcher {
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

        broBoard = BroBoard(this, bromotion!!, questionButton, exclamationButton, backButton)

        bromotion!!.showSoftInputOnFocus = false
        broName!!.requestFocus()
    }

    private val focusChangeListener = OnFocusChangeListener { view, b ->
        when (view.getId()) {
            R.id.broNameRegisterEmotion -> {
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
            R.id.broNameRegister -> {
                if (b) {
                    println("focus on the broname field")
                    // The user clicked on the other field so we make the emotion keyboard invisible
                    if (broBoard!!.visible) {
                        broBoard!!.makeInvisible()
                    }
                }
            }
            R.id.passwordRegister -> {
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

    private val clickRegisterListener = View.OnClickListener { view ->
        when (view.getId()) {
            R.id.buttonRegisterBro -> {
                if (!RegisterAPI.pressedRegister) {
                    RegisterAPI.pressedRegister = true
                    val broName = broName!!.text.toString()
                    val password = broPassword!!.text.toString()
                    val bromotion = broNameRegisterEmotion!!.text.toString()
                    val passwordEncrypt = encryption!!.encryptOrNull(password)
                    println("bro $broName wants to register!")
                    if (broName != "" && bromotion != "" && password != "") {
                        RegisterAPI.registerBro(broName, bromotion, passwordEncrypt, this@RegisterActivity, applicationContext)
                    } else {
                        Toast.makeText(applicationContext, "On of the fields is not filled in, please fill it in.", Toast.LENGTH_SHORT).show()
                        RegisterAPI.pressedRegister = false
                    }
                }
            }
            R.id.broNameRegisterEmotion -> {
                println("bro emotion field touched")
                try {
                    // We want to show the listview and hide the keyboard.
                    val imm: InputMethodManager =
                        applicationContext.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
                    imm.hideSoftInputFromWindow(
                        this.currentFocus!!.windowToken,
                        0
                    )
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
            R.id.broNameRegister -> {
                println("broname field touched")
                // The user clicked on the other field so we make the emotion keyboard invisible
                if (broBoard!!.visible) {
                    broBoard!!.makeInvisible()
                }
            }
        }
    }

}