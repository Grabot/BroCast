package com.bro.brocast

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import kotlinx.android.synthetic.main.activity_main.*
import okhttp3.ResponseBody
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response


class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val sharedPreferences = getSharedPreferences(getString(R.string.preference_file_key), Context.MODE_PRIVATE)
        val broName: String = sharedPreferences.getString("BRONAME", "")!!
        val password: String = sharedPreferences.getString("PASSWORD", "")!!

        // If a broName and password are stored in the shared preferences than the bro has
        // previously made or logged in with an account for which he knows the login information
        // We automatically log in if this is the case.
        if (broName != "" && password != "") {
            println("Welcome back br $broName we will start the autmoatic login")
            automaticLogin(broName, password)
        } else {
            // TODO @Skools: doing it like this will show a white screen until it fails, maybe add loading screen?
            showScreen()
        }
    }

    private val showScreen = {
        setContentView(R.layout.activity_main)
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

    fun automaticLogin(broName: String, password: String) {
        BroCastAPI
            .service
            .loginBro(broName, password)
            .enqueue(object : Callback<ResponseBody> {
                override fun onFailure(call: Call<ResponseBody>, t: Throwable) {
                    // The server is not responding. show an error and display the main screen
                    Toast.makeText(
                        applicationContext,
                        "The BroCast server is not responding. " +
                                "We appologize for the inconvenience, please try again later",
                        Toast.LENGTH_SHORT
                    ).show()
                    // TODO @Skools: It will show a white screen for a while, possibly add loading screen or something?
                    showScreen()
                    val sharedPreferences = getSharedPreferences(getString(R.string.preference_file_key), Context.MODE_PRIVATE)
                    val editor = sharedPreferences.edit()
                    // The bro is logged out so we will empty the stored bro data
                    // and return to the home screen
                    editor.putString("BRONAME", "")
                    editor.putString("PASSWORD", "")
                    editor.apply()
                }
                override fun onResponse(call: Call<ResponseBody>, response: Response<ResponseBody>) {
                    if (response.isSuccessful) {
                        val msg = response.body()?.string()
                        Toast.makeText(applicationContext, msg, Toast.LENGTH_SHORT).show()
                        if (msg != null) {
                            Toast.makeText(
                                applicationContext,
                                "you just logged in!",
                                Toast.LENGTH_SHORT
                            ).show()
                        }
                        val successIntent = Intent(this@MainActivity, BroCastHome::class.java).apply {
                            putExtra("broName", broName)
                        }
                        val sharedPreferences = getSharedPreferences(getString(R.string.preference_file_key), Context.MODE_PRIVATE)
                        val editor = sharedPreferences.edit()
                        editor.putString("BRONAME", broName)
                        editor.putString("PASSWORD", password)
                        editor.apply()
                        startActivity(successIntent)
                    } else {
                        startActivity(
                            Intent(
                                this@MainActivity, MainActivity::class.java)
                        )
                        TODO("the bro will come back to the login screen, show which error occured")
                    }
                }
            })
    }
}
