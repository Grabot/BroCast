package com.bro.brocast

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import kotlinx.android.synthetic.main.activity_find_bros.*
import okhttp3.ResponseBody
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class FindBroActivity: AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_find_bros)

        buttonSearchBros.setOnClickListener(clickButtonListener)
    }

    private val clickButtonListener = View.OnClickListener { view ->
        when (view.getId()) {
            R.id.buttonSearchBros -> {
                val potentialBro = userNameBroSearch.text.toString()
                if (potentialBro == "") {
                    Toast.makeText(this,"No Bro filled in yet", Toast.LENGTH_SHORT).show()
                } else {

                    BroCastAPI
                        .service
                        .findBro(potentialBro)
                        .enqueue(object : Callback<ResponseBody> {
                            override fun onFailure(call: Call<ResponseBody>, t: Throwable) {
                                println("An exception occured with the GET call:: " + t.message)
                                // The BroCast Backend server is not running
                                Toast.makeText(
                                    applicationContext,
                                    "The BroCast server is not responding. " +
                                            "We appologize for the inconvenience, please try again later",
                                    Toast.LENGTH_SHORT
                                ).show()
                            }
                            override fun onResponse(call: Call<ResponseBody>, response: Response<ResponseBody>) {
                                if (response.isSuccessful) {
                                    val msg = response.body()?.string()
                                    println("The GET message returned from the server:: $msg")
                                    Toast.makeText(applicationContext, msg, Toast.LENGTH_SHORT).show()
                                    if (msg != null) {
                                        println("The GET message returned from the server:: $msg")
                                        Toast.makeText(
                                            applicationContext,
                                            "found a new possible bro!",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                } else {
                                    TODO("the user will come back to the login screen, show which error occured")
                                }
                            }
                        })
                }
            }
        }
    }
}