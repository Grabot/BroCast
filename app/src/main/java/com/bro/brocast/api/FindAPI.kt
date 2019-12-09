package com.bro.brocast.api

import android.content.Context
import android.view.inputmethod.InputMethodManager
import android.widget.Toast
import com.beust.klaxon.JsonArray
import com.beust.klaxon.JsonObject
import com.beust.klaxon.Parser
import com.bro.brocast.FindBroActivity
import com.bro.brocast.objects.Bro
import okhttp3.ResponseBody
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

object FindAPI {

    var potentialBros = ArrayList<Bro>()
    val body: ArrayList<ArrayList<Bro>> = ArrayList()

    fun findBro(potentialBro: String, context: Context, findBroActivity: FindBroActivity) {
        BroCastAPI
            .service
            .findBro(potentialBro)
            .enqueue(object : Callback<ResponseBody> {
                override fun onFailure(call: Call<ResponseBody>, t: Throwable) {
                    println("An exception occured with the GET call:: " + t.message)
                    // The BroCast Backend server is not running
                    Toast.makeText(
                        context,
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
                        Toast.makeText(context, msg, Toast.LENGTH_SHORT)
                            .show()
                        if (msg != null) {
                            val parser: Parser = Parser.default()
                            val stringBuilder: StringBuilder = StringBuilder(msg)
                            val json: JsonObject = parser.parse(stringBuilder) as JsonObject
                            val bros = json.get("bros") as JsonArray<*>

                            potentialBros.clear()
                            body.clear()

                            // TODO @Skools: add a check that will exclude the logged in bro. We will do this client side instead of server side to not do too much on the server side
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
                            findBroActivity.notifyAdapter()
                            try {
                                // We want to show the listview and hide the keyboard.
                                val imm: InputMethodManager =
                                    context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
                                imm.hideSoftInputFromWindow(
                                    findBroActivity.currentFocus!!.windowToken,
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