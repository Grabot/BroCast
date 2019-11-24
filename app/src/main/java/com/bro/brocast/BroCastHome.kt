package com.bro.brocast

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import kotlinx.android.synthetic.main.brocast_home.*

class BroCastHome: AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.brocast_home)

        val intent = intent
        val username= intent.getStringExtra("username")
        broCastWelcomeView.text = "Heey $username!"
    }
}