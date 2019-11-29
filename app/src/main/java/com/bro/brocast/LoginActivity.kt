package com.bro.brocast

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.beust.klaxon.JsonObject
import com.beust.klaxon.Parser
import kotlinx.android.synthetic.main.activity_login.*
import okhttp3.ResponseBody
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
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
        pressedLogin = false
    }

    private val clickLoginListener = View.OnClickListener { view ->
        when (view.getId()) {
            R.id.buttonLoginBro -> {
                if (!pressedLogin) {
                    pressedLogin = true
                    val broName = broNameLogin.text.toString()
                    val password = passwordLogin.text.toString()
                    val passwordEncrypt = encryption!!.encryptOrNull(password)
                    println("bro $broName wants to login!")
                    loginBro(broName, passwordEncrypt)
                }
            }
            R.id.buttonForgotPass -> {
                TODO("implement the 'forgot pass' screen.")
            }
        }
    }

    private fun loginBro(broName: String, password: String) {
        BroCastAPI
            .service
            .loginBro(broName, password)
            .enqueue(object : Callback<ResponseBody> {
                override fun onFailure(call: Call<ResponseBody>, t: Throwable) {
                    pressedLogin = false
                    // The BroCast Backend server is not running
                    Toast.makeText(
                        applicationContext,
                        "The BroCast server is not responding. " +
                                "We appologize for the inconvenience, please try again later",
                        Toast.LENGTH_SHORT
                    ).show()
                    // We will empty the stored login when this fails.
                    val sharedPreferences = getSharedPreferences(getString(R.string.preference_file_key), Context.MODE_PRIVATE)
                    val editor = sharedPreferences.edit()
                    // The bro is logged out so we will empty the stored bro data
                    // and return to the home screen
                    editor.putString("BRONAME", "")
                    editor.putString("PASSWORD", "")
                    editor.apply()
                }
                override fun onResponse(call: Call<ResponseBody>, response: Response<ResponseBody>) {
                    pressedLogin = false
                    if (response.isSuccessful) {
                        val msg = response.body()?.string()
                        Toast.makeText(applicationContext, msg, Toast.LENGTH_SHORT).show()
                        if (msg != null) {
                            val parser: Parser = Parser.default()
                            val stringBuilder: StringBuilder = StringBuilder(msg)
                            val json: JsonObject = parser.parse(stringBuilder) as JsonObject
                            val result = json.get("result")
                            if (result!! == true) {
                                Toast.makeText(
                                    applicationContext,
                                    "you just logged in!",
                                    Toast.LENGTH_SHORT
                                ).show()
                                val successIntent = Intent(this@LoginActivity, BroCastHome::class.java).apply {
                                    putExtra("broName", broName)
                                }
                                val sharedPreferences = getSharedPreferences(getString(R.string.preference_file_key), Context.MODE_PRIVATE)
                                val editor = sharedPreferences.edit()
                                editor.putString("BRONAME", broName)
                                editor.putString("PASSWORD", password)
                                editor.apply()
                                startActivity(successIntent)
                            } else {
                                val reason: String = json.get("reason").toString()
                                Toast.makeText(
                                    applicationContext,
                                    reason,
                                    Toast.LENGTH_SHORT
                                ).show()
                            }
                        }

                    } else {
                        TODO("the bro will come back to the login screen, show which error occured")
                    }
                }
            })
    }
}