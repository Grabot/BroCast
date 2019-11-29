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
                    registerBro(broName, passwordEncrypt)
                }
            }
        }
    }

    private fun registerBro(broName: String, password: String) {
        BroCastAPI
            .service
            .registerBro(broName, password)
            .enqueue(object : Callback<ResponseBody> {
                override fun onFailure(call: Call<ResponseBody>, t: Throwable) {
                    pressedRegister = false
                    failedRegistration("The BroCast server is not responding. \n" +
                            "We appologize for the inconvenience, please try again later")

                }
                override fun onResponse(call: Call<ResponseBody>, response: Response<ResponseBody>) {
                    pressedRegister = false
                    if (response.isSuccessful) {
                        val msg = response.body()?.string()
                        if (msg != null) {
                            val parser: Parser = Parser.default()
                            val stringBuilder: StringBuilder = StringBuilder(msg)
                            val json: JsonObject = parser.parse(stringBuilder) as JsonObject
                            val result = json.get("result")
                            if (result!! == true) {
                                val sharedPreferences = getSharedPreferences(getString(R.string.preference_file_key), Context.MODE_PRIVATE)
                                val editor = sharedPreferences.edit()
                                editor.putString("BRONAME", broName)
                                // There seems to be an issue with storing password because of newline characters.
                                // We concatenate it with an ending that we will remove when we load the password
                                editor.putString("PASSWORD", "$password:broCastPasswordEnd")
                                editor.apply()
                                successfulRegistration(broName, json.get("message").toString())
                            } else {
                                failedRegistration("That broName is already taken, please select another one")
                            }
                        } else {
                            failedRegistration("Something went wrong, we apologize for the inconvenience")
                            TODO("the bro will come back to the register screen, show which error occured")
                        }
                    } else {
                        failedRegistration("Something went wrong, we apologize for the inconvenience")
                        TODO("the bro will come back to the register screen, show which error occured")
                    }
                }
            })
    }

    fun successfulRegistration(broName: String, reason: String) {
        Toast.makeText(
            applicationContext,
            "you just logged in! \n$reason",
            Toast.LENGTH_SHORT
        ).show()
        val successIntent = Intent(this@RegisterActivity, BroCastHome::class.java).apply {
            putExtra("broName", broName)
        }
        startActivity(successIntent)
    }

    fun failedRegistration(reason: String) {
        Toast.makeText(
            applicationContext,
            reason,
            Toast.LENGTH_SHORT
        ).show()
    }
}