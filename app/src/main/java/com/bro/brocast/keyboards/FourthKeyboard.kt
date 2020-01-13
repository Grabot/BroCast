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
            R.id.button_bow_and_arrow,
            R.id.button_fishing_pole,
            R.id.button_boxing_glove,
            R.id.button_martial_arts_uniform,
            R.id.button_running_shirt,
            R.id.button_skateboard,
            R.id.button_sled,
            R.id.button_ice_skate,
            R.id.button_curling_stone,
            R.id.button_skis,
            R.id.button_skier,
            R.id.button_snowboarder,
            R.id.button_woman_lifting_weights,
            R.id.button_man_lifting_weights,
            R.id.button_women_wrestling,
            R.id.button_men_wrestling,
            R.id.button_woman_cartwheeling,
            R.id.button_man_cartwheeling,
            R.id.button_woman_bouncing_ball,
            R.id.button_man_bouncing_ball
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
            R.id.button_fishing_pole -> {
                inputConnection!!.commitText(context.getString(R.string.fishing_pole), 1)
            }
            R.id.button_boxing_glove -> {
                inputConnection!!.commitText(context.getString(R.string.boxing_glove), 1)
            }
            R.id.button_martial_arts_uniform -> {
                inputConnection!!.commitText(context.getString(R.string.martial_arts_uniform), 1)
            }
            R.id.button_running_shirt -> {
                inputConnection!!.commitText(context.getString(R.string.running_shirt), 1)
            }
            R.id.button_skateboard -> {
                inputConnection!!.commitText(context.getString(R.string.skateboard), 1)
            }
            R.id.button_sled -> {
                inputConnection!!.commitText(context.getString(R.string.sled), 1)
            }
            R.id.button_ice_skate -> {
                inputConnection!!.commitText(context.getString(R.string.ice_skate), 1)
            }
            R.id.button_curling_stone -> {
                inputConnection!!.commitText(context.getString(R.string.curling_stone), 1)
            }
            R.id.button_skis -> {
                inputConnection!!.commitText(context.getString(R.string.skis), 1)
            }
            R.id.button_skier -> {
                inputConnection!!.commitText(context.getString(R.string.skier), 1)
            }
            R.id.button_snowboarder -> {
                inputConnection!!.commitText(context.getString(R.string.snowboarder), 1)
            }
            R.id.button_woman_lifting_weights -> {
                inputConnection!!.commitText(context.getString(R.string.woman_lifting_weights), 1)
            }
            R.id.button_man_lifting_weights -> {
                inputConnection!!.commitText(context.getString(R.string.man_lifting_weights), 1)
            }
            R.id.button_women_wrestling -> {
                inputConnection!!.commitText(context.getString(R.string.women_wrestling), 1)
            }
            R.id.button_men_wrestling -> {
                inputConnection!!.commitText(context.getString(R.string.men_wrestling), 1)
            }
            R.id.button_woman_cartwheeling -> {
                inputConnection!!.commitText(context.getString(R.string.woman_cartwheeling), 1)
            }
            R.id.button_man_cartwheeling -> {
                inputConnection!!.commitText(context.getString(R.string.man_cartwheeling), 1)
            }
            R.id.button_woman_bouncing_ball -> {
                inputConnection!!.commitText(context.getString(R.string.woman_bouncing_ball), 1)
            }
            R.id.button_man_bouncing_ball -> {
                inputConnection!!.commitText(context.getString(R.string.man_bouncing_ball), 1)
            }
        }
    }

    fun setInputConnection(ic: InputConnection) {
        inputConnection = ic
    }
}