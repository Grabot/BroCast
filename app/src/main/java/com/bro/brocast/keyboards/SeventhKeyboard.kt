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
            R.id.button_wheelchair_symbol,
            R.id.button_p_button,
            R.id.button_japanese_vacancy_button,
            R.id.button_japanese_service_charge_button,
            R.id.button_passport_control,
            R.id.button_customs,
            R.id.button_baggage_claim,
            R.id.button_left_luggage,
            R.id.button_mens_room,
            R.id.button_womens_room,
            R.id.button_baby_symbol,
            R.id.button_restroom,
            R.id.button_litter_in_bin_sign,
            R.id.button_cinema,
            R.id.button_antenna_bars,
            R.id.button_japanese_here_button,
            R.id.button_input_symbols,
            R.id.button_information,
            R.id.button_input_latin_letters,
            R.id.button_input_latin_lowercase,
            R.id.button_input_latin_uppercase,
            R.id.button_ng_button,
            R.id.button_ok_button,
            R.id.button_up_button_text,
            R.id.button_cool_button,
            R.id.button_new_button,
            R.id.button_free_button,
            R.id.button_keycap_0,
            R.id.button_keycap_1,
            R.id.button_keycap_2,
            R.id.button_keycap_3,
            R.id.button_keycap_4,
            R.id.button_keycap_5,
            R.id.button_keycap_6,
            R.id.button_keycap_7,
            R.id.button_keycap_8,
            R.id.button_keycap_9,
            R.id.button_keycap_10,
            R.id.button_input_numbers,
            R.id.button_hash_key,
            R.id.button_keycap_star,
            R.id.button_eject_button,
            R.id.button_play_button,
            R.id.button_pause_button,
            R.id.button_play_or_pause_button,
            R.id.button_stop_button,
            R.id.button_record_button,
            R.id.button_next_track_button,
            R.id.button_last_track_button,
            R.id.button_fast_forward_button,
            R.id.button_fast_reverse_button,
            R.id.button_fast_up_button,
            R.id.button_fast_down_button,
            R.id.button_reverse_button,
            R.id.button_up_button,
            R.id.button_down_button,
            R.id.button_right_arrow,
            R.id.button_left_arrow,
            R.id.button_up_arrow,
            R.id.button_down_arrow,
            R.id.button_up_right_arrow,
            R.id.button_down_right_arrow,
            R.id.button_down_left_arrow,
            R.id.button_up_left_arrow,
            R.id.button_up_down_arrow,
            R.id.button_left_right_arrow,
            R.id.button_left_arrow_curving_right,
            R.id.button_right_arrow_curving_left,
            R.id.button_right_arrow_curving_up,
            R.id.button_right_arrow_curving_down,
            R.id.button_shuffle_tracks_button,
            R.id.button_repeat_button,
            R.id.button_repeat_single_button,
            R.id.button_anticlockwise_arrows_button,
            R.id.button_clockwise_vertical_arrows,
            R.id.button_musical_note,
            R.id.button_musical_notes,
            R.id.button_heavy_plus_sign,
            R.id.button_heavy_minus_sign,
            R.id.button_heavy_division_sign,
            R.id.button_heavy_multiplication_x,
            R.id.button_infinity,
            R.id.button_heavy_dollar_sign,
            R.id.button_currency_exchange,
            R.id.button_trade_mark,
            R.id.button_copyright,
            R.id.button_registered,
            R.id.button_eye_in_speech_bubble,
            R.id.button_end_arrow,
            R.id.button_back_arrow,
            R.id.button_on_arrow,
            R.id.button_top_arrow,
            R.id.button_soon_arrow,
            R.id.button_wavy_dash,
            R.id.button_curly_loop,
            R.id.button_double_curly_loop,
            R.id.button_heavy_check_mark,
            R.id.button_ballot_box_with_check,
            R.id.button_radio_button,
            R.id.button_white_circle,
            R.id.button_black_circle,
            R.id.button_red_circle,
            R.id.button_blue_circle,
            R.id.button_red_triangle_pointed_up,
            R.id.button_red_triangle_pointed_down,
            R.id.button_small_orange_diamond,
            R.id.button_small_blue_diamond,
            R.id.button_large_orange_diamond,
            R.id.button_large_blue_diamond,
            R.id.button_white_square_button,
            R.id.button_black_square_button,
            R.id.button_black_small_square,
            R.id.button_white_small_square,
            R.id.button_black_medium_small_square,
            R.id.button_white_medium_small_square,
            R.id.button_black_medium_square,
            R.id.button_white_medium_square,
            R.id.button_black_large_square,
            R.id.button_white_large_square,
            R.id.button_speaker_low_volume,
            R.id.button_muted_speaker,
            R.id.button_speaker_medium_volume,
            R.id.button_speaker_high_volume,
            R.id.button_bell,
            R.id.button_bell_with_slash,
            R.id.button_megaphone,
            R.id.button_loudspeaker,
            R.id.button_speech_balloon,
            R.id.button_thought_balloon,
            R.id.button_right_anger_bubble,
            R.id.button_spade_suit,
            R.id.button_club_suit,
            R.id.button_heart_suit,
            R.id.button_diamond_suit,
            R.id.button_joker,
            R.id.button_flower_playing_cards,
            R.id.button_mahjong_red_dragon,
            R.id.button_one_o_clock,
            R.id.button_two_o_clock,
            R.id.button_three_o_clock,
            R.id.button_four_o_clock,
            R.id.button_five_o_clock,
            R.id.button_six_o_clock,
            R.id.button_seven_o_clock,
            R.id.button_eight_o_clock,
            R.id.button_nine_o_clock,
            R.id.button_ten_o_clock,
            R.id.button_eleven_o_clock,
            R.id.button_twelve_o_clock,
            R.id.button_one_thirty,
            R.id.button_two_thirty,
            R.id.button_three_thirty,
            R.id.button_four_thirty
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
            R.id.button_p_button -> {
                inputConnection!!.commitText(context.getString(R.string.p_button), 1)
            }
            R.id.button_japanese_vacancy_button -> {
                inputConnection!!.commitText(context.getString(R.string.japanese_vacancy_button), 1)
            }
            R.id.button_japanese_service_charge_button -> {
                inputConnection!!.commitText(context.getString(R.string.japanese_service_charge_button), 1)
            }
            R.id.button_passport_control -> {
                inputConnection!!.commitText(context.getString(R.string.passport_control), 1)
            }
            R.id.button_customs -> {
                inputConnection!!.commitText(context.getString(R.string.customs), 1)
            }
            R.id.button_baggage_claim -> {
                inputConnection!!.commitText(context.getString(R.string.baggage_claim), 1)
            }
            R.id.button_left_luggage -> {
                inputConnection!!.commitText(context.getString(R.string.left_luggage), 1)
            }
            R.id.button_mens_room -> {
                inputConnection!!.commitText(context.getString(R.string.mens_room), 1)
            }
            R.id.button_womens_room -> {
                inputConnection!!.commitText(context.getString(R.string.womens_room), 1)
            }
            R.id.button_baby_symbol -> {
                inputConnection!!.commitText(context.getString(R.string.baby_symbol), 1)
            }
            R.id.button_restroom -> {
                inputConnection!!.commitText(context.getString(R.string.restroom), 1)
            }
            R.id.button_litter_in_bin_sign -> {
                inputConnection!!.commitText(context.getString(R.string.litter_in_bin_sign), 1)
            }
            R.id.button_cinema -> {
                inputConnection!!.commitText(context.getString(R.string.cinema), 1)
            }
            R.id.button_antenna_bars -> {
                inputConnection!!.commitText(context.getString(R.string.antenna_bars), 1)
            }
            R.id.button_japanese_here_button -> {
                inputConnection!!.commitText(context.getString(R.string.japanese_here_button), 1)
            }
            R.id.button_input_symbols -> {
                inputConnection!!.commitText(context.getString(R.string.input_symbols), 1)
            }
            R.id.button_information -> {
                inputConnection!!.commitText(context.getString(R.string.information), 1)
            }
            R.id.button_input_latin_letters -> {
                inputConnection!!.commitText(context.getString(R.string.input_latin_letters), 1)
            }
            R.id.button_input_latin_lowercase -> {
                inputConnection!!.commitText(context.getString(R.string.input_latin_lowercase), 1)
            }
            R.id.button_input_latin_uppercase -> {
                inputConnection!!.commitText(context.getString(R.string.input_latin_uppercase), 1)
            }
            R.id.button_ng_button -> {
                inputConnection!!.commitText(context.getString(R.string.ng_button), 1)
            }
            R.id.button_ok_button -> {
                inputConnection!!.commitText(context.getString(R.string.ok_button), 1)
            }
            R.id.button_up_button_text -> {
                inputConnection!!.commitText(context.getString(R.string.up_button_text), 1)
            }
            R.id.button_cool_button -> {
                inputConnection!!.commitText(context.getString(R.string.cool_button), 1)
            }
            R.id.button_new_button -> {
                inputConnection!!.commitText(context.getString(R.string.new_button), 1)
            }
            R.id.button_free_button -> {
                inputConnection!!.commitText(context.getString(R.string.free_button), 1)
            }
            R.id.button_keycap_0 -> {
                inputConnection!!.commitText(context.getString(R.string.keycap_0), 1)
            }
            R.id.button_keycap_1 -> {
                inputConnection!!.commitText(context.getString(R.string.keycap_1), 1)
            }
            R.id.button_keycap_2 -> {
                inputConnection!!.commitText(context.getString(R.string.keycap_2), 1)
            }
            R.id.button_keycap_3 -> {
                inputConnection!!.commitText(context.getString(R.string.keycap_3), 1)
            }
            R.id.button_keycap_4 -> {
                inputConnection!!.commitText(context.getString(R.string.keycap_4), 1)
            }
            R.id.button_keycap_5 -> {
                inputConnection!!.commitText(context.getString(R.string.keycap_5), 1)
            }
            R.id.button_keycap_6 -> {
                inputConnection!!.commitText(context.getString(R.string.keycap_6), 1)
            }
            R.id.button_keycap_7 -> {
                inputConnection!!.commitText(context.getString(R.string.keycap_7), 1)
            }
            R.id.button_keycap_8 -> {
                inputConnection!!.commitText(context.getString(R.string.keycap_8), 1)
            }
            R.id.button_keycap_9 -> {
                inputConnection!!.commitText(context.getString(R.string.keycap_9), 1)
            }
            R.id.button_keycap_10 -> {
                inputConnection!!.commitText(context.getString(R.string.keycap_10), 1)
            }
            R.id.button_input_numbers -> {
                inputConnection!!.commitText(context.getString(R.string.input_numbers), 1)
            }
            R.id.button_hash_key -> {
                inputConnection!!.commitText(context.getString(R.string.hash_key), 1)
            }
            R.id.button_keycap_star -> {
                inputConnection!!.commitText(context.getString(R.string.keycap_star), 1)
            }
            R.id.button_eject_button -> {
                inputConnection!!.commitText(context.getString(R.string.eject_button), 1)
            }
            R.id.button_play_button -> {
                inputConnection!!.commitText(context.getString(R.string.play_button), 1)
            }
            R.id.button_pause_button -> {
                inputConnection!!.commitText(context.getString(R.string.pause_button), 1)
            }
            R.id.button_play_or_pause_button -> {
                inputConnection!!.commitText(context.getString(R.string.play_or_pause_button), 1)
            }
            R.id.button_stop_button -> {
                inputConnection!!.commitText(context.getString(R.string.stop_button), 1)
            }
            R.id.button_record_button -> {
                inputConnection!!.commitText(context.getString(R.string.record_button), 1)
            }
            R.id.button_next_track_button -> {
                inputConnection!!.commitText(context.getString(R.string.next_track_button), 1)
            }
            R.id.button_last_track_button -> {
                inputConnection!!.commitText(context.getString(R.string.last_track_button), 1)
            }
            R.id.button_fast_forward_button -> {
                inputConnection!!.commitText(context.getString(R.string.fast_forward_button), 1)
            }
            R.id.button_fast_reverse_button -> {
                inputConnection!!.commitText(context.getString(R.string.fast_reverse_button), 1)
            }
            R.id.button_fast_up_button -> {
                inputConnection!!.commitText(context.getString(R.string.fast_up_button), 1)
            }
            R.id.button_fast_down_button -> {
                inputConnection!!.commitText(context.getString(R.string.fast_down_button), 1)
            }
            R.id.button_reverse_button -> {
                inputConnection!!.commitText(context.getString(R.string.reverse_button), 1)
            }
            R.id.button_up_button -> {
                inputConnection!!.commitText(context.getString(R.string.up_button), 1)
            }
            R.id.button_down_button -> {
                inputConnection!!.commitText(context.getString(R.string.down_button), 1)
            }
            R.id.button_right_arrow -> {
                inputConnection!!.commitText(context.getString(R.string.right_arrow), 1)
            }
            R.id.button_left_arrow -> {
                inputConnection!!.commitText(context.getString(R.string.left_arrow), 1)
            }
            R.id.button_up_arrow -> {
                inputConnection!!.commitText(context.getString(R.string.up_arrow), 1)
            }
            R.id.button_down_arrow -> {
                inputConnection!!.commitText(context.getString(R.string.down_arrow), 1)
            }
            R.id.button_up_right_arrow -> {
                inputConnection!!.commitText(context.getString(R.string.up_right_arrow), 1)
            }
            R.id.button_down_right_arrow -> {
                inputConnection!!.commitText(context.getString(R.string.down_right_arrow), 1)
            }
            R.id.button_down_left_arrow -> {
                inputConnection!!.commitText(context.getString(R.string.down_left_arrow), 1)
            }
            R.id.button_up_left_arrow -> {
                inputConnection!!.commitText(context.getString(R.string.up_left_arrow), 1)
            }
            R.id.button_up_down_arrow -> {
                inputConnection!!.commitText(context.getString(R.string.up_down_arrow), 1)
            }
            R.id.button_left_right_arrow -> {
                inputConnection!!.commitText(context.getString(R.string.left_right_arrow), 1)
            }
            R.id.button_left_arrow_curving_right -> {
                inputConnection!!.commitText(context.getString(R.string.left_arrow_curving_right), 1)
            }
            R.id.button_right_arrow_curving_left -> {
                inputConnection!!.commitText(context.getString(R.string.right_arrow_curving_left), 1)
            }
            R.id.button_right_arrow_curving_up -> {
                inputConnection!!.commitText(context.getString(R.string.right_arrow_curving_up), 1)
            }
            R.id.button_right_arrow_curving_down -> {
                inputConnection!!.commitText(context.getString(R.string.right_arrow_curving_down), 1)
            }
            R.id.button_shuffle_tracks_button -> {
                inputConnection!!.commitText(context.getString(R.string.shuffle_tracks_button), 1)
            }
            R.id.button_repeat_button -> {
                inputConnection!!.commitText(context.getString(R.string.repeat_button), 1)
            }
            R.id.button_repeat_single_button -> {
                inputConnection!!.commitText(context.getString(R.string.repeat_single_button), 1)
            }
            R.id.button_anticlockwise_arrows_button -> {
                inputConnection!!.commitText(context.getString(R.string.anticlockwise_arrows_button), 1)
            }
            R.id.button_clockwise_vertical_arrows -> {
                inputConnection!!.commitText(context.getString(R.string.clockwise_vertical_arrows), 1)
            }
            R.id.button_musical_note -> {
                inputConnection!!.commitText(context.getString(R.string.musical_note), 1)
            }
            R.id.button_musical_notes -> {
                inputConnection!!.commitText(context.getString(R.string.musical_notes), 1)
            }
            R.id.button_heavy_plus_sign -> {
                inputConnection!!.commitText(context.getString(R.string.heavy_plus_sign), 1)
            }
            R.id.button_heavy_minus_sign -> {
                inputConnection!!.commitText(context.getString(R.string.heavy_minus_sign), 1)
            }
            R.id.button_heavy_division_sign -> {
                inputConnection!!.commitText(context.getString(R.string.heavy_division_sign), 1)
            }
            R.id.button_heavy_multiplication_x -> {
                inputConnection!!.commitText(context.getString(R.string.heavy_multiplication_x), 1)
            }
            R.id.button_infinity -> {
                inputConnection!!.commitText(context.getString(R.string.infinity), 1)
            }
            R.id.button_heavy_dollar_sign -> {
                inputConnection!!.commitText(context.getString(R.string.heavy_dollar_sign), 1)
            }
            R.id.button_currency_exchange -> {
                inputConnection!!.commitText(context.getString(R.string.currency_exchange), 1)
            }
            R.id.button_trade_mark -> {
                inputConnection!!.commitText(context.getString(R.string.trade_mark), 1)
            }
            R.id.button_copyright -> {
                inputConnection!!.commitText(context.getString(R.string.copyright), 1)
            }
            R.id.button_registered -> {
                inputConnection!!.commitText(context.getString(R.string.registered), 1)
            }
            R.id.button_eye_in_speech_bubble -> {
                inputConnection!!.commitText(context.getString(R.string.eye_in_speech_bubble), 1)
            }
            R.id.button_end_arrow -> {
                inputConnection!!.commitText(context.getString(R.string.end_arrow), 1)
            }
            R.id.button_back_arrow -> {
                inputConnection!!.commitText(context.getString(R.string.back_arrow), 1)
            }
            R.id.button_on_arrow -> {
                inputConnection!!.commitText(context.getString(R.string.on_arrow), 1)
            }
            R.id.button_top_arrow -> {
                inputConnection!!.commitText(context.getString(R.string.top_arrow), 1)
            }
            R.id.button_soon_arrow -> {
                inputConnection!!.commitText(context.getString(R.string.soon_arrow), 1)
            }
            R.id.button_wavy_dash -> {
                inputConnection!!.commitText(context.getString(R.string.wavy_dash), 1)
            }
            R.id.button_curly_loop -> {
                inputConnection!!.commitText(context.getString(R.string.curly_loop), 1)
            }
            R.id.button_double_curly_loop -> {
                inputConnection!!.commitText(context.getString(R.string.double_curly_loop), 1)
            }
            R.id.button_heavy_check_mark -> {
                inputConnection!!.commitText(context.getString(R.string.heavy_check_mark), 1)
            }
            R.id.button_ballot_box_with_check -> {
                inputConnection!!.commitText(context.getString(R.string.ballot_box_with_check), 1)
            }
            R.id.button_radio_button -> {
                inputConnection!!.commitText(context.getString(R.string.radio_button), 1)
            }
            R.id.button_white_circle -> {
                inputConnection!!.commitText(context.getString(R.string.white_circle), 1)
            }
            R.id.button_black_circle -> {
                inputConnection!!.commitText(context.getString(R.string.black_circle), 1)
            }
            R.id.button_red_circle -> {
                inputConnection!!.commitText(context.getString(R.string.red_circle), 1)
            }
            R.id.button_blue_circle -> {
                inputConnection!!.commitText(context.getString(R.string.blue_circle), 1)
            }
            R.id.button_red_triangle_pointed_up -> {
                inputConnection!!.commitText(context.getString(R.string.red_triangle_pointed_up), 1)
            }
            R.id.button_red_triangle_pointed_down -> {
                inputConnection!!.commitText(context.getString(R.string.red_triangle_pointed_down), 1)
            }
            R.id.button_small_orange_diamond -> {
                inputConnection!!.commitText(context.getString(R.string.small_orange_diamond), 1)
            }
            R.id.button_small_blue_diamond -> {
                inputConnection!!.commitText(context.getString(R.string.small_blue_diamond), 1)
            }
            R.id.button_large_orange_diamond -> {
                inputConnection!!.commitText(context.getString(R.string.large_orange_diamond), 1)
            }
            R.id.button_large_blue_diamond -> {
                inputConnection!!.commitText(context.getString(R.string.large_blue_diamond), 1)
            }
            R.id.button_white_square_button -> {
                inputConnection!!.commitText(context.getString(R.string.white_square_button), 1)
            }
            R.id.button_black_square_button -> {
                inputConnection!!.commitText(context.getString(R.string.black_square_button), 1)
            }
            R.id.button_black_small_square -> {
                inputConnection!!.commitText(context.getString(R.string.black_small_square), 1)
            }
            R.id.button_white_small_square -> {
                inputConnection!!.commitText(context.getString(R.string.white_small_square), 1)
            }
            R.id.button_black_medium_small_square -> {
                inputConnection!!.commitText(context.getString(R.string.black_medium_small_square), 1)
            }
            R.id.button_white_medium_small_square -> {
                inputConnection!!.commitText(context.getString(R.string.white_medium_small_square), 1)
            }
            R.id.button_black_medium_square -> {
                inputConnection!!.commitText(context.getString(R.string.black_medium_square), 1)
            }
            R.id.button_white_medium_square -> {
                inputConnection!!.commitText(context.getString(R.string.white_medium_square), 1)
            }
            R.id.button_black_large_square -> {
                inputConnection!!.commitText(context.getString(R.string.black_large_square), 1)
            }
            R.id.button_white_large_square -> {
                inputConnection!!.commitText(context.getString(R.string.white_large_square), 1)
            }
            R.id.button_speaker_low_volume -> {
                inputConnection!!.commitText(context.getString(R.string.speaker_low_volume), 1)
            }
            R.id.button_muted_speaker -> {
                inputConnection!!.commitText(context.getString(R.string.muted_speaker), 1)
            }
            R.id.button_speaker_medium_volume -> {
                inputConnection!!.commitText(context.getString(R.string.speaker_medium_volume), 1)
            }
            R.id.button_speaker_high_volume -> {
                inputConnection!!.commitText(context.getString(R.string.speaker_high_volume), 1)
            }
            R.id.button_bell -> {
                inputConnection!!.commitText(context.getString(R.string.bell), 1)
            }
            R.id.button_bell_with_slash -> {
                inputConnection!!.commitText(context.getString(R.string.bell_with_slash), 1)
            }
            R.id.button_megaphone -> {
                inputConnection!!.commitText(context.getString(R.string.megaphone), 1)
            }
            R.id.button_loudspeaker -> {
                inputConnection!!.commitText(context.getString(R.string.loudspeaker), 1)
            }
            R.id.button_speech_balloon -> {
                inputConnection!!.commitText(context.getString(R.string.speech_balloon), 1)
            }
            R.id.button_thought_balloon -> {
                inputConnection!!.commitText(context.getString(R.string.thought_balloon), 1)
            }
            R.id.button_right_anger_bubble -> {
                inputConnection!!.commitText(context.getString(R.string.right_anger_bubble), 1)
            }
            R.id.button_spade_suit -> {
                inputConnection!!.commitText(context.getString(R.string.spade_suit), 1)
            }
            R.id.button_club_suit -> {
                inputConnection!!.commitText(context.getString(R.string.club_suit), 1)
            }
            R.id.button_heart_suit -> {
                inputConnection!!.commitText(context.getString(R.string.heart_suit), 1)
            }
            R.id.button_diamond_suit -> {
                inputConnection!!.commitText(context.getString(R.string.diamond_suit), 1)
            }
            R.id.button_joker -> {
                inputConnection!!.commitText(context.getString(R.string.joker), 1)
            }
            R.id.button_flower_playing_cards -> {
                inputConnection!!.commitText(context.getString(R.string.flower_playing_cards), 1)
            }
            R.id.button_mahjong_red_dragon -> {
                inputConnection!!.commitText(context.getString(R.string.mahjong_red_dragon), 1)
            }
            R.id.button_one_o_clock -> {
                inputConnection!!.commitText(context.getString(R.string.one_o_clock), 1)
            }
            R.id.button_two_o_clock -> {
                inputConnection!!.commitText(context.getString(R.string.two_o_clock), 1)
            }
            R.id.button_three_o_clock -> {
                inputConnection!!.commitText(context.getString(R.string.three_o_clock), 1)
            }
            R.id.button_four_o_clock -> {
                inputConnection!!.commitText(context.getString(R.string.four_o_clock), 1)
            }
            R.id.button_five_o_clock -> {
                inputConnection!!.commitText(context.getString(R.string.five_o_clock), 1)
            }
            R.id.button_six_o_clock -> {
                inputConnection!!.commitText(context.getString(R.string.six_o_clock), 1)
            }
            R.id.button_seven_o_clock -> {
                inputConnection!!.commitText(context.getString(R.string.seven_o_clock), 1)
            }
            R.id.button_eight_o_clock -> {
                inputConnection!!.commitText(context.getString(R.string.eight_o_clock), 1)
            }
            R.id.button_nine_o_clock -> {
                inputConnection!!.commitText(context.getString(R.string.nine_o_clock), 1)
            }
            R.id.button_ten_o_clock -> {
                inputConnection!!.commitText(context.getString(R.string.ten_o_clock), 1)
            }
            R.id.button_eleven_o_clock -> {
                inputConnection!!.commitText(context.getString(R.string.eleven_o_clock), 1)
            }
            R.id.button_twelve_o_clock -> {
                inputConnection!!.commitText(context.getString(R.string.twelve_o_clock), 1)
            }
            R.id.button_one_thirty -> {
                inputConnection!!.commitText(context.getString(R.string.one_thirty), 1)
            }
            R.id.button_two_thirty -> {
                inputConnection!!.commitText(context.getString(R.string.two_thirty), 1)
            }
            R.id.button_three_thirty -> {
                inputConnection!!.commitText(context.getString(R.string.three_thirty), 1)
            }
            R.id.button_four_thirty -> {
                inputConnection!!.commitText(context.getString(R.string.four_thirty), 1)
            }
        }
    }

    fun setInputConnection(ic: InputConnection) {
        inputConnection = ic
    }
}