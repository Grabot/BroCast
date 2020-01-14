package com.bro.brocast.keyboards

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View.OnClickListener
import android.view.inputmethod.InputConnection
import android.widget.Button
import android.widget.LinearLayout
import com.bro.brocast.R


class SeventhKeyboard: LinearLayout {

    constructor(context: Context) : super(context) {
        init(context)
    }

    constructor(context: Context, attrs: AttributeSet) : super(context, attrs) {
        init(context)
    }

    constructor(context: Context, attrs: AttributeSet?, defStyleAttr: Int) : super(
        context,
        attrs,
        defStyleAttr
    ) {
        init(context)
    }

    private var inputConnection: InputConnection? = null

    fun init(context: Context) {
        LayoutInflater.from(context).inflate(R.layout.keyboard_7, this, true)

        val buttonIds = arrayOf(
            R.id.button_red_heart,
            R.id.button_orange_heart,
            R.id.button_yellow_heart,
            R.id.button_green_heart,
            R.id.button_blue_heart,
            R.id.button_purple_heart,
            R.id.button_black_heart,
            R.id.button_broken_heart,
            R.id.button_heavy_heart_exclamation,
            R.id.button_two_hearts,
            R.id.button_revolving_hearts,
            R.id.button_beating_heart,
            R.id.button_growing_heart,
            R.id.button_sparkling_heart,
            R.id.button_heart_with_arrow,
            R.id.button_heart_with_ribbon,
            R.id.button_heart_decoration,
            R.id.button_peace_symbol,
            R.id.button_latin_cross
        )

        for (b in buttonIds) {
            findViewById<Button>(b).setOnClickListener(clickButtonListener)
        }
    }

    private val clickButtonListener = OnClickListener { view ->
        when (view.getId()) {
            R.id.button_red_heart -> {
                inputConnection!!.commitText(context.getString(R.string.red_heart), 1)
            }
            R.id.button_orange_heart -> {
                inputConnection!!.commitText(context.getString(R.string.orange_heart), 1)
            }
            R.id.button_yellow_heart -> {
                inputConnection!!.commitText(context.getString(R.string.yellow_heart), 1)
            }
            R.id.button_green_heart -> {
                inputConnection!!.commitText(context.getString(R.string.green_heart), 1)
            }
            R.id.button_blue_heart -> {
                inputConnection!!.commitText(context.getString(R.string.blue_heart), 1)
            }
            R.id.button_purple_heart -> {
                inputConnection!!.commitText(context.getString(R.string.purple_heart), 1)
            }
            R.id.button_black_heart -> {
                inputConnection!!.commitText(context.getString(R.string.black_heart), 1)
            }
            R.id.button_broken_heart -> {
                inputConnection!!.commitText(context.getString(R.string.broken_heart), 1)
            }
            R.id.button_heavy_heart_exclamation -> {
                inputConnection!!.commitText(context.getString(R.string.heavy_heart_exclamation), 1)
            }
            R.id.button_two_hearts -> {
                inputConnection!!.commitText(context.getString(R.string.two_hearts), 1)
            }
            R.id.button_revolving_hearts -> {
                inputConnection!!.commitText(context.getString(R.string.revolving_hearts), 1)
            }
            R.id.button_beating_heart -> {
                inputConnection!!.commitText(context.getString(R.string.beating_heart), 1)
            }
            R.id.button_growing_heart -> {
                inputConnection!!.commitText(context.getString(R.string.growing_heart), 1)
            }
            R.id.button_sparkling_heart -> {
                inputConnection!!.commitText(context.getString(R.string.sparkling_heart), 1)
            }
            R.id.button_heart_with_arrow -> {
                inputConnection!!.commitText(context.getString(R.string.heart_with_arrow), 1)
            }
            R.id.button_heart_with_ribbon -> {
                inputConnection!!.commitText(context.getString(R.string.heart_with_ribbon), 1)
            }
            R.id.button_heart_decoration -> {
                inputConnection!!.commitText(context.getString(R.string.heart_decoration), 1)
            }
            R.id.button_peace_symbol -> {
                inputConnection!!.commitText(context.getString(R.string.peace_symbol), 1)
            }
            R.id.button_latin_cross -> {
                inputConnection!!.commitText(context.getString(R.string.latin_cross), 1)
            }
        }
    }

    fun setInputConnection(ic: InputConnection) {
        inputConnection = ic
    }
}