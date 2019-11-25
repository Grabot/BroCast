package com.bro.brocast

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import kotlinx.android.synthetic.main.brocast_home.*

class BroCastHome: AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.brocast_home)

        val intent = intent
        val username= intent.getStringExtra("username")
        val welcomeText = getString(R.string.brocast_welcome) + " $username"
        broCastWelcomeView.text = welcomeText

        buttonLogout.setOnClickListener(clickLogoutListener)
    }

    private val clickLogoutListener = View.OnClickListener { view ->
        when (view.getId()) {
            R.id.buttonLogout -> {
                val sharedPreferences = getSharedPreferences(getString(R.string.preference_file_key), Context.MODE_PRIVATE)
                val editor = sharedPreferences.edit()
                // The user is logged out so we will empty the stored user data
                // and return to the home screen
                editor.putString("USERNAME", "")
                editor.putString("PASSWORD", "")
                editor.apply()
                startActivity(
                    Intent(
                        this@BroCastHome, MainActivity::class.java)
                )
            }
        }
    }
}