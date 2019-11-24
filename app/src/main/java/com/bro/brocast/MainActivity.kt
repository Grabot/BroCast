package com.bro.brocast

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import kotlinx.android.synthetic.main.activity_main.*


class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val sharedPreferences = getSharedPreferences(getString(R.string.preference_file_key), Context.MODE_PRIVATE)
        val username: String = sharedPreferences.getString("USERNAME", "")!!
        val password: String = sharedPreferences.getString("PASSWORD", "")!!

        // If a username and password are stored in the shared preferences than the user has
        // previously made or logged in with an account for which he knows the login information
        // We automatically log in if this is the case.
        if (username != "" && password != "") {
            // TODO @Sander: automatically log in if the data is provided.
        }
        buttonLogin.setOnClickListener(clickButtonListener)
        buttonRegister.setOnClickListener(clickButtonListener)
    }

    private val clickButtonListener = View.OnClickListener { view ->
        when (view.getId()) {
            R.id.buttonLogin -> {
                println("brocast login")
                startActivity(Intent(this, LoginActivity::class.java))
            }
            R.id.buttonRegister -> {
                println("brocast register")
                startActivity(Intent(this, RegisterActivity::class.java))
            }
        }
    }
}
