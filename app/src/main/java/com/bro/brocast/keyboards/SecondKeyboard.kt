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
            R.id.button_speak_no_evil_monkey,
            R.id.button_monkey,
            R.id.button_chicken,
            R.id.button_penguin,
            R.id.button_bird,
            R.id.button_baby_chick,
            R.id.button_hatching_chick,
            R.id.button_front_facing_baby_chick,
            R.id.button_duck,
            R.id.button_eagle,
            R.id.button_owl,
            R.id.button_bat,
            R.id.button_wolf_face,
            R.id.button_boar,
            R.id.button_horse_face,
            R.id.button_unicorn_face,
            R.id.button_honeybee,
            R.id.button_bug,
            R.id.button_butterfly,
            R.id.button_snail,
            R.id.button_lady_beetle,
            R.id.button_ant,
            R.id.button_mosquito,
            R.id.button_cricket,
            R.id.button_spider,
            R.id.button_spider_web,
            R.id.button_scorpion,
            R.id.button_turtle,
            R.id.button_snake,
            R.id.button_lizard,
            R.id.button_t_rex,
            R.id.button_sauropod,
            R.id.button_octopus,
            R.id.button_squid,
            R.id.button_shrimp,
            R.id.button_lobster,
            R.id.button_crab,
            R.id.button_blowfish,
            R.id.button_tropical_fish)

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
            R.id.button_monkey -> {
                inputConnection!!.commitText(context.getString(R.string.monkey), 1)
            }
            R.id.button_chicken -> {
                inputConnection!!.commitText(context.getString(R.string.chicken), 1)
            }
            R.id.button_penguin -> {
                inputConnection!!.commitText(context.getString(R.string.penguin), 1)
            }
            R.id.button_bird -> {
                inputConnection!!.commitText(context.getString(R.string.bird), 1)
            }
            R.id.button_baby_chick -> {
                inputConnection!!.commitText(context.getString(R.string.baby_chick), 1)
            }
            R.id.button_hatching_chick -> {
                inputConnection!!.commitText(context.getString(R.string.hatching_chick), 1)
            }
            R.id.button_front_facing_baby_chick -> {
                inputConnection!!.commitText(context.getString(R.string.front_facing_baby_chick), 1)
            }
            R.id.button_duck -> {
                inputConnection!!.commitText(context.getString(R.string.duck), 1)
            }
            R.id.button_eagle -> {
                inputConnection!!.commitText(context.getString(R.string.eagle), 1)
            }
            R.id.button_owl -> {
                inputConnection!!.commitText(context.getString(R.string.owl), 1)
            }
            R.id.button_bat -> {
                inputConnection!!.commitText(context.getString(R.string.bat), 1)
            }
            R.id.button_wolf_face -> {
                inputConnection!!.commitText(context.getString(R.string.wolf_face), 1)
            }
            R.id.button_boar -> {
                inputConnection!!.commitText(context.getString(R.string.boar), 1)
            }
            R.id.button_horse_face -> {
                inputConnection!!.commitText(context.getString(R.string.horse_face), 1)
            }
            R.id.button_unicorn_face -> {
                inputConnection!!.commitText(context.getString(R.string.unicorn_face), 1)
            }
            R.id.button_honeybee -> {
                inputConnection!!.commitText(context.getString(R.string.honeybee), 1)
            }
            R.id.button_bug -> {
                inputConnection!!.commitText(context.getString(R.string.bug), 1)
            }
            R.id.button_butterfly -> {
                inputConnection!!.commitText(context.getString(R.string.butterfly), 1)
            }
            R.id.button_snail -> {
                inputConnection!!.commitText(context.getString(R.string.snail), 1)
            }
            R.id.button_lady_beetle -> {
                inputConnection!!.commitText(context.getString(R.string.lady_beetle), 1)
            }
            R.id.button_ant -> {
                inputConnection!!.commitText(context.getString(R.string.ant), 1)
            }
            R.id.button_mosquito -> {
                inputConnection!!.commitText(context.getString(R.string.mosquito), 1)
            }
            R.id.button_cricket -> {
                inputConnection!!.commitText(context.getString(R.string.cricket), 1)
            }
            R.id.button_spider -> {
                inputConnection!!.commitText(context.getString(R.string.spider), 1)
            }
            R.id.button_spider_web -> {
                inputConnection!!.commitText(context.getString(R.string.spider_web), 1)
            }
            R.id.button_scorpion -> {
                inputConnection!!.commitText(context.getString(R.string.scorpion), 1)
            }
            R.id.button_turtle -> {
                inputConnection!!.commitText(context.getString(R.string.turtle), 1)
            }
            R.id.button_snake -> {
                inputConnection!!.commitText(context.getString(R.string.snake), 1)
            }
            R.id.button_lizard -> {
                inputConnection!!.commitText(context.getString(R.string.lizard), 1)
            }
            R.id.button_t_rex -> {
                inputConnection!!.commitText(context.getString(R.string.t_rex), 1)
            }
            R.id.button_sauropod -> {
                inputConnection!!.commitText(context.getString(R.string.sauropod), 1)
            }
            R.id.button_octopus -> {
                inputConnection!!.commitText(context.getString(R.string.octopus), 1)
            }
            R.id.button_squid -> {
                inputConnection!!.commitText(context.getString(R.string.squid), 1)
            }
            R.id.button_shrimp -> {
                inputConnection!!.commitText(context.getString(R.string.shrimp), 1)
            }
            R.id.button_lobster -> {
                inputConnection!!.commitText(context.getString(R.string.lobster), 1)
            }
            R.id.button_crab -> {
                inputConnection!!.commitText(context.getString(R.string.crab), 1)
            }
            R.id.button_blowfish -> {
                inputConnection!!.commitText(context.getString(R.string.blowfish), 1)
            }
            R.id.button_tropical_fish -> {
                inputConnection!!.commitText(context.getString(R.string.tropical_fish), 1)
            }
        }
    }

    fun setInputConnection(ic: InputConnection) {
        inputConnection = ic
    }
}