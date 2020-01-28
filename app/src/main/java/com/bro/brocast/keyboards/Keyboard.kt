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

    private lateinit var layers1: ArrayList<LinearLayout>
    private lateinit var layers2: ArrayList<LinearLayout>
    private lateinit var layers3: ArrayList<LinearLayout>
    private lateinit var layers4: ArrayList<LinearLayout>
    private lateinit var layers5: ArrayList<LinearLayout>
    private lateinit var layers6: ArrayList<LinearLayout>
    private lateinit var layers7: ArrayList<LinearLayout>
    private lateinit var layers8: ArrayList<LinearLayout>
    private lateinit var layers9: ArrayList<LinearLayout>

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
        layers1 = createLayers(context, firstKeyboardBromojis)

        // Create another layer, which is empty. This is to give some space at the bottom
        val spaceLayerFirst = LinearLayout(context)
        val layoutFirst = LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 80)
        layoutFirst.weight = 1f
        spaceLayerFirst.layoutParams = layoutFirst

        val textViewSmileys = TextView(context)
        textViewSmileys.layoutParams = LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
        textViewSmileys.gravity = Gravity.CENTER
        textViewSmileys.setText("Smileys and people")
        spaceLayerFirst.addView(textViewSmileys)

        layers1.add(spaceLayerFirst)
        for (layer in layers1) {
            mainLayout.addView(layer)
        }

        // TODO @Skools: place a category change indicator here.
        // creating the second category
        layers2 = createLayers(context, bromojisPeople)

        // Create another layer, which is empty. This is to give some space at the bottom
        val spaceLayerPeople = LinearLayout(context)
        val layoutPeople = LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 80)
        layoutPeople.weight = 1f
        spaceLayerPeople.layoutParams = layoutPeople

        val textViewAnimals = TextView(context)
        textViewAnimals.layoutParams = LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
        textViewAnimals.gravity = Gravity.CENTER
        textViewAnimals.setText("Animals and nature")
        spaceLayerPeople.addView(textViewAnimals)

        layers2.add(spaceLayerPeople)
        for (layer in layers2) {
            mainLayout.addView(layer)
        }

        layers3 = createLayers(context, bromojisAnimals)

        // Create another layer, which is empty. This is to give some space at the bottom
        val spaceLayerAnimals = LinearLayout(context)
        val layoutAnimals = LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 80)
        layoutAnimals.weight = 1f
        spaceLayerAnimals.layoutParams = layoutAnimals

        val textViewFood = TextView(context)
        textViewFood.layoutParams = LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
        textViewFood.gravity = Gravity.CENTER
        textViewFood.setText("Food and drinks")
        spaceLayerAnimals.addView(textViewFood)

        layers3.add(spaceLayerAnimals)
        for (layer in layers3) {
            mainLayout.addView(layer)
        }

        layers4 = createLayers(context, bromojisFood)

        // Create another layer, which is empty. This is to give some space at the bottom
        val spaceLayerFood = LinearLayout(context)
        val layoutFood = LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 80)
        layoutFood.weight = 1f
        spaceLayerFood.layoutParams = layoutFood

        val textViewSports = TextView(context)
        textViewSports.layoutParams = LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
        textViewSports.gravity = Gravity.CENTER
        textViewSports.setText("Sports and activities")
        spaceLayerFood.addView(textViewSports)

        layers4.add(spaceLayerFood)
        for (layer in layers4) {
            mainLayout.addView(layer)
        }

        layers5 = createLayers(context, bromojisSports)

        // Create another layer, which is empty. This is to give some space at the bottom
        val spaceLayerSports = LinearLayout(context)
        val layoutSports = LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 80)
        layoutSports.weight = 1f
        spaceLayerSports.layoutParams = layoutSports

        val textViewTravel = TextView(context)
        textViewTravel.layoutParams = LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
        textViewTravel.gravity = Gravity.CENTER
        textViewTravel.setText("Travel and places")
        spaceLayerSports.addView(textViewTravel)

        layers5.add(spaceLayerSports)
        for (layer in layers5) {
            mainLayout.addView(layer)
        }

        layers6 = createLayers(context, bromojisTravel)

        // Create another layer, which is empty. This is to give some space at the bottom
        val spaceLayerTravel = LinearLayout(context)
        val layoutTravel = LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 80)
        layoutTravel.weight = 1f
        spaceLayerTravel.layoutParams = layoutTravel

        val textViewObjects = TextView(context)
        textViewObjects.layoutParams = LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
        textViewObjects.gravity = Gravity.CENTER
        textViewObjects.setText("Objects")
        spaceLayerTravel.addView(textViewObjects)

        layers6.add(spaceLayerTravel)
        for (layer in layers6) {
            mainLayout.addView(layer)
        }

        layers7 = createLayers(context, bromojisObjects)

        // Create another layer, which is empty. This is to give some space at the bottom
        val spaceLayerObjects = LinearLayout(context)
        val layoutObjects = LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 80)
        layoutObjects.weight = 1f
        spaceLayerObjects.layoutParams = layoutObjects

        val textViewSymbols = TextView(context)
        textViewSymbols.layoutParams = LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
        textViewSymbols.gravity = Gravity.CENTER
        textViewSymbols.setText("Symbols")
        spaceLayerObjects.addView(textViewSymbols)

        layers7.add(spaceLayerObjects)
        for (layer in layers7) {
            mainLayout.addView(layer)
        }

        layers8 = createLayers(context, bromojisSymbols)

        // Create another layer, which is empty. This is to give some space at the bottom
        val spaceLayerSymbols = LinearLayout(context)
        val layoutSymbols = LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 80)
        layoutSymbols.weight = 1f
        spaceLayerSymbols.layoutParams = layoutSymbols

        val textViewFlags = TextView(context)
        textViewFlags.layoutParams = LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
        textViewFlags.gravity = Gravity.CENTER
        textViewFlags.setText("Flags")
        spaceLayerSymbols.addView(textViewFlags)

        layers8.add(spaceLayerSymbols)
        for (layer in layers8) {
            mainLayout.addView(layer)
        }

        layers9 = createLayers(context, bromojisFlags)

        val spaceLayerFlags = LinearLayout(context)
        val layoutFlag = LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 80)
        layoutFlag.weight = 1f
        spaceLayerFlags.layoutParams = layoutFlag

        layers9.add(spaceLayerFlags)
        for (layer in layers9) {
            mainLayout.addView(layer)
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

    fun determineLengthOfTabLayers() {
        var layerLength1 = 0
        for (layer in layers1) {
            layerLength1 += layer.height
        }
        println("height 1 layer! $layerLength1")
        var layerLength2 = 0
        for (layer in layers2) {
            layerLength2 += layer.height
        }
        println("height 2 layer! $layerLength2")
        var layerLength3 = 0
        for (layer in layers3) {
            layerLength3 += layer.height
        }
        println("height 3 layer! $layerLength3")
        var layerLength4 = 0
        for (layer in layers4) {
            layerLength4 += layer.height
        }
        println("height 4 layer! $layerLength4")
        var layerLength5 = 0
        for (layer in layers5) {
            layerLength5 += layer.height
        }
        println("height 5 layer! $layerLength5")
        var layerLength6 = 0
        for (layer in layers6) {
            layerLength6 += layer.height
        }
        println("height 6 layer! $layerLength6")
        var layerLength7 = 0
        for (layer in layers7) {
            layerLength7 += layer.height
        }
        println("height 7 layer! $layerLength7")
        var layerLength8 = 0
        for (layer in layers8) {
            layerLength8 += layer.height
        }
        println("height 8 layer! $layerLength8")
        var layerLength9 = 0
        for (layer in layers9) {
            layerLength9 += layer.height
        }
        println("height 9 layer! $layerLength9")

        val layerLengths = arrayOf(
            layerLength1,
            layerLength2,
            layerLength3,
            layerLength4,
            layerLength5,
            layerLength6,
            layerLength7,
            layerLength8,
            layerLength9
        )
        var lengthBoard = 0
        var distanceLengths: Array<Double> = arrayOf()
        for (layerLength in layerLengths) {
            val distanceTab = (scrollY.toDouble() - lengthBoard) / layerLength
            distanceLengths += distanceTab
            println("length of layer $distanceTab")
            lengthBoard += layerLength
        }
        println("scrolly $scrollY")
    }

    private val onScrollchangedListener = OnScrollChangedListener {
        determineLengthOfTabLayers()

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