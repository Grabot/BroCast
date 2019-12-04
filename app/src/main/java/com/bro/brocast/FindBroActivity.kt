package com.bro.brocast

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.view.inputmethod.InputMethodManager
import android.widget.BaseExpandableListAdapter
import android.widget.ExpandableListView
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


class FindBroActivity: AppCompatActivity() {

    val body: ArrayList<ArrayList<Bro>> = ArrayList()

    var potentialBros = ArrayList<Bro>()
    var broAdapter: BroAdapter? = null

    var broName: String = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_find_bros)

        val intent = intent
        broName = intent.getStringExtra("broName")

        val listView = bro_list_view
        broAdapter = BroAdapter(this@FindBroActivity, listView, potentialBros, body)
        listView.setAdapter(broAdapter)


        broAdapter!!.expandableListView.visibility = View.INVISIBLE

//        broAdapter!!.expandableListView.setOnGroupExpandListener { groupPosition ->
//            Toast.makeText(applicationContext, potentialBros[groupPosition].broName + " List Expanded.", Toast.LENGTH_SHORT).show()
//        }
//        broAdapter!!.expandableListView.setOnGroupCollapseListener { groupPosition ->
//            Toast.makeText(applicationContext, potentialBros[groupPosition].broName + " List Collapsed.", Toast.LENGTH_SHORT).show()
//        }

        broAdapter!!.expandableListView.setOnChildClickListener { parent, v, groupPosition, childPosition, id ->
            var bro = potentialBros[groupPosition]
            Toast.makeText(applicationContext, "Clicked: " + potentialBros[groupPosition].broName + " -> " + body[groupPosition].get(childPosition).id.toString(), Toast.LENGTH_SHORT).show()
            addBro(bro)
            false
        }


        buttonSearchBros.setOnClickListener(clickButtonListener)
    }

    fun addBro(bro: Bro) {
        println("bro $broName wants to add ${bro.broName} to his brolist")
        BroCastAPI
            .service
            .addBro(broName, bro.broName)
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
                        Toast.makeText(applicationContext, msg, Toast.LENGTH_SHORT)
                            .show()
                        if (msg != null) {
                            val parser: Parser = Parser.default()
                            val stringBuilder: StringBuilder = StringBuilder(msg)
                            val json: JsonObject = parser.parse(stringBuilder) as JsonObject
//                            val result = json.get("result")
                            val result = json.get("results")
                            if (result!! == true) {
                                println("bro $broName wants to add ${bro.broName} to his brolist")
                                Toast.makeText(
                                    applicationContext,
                                    "bro $broName and bro ${bro.broName} are now bros",
                                    Toast.LENGTH_SHORT
                                ).show()
                                val successIntent = Intent(this@FindBroActivity, BroCastHome::class.java).apply {
                                    putExtra("broName", broName)
                                }
                                startActivity(successIntent)
                            } else {
                                Toast.makeText(
                                    applicationContext,
                                    "Something went wrong " +
                                            "We appologize for the inconvenience, please try again later",
                                    Toast.LENGTH_SHORT
                                ).show()
                            }
                        }
                    } else {
                        // The BroCast Backend server gave an error
                        Toast.makeText(
                            applicationContext,
                            "The BroCast server is down right. " +
                                    "We appologize for the inconvenience, please try again later",
                            Toast.LENGTH_SHORT
                        ).show()
                    }
                }
            })
    }

    private val clickButtonListener = View.OnClickListener { view ->
        when (view.getId()) {
            R.id.buttonSearchBros -> {
                val potentialBro = broNameBroSearch.text.toString()
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
                                    Toast.makeText(applicationContext, msg, Toast.LENGTH_SHORT)
                                        .show()
                                    if (msg != null) {
                                        val parser: Parser = Parser.default()
                                        val stringBuilder: StringBuilder = StringBuilder(msg)
                                        val json: JsonObject = parser.parse(stringBuilder) as JsonObject
                                        val bros = json.get("bros") as JsonArray<*>

                                        potentialBros.clear()
                                        body.clear()

                                        for (b in bros) {
                                            val foundBro = b as JsonObject
                                            val broName: String = foundBro.get("bro_name") as String
                                            val id: Int = foundBro.get("id") as Int

                                            // Add the bro to the potential bro list
                                            val bro = Bro(broName, id, "")
                                            val brorray = ArrayList<Bro>()
                                            potentialBros.add(bro)
                                            brorray.add(bro)
                                            body.add(brorray)
                                        }
                                        broAdapter!!.notifyDataSetChanged()
                                        broAdapter!!.expandableListView.visibility = View.VISIBLE
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
                                    TODO("the bro will come back to the login screen, show which error occured")
                                }
                            }
                        })
                }
            }
        }
    }
}