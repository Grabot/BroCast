package com.bro.brocast.keyboards

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.view.View.OnClickListener
import android.view.ViewTreeObserver.OnScrollChangedListener
import android.view.inputmethod.InputConnection
import android.text.TextUtils
import android.view.ViewGroup
import android.widget.*
import com.beust.klaxon.JsonArray
import com.beust.klaxon.Parser
import com.bro.brocast.R


class Keyboard: ScrollView {

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

    private var inputConnection: InputConnection? = null

    var extraInputField: RelativeLayout? = null

    var questionButton: Button? = null
    var exclamationButton: Button? = null
    var backButton: ImageButton? = null

    private fun init(context: Context) {

//        val emojis = resources.openRawResource(R.raw.emojis)
//            .bufferedReader().use {
//                it.readText()
//            }
//
//        val parser: Parser = Parser.default()
//        val stringBuilder: StringBuilder = StringBuilder(emojis)
//        val json = parser.parse(stringBuilder) as JsonArray<*>

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

        // creating the first category
        val layers1 = createLayers(context, firstKeyboardBromojis)
        for (layer in layers1) {
            mainLayout.addView(layer)
        }

        // Create another layer, which is empty. This is to give some space at the bottom
        val spaceLayerFirst = LinearLayout(context)
        val layoutFirst = LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, 80)
        layoutFirst.weight = 1f
        spaceLayerFirst.layoutParams = layoutFirst
        mainLayout.addView(spaceLayerFirst)

        // TODO @Skools: place a category change indicator here.
        // creating the second category
        val layers2 = createLayers(context, bromojisPeople)
        for (layer in layers2) {
            mainLayout.addView(layer)
        }

        // Create another layer, which is empty. This is to give some space at the bottom
        val spaceLayerPeople = LinearLayout(context)
        val layoutPeople = LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, 80)
        layoutPeople.weight = 1f
        spaceLayerPeople.layoutParams = layoutPeople
        mainLayout.addView(spaceLayerPeople)

        val layers3 = createLayers(context, bromojisAnimals)
        for (layer in layers3) {
            mainLayout.addView(layer)
        }

        // Create another layer, which is empty. This is to give some space at the bottom
        val spaceLayerAnimals = LinearLayout(context)
        val layoutAnimals = LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, 80)
        layoutAnimals.weight = 1f
        spaceLayerAnimals.layoutParams = layoutAnimals
        mainLayout.addView(spaceLayerAnimals)

        val layers4 = createLayers(context, bromojisFood)
        for (layer in layers4) {
            mainLayout.addView(layer)
        }

        // Create another layer, which is empty. This is to give some space at the bottom
        val spaceLayerFood = LinearLayout(context)
        val layoutFood = LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, 80)
        layoutFood.weight = 1f
        spaceLayerFood.layoutParams = layoutFood
        mainLayout.addView(spaceLayerFood)

        val layers5 = createLayers(context, bromojisSports)
        for (layer in layers5) {
            mainLayout.addView(layer)
        }

        // Create another layer, which is empty. This is to give some space at the bottom
        val spaceLayerSports = LinearLayout(context)
        val layoutSports = LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, 80)
        layoutSports.weight = 1f
        spaceLayerSports.layoutParams = layoutSports
        mainLayout.addView(spaceLayerSports)

        val layers6 = createLayers(context, bromojisTravel)
        for (layer in layers6) {
            mainLayout.addView(layer)
        }

        // Create another layer, which is empty. This is to give some space at the bottom
        val spaceLayerTravel = LinearLayout(context)
        val layoutTravel = LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, 80)
        layoutTravel.weight = 1f
        spaceLayerTravel.layoutParams = layoutTravel
        mainLayout.addView(spaceLayerTravel)

        val layers7 = createLayers(context, bromojisObjects)
        for (layer in layers7) {
            mainLayout.addView(layer)
        }

        // Create another layer, which is empty. This is to give some space at the bottom
        val spaceLayerObjects = LinearLayout(context)
        val layoutObjects = LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, 80)
        layoutObjects.weight = 1f
        spaceLayerObjects.layoutParams = layoutObjects
        mainLayout.addView(spaceLayerObjects)

        val layers8 = createLayers(context, bromojisSymbols)
        for (layer in layers8) {
            mainLayout.addView(layer)
        }

        // Create another layer, which is empty. This is to give some space at the bottom
        val spaceLayerSymbols = LinearLayout(context)
        val layoutSymbols = LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, 80)
        layoutSymbols.weight = 1f
        spaceLayerSymbols.layoutParams = layoutSymbols
        mainLayout.addView(spaceLayerSymbols)

        val layers9 = createLayers(context, bromojisFlags)
        for (layer in layers9) {
            mainLayout.addView(layer)
        }

        val spaceLayerFlags = LinearLayout(context)
        val layoutFlag = LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, 80)
        layoutFlag.weight = 1f
        spaceLayerFlags.layoutParams = layoutFlag
        mainLayout.addView(spaceLayerFlags)

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

    private val onScrollchangedListener = OnScrollChangedListener {
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
}