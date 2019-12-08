package com.bro.brocast

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.AdapterView
import android.widget.ListView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.beust.klaxon.JsonArray
import com.beust.klaxon.JsonObject
import com.beust.klaxon.Parser
import com.bro.brocast.objects.Bro
import com.bro.brocast.adapters.Brodapter
import com.bro.brocast.api.BroCastAPI
import kotlinx.android.synthetic.main.brocast_home.*
import okhttp3.ResponseBody
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response


class BroCastHome: AppCompatActivity() {

    lateinit var listView: ListView

    var bros = ArrayList<Bro>()
    var brodapter: Brodapter? = null

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

        brodapter = Brodapter(
            this,
            R.layout.bro_list, bros
        )

        listView = findViewById(R.id.bro_home_list_view)
        listView.adapter = brodapter
        listView.visibility = View.VISIBLE

        listView.onItemClickListener = broClickListener

        fillBroList()
    }

    private val broClickListener = AdapterView.OnItemClickListener {  parent, view, position, id ->

        val bro = listView.getItemAtPosition(position) as Bro
        // TODO @Sander: Toast the values for now, add actual functionality to add the bro.
        Toast.makeText(applicationContext,
            "Position :$position\nItem Value : " + bro.broName, Toast.LENGTH_LONG)
            .show()

        val successIntent = Intent(this@BroCastHome, MessagingActivity::class.java)
        successIntent.putExtra("broName", broName)
        successIntent.putExtra("brosBro", bro.broName)
        startActivity(successIntent)
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
                                val broList = json.get("bro_list") as JsonArray<*>
                                bros.clear()
                                // TODO @Skools: add a check that will exclude the logged in bro. We will do this client side instead of server side to not do too much on the server side
                                for (b in broList) {
                                    val foundBro = b as JsonObject
                                    val broName: String = foundBro.get("bro_name") as String
                                    val id: Int = foundBro.get("id") as Int

                                    // Add the bro to the potential bro list
                                    val bro = Bro(broName, id, "")
                                    bros.add(bro)
                                }
                                brodapter!!.notifyDataSetChanged()
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