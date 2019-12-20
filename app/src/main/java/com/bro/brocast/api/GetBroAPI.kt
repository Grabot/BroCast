package com.bro.brocast.api

import android.content.Context
import android.widget.Toast
import com.beust.klaxon.JsonArray
import com.beust.klaxon.JsonObject
import com.beust.klaxon.Parser
import com.bro.brocast.BroCastHome
import com.bro.brocast.objects.Bro
import okhttp3.ResponseBody
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

object GetBroAPI {

    var bros = ArrayList<Bro>()

    fun getBroAPI(
        loggedInBroName: String,
        bromotion: String,
        context: Context,
        broCastHome: BroCastHome
    ) {
        BroCastAPI
            .service
            .getBros(loggedInBroName, bromotion)
            .enqueue(object : Callback<ResponseBody> {
                override fun onFailure(call: Call<ResponseBody>, t: Throwable) {
                    // The BroCast Backend server is not running
                    Toast.makeText(
                        context,
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
                                val broList = json.get("bro_list") as JsonArray<*>
                                bros.clear()
                                for (b in broList) {
                                    val foundBro = b as JsonObject
                                    val broName: String = foundBro.get("bro_name") as String
                                    val bromotion: String = foundBro.get("bromotion") as String
                                    val id: Int = foundBro.get("id") as Int

                                    if (loggedInBroName != broName) {
                                        // Add the bro to the potential bro list
                                        val bro = Bro(broName, id, bromotion)
                                        bros.add(bro)
                                    }
                                }
                                broCastHome.notifyBrodapter()
                            } else {
                                Toast.makeText(
                                    context,
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
}