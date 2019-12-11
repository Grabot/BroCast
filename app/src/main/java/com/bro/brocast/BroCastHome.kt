package com.bro.brocast

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.AdapterView
import android.widget.ListView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.bro.brocast.objects.Bro
import com.bro.brocast.adapters.Brodapter
import com.bro.brocast.api.GetBroAPI
import kotlinx.android.synthetic.main.brocast_home.*


class BroCastHome: AppCompatActivity() {

    lateinit var listView: ListView

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
            R.layout.bro_list, GetBroAPI.bros
        )

        listView = findViewById(R.id.bro_home_list_view)
        listView.adapter = brodapter
        listView.visibility = View.VISIBLE

        listView.onItemClickListener = broClickListener

        // Fill the broList of the bro
        GetBroAPI.getBroAPI(broName, applicationContext, this@BroCastHome)
    }

    fun notifyBrodapter() {
        brodapter!!.notifyDataSetChanged()
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