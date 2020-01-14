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
            R.id.button_latin_cross,
            R.id.button_star_and_crescent,
            R.id.button_om,
            R.id.button_wheel_of_dharma,
            R.id.button_star_of_david,
            R.id.button_dotted_six_pointed_star,
            R.id.button_menorah,
            R.id.button_yin_yang,
            R.id.button_orthodox_cross,
            R.id.button_place_of_worship,
            R.id.button_ophiuchus,
            R.id.button_aries,
            R.id.button_taurus,
            R.id.button_gemini,
            R.id.button_cancer,
            R.id.button_leo,
            R.id.button_virgo,
            R.id.button_libra,
            R.id.button_scorpius,
            R.id.button_sagittarius,
            R.id.button_capricorn,
            R.id.button_aquarius,
            R.id.button_pisces,
            R.id.button_id_button,
            R.id.button_atom_symbol,
            R.id.button_japanese_acceptable_button,
            R.id.button_radioactive,
            R.id.button_biohazard,
            R.id.button_mobile_phone_off,
            R.id.button_vibration_mode,
            R.id.button_japanese_not_free_of_charge_button,
            R.id.button_japanese_free_of_charge_button,
            R.id.button_japanese_application_button,
            R.id.button_japanese_open_for_business_button,
            R.id.button_japanese_monthly_amount_button,
            R.id.button_eight_pointed_star,
            R.id.button_vs_button,
            R.id.button_white_flower,
            R.id.button_japanese_bargain_button
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
            R.id.button_star_and_crescent -> {
                inputConnection!!.commitText(context.getString(R.string.star_and_crescent), 1)
            }
            R.id.button_om -> {
                inputConnection!!.commitText(context.getString(R.string.om), 1)
            }
            R.id.button_wheel_of_dharma -> {
                inputConnection!!.commitText(context.getString(R.string.wheel_of_dharma), 1)
            }
            R.id.button_star_of_david -> {
                inputConnection!!.commitText(context.getString(R.string.star_of_david), 1)
            }
            R.id.button_dotted_six_pointed_star -> {
                inputConnection!!.commitText(context.getString(R.string.dotted_six_pointed_star), 1)
            }
            R.id.button_menorah -> {
                inputConnection!!.commitText(context.getString(R.string.menorah), 1)
            }
            R.id.button_yin_yang -> {
                inputConnection!!.commitText(context.getString(R.string.yin_yang), 1)
            }
            R.id.button_orthodox_cross -> {
                inputConnection!!.commitText(context.getString(R.string.orthodox_cross), 1)
            }
            R.id.button_place_of_worship -> {
                inputConnection!!.commitText(context.getString(R.string.place_of_worship), 1)
            }
            R.id.button_ophiuchus -> {
                inputConnection!!.commitText(context.getString(R.string.ophiuchus), 1)
            }
            R.id.button_aries -> {
                inputConnection!!.commitText(context.getString(R.string.aries), 1)
            }
            R.id.button_taurus -> {
                inputConnection!!.commitText(context.getString(R.string.taurus), 1)
            }
            R.id.button_gemini -> {
                inputConnection!!.commitText(context.getString(R.string.gemini), 1)
            }
            R.id.button_cancer -> {
                inputConnection!!.commitText(context.getString(R.string.cancer), 1)
            }
            R.id.button_leo -> {
                inputConnection!!.commitText(context.getString(R.string.leo), 1)
            }
            R.id.button_virgo -> {
                inputConnection!!.commitText(context.getString(R.string.virgo), 1)
            }
            R.id.button_libra -> {
                inputConnection!!.commitText(context.getString(R.string.libra), 1)
            }
            R.id.button_scorpius -> {
                inputConnection!!.commitText(context.getString(R.string.scorpius), 1)
            }
            R.id.button_sagittarius -> {
                inputConnection!!.commitText(context.getString(R.string.sagittarius), 1)
            }
            R.id.button_capricorn -> {
                inputConnection!!.commitText(context.getString(R.string.capricorn), 1)
            }
            R.id.button_aquarius -> {
                inputConnection!!.commitText(context.getString(R.string.aquarius), 1)
            }
            R.id.button_pisces -> {
                inputConnection!!.commitText(context.getString(R.string.pisces), 1)
            }
            R.id.button_id_button -> {
                inputConnection!!.commitText(context.getString(R.string.id_button), 1)
            }
            R.id.button_atom_symbol -> {
                inputConnection!!.commitText(context.getString(R.string.atom_symbol), 1)
            }
            R.id.button_japanese_acceptable_button -> {
                inputConnection!!.commitText(context.getString(R.string.japanese_acceptable_button), 1)
            }
            R.id.button_radioactive -> {
                inputConnection!!.commitText(context.getString(R.string.radioactive), 1)
            }
            R.id.button_biohazard -> {
                inputConnection!!.commitText(context.getString(R.string.biohazard), 1)
            }
            R.id.button_mobile_phone_off -> {
                inputConnection!!.commitText(context.getString(R.string.mobile_phone_off), 1)
            }
            R.id.button_vibration_mode -> {
                inputConnection!!.commitText(context.getString(R.string.vibration_mode), 1)
            }
            R.id.button_japanese_not_free_of_charge_button -> {
                inputConnection!!.commitText(context.getString(R.string.japanese_not_free_of_charge_button), 1)
            }
            R.id.button_japanese_free_of_charge_button -> {
                inputConnection!!.commitText(context.getString(R.string.japanese_free_of_charge_button), 1)
            }
            R.id.button_japanese_application_button -> {
                inputConnection!!.commitText(context.getString(R.string.japanese_application_button), 1)
            }
            R.id.button_japanese_open_for_business_button -> {
                inputConnection!!.commitText(context.getString(R.string.japanese_open_for_business_button), 1)
            }
            R.id.button_japanese_monthly_amount_button -> {
                inputConnection!!.commitText(context.getString(R.string.japanese_monthly_amount_button), 1)
            }
            R.id.button_eight_pointed_star -> {
                inputConnection!!.commitText(context.getString(R.string.eight_pointed_star), 1)
            }
            R.id.button_vs_button -> {
                inputConnection!!.commitText(context.getString(R.string.vs_button), 1)
            }
            R.id.button_white_flower -> {
                inputConnection!!.commitText(context.getString(R.string.white_flower), 1)
            }
            R.id.button_japanese_bargain_button -> {
                inputConnection!!.commitText(context.getString(R.string.japanese_bargain_button), 1)
            }
        }
    }

    fun setInputConnection(ic: InputConnection) {
        inputConnection = ic
    }
}