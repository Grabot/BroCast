package com.bro.brocast

import android.os.Bundle
import android.view.View
import android.widget.ExpandableListView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.bro.brocast.adapters.ExpandableBrodapter
import com.bro.brocast.api.AddAPI
import com.bro.brocast.api.FindAPI
import com.bro.brocast.objects.Bro
import kotlinx.android.synthetic.main.activity_find_bros.*


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
        expandableBrodapter!!.expandableListView.setOnChildClickListener(onChildClickListener)

        buttonSearchBros.setOnClickListener(clickButtonListener)
    }

    fun addBro(bro: Bro) {
        println("bro $broName wants to add ${bro.broName} to his brolist")
        AddAPI.addBro(broName, bro.broName, applicationContext, this@FindBroActivity)
    }

    fun notifyAdapter() {
        expandableBrodapter!!.notifyDataSetChanged()
        expandableBrodapter!!.expandableListView.visibility = View.VISIBLE
    }

    private val onChildClickListener = ExpandableListView.OnChildClickListener {
            parent, v, groupPosition, childPosition, id ->
        var bro = FindAPI.potentialBros[groupPosition]
        Toast.makeText(applicationContext, "Clicked: " + FindAPI.potentialBros[groupPosition].broName + " -> " + FindAPI.body[groupPosition].get(childPosition).id.toString(), Toast.LENGTH_SHORT).show()
        addBro(bro)
        false
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