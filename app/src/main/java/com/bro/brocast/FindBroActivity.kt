package com.bro.brocast

import android.content.Context
import android.os.Bundle
import android.view.View
import android.view.inputmethod.InputMethodManager
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.beust.klaxon.JsonArray
import com.beust.klaxon.JsonObject
import com.beust.klaxon.Parser
import com.bro.brocast.objects.Bro
import com.bro.brocast.objects.ExpandableListAdapter
import kotlinx.android.synthetic.main.activity_find_bros.*
import okhttp3.ResponseBody
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response


class FindBroActivity: AppCompatActivity() {

    val body: ArrayList<ArrayList<Bro>> = ArrayList()

    var potentialBros = ArrayList<Bro>()
    var broAdapter: ExpandableListAdapter? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_find_bros)

        val listView = bro_list_view
        broAdapter = ExpandableListAdapter(this@FindBroActivity, listView, potentialBros, body)
        listView.setAdapter(broAdapter)


        broAdapter!!.expandableListView.visibility = View.INVISIBLE

        buttonSearchBros.setOnClickListener(clickButtonListener)
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