package com.bro.brocast

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.AdapterView
import android.widget.ArrayAdapter
import android.widget.ListView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.beust.klaxon.JsonObject
import com.beust.klaxon.Parser
import kotlinx.android.synthetic.main.brocast_home.*
import okhttp3.ResponseBody
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response


class BroCastHome: AppCompatActivity() {

    lateinit var listView: ListView

    var bros = ArrayList<String>()
    var broAdapter: ArrayAdapter<String>? = null

    var broName: String = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.brocast_home)

        val intent = intent
        broName = intent.getStringExtra("broName")
        val welcomeText = getString(R.string.brocast_welcome) + " $broName"
        broCastWelcomeView.text = welcomeText

        buttonLogout.setOnClickListener(clickButtonListener)
        buttonFindBros.setOnClickListener(clickButtonListener)

        broAdapter = ArrayAdapter(this,
            R.layout.bro_list, bros)

        listView = findViewById(R.id.bro_home_list_view)
        listView.adapter = broAdapter
        listView.visibility = View.VISIBLE

        listView.onItemClickListener = object : AdapterView.OnItemClickListener {

            override fun onItemClick(parent: AdapterView<*>, view: View,
                                     position: Int, id: Long) {

                // value of item that is clicked
                val itemValue = listView.getItemAtPosition(position) as String

                // Toast the values
                Toast.makeText(applicationContext,
                    "Position :$position\nItem Value : $itemValue", Toast.LENGTH_LONG)
                    .show()
            }
        }

        fillBroList()
    }

    private fun fillBroList() {
        BroCastAPI
            .service
            .getBros(broName)
            .enqueue(object : Callback<ResponseBody> {
                override fun onFailure(call: Call<ResponseBody>, t: Throwable) {
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
                            } else {
                                Toast.makeText(
                                    applicationContext,
                                    "The BroCast server is not responding. " +
                                            "We appologize for the inconvenience, please try again later",
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

    private val clickButtonListener = View.OnClickListener { view ->
        when (view.getId()) {
            R.id.buttonLogout -> {
                val sharedPreferences = getSharedPreferences(getString(R.string.preference_file_key), Context.MODE_PRIVATE)
                val editor = sharedPreferences.edit()
                // The bro is logged out so we will empty the stored bro data
                // and return to the home screen
                editor.putString("BRONAME", "")
                editor.putString("PASSWORD", "")
                editor.apply()
                startActivity(
                    Intent(
                        this@BroCastHome, MainActivity::class.java)
                )
            }
            R.id.buttonFindBros -> {
                val successIntent = Intent(this@BroCastHome, FindBroActivity::class.java).apply {
                    putExtra("broName", broName)
                }
                startActivity(successIntent)
            }
        }
    }
}