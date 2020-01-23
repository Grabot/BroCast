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


class FirstKeyboard: ScrollView {

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

        val emojis = resources.openRawResource(R.raw.emojis)
            .bufferedReader().use {
                it.readText()
            }

        val parser: Parser = Parser.default()
        val stringBuilder: StringBuilder = StringBuilder(emojis)
        val json = parser.parse(stringBuilder) as JsonArray<*>

        LayoutInflater.from(context).inflate(R.layout.keyboard_1, this, true)

        var stringIds = arrayOf(
            R.string.grinning_face,
            R.string.winking_face,
            R.string.face_blowing_a_kiss,
            R.string.kissing_face_with_closed_eyes,
            R.string.face_with_stuck_out_tongue,
            R.string.face_with_cold_sweat,
            R.string.pensive_face,
            R.string.face_with_tears_of_joy,
            R.string.smiling_face_with_heart_eyes,
            R.string.red_heart,
            R.string.rolling_on_the_floor_laughing,
            R.string.smiling_face_with_3_hearts,
            R.string.folded_hands,
            R.string.loudly_crying_face,
            R.string.right_facing_fist,
            R.string.left_facing_fist,
            R.string.eggplant,
            R.string.sweat_droplets,
            R.string.banana,
            R.string.thumbs_up,
            R.string.fire,
            R.string.rainbow,
            R.string.clinking_beer_mugs,
            R.string.wine_glass,
            R.string.thinking_face,
            R.string.mushroom,
            R.string.peach,
            R.string.pile_of_poo,
            R.string.woman_facepalming,
            R.string.fireworks,
            R.string.confetti_ball,
            R.string.party_popper
        )

        while ((stringIds.size % 8) != 0) {
            stringIds += 0
        }

        // The outer and main layer of the keyboard
        val mainLayout = findViewById<LinearLayout>(R.id.main_keyboard_layout)

        // creating the button
        val layers = createLayers(context, stringIds)
        for (layer in layers) {
            mainLayout.addView(layer)
        }

        // Create another layer, which is empty. This is to give some space at the bottom
        val spaceLayer = LinearLayout(context)
        val layout = LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, 80)
        layout.weight = 1f
        spaceLayer.layoutParams = layout
        mainLayout.addView(spaceLayer)

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