package com.bro.brocast

import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import com.bro.brocast.api.LoginAPI
import kotlinx.android.synthetic.main.activity_login.*
import se.simbio.encryption.Encryption

class LoginActivity: AppCompatActivity() {

    var encryption: Encryption? = null
    // This variable is a simple lock for the login button functionality.
    private var pressedLogin = false

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
    }

    private val clickLoginListener = View.OnClickListener { view ->
        when (view.getId()) {
            R.id.buttonLoginBro -> {
                if (!LoginAPI.pressedLogin) {
                    LoginAPI.pressedLogin = true
                    val broName = broNameLogin.text.toString()
                    val password = passwordLogin.text.toString()
                    val passwordEncrypt = encryption!!.encryptOrNull(password)
                    println("bro $broName wants to login!")

                    // We call the Login functionality of the API with the loginActivity class
                    LoginAPI.loginBro(
                        broName, passwordEncrypt, applicationContext, this@LoginActivity, null)
                }
            }
            R.id.buttonForgotPass -> {
                TODO("implement the 'forgot pass' screen.")
            }
        }
    }
}