package com.bro.brocast

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.view.inputmethod.InputMethodManager
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.beust.klaxon.JsonArray
import com.beust.klaxon.JsonObject
import com.beust.klaxon.Parser
import com.bro.brocast.objects.Bro
import com.bro.brocast.adapters.ExpandableBrodapter
import com.bro.brocast.api.AddAPI
import com.bro.brocast.api.BroCastAPI
import com.bro.brocast.api.FindAPI
import kotlinx.android.synthetic.main.activity_find_bros.*
import okhttp3.ResponseBody
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response


class FindBroActivity: AppCompatActivity() {

    var broName: String = ""
    var expandableBrodapter: ExpandableBrodapter? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_find_bros)

        val intent = intent
        broName = intent.getStringExtra("broName")

        val listView = bro_list_view
        expandableBrodapter = ExpandableBrodapter(
            this@FindBroActivity,
            listView,
            FindAPI.potentialBros,
            FindAPI.body
        )
        listView.setAdapter(expandableBrodapter)


        expandableBrodapter!!.expandableListView.visibility = View.INVISIBLE

        expandableBrodapter!!.expandableListView.setOnChildClickListener { parent, v, groupPosition, childPosition, id ->
            var bro = FindAPI.potentialBros[groupPosition]
            Toast.makeText(applicationContext, "Clicked: " + FindAPI.potentialBros[groupPosition].broName + " -> " + FindAPI.body[groupPosition].get(childPosition).id.toString(), Toast.LENGTH_SHORT).show()
            addBro(bro)
            false
        }


        buttonSearchBros.setOnClickListener(clickButtonListener)
    }

    fun addBro(bro: Bro) {
        println("bro $broName wants to add ${bro.broName} to his brolist")
        AddAPI.addBro(broName, bro.broName, applicationContext, this@FindBroActivity)
//        BroCastAPI
//            .service
//            .addBro(broName, bro.broName)
//            .enqueue(object : Callback<ResponseBody> {
//                override fun onFailure(call: Call<ResponseBody>, t: Throwable) {
//                    println("An exception occured with the GET call:: " + t.message)
//                    // The BroCast Backend server is not running
//                    Toast.makeText(
//                        applicationContext,
//                        "The BroCast server is not responding. " +
//                                "We appologize for the inconvenience, please try again later",
//                        Toast.LENGTH_SHORT
//                    ).show()
//                }
//                override fun onResponse(
//                    call: Call<ResponseBody>,
//                    response: Response<ResponseBody>
//                ) {
//                    if (response.isSuccessful) {
//                        val msg = response.body()?.string()
//                        Toast.makeText(applicationContext, msg, Toast.LENGTH_SHORT)
//                            .show()
//                        if (msg != null) {
//                            val parser: Parser = Parser.default()
//                            val stringBuilder: StringBuilder = StringBuilder(msg)
//                            val json: JsonObject = parser.parse(stringBuilder) as JsonObject
//                            val result = json.get("result")
//                            if (result!! == true) {
//                                println("bro $broName wants to add ${bro.broName} to his brolist")
//                                Toast.makeText(
//                                    applicationContext,
//                                    "bro $broName and bro ${bro.broName} are now bros",
//                                    Toast.LENGTH_SHORT
//                                ).show()
//                                val successIntent = Intent(this@FindBroActivity, BroCastHome::class.java).apply {
//                                    putExtra("broName", broName)
//                                }
//                                startActivity(successIntent)
//                            } else {
//                                Toast.makeText(
//                                    applicationContext,
//                                    "Something went wrong " +
//                                            "We appologize for the inconvenience, please try again later",
//                                    Toast.LENGTH_SHORT
//                                ).show()
//                            }
//                        }
//                    } else {
//                        // The BroCast Backend server gave an error
//                        Toast.makeText(
//                            applicationContext,
//                            "The BroCast server is down right. " +
//                                    "We appologize for the inconvenience, please try again later",
//                            Toast.LENGTH_SHORT
//                        ).show()
//                    }
//                }
//            })
    }

    fun notifyAdapter() {
        expandableBrodapter!!.notifyDataSetChanged()
        expandableBrodapter!!.expandableListView.visibility = View.VISIBLE
    }

    private val clickButtonListener = View.OnClickListener { view ->
        when (view.getId()) {
            R.id.buttonSearchBros -> {
                val potentialBro = broNameBroSearch.text.toString()
                if (potentialBro == "") {
                    Toast.makeText(this, "No Bro filled in yet", Toast.LENGTH_SHORT).show()
                } else {
                    FindAPI.findBro(potentialBro, applicationContext, this)
                }
            }
        }
    }
}