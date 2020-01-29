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

        val bromoji = BromojiList()
        val emojis = resources.openRawResource(R.raw.emojis_bro)
            .bufferedReader().use {
                it.readText()
            }

        val parser: Parser = Parser.default()
        val stringBuilder: StringBuilder = StringBuilder(emojis)
        val json = parser.parse(stringBuilder) as JsonArray<*>

        println("processing all emojis")
        for (i in 0 until json.size) {
            val emoji = json.get(i) as JsonObject
            val codes = emoji.get("codes") as String
            val char = emoji.get("char") as String
            val name = emoji.get("name") as String
            val category = emoji.get("category") as String
            if (category.contains("Smileys & Emotion") || category.contains("People & Body")) {
                // For now we will exclude the skin tone emojis, we will add them later
                // TODO @Skools: add skin tone features!
                if (!name.contains("skin tone")) {
                    bromoji.addPeopleCategory(codes, char, name, category)
                }
            } else if (category.contains("Animals & Nature")) {
                bromoji.addAnimalsCategory(char)
            } else if (category.contains("Food & Drink")) {
                bromoji.addFoodCategory(char)
            } else if (category.contains("Activities")) {
                bromoji.addSportsCategory(char)
            } else if (category.contains("Travel & Places")) {
                bromoji.addTravelCategory(char)
            } else if (category.contains("Objects")) {
                bromoji.addObjectsCategory(char)
            } else if (category.contains("Symbols")) {
                bromoji.addSymbolsCategory(char)
            } else if (category.contains("Flags")) {
                bromoji.addFlagsCategory(char)
            }
        }

        LayoutInflater.from(context).inflate(R.layout.keyboard_1, this, true)

        while ((bromoji.bromojiFirstKeyboard.size % 8) != 0) {
            bromoji.bromojiFirstKeyboard.add("")
        }

        while ((bromoji.bromojiPeople2.size % 8) != 0) {
            bromoji.addPeopleCategory("", "", "", "")
        }

        while ((bromoji.bromojiAnimals.size % 8) != 0) {
            bromoji.bromojiAnimals.add("")
        }

        while ((bromoji.bromojiFood.size % 8) != 0) {
            bromoji.bromojiFood.add("")
        }

        while ((bromoji.bromojiSports.size % 8) != 0) {
            bromoji.bromojiSports.add("")
        }

        while ((bromoji.bromojiTravel.size % 8) != 0) {
            bromoji.bromojiTravel.add("")
        }

        while ((bromoji.bromojiObjects.size % 8) != 0) {
            bromoji.bromojiObjects.add("")
        }

        while ((bromoji.bromojiSymbols.size % 8) != 0) {
            bromoji.bromojiSymbols.add("")
        }

        while ((bromoji.bromojiFlags.size % 8) != 0) {
            bromoji.bromojiFlags.add("")
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

    private fun createLayers(context: Context, emojiArray: ArrayList<String>): ArrayList<LinearLayout> {
        var layers: ArrayList<LinearLayout> = ArrayList()
        for(n in emojiArray.indices step 8) {
            val layer = arrayOf(
                emojiArray.get(n),
                emojiArray.get(n+1),
                emojiArray.get(n+2),
                emojiArray.get(n+3),
                emojiArray.get(n+4),
                emojiArray.get(n+5),
                emojiArray.get(n+6),
                emojiArray.get(n+7)
            )
            val layoutLayer = createLayoutLayer(context, layer)
            layers.add(layoutLayer)
        }
        return layers
    }

    private fun createLayoutLayer(
        context: Context,
        emojiCharArray: Array<String>
    ): LinearLayout {
        val newLayer = LinearLayout(context)
        for (emojiChar in emojiCharArray) {
            val button = createButton(context, emojiChar)
            newLayer.addView(button)
        }
        return newLayer
    }

    private fun createButton(context: Context, emojiChar: String): Button {
        val button = Button(context, null, android.R.attr.borderlessButtonStyle)
        val layout = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT)
        layout.weight = 1f
        button.layoutParams = layout
        button.textSize = 19f
        if (emojiChar != "") {
            button.id = View.generateViewId()
            button.text = emojiChar
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