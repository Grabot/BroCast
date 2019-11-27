package com.bro.brocast

import android.content.Context
import android.os.Bundle
import android.view.View
import android.view.inputmethod.InputMethodManager
import android.widget.AdapterView
import android.widget.ListView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.beust.klaxon.JsonArray
import com.beust.klaxon.JsonObject
import com.beust.klaxon.Parser
import com.bro.brocast.objects.Bro
import com.bro.brocast.objects.BroAdapter
import kotlinx.android.synthetic.main.activity_find_bros.*
import okhttp3.ResponseBody
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.lang.Exception


class FindBroActivity: AppCompatActivity() {

    lateinit var listView:ListView

    var potentialBros = ArrayList<String>()
    var broAdapter: BroAdapter? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_find_bros)

        broAdapter = BroAdapter(this, potentialBros)

        listView = findViewById(R.id.bro_list_view)
        listView.adapter = broAdapter
        listView.visibility = View.INVISIBLE

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

        buttonSearchBros.setOnClickListener(clickButtonListener)
    }
    private val clickButtonListener = View.OnClickListener { view ->
        when (view.getId()) {
            R.id.buttonSearchBros -> {
                val potentialBro = userNameBroSearch.text.toString()
                if (potentialBro == "") {
                    Toast.makeText(this, "No Bro filled in yet", Toast.LENGTH_SHORT).show()
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

                            override fun onResponse(
                                call: Call<ResponseBody>,
                                response: Response<ResponseBody>
                            ) {
                                if (response.isSuccessful) {
                                    val msg = response.body()?.string()
                                    println("The GET message returned from the server:: $msg")
                                    Toast.makeText(applicationContext, msg, Toast.LENGTH_SHORT)
                                        .show()
                                    if (msg != null) {
                                        println("The GET message returned from the server:: $msg")

                                        val parser: Parser = Parser.default()
                                        val stringBuilder: StringBuilder = StringBuilder(msg)
                                        val json: JsonObject = parser.parse(stringBuilder) as JsonObject
                                        val bros = json.get("bros") as JsonArray<*>

                                        potentialBros.clear()
                                        for (b in bros) {
                                            val foundBro = b as JsonObject
                                            val username: String = foundBro.get("username") as String
                                            val id: Int = foundBro.get("id") as Int
                                            val bro: Bro = Bro(username, id)
                                            potentialBros.add(bro.getUsername())
                                        }
                                        broAdapter!!.notifyDataSetChanged()
                                        listView.visibility = View.VISIBLE
                                        try {
                                            // We want to show the listview and hide the keyboard.
                                            val imm: InputMethodManager =
                                                getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
                                            imm.hideSoftInputFromWindow(
                                                currentFocus!!.windowToken,
                                                0
                                            )
                                        } catch (e: Exception) {
                                            // This is for the keyboard. If something went wrong
                                            // than, whatever! It will not effect the app!
                                        }
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