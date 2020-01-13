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


class SecondKeyboard: LinearLayout {

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
        LayoutInflater.from(context).inflate(R.layout.keyboard_2, this, true)

        val buttonIds = arrayOf(
            R.id.button_dog_face,
            R.id.button_cat_face,
            R.id.button_mouse_face,
            R.id.button_hamster_face,
            R.id.button_rabbit_face,
            R.id.button_fox_face,
            R.id.button_bear_face,
            R.id.button_panda_face,
            R.id.button_koala,
            R.id.button_tiger_face,
            R.id.button_lion_face,
            R.id.button_cow_face,
            R.id.button_pig_face,
            R.id.button_pig_nose,
            R.id.button_frog_face,
            R.id.button_monkey_face,
            R.id.button_see_no_evil_monkey,
            R.id.button_hear_no_evil_monkey,
            R.id.button_speak_no_evil_monkey
        )

        for (b in buttonIds) {
            findViewById<Button>(b).setOnClickListener(clickButtonListener)
        }
    }

    private val clickButtonListener = OnClickListener { view ->
        when (view.getId()) {
            R.id.button_dog_face -> {
                inputConnection!!.commitText(context.getString(R.string.dog_face), 1)
            }
            R.id.button_cat_face -> {
                inputConnection!!.commitText(context.getString(R.string.cat_face), 1)
            }
            R.id.button_mouse_face -> {
                inputConnection!!.commitText(context.getString(R.string.mouse_face), 1)
            }
            R.id.button_hamster_face -> {
                inputConnection!!.commitText(context.getString(R.string.hamster_face), 1)
            }
            R.id.button_rabbit_face -> {
                inputConnection!!.commitText(context.getString(R.string.rabbit_face), 1)
            }
            R.id.button_fox_face -> {
                inputConnection!!.commitText(context.getString(R.string.fox_face), 1)
            }
            R.id.button_bear_face -> {
                inputConnection!!.commitText(context.getString(R.string.bear_face), 1)
            }
            R.id.button_panda_face -> {
                inputConnection!!.commitText(context.getString(R.string.panda_face), 1)
            }
            R.id.button_koala -> {
                inputConnection!!.commitText(context.getString(R.string.koala), 1)
            }
            R.id.button_tiger_face -> {
                inputConnection!!.commitText(context.getString(R.string.tiger_face), 1)
            }
            R.id.button_lion_face -> {
                inputConnection!!.commitText(context.getString(R.string.lion_face), 1)
            }
            R.id.button_cow_face -> {
                inputConnection!!.commitText(context.getString(R.string.cow_face), 1)
            }
            R.id.button_pig_face -> {
                inputConnection!!.commitText(context.getString(R.string.pig_face), 1)
            }
            R.id.button_pig_nose -> {
                inputConnection!!.commitText(context.getString(R.string.pig_nose), 1)
            }
            R.id.button_frog_face -> {
                inputConnection!!.commitText(context.getString(R.string.frog_face), 1)
            }
            R.id.button_monkey_face -> {
                inputConnection!!.commitText(context.getString(R.string.monkey_face), 1)
            }
            R.id.button_see_no_evil_monkey -> {
                inputConnection!!.commitText(context.getString(R.string.see_no_evil_monkey), 1)
            }
            R.id.button_hear_no_evil_monkey -> {
                inputConnection!!.commitText(context.getString(R.string.hear_no_evil_monkey), 1)
            }
            R.id.button_speak_no_evil_monkey -> {
                inputConnection!!.commitText(context.getString(R.string.speak_no_evil_monkey), 1)
            }
        }
    }

    fun setInputConnection(ic: InputConnection) {
        inputConnection = ic
    }
}