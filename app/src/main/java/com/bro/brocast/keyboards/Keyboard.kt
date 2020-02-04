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
import com.beust.klaxon.JsonObject
import com.beust.klaxon.Parser
import com.bro.brocast.R


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

        // emoji versions found so far; 12.1.1, 12.1.0, 12.0.0, 11.0.1, 11.0.0, 5.0.0, 1.2.0, 1.1.1, 1.1.0, 1.0.0
        val bromoji = BromojiList()
        val emojis = resources.openRawResource(R.raw.emoji_api)
            .bufferedReader().use {
                it.readText()
            }

        val parser: Parser = Parser.default()
        val stringBuilder: StringBuilder = StringBuilder(emojis)
        val json = parser.parse(stringBuilder) as JsonArray<*>

        println("processing all emojis")
        for (i in 0 until json.size) {
            val emoji = json.get(i) as JsonObject

            val codes_full = emoji.get("codes") as String
            val char = emoji.get("char") as String
            val name = emoji.get("name") as String

            var codes: Array<String> = arrayOf()
            if (codes_full.contains(" ")) {
                for (c in codes_full.split(" ")) {
                    codes += c
                }
            } else {
                codes += codes_full
            }

            val apis = emoji.get("apis") as JsonArray<*>
            for (api in apis) {
                if (android.os.Build.VERSION.SDK_INT == api as Int) {
                    val category = emoji.get("category") as String

                    if (category == "Smileys") {
                        bromoji.addPeopleCategory(codes, char, name, category)
                    }
                    if (category == "Animals") {
                        bromoji.addAnimalsCategory(codes, char, name, category)
                    }
                    if (category == "Food") {
                        bromoji.addFoodCategory(codes, char, name, category)
                    }
                    if (category == "Travel") {
                        bromoji.addTravelCategory(codes, char, name, category)
                    }
                    if (category == "Activities") {
                        bromoji.addSportsCategory(codes, char, name, category)
                    }
                    if (category == "Objects") {
                        bromoji.addObjectsCategory(codes, char, name, category)
                    }
                    if (category == "Symbols") {
                        bromoji.addSymbolsCategory(codes, char, name, category)
                    }
                    if (category == "Flags") {
                        bromoji.addFlagsCategory(codes, char, name, category)
                    }
                }
            }
        }

        LayoutInflater.from(context).inflate(R.layout.keyboard_1, this, true)

        while ((bromoji.bromojiFirstKeyboard.size % 8) != 0) {
            bromoji.addMostUsed(arrayOf(), "", "", "")
        }

        while ((bromoji.bromojiPeople.size % 8) != 0) {
            bromoji.addPeopleCategory(arrayOf(), "", "", "")
        }

        while ((bromoji.bromojiAnimals.size % 8) != 0) {
            bromoji.addAnimalsCategory(arrayOf(), "", "", "")
        }

        while ((bromoji.bromojiFood.size % 8) != 0) {
            bromoji.addFoodCategory(arrayOf(), "", "", "")
        }

        while ((bromoji.bromojiSports.size % 8) != 0) {
            bromoji.addSportsCategory(arrayOf(), "", "", "")
        }

        while ((bromoji.bromojiTravel.size % 8) != 0) {
            bromoji.addTravelCategory(arrayOf(), "", "", "")
        }

        while ((bromoji.bromojiObjects.size % 8) != 0) {
            bromoji.addObjectsCategory(arrayOf(), "", "", "")
        }

        while ((bromoji.bromojiSymbols.size % 8) != 0) {
            bromoji.addSymbolsCategory(arrayOf(), "", "", "")
        }

        while ((bromoji.bromojiFlags.size % 8) != 0) {
            bromoji.addFlagsCategory(arrayOf(), "", "", "")
        }

        // The outer and main layer of the keyboard
        val mainLayout = findViewById<LinearLayout>(R.id.main_keyboard_layout)

        layers = arrayOf(
            ArrayList(), ArrayList(), ArrayList(), ArrayList(), ArrayList(), ArrayList(), ArrayList(), ArrayList(), ArrayList()
        )
        val bromojis = arrayOf(
            bromoji.bromojiFirstKeyboard,
            bromoji.bromojiPeople,
            bromoji.bromojiAnimals,
            bromoji.bromojiFood,
            bromoji.bromojiSports,
            bromoji.bromojiTravel,
            bromoji.bromojiObjects,
            bromoji.bromojiSymbols,
            bromoji.bromojiFlags
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
        for (i in layers.indices) {
            layers[i] = createLayers(context, bromojis[i])

            val spaceLayer = LinearLayout(context)
            val layout = LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 80)
            layout.weight = 1f
            spaceLayer.layoutParams = layout

            val textViewCategory = TextView(context)
            textViewCategory.layoutParams = LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
            textViewCategory.gravity = Gravity.CENTER
            textViewCategory.setText(spaceLayerText[i])
            spaceLayer.addView(textViewCategory)

            layers[i].add(spaceLayer)
            for (layer in layers[i]) {
                mainLayout.addView(layer)
            }
        }

        this.viewTreeObserver.addOnScrollChangedListener(onScrollchangedListener)
    }

    private fun createLayers(context: Context, bromojiArray: ArrayList<Bromoji>): ArrayList<LinearLayout> {
        var layers: ArrayList<LinearLayout> = ArrayList()
        for(n in bromojiArray.indices step 8) {
            val layer = arrayOf(
                bromojiArray.get(n),
                bromojiArray.get(n+1),
                bromojiArray.get(n+2),
                bromojiArray.get(n+3),
                bromojiArray.get(n+4),
                bromojiArray.get(n+5),
                bromojiArray.get(n+6),
                bromojiArray.get(n+7)
            )
            val layoutLayer = createLayoutLayer(context, layer)
            layers.add(layoutLayer)
        }
        return layers
    }

    private fun createLayoutLayer(
        context: Context,
        bromojiArray: Array<Bromoji>
    ): LinearLayout {
        val newLayer = LinearLayout(context)
        for (bromoji in bromojiArray) {
            val button = createButton(context, bromoji)
            newLayer.addView(button)
        }
        return newLayer
    }

    private fun createButton(context: Context, bromoji: Bromoji): Button {
        val button = Button(context, null, android.R.attr.borderlessButtonStyle)
        val layout = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT)
        layout.weight = 1f
        button.layoutParams = layout
        button.textSize = 19f
        if (bromoji.char != "") {
            button.id = View.generateViewId()
            button.text = bromoji.char
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
                println("button pressed " + button.text)
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