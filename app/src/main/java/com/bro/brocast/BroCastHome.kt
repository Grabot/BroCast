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
import kotlinx.android.synthetic.main.brocast_home.*


class BroCastHome: AppCompatActivity() {

    lateinit var listView: ListView

    var bros = ArrayList<String>()
    var broAdapter: ArrayAdapter<String>? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.brocast_home)

        val intent = intent
        val broName= intent.getStringExtra("broName")
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
                startActivity(
                    Intent(
                        this@BroCastHome, FindBroActivity::class.java)
                )
            }
        }
    }
}