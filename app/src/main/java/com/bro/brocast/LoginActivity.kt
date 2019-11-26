package com.bro.brocast

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import kotlinx.android.synthetic.main.activity_login.*
import okhttp3.ResponseBody
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import se.simbio.encryption.Encryption

class LoginActivity: AppCompatActivity() {

    var encryption: Encryption? = null

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
    }

    private val clickLoginListener = View.OnClickListener { view ->
        when (view.getId()) {
            R.id.buttonLoginBro -> {
                val username = userNameLogin.text.toString()
                val password = passwordLogin.text.toString()
                val passwordEncrypt = encryption!!.encryptOrNull(password)
                println("user $username wants to login!")
                loginUser(username, passwordEncrypt)
            }
            R.id.buttonForgotPass -> {
                TODO("implement the 'forgot pass' screen.")
            }
        }
    }

    private fun loginUser(username: String, password: String) {
        BroCastAPI
            .service
            .loginUser(username, password)
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
                                "you just logged in!",
                                Toast.LENGTH_SHORT
                            ).show()
                        }
                        val successIntent = Intent(this@LoginActivity, BroCastHome::class.java).apply {
                            putExtra("username", username)
                        }
                        val sharedPreferences = getSharedPreferences(getString(R.string.preference_file_key), Context.MODE_PRIVATE)
                        val editor = sharedPreferences.edit()
                        editor.putString("USERNAME", username)
                        editor.putString("PASSWORD", password)
                        editor.apply()
                        startActivity(successIntent)
                    } else {
                        TODO("the user will come back to the login screen, show which error occured")
                    }
                }
            })
    }
}