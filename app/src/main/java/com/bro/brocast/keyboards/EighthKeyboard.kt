package com.bro.brocast.keyboards

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View.OnClickListener
import android.view.inputmethod.InputConnection
import android.widget.Button
import android.widget.LinearLayout
import com.bro.brocast.R


class EighthKeyboard: LinearLayout {

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
        LayoutInflater.from(context).inflate(R.layout.keyboard_8, this, true)

        val buttonIds = arrayOf(
            R.id.button_white_flag,
            R.id.button_black_flag,
            R.id.button_pirate_flag,
            R.id.button_chequered_flag,
            R.id.button_triangular_flag,
            R.id.button_rainbow_flag,
            R.id.button_united_nations,
            R.id.button_afghanistan,
            R.id.button_aland_islands,
            R.id.button_albania,
            R.id.button_algeria,
            R.id.button_american_samoa,
            R.id.button_andorra,
            R.id.button_angola,
            R.id.button_anguilla,
            R.id.button_antarctica,
            R.id.button_antigua_and_barbuda,
            R.id.button_argentina,
            R.id.button_armenia,
            R.id.button_aruba,
            R.id.button_australia,
            R.id.button_austria,
            R.id.button_azerbaijan,
            R.id.button_bahamas,
            R.id.button_bahrain,
            R.id.button_bangladesh,
            R.id.button_barbados,
            R.id.button_belarus,
            R.id.button_belgium,
            R.id.button_belize,
            R.id.button_benin,
            R.id.button_bermuda,
            R.id.button_bhutan,
            R.id.button_bolivia,
            R.id.button_bosnia_and_herzegovina,
            R.id.button_botswana,
            R.id.button_brazil,
            R.id.button_british_indian_ocean_territory
        )

        for (b in buttonIds) {
            findViewById<Button>(b).setOnClickListener(clickButtonListener)
        }
    }

    private val clickButtonListener = OnClickListener { view ->
        when (view.getId()) {
            R.id.button_white_flag -> {
                inputConnection!!.commitText(context.getString(R.string.white_flag), 1)
            }
            R.id.button_black_flag -> {
                inputConnection!!.commitText(context.getString(R.string.black_flag), 1)
            }
            R.id.button_pirate_flag -> {
                inputConnection!!.commitText(context.getString(R.string.pirate_flag), 1)
            }
            R.id.button_chequered_flag -> {
                inputConnection!!.commitText(context.getString(R.string.chequered_flag), 1)
            }
            R.id.button_triangular_flag -> {
                inputConnection!!.commitText(context.getString(R.string.triangular_flag), 1)
            }
            R.id.button_rainbow_flag -> {
                inputConnection!!.commitText(context.getString(R.string.rainbow_flag), 1)
            }
            R.id.button_united_nations -> {
                inputConnection!!.commitText(context.getString(R.string.united_nations), 1)
            }
            R.id.button_afghanistan -> {
                inputConnection!!.commitText(context.getString(R.string.afghanistan), 1)
            }
            R.id.button_aland_islands -> {
                inputConnection!!.commitText(context.getString(R.string.aland_islands), 1)
            }
            R.id.button_albania -> {
                inputConnection!!.commitText(context.getString(R.string.albania), 1)
            }
            R.id.button_algeria -> {
                inputConnection!!.commitText(context.getString(R.string.algeria), 1)
            }
            R.id.button_american_samoa -> {
                inputConnection!!.commitText(context.getString(R.string.american_samoa), 1)
            }
            R.id.button_andorra -> {
                inputConnection!!.commitText(context.getString(R.string.andorra), 1)
            }
            R.id.button_angola -> {
                inputConnection!!.commitText(context.getString(R.string.angola), 1)
            }
            R.id.button_anguilla -> {
                inputConnection!!.commitText(context.getString(R.string.anguilla), 1)
            }
            R.id.button_antarctica -> {
                inputConnection!!.commitText(context.getString(R.string.antarctica), 1)
            }
            R.id.button_antigua_and_barbuda -> {
                inputConnection!!.commitText(context.getString(R.string.antigua_and_barbuda), 1)
            }
            R.id.button_argentina -> {
                inputConnection!!.commitText(context.getString(R.string.argentina), 1)
            }
            R.id.button_armenia -> {
                inputConnection!!.commitText(context.getString(R.string.armenia), 1)
            }
            R.id.button_aruba -> {
                inputConnection!!.commitText(context.getString(R.string.aruba), 1)
            }
            R.id.button_australia -> {
                inputConnection!!.commitText(context.getString(R.string.australia), 1)
            }
            R.id.button_austria -> {
                inputConnection!!.commitText(context.getString(R.string.austria), 1)
            }
            R.id.button_azerbaijan -> {
                inputConnection!!.commitText(context.getString(R.string.azerbaijan), 1)
            }
            R.id.button_bahamas -> {
                inputConnection!!.commitText(context.getString(R.string.bahamas), 1)
            }
            R.id.button_bahrain -> {
                inputConnection!!.commitText(context.getString(R.string.bahrain), 1)
            }
            R.id.button_bangladesh -> {
                inputConnection!!.commitText(context.getString(R.string.bangladesh), 1)
            }
            R.id.button_barbados -> {
                inputConnection!!.commitText(context.getString(R.string.barbados), 1)
            }
            R.id.button_belarus -> {
                inputConnection!!.commitText(context.getString(R.string.belarus), 1)
            }
            R.id.button_belgium -> {
                inputConnection!!.commitText(context.getString(R.string.belgium), 1)
            }
            R.id.button_belize -> {
                inputConnection!!.commitText(context.getString(R.string.belize), 1)
            }
            R.id.button_benin -> {
                inputConnection!!.commitText(context.getString(R.string.benin), 1)
            }
            R.id.button_bermuda -> {
                inputConnection!!.commitText(context.getString(R.string.bermuda), 1)
            }
            R.id.button_bhutan -> {
                inputConnection!!.commitText(context.getString(R.string.bhutan), 1)
            }
            R.id.button_bolivia -> {
                inputConnection!!.commitText(context.getString(R.string.bolivia), 1)
            }
            R.id.button_bosnia_and_herzegovina -> {
                inputConnection!!.commitText(context.getString(R.string.bosnia_and_herzegovina), 1)
            }
            R.id.button_botswana -> {
                inputConnection!!.commitText(context.getString(R.string.botswana), 1)
            }
            R.id.button_brazil -> {
                inputConnection!!.commitText(context.getString(R.string.brazil), 1)
            }
            R.id.button_british_indian_ocean_territory -> {
                inputConnection!!.commitText(context.getString(R.string.british_indian_ocean_territory), 1)
            }
        }
    }

    fun setInputConnection(ic: InputConnection) {
        inputConnection = ic
    }
}