package com.bro.brocast.keyboards

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.view.View.OnClickListener
import android.view.ViewTreeObserver.OnScrollChangedListener
import android.view.inputmethod.InputConnection
import android.text.TextUtils
import android.view.Gravity
import android.view.ViewGroup
import android.widget.*
import com.beust.klaxon.JsonArray
import com.beust.klaxon.Parser
import com.bro.brocast.R
import java.text.FieldPosition


class Keyboard: ScrollView {

    private var broBoard: BroBoard? = null

    private var inputConnection: InputConnection? = null

    var extraInputField: RelativeLayout? = null

    var questionButton: Button? = null
    var exclamationButton: Button? = null
    var backButton: ImageButton? = null

    lateinit var layers: Array<ArrayList<LinearLayout>>

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        // TODO @Sander: find a way to set a decent height!
        val height = 650

        val heightSpec = MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY)

        super.onMeasure(widthMeasureSpec, heightSpec)
    }

    constructor(context: Context) : super(context){
        init(context)
    }

    constructor(context: Context, attrs: AttributeSet):    super(context, attrs){
        init(context)
    }

    constructor(context: Context, attrs: AttributeSet?,    defStyleAttr: Int) : super(context, attrs, defStyleAttr) {
        init(context)
    }

    private fun init(context: Context) {

        val emojis = resources.openRawResource(R.raw.emojis)
            .bufferedReader().use {
                it.readText()
            }

        val parser: Parser = Parser.default()
        val stringBuilder: StringBuilder = StringBuilder(emojis)
        val json = parser.parse(stringBuilder) as JsonArray<*>

        LayoutInflater.from(context).inflate(R.layout.keyboard_1, this, true)

        while ((firstKeyboardBromojis.size % 8) != 0) {
            firstKeyboardBromojis += 0
        }

        while ((bromojisPeople.size % 8) != 0) {
            bromojisPeople += 0
        }

        while ((bromojisAnimals.size % 8) != 0) {
            bromojisAnimals += 0
        }

        while ((bromojisFood.size % 8) != 0) {
            bromojisFood += 0
        }

        while ((bromojisSports.size % 8) != 0) {
            bromojisSports += 0
        }

        while ((bromojisTravel.size % 8) != 0) {
            bromojisTravel += 0
        }

        while ((bromojisObjects.size % 8) != 0) {
            bromojisObjects += 0
        }

        while ((bromojisSymbols.size % 8) != 0) {
            bromojisSymbols += 0
        }

        while ((bromojisFlags.size % 8) != 0) {
            bromojisFlags += 0
        }

        // The outer and main layer of the keyboard
        val mainLayout = findViewById<LinearLayout>(R.id.main_keyboard_layout)

        layers = arrayOf(
            ArrayList(), ArrayList(), ArrayList(), ArrayList(), ArrayList(), ArrayList(), ArrayList(), ArrayList(), ArrayList()
        )
        val bromojis = arrayOf(
            firstKeyboardBromojis,
            bromojisPeople,
            bromojisAnimals,
            bromojisFood,
            bromojisSports,
            bromojisTravel,
            bromojisObjects,
            bromojisSymbols,
            bromojisFlags
        )
        val spaceLayerText = arrayOf(
            "Smileys and people",
            "Animals and nature",
            "Food and drinks",
            "Sports and activities",
            "Travel and places",
            "Objects",
            "Symbols",
            "Flags",
            ""
        )
        for (i in 0 until bromojis.size) {
        // creating the first category
            layers[i] = createLayers(context, bromojis[i])

            // Create another layer, which is empty. This is to give some space at the bottom
            val spaceLayerFirst = LinearLayout(context)
            val layoutFirst = LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 80)
            layoutFirst.weight = 1f
            spaceLayerFirst.layoutParams = layoutFirst

            val textViewSmileys = TextView(context)
            textViewSmileys.layoutParams = LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
            textViewSmileys.gravity = Gravity.CENTER
            textViewSmileys.setText(spaceLayerText[i])
            spaceLayerFirst.addView(textViewSmileys)

            layers[i].add(spaceLayerFirst)
            for (layer in layers[i]) {
                mainLayout.addView(layer)
            }
        }

        this.viewTreeObserver.addOnScrollChangedListener(onScrollchangedListener)
    }

    private fun createLayers(context: Context, stringIdArray: Array<Int>): ArrayList<LinearLayout> {
        var layers: ArrayList<LinearLayout> = ArrayList()
        for(n in stringIdArray.indices step 8) {
            val layer = arrayOf(
                stringIdArray[n],
                stringIdArray[n+1],
                stringIdArray[n+2],
                stringIdArray[n+3],
                stringIdArray[n+4],
                stringIdArray[n+5],
                stringIdArray[n+6],
                stringIdArray[n+7]
            )
            val layoutLayer = createLayoutLayer(context, layer)
            layers.add(layoutLayer)
        }
        return layers
    }

    private fun createLayoutLayer(
        context: Context,
        stringIdArray: Array<Int>
    ): LinearLayout {
        val newLayer = LinearLayout(context)
        for (stringId in stringIdArray) {
            val button = createButton(context, stringId)
            newLayer.addView(button)
        }
        return newLayer
    }

    private fun createButton(context: Context, buttonId: Int): Button {
        val button = Button(context, null, android.R.attr.borderlessButtonStyle)
        val layout = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT)
        layout.weight = 1f
        button.layoutParams = layout
        button.textSize = 19f
        if (buttonId != 0) {
            button.id = View.generateViewId()
            button.text = context.getString(buttonId)
            button.setOnClickListener(clickButtonListener)
        } else {
            button.text = ""
            button.isClickable = false
        }
        return button
    }

    fun setClickListenerExtraFields() {
        questionButton!!.setOnClickListener(clickButtonListener)
        exclamationButton!!.setOnClickListener(clickButtonListener)
        backButton!!.setOnClickListener(clickButtonListener)
    }

    fun determineLengthOfTabLayers(position: Int) {
        var lengthBoard = 0
        for (i in layers.indices) {
            var lengthOfLayer = 0
            for (layer in layers[i]) {
                lengthOfLayer += layer.height
            }
            val distanceTab = (scrollY.toFloat() - lengthBoard) / lengthOfLayer
            if ((distanceTab >= 0 && distanceTab < 1)) {
                broBoard!!.goToTabPosition(i, distanceTab)
            }
            if (i == position) {
                scrollY = lengthBoard
            }
            lengthBoard += lengthOfLayer
        }
    }

    private val onScrollchangedListener = OnScrollChangedListener {
        determineLengthOfTabLayers(-1)

        if (this.visibility != View.GONE) {
            extraInputField!!.visibility = View.GONE
            if (scrollY == 0) {
                if (extraInputField!!.visibility != View.VISIBLE) {
                    extraInputField!!.visibility = View.VISIBLE
                }
            } else {
                if (extraInputField!!.visibility != View.GONE) {
                    extraInputField!!.visibility = View.GONE
                }
            }
        }
    }

    private val clickButtonListener = OnClickListener { view ->
        when (view.id) {
            R.id.button_back -> {
                val selectedText = inputConnection!!.getSelectedText(0)
                var test = inputConnection!!.getTextBeforeCursor(1, 0)

                if (TextUtils.isEmpty(selectedText)) {
                    inputConnection!!.deleteSurroundingText(1, 0)
                } else {
                    inputConnection!!.commitText("", 1)
                }
            }
            R.id.button_question -> {
                inputConnection!!.commitText("?", 1)
            }
            R.id.button_exclamation -> {
                inputConnection!!.commitText("!", 1)
            }
            else -> {
                val button = findViewById<Button>(view.id)
                inputConnection!!.commitText(button.text, 1)

                if (extraInputField!!.visibility != View.VISIBLE) {
                    extraInputField!!.visibility = View.VISIBLE
                }
            }
        }
    }

    fun setInputConnection(ic: InputConnection) {
        inputConnection = ic
    }

    fun setBroBoard(broBoard: BroBoard) {
        this.broBoard = broBoard
    }
}