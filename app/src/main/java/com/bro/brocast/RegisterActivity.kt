package com.bro.brocast

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.beust.klaxon.JsonObject
import com.beust.klaxon.Parser
import kotlinx.android.synthetic.main.activity_register.*
import okhttp3.ResponseBody
import retrofit2.Callback
import retrofit2.Call
import retrofit2.Response
import se.simbio.encryption.Encryption

class RegisterActivity : AppCompatActivity() {

    var encryption: Encryption? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_register)

        // Initialization of the keys. For anyone reading this, I know you shouldn't compile the
        // keys with the app because it can be decompiled from the apk. But I wanted users to have
        // their passwords encrypted and the application level and also have the ability to switch
        // phones and log in again. This way their passwords are encrypted before sending to the
        // server and any person who wants to do malice and scans traffic will not be able to read
        // it and he would have to specially target the user and the app in order to decrypt it,
        // which would be way to much trouble for this simple app. On top of that, most companies
        // (Including Google and Facebook) send their user/pass in cleartext over https because
        // they don't feel the need to do this. So I think this is already pretty nice of me.
        encryption =
            Encryption.getDefault(secretBroCastKey, saltyBroCastSalt, ByteArray(16))

        buttonRegisterBro.setOnClickListener(clickRegisterListener)
    }

    private val clickRegisterListener = View.OnClickListener { view ->
        when (view.getId()) {
            R.id.buttonRegisterBro -> {
                val username = userNameRegister.text.toString()
                val password = passwordRegister.text.toString()
                val passwordEncrypt = encryption!!.encryptOrNull(password)
                println("user $username wants to register!")
                registerUser(username, passwordEncrypt)
            }
        }
    }

    private fun registerUser(username: String, password: String) {
        BroCastAPI
            .service
            .registerUser(username, password)
            .enqueue(object : Callback<ResponseBody> {
                override fun onFailure(call: Call<ResponseBody>, t: Throwable) {
                    failedRegistration("Something went wrong, we apologize for the inconvenience")
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
                            val parser: Parser = Parser.default()
                            val stringBuilder: StringBuilder = StringBuilder(msg)
                            val json: JsonObject = parser.parse(stringBuilder) as JsonObject
                            val result = json.get("result")
                            if (result!! == true) {
                                val sharedPreferences = getSharedPreferences(getString(R.string.preference_file_key), Context.MODE_PRIVATE)
                                val editor = sharedPreferences.edit()
                                editor.putString("USERNAME", username)
                                editor.putString("PASSWORD", password)
                                editor.apply()
                                successfulRegistration(username, json.get("message").toString())
                            } else {
                                failedRegistration("That username is already taken, please select another one")
                            }
                        } else {
                            failedRegistration("Something went wrong, we apologize for the inconvenience")
                            TODO("the user will come back to the register screen, show which error occured")
                        }
                    } else {
                        failedRegistration("Something went wrong, we apologize for the inconvenience")
                        TODO("the user will come back to the register screen, show which error occured")
                    }
                }
            })
    }

    fun successfulRegistration(username: String, reason: String) {
        Toast.makeText(
            applicationContext,
            "you just logged in! \n$reason",
            Toast.LENGTH_SHORT
        ).show()
        val successIntent = Intent(this@RegisterActivity, BroCastHome::class.java).apply {
            putExtra("username", username)
        }
        startActivity(successIntent)
    }

    fun failedRegistration(reason: String) {
        Toast.makeText(
            applicationContext,
            "A problem occurred \n$reason",
            Toast.LENGTH_SHORT
        ).show()
        startActivity(Intent(
            this@RegisterActivity, RegisterActivity::class.java))
    }
}