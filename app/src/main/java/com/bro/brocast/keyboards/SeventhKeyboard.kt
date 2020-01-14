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
            R.id.button_japanese_bargain_button,
            R.id.button_japanese_secret_button,
            R.id.button_japanese_congratulations_button,
            R.id.button_japanese_passing_grade_button,
            R.id.button_japanese_no_vacancy_button,
            R.id.button_japanese_discount_button,
            R.id.button_japanese_prohibited_button,
            R.id.button_a_button_blood_type,
            R.id.button_b_button_blood_type,
            R.id.button_ab_button_blood_type,
            R.id.button_cl_button,
            R.id.button_o_button_blood_type,
            R.id.button_sos_button,
            R.id.button_cross_mark,
            R.id.button_heavy_large_circle,
            R.id.button_stop_sign,
            R.id.button_no_entry,
            R.id.button_name_badge,
            R.id.button_prohibited,
            R.id.button_hundred_points,
            R.id.button_anger_symbol,
            R.id.button_hot_springs,
            R.id.button_no_pedestrians,
            R.id.button_no_littering,
            R.id.button_no_bicycles,
            R.id.button_non_potable_water,
            R.id.button_no_one_under_eighteen,
            R.id.button_no_mobile_phones,
            R.id.button_no_smoking,
            R.id.button_exclamation_mark,
            R.id.button_white_exclamation_mark,
            R.id.button_question_mark,
            R.id.button_white_question_mark,
            R.id.button_double_exclamation_mark,
            R.id.button_exclamation_question_mark,
            R.id.button_dim_button,
            R.id.button_bright_button,
            R.id.button_part_alternation_mark,
            R.id.button_warning,
            R.id.button_children_crossing,
            R.id.button_trident_emblem,
            R.id.button_fleur_de_lis,
            R.id.button_japanese_symbol_for_beginner,
            R.id.button_recycling_symbol,
            R.id.button_white_heavy_check_mark,
            R.id.button_japanese_reserved_button,
            R.id.button_chart_increasing_with_yen,
            R.id.button_sparkle,
            R.id.button_eight_spoked_asterisk,
            R.id.button_cross_mark_button,
            R.id.button_globe_with_meridians,
            R.id.button_diamond_with_a_dot,
            R.id.button_circled_m,
            R.id.button_cyclone,
            R.id.button_zzz,
            R.id.button_atm_sign,
            R.id.button_water_closet,
            R.id.button_wheelchair_symbol
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
            R.id.button_japanese_secret_button -> {
                inputConnection!!.commitText(context.getString(R.string.japanese_secret_button), 1)
            }
            R.id.button_japanese_congratulations_button -> {
                inputConnection!!.commitText(context.getString(R.string.japanese_congratulations_button), 1)
            }
            R.id.button_japanese_passing_grade_button -> {
                inputConnection!!.commitText(context.getString(R.string.japanese_passing_grade_button), 1)
            }
            R.id.button_japanese_no_vacancy_button -> {
                inputConnection!!.commitText(context.getString(R.string.japanese_no_vacancy_button), 1)
            }
            R.id.button_japanese_discount_button -> {
                inputConnection!!.commitText(context.getString(R.string.japanese_discount_button), 1)
            }
            R.id.button_japanese_prohibited_button -> {
                inputConnection!!.commitText(context.getString(R.string.japanese_prohibited_button), 1)
            }
            R.id.button_a_button_blood_type -> {
                inputConnection!!.commitText(context.getString(R.string.a_button_blood_type), 1)
            }
            R.id.button_b_button_blood_type -> {
                inputConnection!!.commitText(context.getString(R.string.b_button_blood_type), 1)
            }
            R.id.button_ab_button_blood_type -> {
                inputConnection!!.commitText(context.getString(R.string.ab_button_blood_type), 1)
            }
            R.id.button_cl_button -> {
                inputConnection!!.commitText(context.getString(R.string.cl_button), 1)
            }
            R.id.button_o_button_blood_type -> {
                inputConnection!!.commitText(context.getString(R.string.o_button_blood_type), 1)
            }
            R.id.button_sos_button -> {
                inputConnection!!.commitText(context.getString(R.string.sos_button), 1)
            }
            R.id.button_cross_mark -> {
                inputConnection!!.commitText(context.getString(R.string.cross_mark), 1)
            }
            R.id.button_heavy_large_circle -> {
                inputConnection!!.commitText(context.getString(R.string.heavy_large_circle), 1)
            }
            R.id.button_stop_sign -> {
                inputConnection!!.commitText(context.getString(R.string.stop_sign), 1)
            }
            R.id.button_no_entry -> {
                inputConnection!!.commitText(context.getString(R.string.no_entry), 1)
            }
            R.id.button_name_badge -> {
                inputConnection!!.commitText(context.getString(R.string.name_badge), 1)
            }
            R.id.button_prohibited -> {
                inputConnection!!.commitText(context.getString(R.string.prohibited), 1)
            }
            R.id.button_hundred_points -> {
                inputConnection!!.commitText(context.getString(R.string.hundred_points), 1)
            }
            R.id.button_anger_symbol -> {
                inputConnection!!.commitText(context.getString(R.string.anger_symbol), 1)
            }
            R.id.button_hot_springs -> {
                inputConnection!!.commitText(context.getString(R.string.hot_springs), 1)
            }
            R.id.button_no_pedestrians -> {
                inputConnection!!.commitText(context.getString(R.string.no_pedestrians), 1)
            }
            R.id.button_no_littering -> {
                inputConnection!!.commitText(context.getString(R.string.no_littering), 1)
            }
            R.id.button_no_bicycles -> {
                inputConnection!!.commitText(context.getString(R.string.no_bicycles), 1)
            }
            R.id.button_non_potable_water -> {
                inputConnection!!.commitText(context.getString(R.string.non_potable_water), 1)
            }
            R.id.button_no_one_under_eighteen -> {
                inputConnection!!.commitText(context.getString(R.string.no_one_under_eighteen), 1)
            }
            R.id.button_no_mobile_phones -> {
                inputConnection!!.commitText(context.getString(R.string.no_mobile_phones), 1)
            }
            R.id.button_no_smoking -> {
                inputConnection!!.commitText(context.getString(R.string.no_smoking), 1)
            }
            R.id.button_exclamation_mark -> {
                inputConnection!!.commitText(context.getString(R.string.exclamation_mark), 1)
            }
            R.id.button_white_exclamation_mark -> {
                inputConnection!!.commitText(context.getString(R.string.white_exclamation_mark), 1)
            }
            R.id.button_question_mark -> {
                inputConnection!!.commitText(context.getString(R.string.question_mark), 1)
            }
            R.id.button_white_question_mark -> {
                inputConnection!!.commitText(context.getString(R.string.white_question_mark), 1)
            }
            R.id.button_double_exclamation_mark -> {
                inputConnection!!.commitText(context.getString(R.string.double_exclamation_mark), 1)
            }
            R.id.button_exclamation_question_mark -> {
                inputConnection!!.commitText(context.getString(R.string.exclamation_question_mark), 1)
            }
            R.id.button_dim_button -> {
                inputConnection!!.commitText(context.getString(R.string.dim_button), 1)
            }
            R.id.button_bright_button -> {
                inputConnection!!.commitText(context.getString(R.string.bright_button), 1)
            }
            R.id.button_part_alternation_mark -> {
                inputConnection!!.commitText(context.getString(R.string.part_alternation_mark), 1)
            }
            R.id.button_warning -> {
                inputConnection!!.commitText(context.getString(R.string.warning), 1)
            }
            R.id.button_children_crossing -> {
                inputConnection!!.commitText(context.getString(R.string.children_crossing), 1)
            }
            R.id.button_trident_emblem -> {
                inputConnection!!.commitText(context.getString(R.string.trident_emblem), 1)
            }
            R.id.button_fleur_de_lis -> {
                inputConnection!!.commitText(context.getString(R.string.fleur_de_lis), 1)
            }
            R.id.button_japanese_symbol_for_beginner -> {
                inputConnection!!.commitText(context.getString(R.string.japanese_symbol_for_beginner), 1)
            }
            R.id.button_recycling_symbol -> {
                inputConnection!!.commitText(context.getString(R.string.recycling_symbol), 1)
            }
            R.id.button_white_heavy_check_mark -> {
                inputConnection!!.commitText(context.getString(R.string.white_heavy_check_mark), 1)
            }
            R.id.button_japanese_reserved_button -> {
                inputConnection!!.commitText(context.getString(R.string.japanese_reserved_button), 1)
            }
            R.id.button_chart_increasing_with_yen -> {
                inputConnection!!.commitText(context.getString(R.string.chart_increasing_with_yen), 1)
            }
            R.id.button_sparkle -> {
                inputConnection!!.commitText(context.getString(R.string.sparkle), 1)
            }
            R.id.button_eight_spoked_asterisk -> {
                inputConnection!!.commitText(context.getString(R.string.eight_spoked_asterisk), 1)
            }
            R.id.button_cross_mark_button -> {
                inputConnection!!.commitText(context.getString(R.string.cross_mark_button), 1)
            }
            R.id.button_globe_with_meridians -> {
                inputConnection!!.commitText(context.getString(R.string.globe_with_meridians), 1)
            }
            R.id.button_diamond_with_a_dot -> {
                inputConnection!!.commitText(context.getString(R.string.diamond_with_a_dot), 1)
            }
            R.id.button_circled_m -> {
                inputConnection!!.commitText(context.getString(R.string.circled_m), 1)
            }
            R.id.button_cyclone -> {
                inputConnection!!.commitText(context.getString(R.string.cyclone), 1)
            }
            R.id.button_zzz -> {
                inputConnection!!.commitText(context.getString(R.string.zzz), 1)
            }
            R.id.button_atm_sign -> {
                inputConnection!!.commitText(context.getString(R.string.atm_sign), 1)
            }
            R.id.button_water_closet -> {
                inputConnection!!.commitText(context.getString(R.string.water_closet), 1)
            }
            R.id.button_wheelchair_symbol -> {
                inputConnection!!.commitText(context.getString(R.string.wheelchair_symbol), 1)
            }
        }
    }

    fun setInputConnection(ic: InputConnection) {
        inputConnection = ic
    }
}