package com.bro.brocast.keyboards

import android.content.Context
import android.text.TextUtils
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View.OnClickListener
import android.view.inputmethod.InputConnection
import android.widget.Button
import android.widget.LinearLayout
import com.bro.brocast.R
import com.bro.brocast.R.id.button_smile
import com.bro.brocast.R.id.button_back
import com.bro.brocast.R.id.button_wink
import com.bro.brocast.R.id.button_throwing_a_kiss
import com.bro.brocast.R.id.button_kissing_face_closed_eyes
import com.bro.brocast.R.id.button_stuck_out_tongue
import com.bro.brocast.R.id.button_cold_sweat
import com.bro.brocast.R.id.button_pensive
import com.bro.brocast.R.id.button_tears_of_joy
import com.bro.brocast.R.id.button_heart_shaped_eyes
import com.bro.brocast.R.id.button_heart
import com.bro.brocast.R.id.button_rolling_on_the_floor
import com.bro.brocast.R.id.button_face_with_hearts
import com.bro.brocast.R.id.button_folded_hands
import com.bro.brocast.R.id.button_loudly_crying
import com.bro.brocast.R.id.button_right_facing_fist
import com.bro.brocast.R.id.button_left_facing_fist
import com.bro.brocast.R.id.button_eggplant
import com.bro.brocast.R.id.button_sweat_droplets
import com.bro.brocast.R.id.button_banana
import com.bro.brocast.R.id.button_thumbs_up
import com.bro.brocast.R.id.button_fire
import com.bro.brocast.R.id.button_rainbow
import com.bro.brocast.R.id.button_clinking_beer_mugs
import com.bro.brocast.R.id.button_thinking_face
import com.bro.brocast.R.id.button_wine_glass
import com.bro.brocast.R.id.button_mushroom
import com.bro.brocast.R.id.button_peach
import com.bro.brocast.R.id.button_exlamation_mark
import com.bro.brocast.R.id.button_question_mark
import com.bro.brocast.R.id.button_pile_of_poo
import com.bro.brocast.R.id.button_person_facepalming
import com.bro.brocast.R.id.button_fireworks
import com.bro.brocast.R.id.button_party_poppers
import com.bro.brocast.R.id.button_confetti_ball

class FirstKeyboard: LinearLayout {

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

    fun init(context: Context) {
        LayoutInflater.from(context).inflate(R.layout.keyboard_1, this, true)

        val buttonIds = arrayOf(
            button_smile,
            button_back,
            button_wink,
            button_throwing_a_kiss,
            button_kissing_face_closed_eyes,
            button_stuck_out_tongue,
            button_cold_sweat,
            button_pensive,
            button_tears_of_joy,
            button_heart_shaped_eyes,
            button_heart,
            button_rolling_on_the_floor,
            button_face_with_hearts,
            button_folded_hands,
            button_loudly_crying,
            button_right_facing_fist,
            button_left_facing_fist,
            button_eggplant,
            button_sweat_droplets,
            button_banana,
            button_thumbs_up,
            button_fire,
            button_rainbow,
            button_clinking_beer_mugs,
            button_thinking_face,
            button_wine_glass,
            button_mushroom,
            button_peach,
            button_exlamation_mark,
            button_question_mark,
            button_pile_of_poo,
            button_person_facepalming,
            button_fireworks,
            button_party_poppers,
            button_confetti_ball
        )

        for (b in buttonIds) {
            findViewById<Button>(b).setOnClickListener(clickButtonListener)
        }
    }

    private val clickButtonListener = OnClickListener { view ->
        when (view.getId()) {
            button_back -> {
                val selectedText = inputConnection!!.getSelectedText(0)

                if (TextUtils.isEmpty(selectedText)) {
                    // We assume that the emoji will always have length 2
                    // TODO @Skools: sometimes the emoji is NOT length 2. Fix this!
                    //  Possibly a complete Emoji overhaul
                    if (inputConnection!!.getTextBeforeCursor(1, 1).toString().equals("❤")
                        || inputConnection!!.getTextBeforeCursor(1, 1).toString().equals("!")
                        || inputConnection!!.getTextBeforeCursor(1, 1).toString().equals("?")) {
                        // Simple solution to fix the emoji's and characters of length 1
                        inputConnection!!.deleteSurroundingText(1, 0)
                    } else {
                        inputConnection!!.deleteSurroundingText(2, 0)
                    }
                } else {
                    inputConnection!!.commitText("", 1)
                }
            }
            // row 1
            button_smile -> {
                inputConnection!!.commitText(context.getString(R.string.emoji_smile), 1)
            }
            button_wink -> {
                inputConnection!!.commitText(context.getString(R.string.emoji_wink), 1)
            }
            button_throwing_a_kiss -> {
                inputConnection!!.commitText(context.getString(R.string.emoji_throwing_a_kiss), 1)
            }
            button_kissing_face_closed_eyes -> {
                inputConnection!!.commitText(context.getString(R.string.emoji_kissing_face_closed_eyes), 1)
            }
            button_stuck_out_tongue -> {
                inputConnection!!.commitText(context.getString(R.string.emoji_stuck_out_tongue), 1)
            }
            button_cold_sweat -> {
                inputConnection!!.commitText(context.getString(R.string.emoji_cold_sweat), 1)
            }
            button_pensive -> {
                inputConnection!!.commitText(context.getString(R.string.emoji_pensive), 1)
            }
            // row 2
            button_tears_of_joy -> {
                inputConnection!!.commitText(context.getString(R.string.emoji_tears_of_joy), 1)
            }
            button_heart_shaped_eyes -> {
                inputConnection!!.commitText(context.getString(R.string.emoji_heart_shaped_eyes), 1)
            }
            button_heart -> {
                inputConnection!!.commitText(context.getString(R.string.emoji_heart), 1)
            }
            button_rolling_on_the_floor -> {
                inputConnection!!.commitText(context.getString(R.string.emoji_rolling_on_the_floor), 1)
            }
            button_face_with_hearts -> {
                inputConnection!!.commitText(context.getString(R.string.emoji_face_with_hearts), 1)
            }
            button_folded_hands -> {
                inputConnection!!.commitText(context.getString(R.string.emoji_folded_hands), 1)
            }
            button_loudly_crying -> {
                inputConnection!!.commitText(context.getString(R.string.emoji_loudly_crying), 1)
            }
            button_right_facing_fist -> {
                inputConnection!!.commitText(context.getString(R.string.emoji_right_facing_fist), 1)
            }
            button_left_facing_fist -> {
                inputConnection!!.commitText(context.getString(R.string.emoji_left_facing_fist), 1)
            }
            // row 3
            button_eggplant -> {
                inputConnection!!.commitText(context.getString(R.string.emoji_eggplant), 1)
            }
            button_sweat_droplets -> {
                inputConnection!!.commitText(context.getString(R.string.emoji_sweat_droplets), 1)
            }
            button_banana -> {
                inputConnection!!.commitText(context.getString(R.string.emoji_banana), 1)
            }
            button_thumbs_up -> {
                inputConnection!!.commitText(context.getString(R.string.emoji_thumbs_up), 1)
            }
            button_fire -> {
                inputConnection!!.commitText(context.getString(R.string.emoji_fire), 1)
            }
            button_rainbow -> {
                inputConnection!!.commitText(context.getString(R.string.emoji_rainbow), 1)
            }
            button_clinking_beer_mugs -> {
                inputConnection!!.commitText(context.getString(R.string.emoji_clinking_beer_mugs), 1)
            }
            button_thinking_face -> {
                inputConnection!!.commitText(context.getString(R.string.emoji_thinking_face), 1)
            }
            button_wine_glass -> {
                inputConnection!!.commitText(context.getString(R.string.emoji_wine_glass), 1)
            }

            // row 4
            button_mushroom -> {
                inputConnection!!.commitText(context.getString(R.string.emoji_mushroom), 1)
            }
            button_peach -> {
                inputConnection!!.commitText(context.getString(R.string.emoji_peach), 1)
            }
            button_pile_of_poo -> {
                inputConnection!!.commitText(context.getString(R.string.emoji_pile_of_poo), 1)
            }
            button_person_facepalming -> {
                inputConnection!!.commitText(context.getString(R.string.emoji_person_facepalming), 1)
            }
            button_fireworks -> {
                inputConnection!!.commitText(context.getString(R.string.emoji_fireworks), 1)
            }
            button_party_poppers -> {
                inputConnection!!.commitText(context.getString(R.string.emoji_party_poppers), 1)
            }
            button_confetti_ball -> {
                inputConnection!!.commitText(context.getString(R.string.emoji_confetti_ball), 1)
            }
            button_exlamation_mark -> {
                inputConnection!!.commitText("!", 1)
            }
            button_question_mark -> {
                inputConnection!!.commitText("?", 1)
            }
        }
    }

    fun setInputConnection(ic: InputConnection) {
        inputConnection = ic
    }
}