package com.bro.brocast

import android.app.Activity
import android.content.Context
import android.os.Build
import android.os.Bundle
import android.text.InputType
import android.view.View
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputMethodManager
import android.widget.EditText
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.Fragment
import com.beust.klaxon.JsonObject
import com.bro.brocast.api.RegisterAPI
import com.bro.brocast.api.SendMessagesAPI
import com.bro.brocast.objects.MyKeyboard
import kotlinx.android.synthetic.main.activity_messaging.*
import kotlinx.android.synthetic.main.activity_register.*
import kotlinx.android.synthetic.main.activity_register.keyboard
import se.simbio.encryption.Encryption

class RegisterActivity : AppCompatActivity() {

    var encryption: Encryption? = null
    // A simple variable to lock the register button after it's pressed
    private var pressedRegister = false

    var bromotion: EditText? = null
    var broName: EditText? = null

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
        pressedRegister = false

        bromotion = findViewById(R.id.broNameRegisterEmotion) as EditText
        broName = findViewById(R.id.broNameRegister) as EditText
        val keyboard = findViewById(R.id.keyboard) as MyKeyboard

        bromotion!!.setOnClickListener(clickRegisterListener)
        broName!!.setOnClickListener(clickRegisterListener)

        bromotion!!.setRawInputType(InputType.TYPE_CLASS_TEXT)
        bromotion!!.setTextIsSelectable(true)
        bromotion!!.setTextSize(20f)
        // TODO @Skools: set the minimum SDK to this version (LOLLIPOP).
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            bromotion!!.requestFocus()
            bromotion!!.showSoftInputOnFocus = false
        }

        val ic = bromotion!!.onCreateInputConnection(EditorInfo())
        keyboard.setInputConnection(ic)

    }

    private val clickRegisterListener = View.OnClickListener { view ->
        when (view.getId()) {
            R.id.buttonRegisterBro -> {
                if (!pressedRegister) {
                    pressedRegister = true
                    val broName = broNameRegister.text.toString()
                    val password = passwordRegister.text.toString()
                    val passwordEncrypt = encryption!!.encryptOrNull(password)
                    println("bro $broName wants to register!")
                    RegisterAPI.registerBro(broName, passwordEncrypt, this@RegisterActivity, applicationContext)
                }
            }
            R.id.broMessageField -> {
                // We want to make the keyboard visible if it isn't yet.
                if (keyboard.visibility != View.VISIBLE) {
                    keyboard.visibility = View.VISIBLE
                }
            }
            R.id.broNameRegister -> {
                // The user clicked on the other field so we make the emotion keyboard invisible
                if (keyboard.visibility == View.VISIBLE) {
                    keyboard.visibility = View.INVISIBLE
                }
            }
        }
    }

}