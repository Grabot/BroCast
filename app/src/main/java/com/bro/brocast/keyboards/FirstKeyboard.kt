package com.bro.brocast.keyboards

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.view.View.OnClickListener
import android.view.ViewTreeObserver.OnScrollChangedListener
import android.view.inputmethod.InputConnection
import android.widget.Button
import android.widget.ImageButton
import android.widget.RelativeLayout
import android.widget.ScrollView
import android.text.TextUtils
import com.beust.klaxon.JsonArray
import com.beust.klaxon.JsonObject
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

        val buttonIds = arrayOf(
            R.id.button_grinning_face,
            R.id.button_winking_face,
            R.id.button_face_blowing_a_kiss,
            R.id.button_kissing_face_with_closed_eyes,
            R.id.button_face_with_stuck_out_tongue,
            R.id.button_face_with_cold_sweat,
            R.id.button_pensive_face,
            R.id.button_face_with_tears_of_joy,
            R.id.button_smiling_face_with_heart_eyes,
            R.id.button_red_heart,
            R.id.button_rolling_on_the_floor_laughing,
            R.id.button_smiling_face_with_3_hearts,
            R.id.button_folded_hands,
            R.id.button_loudly_crying_face,
            R.id.button_right_facing_fist,
            R.id.button_left_facing_fist,
            R.id.button_eggplant,
            R.id.button_sweat_droplets,
            R.id.button_banana,
            R.id.button_thumbs_up,
            R.id.button_fire,
            R.id.button_rainbow,
            R.id.button_clinking_beer_mugs,
            R.id.button_wine_glass,
            R.id.button_thinking_face,
            R.id.button_mushroom,
            R.id.button_peach,
            R.id.button_pile_of_poo,
            R.id.button_woman_facepalming,
            R.id.button_fireworks,
            R.id.button_confetti_ball,
            R.id.button_party_popper
        )

        for (b in buttonIds) {
            findViewById<Button>(b).setOnClickListener(clickButtonListener)
        }

        this.viewTreeObserver.addOnScrollChangedListener(onScrollchangedListener)
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
            R.id.button_grinning_face -> {
                inputConnection!!.commitText(context.getString(R.string.grinning_face), 1)
                if (extraInputField!!.visibility != View.VISIBLE) {
                    extraInputField!!.visibility = View.VISIBLE
                }
            }
            R.id.button_winking_face -> {
                inputConnection!!.commitText(context.getString(R.string.winking_face), 1)
                if (extraInputField!!.visibility != View.VISIBLE) {
                    extraInputField!!.visibility = View.VISIBLE
                }
            }
            R.id.button_face_blowing_a_kiss -> {
                inputConnection!!.commitText(context.getString(R.string.face_blowing_a_kiss), 1)
                if (extraInputField!!.visibility != View.VISIBLE) {
                    extraInputField!!.visibility = View.VISIBLE
                }
            }
            R.id.button_kissing_face_with_closed_eyes -> {
                inputConnection!!.commitText(context.getString(R.string.kissing_face_with_closed_eyes), 1)
                if (extraInputField!!.visibility != View.VISIBLE) {
                    extraInputField!!.visibility = View.VISIBLE
                }
            }
            R.id.button_face_with_stuck_out_tongue -> {
                inputConnection!!.commitText(context.getString(R.string.face_with_stuck_out_tongue), 1)
                if (extraInputField!!.visibility != View.VISIBLE) {
                    extraInputField!!.visibility = View.VISIBLE
                }
            }
            R.id.button_face_with_cold_sweat -> {
                inputConnection!!.commitText(context.getString(R.string.face_with_cold_sweat), 1)
                if (extraInputField!!.visibility != View.VISIBLE) {
                    extraInputField!!.visibility = View.VISIBLE
                }
            }
            R.id.button_pensive_face -> {
                inputConnection!!.commitText(context.getString(R.string.pensive_face), 1)
                if (extraInputField!!.visibility != View.VISIBLE) {
                    extraInputField!!.visibility = View.VISIBLE
                }
            }
            R.id.button_face_with_tears_of_joy -> {
                inputConnection!!.commitText(context.getString(R.string.face_with_tears_of_joy), 1)
                if (extraInputField!!.visibility != View.VISIBLE) {
                    extraInputField!!.visibility = View.VISIBLE
                }
            }
            R.id.button_smiling_face_with_heart_eyes -> {
                inputConnection!!.commitText(context.getString(R.string.smiling_face_with_heart_eyes), 1)
                if (extraInputField!!.visibility != View.VISIBLE) {
                    extraInputField!!.visibility = View.VISIBLE
                }
            }
            R.id.button_red_heart -> {
                inputConnection!!.commitText(context.getString(R.string.red_heart), 1)
                if (extraInputField!!.visibility != View.VISIBLE) {
                    extraInputField!!.visibility = View.VISIBLE
                }
            }
            R.id.button_rolling_on_the_floor_laughing -> {
                inputConnection!!.commitText(context.getString(R.string.rolling_on_the_floor_laughing), 1)
                if (extraInputField!!.visibility != View.VISIBLE) {
                    extraInputField!!.visibility = View.VISIBLE
                }
            }
            R.id.button_smiling_face_with_3_hearts -> {
                inputConnection!!.commitText(context.getString(R.string.smiling_face_with_3_hearts), 1)
                if (extraInputField!!.visibility != View.VISIBLE) {
                    extraInputField!!.visibility = View.VISIBLE
                }
            }
            R.id.button_folded_hands -> {
                inputConnection!!.commitText(context.getString(R.string.folded_hands), 1)
                if (extraInputField!!.visibility != View.VISIBLE) {
                    extraInputField!!.visibility = View.VISIBLE
                }
            }
            R.id.button_loudly_crying_face -> {
                inputConnection!!.commitText(context.getString(R.string.loudly_crying_face), 1)
                if (extraInputField!!.visibility != View.VISIBLE) {
                    extraInputField!!.visibility = View.VISIBLE
                }
            }
            R.id.button_right_facing_fist -> {
                inputConnection!!.commitText(context.getString(R.string.right_facing_fist), 1)
                if (extraInputField!!.visibility != View.VISIBLE) {
                    extraInputField!!.visibility = View.VISIBLE
                }
            }
            R.id.button_left_facing_fist -> {
                inputConnection!!.commitText(context.getString(R.string.left_facing_fist), 1)
                if (extraInputField!!.visibility != View.VISIBLE) {
                    extraInputField!!.visibility = View.VISIBLE
                }
            }
            R.id.button_eggplant -> {
                inputConnection!!.commitText(context.getString(R.string.eggplant), 1)
                if (extraInputField!!.visibility != View.VISIBLE) {
                    extraInputField!!.visibility = View.VISIBLE
                }
            }
            R.id.button_sweat_droplets -> {
                inputConnection!!.commitText(context.getString(R.string.sweat_droplets), 1)
                if (extraInputField!!.visibility != View.VISIBLE) {
                    extraInputField!!.visibility = View.VISIBLE
                }
            }
            R.id.button_banana -> {
                inputConnection!!.commitText(context.getString(R.string.banana), 1)
                if (extraInputField!!.visibility != View.VISIBLE) {
                    extraInputField!!.visibility = View.VISIBLE
                }
            }
            R.id.button_thumbs_up -> {
                inputConnection!!.commitText(context.getString(R.string.thumbs_up), 1)
                if (extraInputField!!.visibility != View.VISIBLE) {
                    extraInputField!!.visibility = View.VISIBLE
                }
            }
            R.id.button_fire -> {
                inputConnection!!.commitText(context.getString(R.string.fire), 1)
                if (extraInputField!!.visibility != View.VISIBLE) {
                    extraInputField!!.visibility = View.VISIBLE
                }
            }
            R.id.button_rainbow -> {
                inputConnection!!.commitText(context.getString(R.string.rainbow), 1)
                if (extraInputField!!.visibility != View.VISIBLE) {
                    extraInputField!!.visibility = View.VISIBLE
                }
            }
            R.id.button_clinking_beer_mugs -> {
                inputConnection!!.commitText(context.getString(R.string.clinking_beer_mugs), 1)
                if (extraInputField!!.visibility != View.VISIBLE) {
                    extraInputField!!.visibility = View.VISIBLE
                }
            }
            R.id.button_wine_glass -> {
                inputConnection!!.commitText(context.getString(R.string.wine_glass), 1)
                if (extraInputField!!.visibility != View.VISIBLE) {
                    extraInputField!!.visibility = View.VISIBLE
                }
            }
            R.id.button_thinking_face -> {
                inputConnection!!.commitText(context.getString(R.string.thinking_face), 1)
                if (extraInputField!!.visibility != View.VISIBLE) {
                    extraInputField!!.visibility = View.VISIBLE
                }
            }
            R.id.button_mushroom -> {
                inputConnection!!.commitText(context.getString(R.string.mushroom), 1)
                if (extraInputField!!.visibility != View.VISIBLE) {
                    extraInputField!!.visibility = View.VISIBLE
                }
            }
            R.id.button_peach -> {
                inputConnection!!.commitText(context.getString(R.string.peach), 1)
                if (extraInputField!!.visibility != View.VISIBLE) {
                    extraInputField!!.visibility = View.VISIBLE
                }
            }
            R.id.button_pile_of_poo -> {
                inputConnection!!.commitText(context.getString(R.string.pile_of_poo), 1)
                if (extraInputField!!.visibility != View.VISIBLE) {
                    extraInputField!!.visibility = View.VISIBLE
                }
            }
            R.id.button_woman_facepalming -> {
                inputConnection!!.commitText(context.getString(R.string.woman_facepalming), 1)
                if (extraInputField!!.visibility != View.VISIBLE) {
                    extraInputField!!.visibility = View.VISIBLE
                }
            }
            R.id.button_fireworks -> {
                inputConnection!!.commitText(context.getString(R.string.fireworks), 1)
                if (extraInputField!!.visibility != View.VISIBLE) {
                    extraInputField!!.visibility = View.VISIBLE
                }
            }
            R.id.button_confetti_ball -> {
                inputConnection!!.commitText(context.getString(R.string.confetti_ball), 1)
                if (extraInputField!!.visibility != View.VISIBLE) {
                    extraInputField!!.visibility = View.VISIBLE
                }
            }
            R.id.button_party_popper -> {
                inputConnection!!.commitText(context.getString(R.string.party_popper), 1)
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