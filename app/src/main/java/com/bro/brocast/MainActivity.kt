package com.bro.brocast

import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.beust.klaxon.JsonObject
import com.beust.klaxon.JsonReader
import com.beust.klaxon.Parser
import kotlinx.android.synthetic.main.activity_main.*
import okhttp3.ResponseBody
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import se.simbio.encryption.Encryption
import java.io.StringReader


class MainActivity : AppCompatActivity() {


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        buttonGet.setOnClickListener {
            println("button Get is clicked!")
            BroCastAPI
                .service
                .getTest()
                .enqueue(object : Callback<ResponseBody> {
                    override fun onFailure(call: Call<ResponseBody>, t: Throwable) {
                        println("An exception occured with the GET call:: " + t.message)
                    }

                    override fun onResponse(call: Call<ResponseBody>, response: Response<ResponseBody>) {
                        if (response.isSuccessful) {
                            val msg = response.body()?.string()
                            println("The GET message returned from the server:: " + msg)
                            Toast.makeText(applicationContext, msg, Toast.LENGTH_SHORT).show()
                        }
                    }
                })
        }

        val key = secretBroCastKey
        val salt = saltyBroCastKey
        val iv = ByteArray(16)
        val encryption: Encryption = Encryption.getDefault(key, salt, iv)

        val username = "Sander30name"
        val password = "Sander30pass"
        val encrypted = encryption.encryptOrNull(password)

        buttonRegister.setOnClickListener {
            println("A user wants to register!")
            BroCastAPI
                .service
                .registerUser(username, encrypted)
                .enqueue(object : Callback<ResponseBody> {
                    override fun onFailure(call: Call<ResponseBody>, t: Throwable) {
                        println("An exception occured with the GET call:: " + t.message)
                    }

                    override fun onResponse(call: Call<ResponseBody>, response: Response<ResponseBody>) {
                        if (response.isSuccessful) {
                            val msg = response.body()?.string()
                            if (msg != null) {
                                val parser: Parser = Parser.default()
                                val stringBuilder: StringBuilder = StringBuilder(msg)
                                val json: JsonObject = parser.parse(stringBuilder) as JsonObject
                                val decrypted = encryption.decryptOrNull(json.get("password").toString())
                                println("The GET message returned from the server:: " + msg)
                                Toast.makeText(applicationContext,
                                    "user " + json.get("username") + " signed up with password: " + decrypted +
                                            " \n" + json.get("messgae"),
                                    Toast.LENGTH_SHORT).show()
                            }
                        }
                    }
                })
        }
    }
}
