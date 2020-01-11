package com.bro.brocast.keyboards

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View.OnClickListener
import android.view.inputmethod.InputConnection
import android.widget.Button
import android.widget.LinearLayout
import com.bro.brocast.R
import com.bro.brocast.R.id.button_grinning_face
import com.bro.brocast.R.id.button_smiling_face_with_open_mouth
import com.bro.brocast.R.id.button_smiling_face_with_open_mouth_and_smilinge_eyes
import com.bro.brocast.R.id.button_grinning_face_with_smiling_eyes
import com.bro.brocast.R.id.button_smiling_face_with_open_mouth_and_closed_eyes
import com.bro.brocast.R.id.button_smiling_face_with_open_mouth_and_cold_sweat
import com.bro.brocast.R.id.button_face_with_tears_of_joy
import com.bro.brocast.R.id.button_rolling_on_the_floor_laughing
import com.bro.brocast.R.id.button_smiling_face
import com.bro.brocast.R.id.button_smiling_face_with_smiling_eyes
import com.bro.brocast.R.id.button_smiling_face_with_halo
import com.bro.brocast.R.id.button_slightly_smiling_face
import com.bro.brocast.R.id.button_upside_down_face
import com.bro.brocast.R.id.button_winking_face
import com.bro.brocast.R.id.button_relieved_face
import com.bro.brocast.R.id.button_smiling_face_with_heart_eyes
import com.bro.brocast.R.id.button_smiling_face_with_3_hearts
import com.bro.brocast.R.id.button_face_blowing_a_kiss
import com.bro.brocast.R.id.button_kissing_face

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

    private fun init(context: Context) {
        LayoutInflater.from(context).inflate(R.layout.keyboard_1, this, true)

        val buttonIds = arrayOf(
            button_grinning_face,
            button_smiling_face_with_open_mouth,
            button_smiling_face_with_open_mouth_and_smilinge_eyes,
            button_grinning_face_with_smiling_eyes,
            button_smiling_face_with_open_mouth_and_closed_eyes,
            button_smiling_face_with_open_mouth_and_cold_sweat,
            button_face_with_tears_of_joy,
            button_rolling_on_the_floor_laughing,
            button_smiling_face,
            button_smiling_face_with_smiling_eyes,
            button_smiling_face_with_halo,
            button_slightly_smiling_face,
            button_upside_down_face,
            button_winking_face,
            button_relieved_face,
            button_smiling_face_with_heart_eyes,
            button_smiling_face_with_3_hearts,
            button_face_blowing_a_kiss,
            button_kissing_face
        )

        for (b in buttonIds) {
            findViewById<Button>(b).setOnClickListener(clickButtonListener)
        }
    }

    private val clickButtonListener = OnClickListener { view ->
        when (view.id) {
            button_grinning_face -> {
                inputConnection!!.commitText(context.getString(R.string.grinning_face), 1)
            }
            button_smiling_face_with_open_mouth -> {
                inputConnection!!.commitText(context.getString(R.string.smiling_face_with_open_mouth), 1)
            }
            button_smiling_face_with_open_mouth_and_smilinge_eyes -> {
                inputConnection!!.commitText(context.getString(R.string.smiling_face_with_open_mouth_and_smilinge_eyes), 1)
            }
            button_grinning_face_with_smiling_eyes -> {
                inputConnection!!.commitText(context.getString(R.string.grinning_face_with_smiling_eyes), 1)
            }
            button_smiling_face_with_open_mouth_and_closed_eyes -> {
                inputConnection!!.commitText(context.getString(R.string.smiling_face_with_open_mouth_and_closed_eyes), 1)
            }
            button_smiling_face_with_open_mouth_and_cold_sweat -> {
                inputConnection!!.commitText(context.getString(R.string.smiling_face_with_open_mouth_and_cold_sweat), 1)
            }
            button_face_with_tears_of_joy -> {
                inputConnection!!.commitText(context.getString(R.string.face_with_tears_of_joy), 1)
            }
            button_rolling_on_the_floor_laughing -> {
                inputConnection!!.commitText(context.getString(R.string.rolling_on_the_floor_laughing), 1)
            }
            button_smiling_face -> {
                inputConnection!!.commitText(context.getString(R.string.smiling_face), 1)
            }
            button_smiling_face_with_smiling_eyes -> {
                inputConnection!!.commitText(context.getString(R.string.smiling_face_with_smiling_eyes), 1)
            }
            button_smiling_face_with_halo -> {
                inputConnection!!.commitText(context.getString(R.string.smiling_face_with_halo), 1)
            }
            button_slightly_smiling_face -> {
                inputConnection!!.commitText(context.getString(R.string.slightly_smiling_face), 1)
            }
            button_upside_down_face -> {
                inputConnection!!.commitText(context.getString(R.string.upside_down_face), 1)
            }
            button_winking_face -> {
                inputConnection!!.commitText(context.getString(R.string.winking_face), 1)
            }
            button_relieved_face -> {
                inputConnection!!.commitText(context.getString(R.string.relieved_face), 1)
            }
            button_smiling_face_with_heart_eyes -> {
                inputConnection!!.commitText(context.getString(R.string.smiling_face_with_heart_eyes), 1)
            }
            button_smiling_face_with_3_hearts -> {
                inputConnection!!.commitText(context.getString(R.string.smiling_face_with_3_hearts), 1)
            }
            button_face_blowing_a_kiss -> {
                inputConnection!!.commitText(context.getString(R.string.face_blowing_a_kiss), 1)
            }
            button_kissing_face -> {
                inputConnection!!.commitText(context.getString(R.string.kissing_face), 1)
            }
        }
    }

    fun setInputConnection(ic: InputConnection) {
        inputConnection = ic
    }
}