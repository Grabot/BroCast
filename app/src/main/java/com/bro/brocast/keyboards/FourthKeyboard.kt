package com.bro.brocast.keyboards

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View.OnClickListener
import android.view.inputmethod.InputConnection
import android.widget.Button
import android.widget.LinearLayout
import com.bro.brocast.R


class FourthKeyboard: LinearLayout {

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
        LayoutInflater.from(context).inflate(R.layout.keyboard_4, this, true)

        val buttonIds = arrayOf(
            R.id.button_soccer_ball,
            R.id.button_basketball,
            R.id.button_american_football,
            R.id.button_baseball,
            R.id.button_softball,
            R.id.button_tennis,
            R.id.button_volleyball,
            R.id.button_rugby_football,
            R.id.button_flying_disc,
            R.id.button_pool_8_ball,
            R.id.button_ping_pong,
            R.id.button_badminton,
            R.id.button_ice_hockey,
            R.id.button_field_hockey,
            R.id.button_lacrosse,
            R.id.button_cricket_sport,
            R.id.button_goal_net,
            R.id.button_flag_in_hole,
            R.id.button_bow_and_arrow
        )

        for (b in buttonIds) {
            findViewById<Button>(b).setOnClickListener(clickButtonListener)
        }
    }

    private val clickButtonListener = OnClickListener { view ->
        when (view.getId()) {
            R.id.button_soccer_ball -> {
                inputConnection!!.commitText(context.getString(R.string.soccer_ball), 1)
            }
            R.id.button_basketball -> {
                inputConnection!!.commitText(context.getString(R.string.basketball), 1)
            }
            R.id.button_american_football -> {
                inputConnection!!.commitText(context.getString(R.string.american_football), 1)
            }
            R.id.button_baseball -> {
                inputConnection!!.commitText(context.getString(R.string.baseball), 1)
            }
            R.id.button_softball -> {
                inputConnection!!.commitText(context.getString(R.string.softball), 1)
            }
            R.id.button_tennis -> {
                inputConnection!!.commitText(context.getString(R.string.tennis), 1)
            }
            R.id.button_volleyball -> {
                inputConnection!!.commitText(context.getString(R.string.volleyball), 1)
            }
            R.id.button_rugby_football -> {
                inputConnection!!.commitText(context.getString(R.string.rugby_football), 1)
            }
            R.id.button_flying_disc -> {
                inputConnection!!.commitText(context.getString(R.string.flying_disc), 1)
            }
            R.id.button_pool_8_ball -> {
                inputConnection!!.commitText(context.getString(R.string.pool_8_ball), 1)
            }
            R.id.button_ping_pong -> {
                inputConnection!!.commitText(context.getString(R.string.ping_pong), 1)
            }
            R.id.button_badminton -> {
                inputConnection!!.commitText(context.getString(R.string.badminton), 1)
            }
            R.id.button_ice_hockey -> {
                inputConnection!!.commitText(context.getString(R.string.ice_hockey), 1)
            }
            R.id.button_field_hockey -> {
                inputConnection!!.commitText(context.getString(R.string.field_hockey), 1)
            }
            R.id.button_lacrosse -> {
                inputConnection!!.commitText(context.getString(R.string.lacrosse), 1)
            }
            R.id.button_cricket_sport -> {
                inputConnection!!.commitText(context.getString(R.string.cricket_sport), 1)
            }
            R.id.button_goal_net -> {
                inputConnection!!.commitText(context.getString(R.string.goal_net), 1)
            }
            R.id.button_flag_in_hole -> {
                inputConnection!!.commitText(context.getString(R.string.flag_in_hole), 1)
            }
            R.id.button_bow_and_arrow -> {
                inputConnection!!.commitText(context.getString(R.string.bow_and_arrow), 1)
            }
        }
    }

    fun setInputConnection(ic: InputConnection) {
        inputConnection = ic
    }
}