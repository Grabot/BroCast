package com.bro.brocast.keyboards

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View.OnClickListener
import android.view.inputmethod.InputConnection
import android.widget.Button
import android.widget.LinearLayout
import com.bro.brocast.R


class ThirdKeyboard: LinearLayout {

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

    var buttonSmile: Button? = null

    val emoji_Smile = 0x1F604

    private var inputConnection: InputConnection? = null

    fun init(context: Context) {
        LayoutInflater.from(context).inflate(R.layout.keyboard_3, this, true)

        val buttonIds = arrayOf(
            R.id.button_green_apple,
            R.id.button_red_apple,
            R.id.button_pear,
            R.id.button_tangerine,
            R.id.button_lemon,
            R.id.button_banana,
            R.id.button_watermelon,
            R.id.button_grapes,
            R.id.button_strawberry,
            R.id.button_melon,
            R.id.button_cherries,
            R.id.button_peach,
            R.id.button_mango,
            R.id.button_pineapple,
            R.id.button_coconut,
            R.id.button_kiwi_fruit,
            R.id.button_tomato,
            R.id.button_eggplant,
            R.id.button_avocado,
            R.id.button_broccoli,
            R.id.button_leafy_green,
            R.id.button_cucumber,
            R.id.button_hot_pepper,
            R.id.button_ear_of_corn,
            R.id.button_carrot,
            R.id.button_potato,
            R.id.button_roasted_sweet_potato,
            R.id.button_croissant,
            R.id.button_bagel,
            R.id.button_bread,
            R.id.button_baguette_bread,
            R.id.button_pretzel,
            R.id.button_cheese_wedge,
            R.id.button_egg,
            R.id.button_cooking,
            R.id.button_pancakes,
            R.id.button_bacon,
            R.id.button_cut_of_meat
        )

        for (b in buttonIds) {
            findViewById<Button>(b).setOnClickListener(clickButtonListener)
        }
    }

    private val clickButtonListener = OnClickListener { view ->
        when (view.getId()) {
            R.id.button_green_apple -> {
                inputConnection!!.commitText(context.getString(R.string.green_apple), 1)
            }
            R.id.button_red_apple -> {
                inputConnection!!.commitText(context.getString(R.string.red_apple), 1)
            }
            R.id.button_pear -> {
                inputConnection!!.commitText(context.getString(R.string.pear), 1)
            }
            R.id.button_tangerine -> {
                inputConnection!!.commitText(context.getString(R.string.tangerine), 1)
            }
            R.id.button_lemon -> {
                inputConnection!!.commitText(context.getString(R.string.lemon), 1)
            }
            R.id.button_banana -> {
                inputConnection!!.commitText(context.getString(R.string.banana), 1)
            }
            R.id.button_watermelon -> {
                inputConnection!!.commitText(context.getString(R.string.watermelon), 1)
            }
            R.id.button_grapes -> {
                inputConnection!!.commitText(context.getString(R.string.grapes), 1)
            }
            R.id.button_strawberry -> {
                inputConnection!!.commitText(context.getString(R.string.strawberry), 1)
            }
            R.id.button_melon -> {
                inputConnection!!.commitText(context.getString(R.string.melon), 1)
            }
            R.id.button_cherries -> {
                inputConnection!!.commitText(context.getString(R.string.cherries), 1)
            }
            R.id.button_peach -> {
                inputConnection!!.commitText(context.getString(R.string.peach), 1)
            }
            R.id.button_mango -> {
                inputConnection!!.commitText(context.getString(R.string.mango), 1)
            }
            R.id.button_pineapple -> {
                inputConnection!!.commitText(context.getString(R.string.pineapple), 1)
            }
            R.id.button_coconut -> {
                inputConnection!!.commitText(context.getString(R.string.coconut), 1)
            }
            R.id.button_kiwi_fruit -> {
                inputConnection!!.commitText(context.getString(R.string.kiwi_fruit), 1)
            }
            R.id.button_tomato -> {
                inputConnection!!.commitText(context.getString(R.string.tomato), 1)
            }
            R.id.button_eggplant -> {
                inputConnection!!.commitText(context.getString(R.string.eggplant), 1)
            }
            R.id.button_avocado -> {
                inputConnection!!.commitText(context.getString(R.string.avocado), 1)
            }
            R.id.button_broccoli -> {
                inputConnection!!.commitText(context.getString(R.string.broccoli), 1)
            }
            R.id.button_leafy_green -> {
                inputConnection!!.commitText(context.getString(R.string.leafy_green), 1)
            }
            R.id.button_cucumber -> {
                inputConnection!!.commitText(context.getString(R.string.cucumber), 1)
            }
            R.id.button_hot_pepper -> {
                inputConnection!!.commitText(context.getString(R.string.hot_pepper), 1)
            }
            R.id.button_ear_of_corn -> {
                inputConnection!!.commitText(context.getString(R.string.ear_of_corn), 1)
            }
            R.id.button_carrot -> {
                inputConnection!!.commitText(context.getString(R.string.carrot), 1)
            }
            R.id.button_potato -> {
                inputConnection!!.commitText(context.getString(R.string.potato), 1)
            }
            R.id.button_roasted_sweet_potato -> {
                inputConnection!!.commitText(context.getString(R.string.roasted_sweet_potato), 1)
            }
            R.id.button_croissant -> {
                inputConnection!!.commitText(context.getString(R.string.croissant), 1)
            }
            R.id.button_bagel -> {
                inputConnection!!.commitText(context.getString(R.string.bagel), 1)
            }
            R.id.button_bread -> {
                inputConnection!!.commitText(context.getString(R.string.bread), 1)
            }
            R.id.button_baguette_bread -> {
                inputConnection!!.commitText(context.getString(R.string.baguette_bread), 1)
            }
            R.id.button_pretzel -> {
                inputConnection!!.commitText(context.getString(R.string.pretzel), 1)
            }
            R.id.button_cheese_wedge -> {
                inputConnection!!.commitText(context.getString(R.string.cheese_wedge), 1)
            }
            R.id.button_egg -> {
                inputConnection!!.commitText(context.getString(R.string.egg), 1)
            }
            R.id.button_cooking -> {
                inputConnection!!.commitText(context.getString(R.string.cooking), 1)
            }
            R.id.button_pancakes -> {
                inputConnection!!.commitText(context.getString(R.string.pancakes), 1)
            }
            R.id.button_bacon -> {
                inputConnection!!.commitText(context.getString(R.string.bacon), 1)
            }
            R.id.button_cut_of_meat -> {
                inputConnection!!.commitText(context.getString(R.string.cut_of_meat), 1)
            }
        }
    }

    fun setInputConnection(ic: InputConnection) {
        inputConnection = ic
    }
}