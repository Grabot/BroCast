package com.bro.brocast

import android.content.Context
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.text.Editable
import android.text.InputType
import android.text.TextWatcher
import android.view.View
import android.view.inputmethod.InputMethodManager
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import com.bro.brocast.adapters.ExpandableBrodapter
import com.bro.brocast.api.AddBroAPI
import com.bro.brocast.api.FindBroAPI
import com.bro.brocast.keyboards.BroBoard
import kotlinx.android.synthetic.main.activity_find_bros.*


class FindBroActivity: AppCompatActivity() {

    var broName: String? = ""
    var bromotion: String? = ""
    var expandableBrodapter: ExpandableBrodapter? = null

    var bromotionField: EditText? = null
    var broNameField: EditText? = null

    var broBoard: BroBoard? = null

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

        bromotionField!!.setRawInputType(InputType.TYPE_CLASS_TEXT)
        bromotionField!!.setTextIsSelectable(true)
        bromotionField!!.setTextSize(20f)

        bromotionField!!.setOnFocusChangeListener(focusChangeListener)
        broNameField!!.setOnFocusChangeListener(focusChangeListener)

        var bromotion_length: Int = 0
        bromotionField!!.addTextChangedListener(object : TextWatcher {
            // We assume the emoji length is always 2
            override fun afterTextChanged(s: Editable) {
                // TODO @Skools: Code reuse in the Login, Register en FindBro application with the bromotion input
                s.delete(0, bromotion_length)
            }

            override fun beforeTextChanged(s: CharSequence, start: Int, count: Int, after: Int ) {
                bromotion_length = start
            }

            override fun onTextChanged(s: CharSequence, start: Int, before: Int, count: Int) {
            }
        })

        val questionButton = findViewById<Button>(R.id.button_question)
        val exclamationButton = findViewById<Button>(R.id.button_exclamation)
        val backButton = findViewById<ImageButton>(R.id.button_back)
        val searchEmojiButton = findViewById<ImageButton>(R.id.button_search_emoji)

        broBoard = BroBoard(this, bromotionField!!, questionButton, exclamationButton, backButton)

        bromotionField!!.showSoftInputOnFocus = false
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

                    // Incredibly ugly hack to ensure that the keyboard and the
                    // bromotionboard are not visible at the same time.
                    Handler().postDelayed({
                        // We want to make the keyboard visible if it isn't yet.
                        if (!broBoard!!.visible) {
                            broBoard!!.makeVisible()
                        }
                    }, 100)
                }
            }
            R.id.broNameBroSearch -> {
                if (b) {
                    println("focus on the broname field")
                    // The user clicked on the other field so we make the emotion keyboard invisible
                    if (broBoard!!.visible) {
                        broBoard!!.makeInvisible()
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
                    FindBroAPI.findBro(broName!!, bromotion!!, potentialBro, potentialBromotion, applicationContext, this)
                }
            }
        }
    }
}