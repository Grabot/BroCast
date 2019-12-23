package com.bro.brocast

import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.text.Editable
import android.text.InputType
import android.text.TextWatcher
import android.view.View
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputMethodManager
import android.widget.EditText
import android.widget.ExpandableListView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.bro.brocast.adapters.ExpandableBrodapter
import com.bro.brocast.api.AddBroAPI
import com.bro.brocast.api.FindBroAPI
import com.bro.brocast.objects.MyKeyboard
import kotlinx.android.synthetic.main.activity_find_bros.*
import androidx.core.app.ComponentActivity.ExtraData
import androidx.core.content.ContextCompat.getSystemService
import android.icu.lang.UCharacter.GraphemeClusterBreak.T
import kotlinx.android.synthetic.main.activity_find_bros.keyboard
import kotlinx.android.synthetic.main.activity_messaging.*


class FindBroActivity: AppCompatActivity() {

    var broName: String? = ""
    var bromotion: String? = ""
    var expandableBrodapter: ExpandableBrodapter? = null

    var bromotionField: EditText? = null
    var broNameField: EditText? = null


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_find_bros)

        val intent = intent
        broName = intent.getStringExtra("broName")
        bromotion = intent.getStringExtra("bromotion")

        val listView = bro_list_view
        expandableBrodapter = ExpandableBrodapter(
            this@FindBroActivity,
            listView,
            FindBroAPI.potentialBros,
            FindBroAPI.body
        )
        listView.setAdapter(expandableBrodapter)

        expandableBrodapter!!.expandableListView.visibility = View.INVISIBLE
        expandableBrodapter!!.expandableListView.setOnChildClickListener(onChildClickListener)

        buttonSearchBros.setOnClickListener(clickButtonListener)

        bromotionField = findViewById(R.id.broNameSearchEmotion) as EditText
        broNameField = findViewById(R.id.broNameBroSearch) as EditText
        val keyboard = findViewById(R.id.keyboard) as MyKeyboard

        bromotionField!!.setRawInputType(InputType.TYPE_CLASS_TEXT)
        bromotionField!!.setTextIsSelectable(true)
        bromotionField!!.setTextSize(20f)
        // TODO @Skools: set the minimum SDK to this version (LOLLIPOP).
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            bromotionField!!.requestFocus()
            bromotionField!!.showSoftInputOnFocus = false
        }

        bromotionField!!.setOnFocusChangeListener(focusChangeListener)
        broNameField!!.setOnFocusChangeListener(focusChangeListener)

        val ic = bromotionField!!.onCreateInputConnection(EditorInfo())
        keyboard.setInputConnection(ic)

        bromotionField!!.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(s: Editable) {
                // TODO @Skools: Code reuse in the Login, Register en FindBro application with the bromotion input
                if (s.length > 1 ) {
                    if (s.toString().endsWith("❤")
                        || s.toString().endsWith("!")
                        || s.toString().endsWith("?")
                    ) {
                        // An emoji was entered and the last was a heart (or ?/!)
                        // It is too long, so we remove only 1
                        s.delete(0, 1)
                    }
                }
                if (s.length > 2) {
                    if (s.toString().startsWith("❤")
                        || s.toString().startsWith("!")
                        || s.toString().startsWith("?")
                    ) {
                        s.delete(0, 1)
                    } else {
                        s.delete(0, 2)
                    }
                }
            }

            override fun beforeTextChanged(s: CharSequence, start: Int, count: Int, after: Int ) {
            }

            override fun onTextChanged(s: CharSequence, start: Int, before: Int, count: Int) {
            }
        })

        // We set the focus to the broname field
        broNameField!!.requestFocus()
    }

    private val focusChangeListener = View.OnFocusChangeListener { view, b ->
        when (view.getId()) {
            R.id.broNameSearchEmotion -> {
                if (b) {
                    println("focus on bromotion field")
                    try {
                        // We want to show the listview and hide the keyboard.
                        val imm: InputMethodManager =
                            applicationContext.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
                        imm.hideSoftInputFromWindow(
                            this.currentFocus!!.windowToken,
                            0
                        )
                        println("keyboard hidden")
                    } catch (e: Exception) {
                        // This is for the keyboard. If something went wrong
                        // than, whatever! It will not effect the app!
                    }

                    // We want to make the keyboard visible if it isn't yet.
                    if (keyboard.visibility != View.VISIBLE) {
                        keyboard.visibility = View.VISIBLE
                    }

                }
            }
            R.id.broNameBroSearch -> {
                if (b) {
                    println("focus on the broname field")
                    // The user clicked on the other field so we make the emotion keyboard invisible
                    if (keyboard.visibility == View.VISIBLE) {
                        keyboard.visibility = View.INVISIBLE
                    }
                }
            }
        }
    }

    fun notifyAdapter() {
        expandableBrodapter!!.notifyDataSetChanged()
        expandableBrodapter!!.expandableListView.visibility = View.VISIBLE
    }

    private val onChildClickListener = ExpandableListView.OnChildClickListener {
            parent, v, groupPosition, childPosition, id ->
        val bro = FindBroAPI.potentialBros[groupPosition]

        println("bro $broName wants to add ${bro.broName} to his brolist")
        AddBroAPI.addBro(broName!!, bromotion!!, bro.broName, bro.bromotion, applicationContext, this@FindBroActivity)
        false
    }

    private val clickButtonListener = View.OnClickListener { view ->
        when (view.getId()) {
            R.id.buttonSearchBros -> {
                // TODO @Sander: potentially expand it with an emoji search
                val potentialBro = broNameBroSearch.text.toString()
                if (potentialBro == "") {
                    Toast.makeText(this, "No Bro filled in yet", Toast.LENGTH_SHORT).show()
                } else {
                    var potentialBromotion = broNameSearchEmotion.text.toString()
                    if (potentialBromotion == "") {
                        // The backend will look for 'None' to determine whether or not the bromotion should be used.
                        potentialBromotion = "None"
                    }
                    FindBroAPI.findBro(broName!!, potentialBro, potentialBromotion, applicationContext, this)
                }
            }
        }
    }

    override fun onBackPressed() {
        // We want to make the keyboard visible if it isn't yet.
        if (keyboard.visibility == View.VISIBLE) {
            keyboard.visibility = View.GONE
        } else {
            super.onBackPressed()
        }
    }
}