package com.bro.brocast

import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import com.bro.brocast.api.RegisterAPI
import kotlinx.android.synthetic.main.activity_register.*
import se.simbio.encryption.Encryption

class RegisterActivity : AppCompatActivity() {

    var encryption: Encryption? = null
    // A simple variable to lock the register button after it's pressed
    private var pressedRegister = false

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
        }
    }

}