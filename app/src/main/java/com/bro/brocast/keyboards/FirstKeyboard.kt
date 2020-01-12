package com.bro.brocast.keyboards

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View.OnClickListener
import android.view.inputmethod.InputConnection
import android.widget.Button
import android.widget.LinearLayout
import com.bro.brocast.R

class FirstKeyboard: LinearLayout {

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

    private fun init(context: Context) {
        LayoutInflater.from(context).inflate(R.layout.keyboard_1, this, true)

        val buttonIds = arrayOf(
            R.id.button_grinning_face,
            R.id.button_smiling_face_with_open_mouth,
            R.id.button_smiling_face_with_open_mouth_and_smiling_eyes,
            R.id.button_grinning_face_with_smiling_eyes,
            R.id.button_smiling_face_with_open_mouth_and_closed_eyes,
            R.id.button_smiling_face_with_open_mouth_and_cold_sweat,
            R.id.button_face_with_tears_of_joy,
            R.id.button_rolling_on_the_floor_laughing,
            R.id.button_smiling_face,
            R.id.button_smiling_face_with_smiling_eyes,
            R.id.button_smiling_face_with_halo,
            R.id.button_slightly_smiling_face,
            R.id.button_upside_down_face,
            R.id.button_winking_face,
            R.id.button_relieved_face,
            R.id.button_smiling_face_with_heart_eyes,
            R.id.button_smiling_face_with_3_hearts,
            R.id.button_face_blowing_a_kiss,
            R.id.button_kissing_face,
            R.id.button_kissing_face_with_smiling_eyes,
            R.id.button_kissing_face_with_closed_eyes,
            R.id.button_face_savouring_delicious_food,
            R.id.button_face_with_stuck_out_tongue,
            R.id.button_face_with_stuck_out_tongue_and_closed_eyes,
            R.id.button_face_with_stuck_out_tongue_and_winking_eye,
            R.id.button_crazy_face,
            R.id.button_face_with_raised_eyebrow,
            R.id.button_face_with_monocle,
            R.id.button_nerd_face,
            R.id.button_star_struck,
            R.id.button_smiling_face_with_sunglasses,
            R.id.button_partying_face,
            R.id.button_smirking_face,
            R.id.button_unamused_face,
            R.id.button_disappointed_face,
            R.id.button_pensive_face,
            R.id.button_worried_face,
            R.id.button_confused_face,
            R.id.button_slightly_frowning_face,
            R.id.button_frowning_face,
            R.id.button_persevering_face,
            R.id.button_confounded_face,
            R.id.button_tired_face,
            R.id.button_weary_face,
            R.id.button_pleading_face,
            R.id.button_crying_face,
            R.id.button_loudly_crying_face,
            R.id.button_face_with_steam_from_nose,
            R.id.button_angry_face,
            R.id.button_pouting_face,
            R.id.button_face_with_symbols_over_mouth,
            R.id.button_exploding_head,
            R.id.button_flushed_face,
            R.id.button_hot_face,
            R.id.button_cold_face,
            R.id.button_face_screaming_in_fear,
            R.id.button_fearful_face,
            R.id.button_face_with_open_mouth_and_cold_sweat,
            R.id.button_disappointed_but_relieved_face,
            R.id.button_face_with_cold_sweat,
            R.id.button_hugging_face,
            R.id.button_thinking_face,
            R.id.button_face_with_hand_over_mouth,
            R.id.button_shushing_face,
            R.id.button_lying_face,
            R.id.button_face_without_mouth,
            R.id.button_neutral_face,
            R.id.button_expressionless_face,
            R.id.button_grimacing_face,
            R.id.button_face_with_rolling_eyes,
            R.id.button_hushed_face,
            R.id.button_frowning_face_with_open_mouth,
            R.id.button_anguished_face,
            R.id.button_face_with_open_mouth,
            R.id.button_astonished_face,
            R.id.button_sleeping_face,
            R.id.button_drooling_face,
            R.id.button_sleepy_face,
            R.id.button_dizzy_face,
            R.id.button_zipper_mouth_face,
            R.id.button_woozy_face,
            R.id.button_nauseated_face,
            R.id.button_face_vomiting,
            R.id.button_sneezing_face,
            R.id.button_face_with_medical_mask,
            R.id.button_face_with_thermometer,
            R.id.button_face_with_head_bandage,
            R.id.button_money_mouth_face,
            R.id.button_cowboy_hat_face,
            R.id.button_smiling_face_with_horns,
            R.id.button_angry_face_with_horns,
            R.id.button_ogre,
            R.id.button_goblin,
            R.id.button_clown_face,
            R.id.button_pile_of_poo,
            R.id.button_ghost,
            R.id.button_skull,
            R.id.button_skull_and_crossbones,
            R.id.button_alien,
            R.id.button_alien_monster,
            R.id.button_robot_face,
            R.id.button_jack_o_lantern,
            R.id.button_smiling_cat_face_with_open_mouth,
            R.id.button_grinning_cat_face_with_smiling_eyes,
            R.id.button_cat_face_with_tears_of_joy,
            R.id.button_smiling_cat_face_with_heart_eyes,
            R.id.button_cat_face_with_wry_smile,
            R.id.button_kissing_cat_face_with_closed_eyes,
            R.id.button_weary_cat_face,
            R.id.button_crying_cat_face,
            R.id.button_pouting_cat_face,
            R.id.button_palms_up_together,
            R.id.button_open_hands,
            R.id.button_raising_hands,
            R.id.button_clapping_hands,
            R.id.button_handshake,
            R.id.button_thumbs_up,
            R.id.button_thumbs_down,
            R.id.button_oncoming_fist,
            R.id.button_raised_fist,
            R.id.button_left_facing_fist,
            R.id.button_right_facing_fist,
            R.id.button_crossed_fingers,
            R.id.button_victory_hand,
            R.id.button_love_you_gesture,
            R.id.button_sign_of_the_horns,
            R.id.button_ok_hand,
            R.id.button_backhand_index_pointing_left,
            R.id.button_backhand_index_pointing_right,
            R.id.button_backhand_index_pointing_up,
            R.id.button_backhand_index_pointing_down,
            R.id.button_index_pointing_up,
            R.id.button_raised_hand,
            R.id.button_raised_back_of_hand,
            R.id.button_raised_hand_with_fingers_splayed,
            R.id.button_vulcan_salute,
            R.id.button_waving_hand,
            R.id.button_call_me_hand,
            R.id.button_flexed_biceps,
            R.id.button_middle_finger,
            R.id.button_writing_hand,
            R.id.button_folded_hands,
            R.id.button_foot,
            R.id.button_leg,
            R.id.button_lipstick,
            R.id.button_kiss_mark,
            R.id.button_mouth,
            R.id.button_tooth,
            R.id.button_tongue,
            R.id.button_ear,
            R.id.button_nose,
            R.id.button_footprints,
            R.id.button_eye,
            R.id.button_eyes,
            R.id.button_brain,
            R.id.button_speaking_head,
            R.id.button_bust_in_silhouette,
            R.id.button_busts_in_silhouette,
            R.id.button_baby,
            R.id.button_girl,
            R.id.button_child,
            R.id.button_boy,
            R.id.button_woman,
            R.id.button_adult,
            R.id.button_man,
            R.id.button_woman_curly_haired,
            R.id.button_man_curly_haired,
            R.id.button_woman_red_haired,
            R.id.button_man_red_haired,
            R.id.button_blond_haired_woman,
            R.id.button_blond_haired_man,
            R.id.button_woman_white_haired,
            R.id.button_man_white_haired,
            R.id.button_woman_bald,
            R.id.button_man_bald,
            R.id.button_bearded_person,
            R.id.button_old_woman,
            R.id.button_older_adult,
            R.id.button_old_man,
            R.id.button_man_with_chinese_cap,
            R.id.button_woman_wearing_turban,
            R.id.button_man_wearing_turban,
            R.id.button_woman_with_headscarf,
            R.id.button_woman_police_officer,
            R.id.button_man_police_officer,
            R.id.button_woman_construction_worker,
            R.id.button_man_construction_worker,
            R.id.button_woman_guard,
            R.id.button_man_guard,
            R.id.button_woman_detective,
            R.id.button_man_detective,
            R.id.button_woman_health_worker,
            R.id.button_man_health_worker,
            R.id.button_woman_farmer,
            R.id.button_man_farmer,
            R.id.button_woman_cook,
            R.id.button_man_cook,
            R.id.button_woman_student,
            R.id.button_man_student,
            R.id.button_woman_singer,
            R.id.button_man_singer,
            R.id.button_woman_teacher,
            R.id.button_man_teacher,
            R.id.button_woman_factory_worker,
            R.id.button_man_factory_worker,
            R.id.button_woman_technologist,
            R.id.button_man_technologist,
            R.id.button_woman_office_worker,
            R.id.button_man_office_worker,
            R.id.button_woman_mechanic,
            R.id.button_man_mechanic,
            R.id.button_woman_scientist,
            R.id.button_man_scientist,
            R.id.button_woman_artist,
            R.id.button_man_artist,
            R.id.button_woman_firefighter,
            R.id.button_man_firefighter,
            R.id.button_woman_pilot,
            R.id.button_man_pilot,
            R.id.button_woman_astronaut,
            R.id.button_man_astronaut,
            R.id.button_woman_judge,
            R.id.button_man_judge,
            R.id.button_bride_with_veil,
            R.id.button_man_in_tuxedo,
            R.id.button_princess,
            R.id.button_prince,
            R.id.button_woman_superhero,
            R.id.button_man_superhero,
            R.id.button_woman_supervillain,
            R.id.button_man_supervillain,
            R.id.button_mrs_claus,
            R.id.button_santa_claus,
            R.id.button_woman_mage,
            R.id.button_man_mage,
            R.id.button_woman_elf,
            R.id.button_man_elf,
            R.id.button_woman_vampire,
            R.id.button_man_vampire,
            R.id.button_woman_zombie,
            R.id.button_man_zombie,
            R.id.button_woman_genie,
            R.id.button_man_genie,
            R.id.button_mermaid,
            R.id.button_merman,
            R.id.button_woman_fairy,
            R.id.button_man_fairy,
            R.id.button_baby_angel,
            R.id.button_pregnant_woman,
            R.id.button_breast_feeding,
            R.id.button_woman_bowing,
            R.id.button_man_bowing,
            R.id.button_woman_tipping_hand,
            R.id.button_man_tipping_hand,
            R.id.button_woman_gesturing_no,
            R.id.button_man_gesturing_no,
            R.id.button_woman_gesturing_ok,
            R.id.button_man_gesturing_ok,
            R.id.button_woman_raising_hand,
            R.id.button_man_raising_hand,
            R.id.button_woman_facepalming,
            R.id.button_man_facepalming,
            R.id.button_woman_shrugging,
            R.id.button_man_shrugging,
            R.id.button_woman_pouting,
            R.id.button_man_pouting,
            R.id.button_woman_frowning,
            R.id.button_man_frowning,
            R.id.button_woman_getting_haircut,
            R.id.button_man_getting_haircut,
            R.id.button_woman_getting_massage,
            R.id.button_man_getting_massage,
            R.id.button_woman_in_steamy_room,
            R.id.button_man_in_steamy_room,
            R.id.button_nail_polish,
            R.id.button_selfie,
            R.id.button_woman_dancing,
            R.id.button_man_dancing,
            R.id.button_women_with_bunny_ears_partying,
            R.id.button_men_with_bunny_ears_partying,
            R.id.button_man_in_business_suit_levitating,
            R.id.button_woman_walking,
            R.id.button_man_walking,
            R.id.button_woman_running,
            R.id.button_man_running,
            R.id.button_man_and_woman_holding_hands,
            R.id.button_two_women_holding_hands,
            R.id.button_two_men_holding_hands,
            R.id.button_couple_with_heart,
            R.id.button_couple_with_heart_woman_woman,
            R.id.button_couple_with_heart_man_man,
            R.id.button_kiss,
            R.id.button_kiss_woman_woman,
            R.id.button_kiss_man_man,
            R.id.button_family,
            R.id.button_family_man_woman_girl,
            R.id.button_family_man_woman_girl_boy,
            R.id.button_family_man_woman_boy_boy,
            R.id.button_family_man_woman_girl_girl,
            R.id.button_family_woman_woman_boy,
            R.id.button_family_woman_woman_girl,
            R.id.button_family_woman_woman_girl_boy,
            R.id.button_family_woman_woman_boy_boy,
            R.id.button_family_woman_woman_girl_girl,
            R.id.button_family_man_man_boy,
            R.id.button_family_man_man_girl,
            R.id.button_family_man_man_girl_boy,
            R.id.button_family_man_man_boy_boy,
            R.id.button_family_man_man_girl_girl,
            R.id.button_family_woman_boy,
            R.id.button_family_woman_girl,
            R.id.button_family_woman_girl_boy,
            R.id.button_family_woman_boy_boy,
            R.id.button_family_woman_girl_girl,
            R.id.button_family_man_boy,
            R.id.button_family_man_girl,
            R.id.button_family_man_girl_boy,
            R.id.button_family_man_boy_boy,
            R.id.button_family_man_girl_girl,
            R.id.button_yarn,
            R.id.button_thread,
            R.id.button_coat,
            R.id.button_lab_coat,
            R.id.button_womans_clothes,
            R.id.button_t_shirt,
            R.id.button_jeans,
            R.id.button_necktie,
            R.id.button_dress,
            R.id.button_bikini,
            R.id.button_kimono,
            R.id.button_womans_flat_shoe,
            R.id.button_high_heeled_shoe,
            R.id.button_womans_sandal,
            R.id.button_womans_boot,
            R.id.button_mans_shoe,
            R.id.button_running_shoe,
            R.id.button_hiking_boot,
            R.id.button_socks,
            R.id.button_gloves,
            R.id.button_scarf,
            R.id.button_top_hat,
            R.id.button_billed_cap
        )

        for (b in buttonIds) {
            findViewById<Button>(b).setOnClickListener(clickButtonListener)
        }
    }

    private val clickButtonListener = OnClickListener { view ->
        when (view.id) {
            R.id.button_grinning_face -> {
                inputConnection!!.commitText(context.getString(R.string.grinning_face), 1)
            }
            R.id.button_smiling_face_with_open_mouth -> {
                inputConnection!!.commitText(context.getString(R.string.smiling_face_with_open_mouth), 1)
            }
            R.id.button_smiling_face_with_open_mouth_and_smiling_eyes -> {
                inputConnection!!.commitText(context.getString(R.string.smiling_face_with_open_mouth_and_smiling_eyes), 1)
            }
            R.id.button_grinning_face_with_smiling_eyes -> {
                inputConnection!!.commitText(context.getString(R.string.grinning_face_with_smiling_eyes), 1)
            }
            R.id.button_smiling_face_with_open_mouth_and_closed_eyes -> {
                inputConnection!!.commitText(context.getString(R.string.smiling_face_with_open_mouth_and_closed_eyes), 1)
            }
            R.id.button_smiling_face_with_open_mouth_and_cold_sweat -> {
                inputConnection!!.commitText(context.getString(R.string.smiling_face_with_open_mouth_and_cold_sweat), 1)
            }
            R.id.button_face_with_tears_of_joy -> {
                inputConnection!!.commitText(context.getString(R.string.face_with_tears_of_joy), 1)
            }
            R.id.button_rolling_on_the_floor_laughing -> {
                inputConnection!!.commitText(context.getString(R.string.rolling_on_the_floor_laughing), 1)
            }
            R.id.button_smiling_face -> {
                inputConnection!!.commitText(context.getString(R.string.smiling_face), 1)
            }
            R.id.button_smiling_face_with_smiling_eyes -> {
                inputConnection!!.commitText(context.getString(R.string.smiling_face_with_smiling_eyes), 1)
            }
            R.id.button_smiling_face_with_halo -> {
                inputConnection!!.commitText(context.getString(R.string.smiling_face_with_halo), 1)
            }
            R.id.button_slightly_smiling_face -> {
                inputConnection!!.commitText(context.getString(R.string.slightly_smiling_face), 1)
            }
            R.id.button_upside_down_face -> {
                inputConnection!!.commitText(context.getString(R.string.upside_down_face), 1)
            }
            R.id.button_winking_face -> {
                inputConnection!!.commitText(context.getString(R.string.winking_face), 1)
            }
            R.id.button_relieved_face -> {
                inputConnection!!.commitText(context.getString(R.string.relieved_face), 1)
            }
            R.id.button_smiling_face_with_heart_eyes -> {
                inputConnection!!.commitText(context.getString(R.string.smiling_face_with_heart_eyes), 1)
            }
            R.id.button_smiling_face_with_3_hearts -> {
                inputConnection!!.commitText(context.getString(R.string.smiling_face_with_3_hearts), 1)
            }
            R.id.button_face_blowing_a_kiss -> {
                inputConnection!!.commitText(context.getString(R.string.face_blowing_a_kiss), 1)
            }
            R.id.button_kissing_face -> {
                inputConnection!!.commitText(context.getString(R.string.kissing_face), 1)
            }
            R.id.button_kissing_face_with_smiling_eyes -> {
                inputConnection!!.commitText(context.getString(R.string.kissing_face_with_smiling_eyes), 1)
            }
            R.id.button_kissing_face_with_closed_eyes -> {
                inputConnection!!.commitText(context.getString(R.string.kissing_face_with_closed_eyes), 1)
            }
            R.id.button_face_savouring_delicious_food -> {
                inputConnection!!.commitText(context.getString(R.string.face_savouring_delicious_food), 1)
            }
            R.id.button_face_with_stuck_out_tongue -> {
                inputConnection!!.commitText(context.getString(R.string.face_with_stuck_out_tongue), 1)
            }
            R.id.button_face_with_stuck_out_tongue_and_closed_eyes -> {
                inputConnection!!.commitText(context.getString(R.string.face_with_stuck_out_tongue_and_closed_eyes), 1)
            }
            R.id.button_face_with_stuck_out_tongue_and_winking_eye -> {
                inputConnection!!.commitText(context.getString(R.string.face_with_stuck_out_tongue_and_winking_eye), 1)
            }
            R.id.button_crazy_face -> {
                inputConnection!!.commitText(context.getString(R.string.crazy_face), 1)
            }
            R.id.button_face_with_raised_eyebrow -> {
                inputConnection!!.commitText(context.getString(R.string.face_with_raised_eyebrow), 1)
            }
            R.id.button_face_with_monocle -> {
                inputConnection!!.commitText(context.getString(R.string.face_with_monocle), 1)
            }
            R.id.button_nerd_face -> {
                inputConnection!!.commitText(context.getString(R.string.nerd_face), 1)
            }
            R.id.button_star_struck -> {
                inputConnection!!.commitText(context.getString(R.string.star_struck), 1)
            }
            R.id.button_smiling_face_with_sunglasses -> {
                inputConnection!!.commitText(context.getString(R.string.smiling_face_with_sunglasses), 1)
            }
            R.id.button_partying_face -> {
                inputConnection!!.commitText(context.getString(R.string.partying_face), 1)
            }
            R.id.button_smirking_face -> {
                inputConnection!!.commitText(context.getString(R.string.smirking_face), 1)
            }
            R.id.button_unamused_face -> {
                inputConnection!!.commitText(context.getString(R.string.unamused_face), 1)
            }
            R.id.button_disappointed_face -> {
                inputConnection!!.commitText(context.getString(R.string.disappointed_face), 1)
            }
            R.id.button_pensive_face -> {
                inputConnection!!.commitText(context.getString(R.string.pensive_face), 1)
            }
            R.id.button_worried_face -> {
                inputConnection!!.commitText(context.getString(R.string.worried_face), 1)
            }
            R.id.button_confused_face -> {
                inputConnection!!.commitText(context.getString(R.string.confused_face), 1)
            }
            R.id.button_slightly_frowning_face -> {
                inputConnection!!.commitText(context.getString(R.string.slightly_frowning_face), 1)
            }
            R.id.button_frowning_face -> {
                inputConnection!!.commitText(context.getString(R.string.frowning_face), 1)
            }
            R.id.button_persevering_face -> {
                inputConnection!!.commitText(context.getString(R.string.persevering_face), 1)
            }
            R.id.button_confounded_face -> {
                inputConnection!!.commitText(context.getString(R.string.confounded_face), 1)
            }
            R.id.button_tired_face -> {
                inputConnection!!.commitText(context.getString(R.string.tired_face), 1)
            }
            R.id.button_weary_face -> {
                inputConnection!!.commitText(context.getString(R.string.weary_face), 1)
            }
            R.id.button_pleading_face -> {
                inputConnection!!.commitText(context.getString(R.string.pleading_face), 1)
            }
            R.id.button_crying_face -> {
                inputConnection!!.commitText(context.getString(R.string.crying_face), 1)
            }
            R.id.button_loudly_crying_face -> {
                inputConnection!!.commitText(context.getString(R.string.loudly_crying_face), 1)
            }
            R.id.button_face_with_steam_from_nose -> {
                inputConnection!!.commitText(context.getString(R.string.face_with_steam_from_nose), 1)
            }
            R.id.button_angry_face -> {
                inputConnection!!.commitText(context.getString(R.string.angry_face), 1)
            }
            R.id.button_pouting_face -> {
                inputConnection!!.commitText(context.getString(R.string.pouting_face), 1)
            }
            R.id.button_face_with_symbols_over_mouth -> {
                inputConnection!!.commitText(context.getString(R.string.face_with_symbols_over_mouth), 1)
            }
            R.id.button_exploding_head -> {
                inputConnection!!.commitText(context.getString(R.string.exploding_head), 1)
            }
            R.id.button_flushed_face -> {
                inputConnection!!.commitText(context.getString(R.string.flushed_face), 1)
            }
            R.id.button_hot_face -> {
                inputConnection!!.commitText(context.getString(R.string.hot_face), 1)
            }
            R.id.button_cold_face -> {
                inputConnection!!.commitText(context.getString(R.string.cold_face), 1)
            }
            R.id.button_face_screaming_in_fear -> {
                inputConnection!!.commitText(context.getString(R.string.face_screaming_in_fear), 1)
            }
            R.id.button_fearful_face -> {
                inputConnection!!.commitText(context.getString(R.string.fearful_face), 1)
            }
            R.id.button_face_with_open_mouth_and_cold_sweat -> {
                inputConnection!!.commitText(context.getString(R.string.face_with_open_mouth_and_cold_sweat), 1)
            }
            R.id.button_disappointed_but_relieved_face -> {
                inputConnection!!.commitText(context.getString(R.string.disappointed_but_relieved_face), 1)
            }
            R.id.button_face_with_cold_sweat -> {
                inputConnection!!.commitText(context.getString(R.string.face_with_cold_sweat), 1)
            }
            R.id.button_hugging_face -> {
                inputConnection!!.commitText(context.getString(R.string.hugging_face), 1)
            }
            R.id.button_thinking_face -> {
                inputConnection!!.commitText(context.getString(R.string.thinking_face), 1)
            }
            R.id.button_face_with_hand_over_mouth -> {
                inputConnection!!.commitText(context.getString(R.string.face_with_hand_over_mouth), 1)
            }
            R.id.button_shushing_face -> {
                inputConnection!!.commitText(context.getString(R.string.shushing_face), 1)
            }
            R.id.button_lying_face -> {
                inputConnection!!.commitText(context.getString(R.string.lying_face), 1)
            }
            R.id.button_face_without_mouth -> {
                inputConnection!!.commitText(context.getString(R.string.face_without_mouth), 1)
            }
            R.id.button_neutral_face -> {
                inputConnection!!.commitText(context.getString(R.string.neutral_face), 1)
            }
            R.id.button_expressionless_face -> {
                inputConnection!!.commitText(context.getString(R.string.expressionless_face), 1)
            }
            R.id.button_grimacing_face -> {
                inputConnection!!.commitText(context.getString(R.string.grimacing_face), 1)
            }
            R.id.button_face_with_rolling_eyes -> {
                inputConnection!!.commitText(context.getString(R.string.face_with_rolling_eyes), 1)
            }
            R.id.button_hushed_face -> {
                inputConnection!!.commitText(context.getString(R.string.hushed_face), 1)
            }
            R.id.button_frowning_face_with_open_mouth -> {
                inputConnection!!.commitText(context.getString(R.string.frowning_face_with_open_mouth), 1)
            }
            R.id.button_anguished_face -> {
                inputConnection!!.commitText(context.getString(R.string.anguished_face), 1)
            }
            R.id.button_face_with_open_mouth -> {
                inputConnection!!.commitText(context.getString(R.string.face_with_open_mouth), 1)
            }
            R.id.button_astonished_face -> {
                inputConnection!!.commitText(context.getString(R.string.astonished_face), 1)
            }
            R.id.button_sleeping_face -> {
                inputConnection!!.commitText(context.getString(R.string.sleeping_face), 1)
            }
            R.id.button_drooling_face -> {
                inputConnection!!.commitText(context.getString(R.string.drooling_face), 1)
            }
            R.id.button_sleepy_face -> {
                inputConnection!!.commitText(context.getString(R.string.sleepy_face), 1)
            }
            R.id.button_dizzy_face -> {
                inputConnection!!.commitText(context.getString(R.string.dizzy_face), 1)
            }
            R.id.button_zipper_mouth_face -> {
                inputConnection!!.commitText(context.getString(R.string.zipper_mouth_face), 1)
            }
            R.id.button_woozy_face -> {
                inputConnection!!.commitText(context.getString(R.string.woozy_face), 1)
            }
            R.id.button_nauseated_face -> {
                inputConnection!!.commitText(context.getString(R.string.nauseated_face), 1)
            }
            R.id.button_face_vomiting -> {
                inputConnection!!.commitText(context.getString(R.string.face_vomiting), 1)
            }
            R.id.button_sneezing_face -> {
                inputConnection!!.commitText(context.getString(R.string.sneezing_face), 1)
            }
            R.id.button_face_with_medical_mask -> {
                inputConnection!!.commitText(context.getString(R.string.face_with_medical_mask), 1)
            }
            R.id.button_face_with_thermometer -> {
                inputConnection!!.commitText(context.getString(R.string.face_with_thermometer), 1)
            }
            R.id.button_face_with_head_bandage -> {
                inputConnection!!.commitText(context.getString(R.string.face_with_head_bandage), 1)
            }
            R.id.button_money_mouth_face -> {
                inputConnection!!.commitText(context.getString(R.string.money_mouth_face), 1)
            }
            R.id.button_cowboy_hat_face -> {
                inputConnection!!.commitText(context.getString(R.string.cowboy_hat_face), 1)
            }
            R.id.button_smiling_face_with_horns -> {
                inputConnection!!.commitText(context.getString(R.string.smiling_face_with_horns), 1)
            }
            R.id.button_angry_face_with_horns -> {
                inputConnection!!.commitText(context.getString(R.string.angry_face_with_horns), 1)
            }
            R.id.button_ogre -> {
                inputConnection!!.commitText(context.getString(R.string.ogre), 1)
            }
            R.id.button_goblin -> {
                inputConnection!!.commitText(context.getString(R.string.goblin), 1)
            }
            R.id.button_clown_face -> {
                inputConnection!!.commitText(context.getString(R.string.clown_face), 1)
            }
            R.id.button_pile_of_poo -> {
                inputConnection!!.commitText(context.getString(R.string.pile_of_poo), 1)
            }
            R.id.button_ghost -> {
                inputConnection!!.commitText(context.getString(R.string.ghost), 1)
            }
            R.id.button_skull -> {
                inputConnection!!.commitText(context.getString(R.string.skull), 1)
            }
            R.id.button_skull_and_crossbones -> {
                inputConnection!!.commitText(context.getString(R.string.skull_and_crossbones), 1)
            }
            R.id.button_alien -> {
                inputConnection!!.commitText(context.getString(R.string.alien), 1)
            }
            R.id.button_alien_monster -> {
                inputConnection!!.commitText(context.getString(R.string.alien_monster), 1)
            }
            R.id.button_robot_face -> {
                inputConnection!!.commitText(context.getString(R.string.robot_face), 1)
            }
            R.id.button_jack_o_lantern -> {
                inputConnection!!.commitText(context.getString(R.string.jack_o_lantern), 1)
            }
            R.id.button_smiling_cat_face_with_open_mouth -> {
                inputConnection!!.commitText(context.getString(R.string.smiling_cat_face_with_open_mouth), 1)
            }
            R.id.button_grinning_cat_face_with_smiling_eyes -> {
                inputConnection!!.commitText(context.getString(R.string.grinning_cat_face_with_smiling_eyes), 1)
            }
            R.id.button_cat_face_with_tears_of_joy -> {
                inputConnection!!.commitText(context.getString(R.string.cat_face_with_tears_of_joy), 1)
            }
            R.id.button_smiling_cat_face_with_heart_eyes -> {
                inputConnection!!.commitText(context.getString(R.string.smiling_cat_face_with_heart_eyes), 1)
            }
            R.id.button_cat_face_with_wry_smile -> {
                inputConnection!!.commitText(context.getString(R.string.cat_face_with_wry_smile), 1)
            }
            R.id.button_kissing_cat_face_with_closed_eyes -> {
                inputConnection!!.commitText(context.getString(R.string.kissing_cat_face_with_closed_eyes), 1)
            }
            R.id.button_weary_cat_face -> {
                inputConnection!!.commitText(context.getString(R.string.weary_cat_face), 1)
            }
            R.id.button_crying_cat_face -> {
                inputConnection!!.commitText(context.getString(R.string.crying_cat_face), 1)
            }
            R.id.button_pouting_cat_face -> {
                inputConnection!!.commitText(context.getString(R.string.pouting_cat_face), 1)
            }
            R.id.button_palms_up_together -> {
                inputConnection!!.commitText(context.getString(R.string.palms_up_together), 1)
            }
            R.id.button_open_hands -> {
                inputConnection!!.commitText(context.getString(R.string.open_hands), 1)
            }
            R.id.button_raising_hands -> {
                inputConnection!!.commitText(context.getString(R.string.raising_hands), 1)
            }
            R.id.button_clapping_hands -> {
                inputConnection!!.commitText(context.getString(R.string.clapping_hands), 1)
            }
            R.id.button_handshake -> {
                inputConnection!!.commitText(context.getString(R.string.handshake), 1)
            }
            R.id.button_thumbs_up -> {
                inputConnection!!.commitText(context.getString(R.string.thumbs_up), 1)
            }
            R.id.button_thumbs_down -> {
                inputConnection!!.commitText(context.getString(R.string.thumbs_down), 1)
            }
            R.id.button_oncoming_fist -> {
                inputConnection!!.commitText(context.getString(R.string.oncoming_fist), 1)
            }
            R.id.button_raised_fist -> {
                inputConnection!!.commitText(context.getString(R.string.raised_fist), 1)
            }
            R.id.button_left_facing_fist -> {
                inputConnection!!.commitText(context.getString(R.string.left_facing_fist), 1)
            }
            R.id.button_right_facing_fist -> {
                inputConnection!!.commitText(context.getString(R.string.right_facing_fist), 1)
            }
            R.id.button_crossed_fingers -> {
                inputConnection!!.commitText(context.getString(R.string.crossed_fingers), 1)
            }
            R.id.button_victory_hand -> {
                inputConnection!!.commitText(context.getString(R.string.victory_hand), 1)
            }
            R.id.button_love_you_gesture -> {
                inputConnection!!.commitText(context.getString(R.string.love_you_gesture), 1)
            }
            R.id.button_sign_of_the_horns -> {
                inputConnection!!.commitText(context.getString(R.string.sign_of_the_horns), 1)
            }
            R.id.button_ok_hand -> {
                inputConnection!!.commitText(context.getString(R.string.ok_hand), 1)
            }
            R.id.button_backhand_index_pointing_left -> {
                inputConnection!!.commitText(context.getString(R.string.backhand_index_pointing_left), 1)
            }
            R.id.button_backhand_index_pointing_right -> {
                inputConnection!!.commitText(context.getString(R.string.backhand_index_pointing_right), 1)
            }
            R.id.button_backhand_index_pointing_up -> {
                inputConnection!!.commitText(context.getString(R.string.backhand_index_pointing_up), 1)
            }
            R.id.button_backhand_index_pointing_down -> {
                inputConnection!!.commitText(context.getString(R.string.backhand_index_pointing_down), 1)
            }
            R.id.button_index_pointing_up -> {
                inputConnection!!.commitText(context.getString(R.string.index_pointing_up), 1)
            }
            R.id.button_raised_hand -> {
                inputConnection!!.commitText(context.getString(R.string.raised_hand), 1)
            }
            R.id.button_raised_back_of_hand -> {
                inputConnection!!.commitText(context.getString(R.string.raised_back_of_hand), 1)
            }
            R.id.button_raised_hand_with_fingers_splayed -> {
                inputConnection!!.commitText(context.getString(R.string.raised_hand_with_fingers_splayed), 1)
            }
            R.id.button_vulcan_salute -> {
                inputConnection!!.commitText(context.getString(R.string.vulcan_salute), 1)
            }
            R.id.button_waving_hand -> {
                inputConnection!!.commitText(context.getString(R.string.waving_hand), 1)
            }
            R.id.button_call_me_hand -> {
                inputConnection!!.commitText(context.getString(R.string.call_me_hand), 1)
            }
            R.id.button_flexed_biceps -> {
                inputConnection!!.commitText(context.getString(R.string.flexed_biceps), 1)
            }
            R.id.button_middle_finger -> {
                inputConnection!!.commitText(context.getString(R.string.middle_finger), 1)
            }
            R.id.button_writing_hand -> {
                inputConnection!!.commitText(context.getString(R.string.writing_hand), 1)
            }
            R.id.button_folded_hands -> {
                inputConnection!!.commitText(context.getString(R.string.folded_hands), 1)
            }
            R.id.button_foot -> {
                inputConnection!!.commitText(context.getString(R.string.foot), 1)
            }
            R.id.button_leg -> {
                inputConnection!!.commitText(context.getString(R.string.leg), 1)
            }
            R.id.button_lipstick -> {
                inputConnection!!.commitText(context.getString(R.string.lipstick), 1)
            }
            R.id.button_kiss_mark -> {
                inputConnection!!.commitText(context.getString(R.string.kiss_mark), 1)
            }
            R.id.button_mouth -> {
                inputConnection!!.commitText(context.getString(R.string.mouth), 1)
            }
            R.id.button_tooth -> {
                inputConnection!!.commitText(context.getString(R.string.tooth), 1)
            }
            R.id.button_tongue -> {
                inputConnection!!.commitText(context.getString(R.string.tongue), 1)
            }
            R.id.button_ear -> {
                inputConnection!!.commitText(context.getString(R.string.ear), 1)
            }
            R.id.button_nose -> {
                inputConnection!!.commitText(context.getString(R.string.nose), 1)
            }
            R.id.button_footprints -> {
                inputConnection!!.commitText(context.getString(R.string.footprints), 1)
            }
            R.id.button_eye -> {
                inputConnection!!.commitText(context.getString(R.string.eye), 1)
            }
            R.id.button_eyes -> {
                inputConnection!!.commitText(context.getString(R.string.eyes), 1)
            }
            R.id.button_brain -> {
                inputConnection!!.commitText(context.getString(R.string.brain), 1)
            }
            R.id.button_speaking_head -> {
                inputConnection!!.commitText(context.getString(R.string.speaking_head), 1)
            }
            R.id.button_bust_in_silhouette -> {
                inputConnection!!.commitText(context.getString(R.string.bust_in_silhouette), 1)
            }
            R.id.button_busts_in_silhouette -> {
                inputConnection!!.commitText(context.getString(R.string.busts_in_silhouette), 1)
            }
            R.id.button_baby -> {
                inputConnection!!.commitText(context.getString(R.string.baby), 1)
            }
            R.id.button_girl -> {
                inputConnection!!.commitText(context.getString(R.string.girl), 1)
            }
            R.id.button_child -> {
                inputConnection!!.commitText(context.getString(R.string.child), 1)
            }
            R.id.button_boy -> {
                inputConnection!!.commitText(context.getString(R.string.boy), 1)
            }
            R.id.button_woman -> {
                inputConnection!!.commitText(context.getString(R.string.woman), 1)
            }
            R.id.button_adult -> {
                inputConnection!!.commitText(context.getString(R.string.adult), 1)
            }
            R.id.button_man -> {
                inputConnection!!.commitText(context.getString(R.string.man), 1)
            }
            R.id.button_woman_curly_haired -> {
                inputConnection!!.commitText(context.getString(R.string.woman_curly_haired), 1)
            }
            R.id.button_man_curly_haired -> {
                inputConnection!!.commitText(context.getString(R.string.man_curly_haired), 1)
            }
            R.id.button_woman_red_haired -> {
                inputConnection!!.commitText(context.getString(R.string.woman_red_haired), 1)
            }
            R.id.button_man_red_haired -> {
                inputConnection!!.commitText(context.getString(R.string.man_red_haired), 1)
            }
            R.id.button_blond_haired_woman -> {
                inputConnection!!.commitText(context.getString(R.string.blond_haired_woman), 1)
            }
            R.id.button_blond_haired_man -> {
                inputConnection!!.commitText(context.getString(R.string.blond_haired_man), 1)
            }
            R.id.button_woman_white_haired -> {
                inputConnection!!.commitText(context.getString(R.string.woman_white_haired), 1)
            }
            R.id.button_man_white_haired -> {
                inputConnection!!.commitText(context.getString(R.string.man_white_haired), 1)
            }
            R.id.button_woman_bald -> {
                inputConnection!!.commitText(context.getString(R.string.woman_bald), 1)
            }
            R.id.button_man_bald -> {
                inputConnection!!.commitText(context.getString(R.string.man_bald), 1)
            }
            R.id.button_bearded_person -> {
                inputConnection!!.commitText(context.getString(R.string.bearded_person), 1)
            }
            R.id.button_old_woman -> {
                inputConnection!!.commitText(context.getString(R.string.old_woman), 1)
            }
            R.id.button_older_adult -> {
                inputConnection!!.commitText(context.getString(R.string.older_adult), 1)
            }
            R.id.button_old_man -> {
                inputConnection!!.commitText(context.getString(R.string.old_man), 1)
            }
            R.id.button_man_with_chinese_cap -> {
                inputConnection!!.commitText(context.getString(R.string.man_with_chinese_cap), 1)
            }
            R.id.button_woman_wearing_turban -> {
                inputConnection!!.commitText(context.getString(R.string.woman_wearing_turban), 1)
            }
            R.id.button_man_wearing_turban -> {
                inputConnection!!.commitText(context.getString(R.string.man_wearing_turban), 1)
            }
            R.id.button_woman_with_headscarf -> {
                inputConnection!!.commitText(context.getString(R.string.woman_with_headscarf), 1)
            }
            R.id.button_woman_police_officer -> {
                inputConnection!!.commitText(context.getString(R.string.woman_police_officer), 1)
            }
            R.id.button_man_police_officer -> {
                inputConnection!!.commitText(context.getString(R.string.man_police_officer), 1)
            }
            R.id.button_woman_construction_worker -> {
                inputConnection!!.commitText(context.getString(R.string.woman_construction_worker), 1)
            }
            R.id.button_man_construction_worker -> {
                inputConnection!!.commitText(context.getString(R.string.man_construction_worker), 1)
            }
            R.id.button_woman_guard -> {
                inputConnection!!.commitText(context.getString(R.string.woman_guard), 1)
            }
            R.id.button_man_guard -> {
                inputConnection!!.commitText(context.getString(R.string.man_guard), 1)
            }
            R.id.button_woman_detective -> {
                inputConnection!!.commitText(context.getString(R.string.woman_detective), 1)
            }
            R.id.button_man_detective -> {
                inputConnection!!.commitText(context.getString(R.string.man_detective), 1)
            }
            R.id.button_woman_health_worker -> {
                inputConnection!!.commitText(context.getString(R.string.woman_health_worker), 1)
            }
            R.id.button_man_health_worker -> {
                inputConnection!!.commitText(context.getString(R.string.man_health_worker), 1)
            }
            R.id.button_woman_farmer -> {
                inputConnection!!.commitText(context.getString(R.string.woman_farmer), 1)
            }
            R.id.button_man_farmer -> {
                inputConnection!!.commitText(context.getString(R.string.man_farmer), 1)
            }
            R.id.button_woman_cook -> {
                inputConnection!!.commitText(context.getString(R.string.woman_cook), 1)
            }
            R.id.button_man_cook -> {
                inputConnection!!.commitText(context.getString(R.string.man_cook), 1)
            }
            R.id.button_woman_student -> {
                inputConnection!!.commitText(context.getString(R.string.woman_student), 1)
            }
            R.id.button_man_student -> {
                inputConnection!!.commitText(context.getString(R.string.man_student), 1)
            }
            R.id.button_woman_singer -> {
                inputConnection!!.commitText(context.getString(R.string.woman_singer), 1)
            }
            R.id.button_man_singer -> {
                inputConnection!!.commitText(context.getString(R.string.man_singer), 1)
            }
            R.id.button_woman_teacher -> {
                inputConnection!!.commitText(context.getString(R.string.woman_teacher), 1)
            }
            R.id.button_man_teacher -> {
                inputConnection!!.commitText(context.getString(R.string.man_teacher), 1)
            }
            R.id.button_woman_factory_worker -> {
                inputConnection!!.commitText(context.getString(R.string.woman_factory_worker), 1)
            }
            R.id.button_man_factory_worker -> {
                inputConnection!!.commitText(context.getString(R.string.man_factory_worker), 1)
            }
            R.id.button_woman_technologist -> {
                inputConnection!!.commitText(context.getString(R.string.woman_technologist), 1)
            }
            R.id.button_man_technologist -> {
                inputConnection!!.commitText(context.getString(R.string.man_technologist), 1)
            }
            R.id.button_woman_office_worker -> {
                inputConnection!!.commitText(context.getString(R.string.woman_office_worker), 1)
            }
            R.id.button_man_office_worker -> {
                inputConnection!!.commitText(context.getString(R.string.man_office_worker), 1)
            }
            R.id.button_woman_mechanic -> {
                inputConnection!!.commitText(context.getString(R.string.woman_mechanic), 1)
            }
            R.id.button_man_mechanic -> {
                inputConnection!!.commitText(context.getString(R.string.man_mechanic), 1)
            }
            R.id.button_woman_scientist -> {
                inputConnection!!.commitText(context.getString(R.string.woman_scientist), 1)
            }
            R.id.button_man_scientist -> {
                inputConnection!!.commitText(context.getString(R.string.man_scientist), 1)
            }
            R.id.button_woman_artist -> {
                inputConnection!!.commitText(context.getString(R.string.woman_artist), 1)
            }
            R.id.button_man_artist -> {
                inputConnection!!.commitText(context.getString(R.string.man_artist), 1)
            }
            R.id.button_woman_firefighter -> {
                inputConnection!!.commitText(context.getString(R.string.woman_firefighter), 1)
            }
            R.id.button_man_firefighter -> {
                inputConnection!!.commitText(context.getString(R.string.man_firefighter), 1)
            }
            R.id.button_woman_pilot -> {
                inputConnection!!.commitText(context.getString(R.string.woman_pilot), 1)
            }
            R.id.button_man_pilot -> {
                inputConnection!!.commitText(context.getString(R.string.man_pilot), 1)
            }
            R.id.button_woman_astronaut -> {
                inputConnection!!.commitText(context.getString(R.string.woman_astronaut), 1)
            }
            R.id.button_man_astronaut -> {
                inputConnection!!.commitText(context.getString(R.string.man_astronaut), 1)
            }
            R.id.button_woman_judge -> {
                inputConnection!!.commitText(context.getString(R.string.woman_judge), 1)
            }
            R.id.button_man_judge -> {
                inputConnection!!.commitText(context.getString(R.string.man_judge), 1)
            }
            R.id.button_bride_with_veil -> {
                inputConnection!!.commitText(context.getString(R.string.bride_with_veil), 1)
            }
            R.id.button_man_in_tuxedo -> {
                inputConnection!!.commitText(context.getString(R.string.man_in_tuxedo), 1)
            }
            R.id.button_princess -> {
                inputConnection!!.commitText(context.getString(R.string.princess), 1)
            }
            R.id.button_prince -> {
                inputConnection!!.commitText(context.getString(R.string.prince), 1)
            }
            R.id.button_woman_superhero -> {
                inputConnection!!.commitText(context.getString(R.string.woman_superhero), 1)
            }
            R.id.button_man_superhero -> {
                inputConnection!!.commitText(context.getString(R.string.man_superhero), 1)
            }
            R.id.button_woman_supervillain -> {
                inputConnection!!.commitText(context.getString(R.string.woman_supervillain), 1)
            }
            R.id.button_man_supervillain -> {
                inputConnection!!.commitText(context.getString(R.string.man_supervillain), 1)
            }
            R.id.button_mrs_claus -> {
                inputConnection!!.commitText(context.getString(R.string.mrs_claus), 1)
            }
            R.id.button_santa_claus -> {
                inputConnection!!.commitText(context.getString(R.string.santa_claus), 1)
            }
            R.id.button_woman_mage -> {
                inputConnection!!.commitText(context.getString(R.string.woman_mage), 1)
            }
            R.id.button_man_mage -> {
                inputConnection!!.commitText(context.getString(R.string.man_mage), 1)
            }
            R.id.button_woman_elf -> {
                inputConnection!!.commitText(context.getString(R.string.woman_elf), 1)
            }
            R.id.button_man_elf -> {
                inputConnection!!.commitText(context.getString(R.string.man_elf), 1)
            }
            R.id.button_woman_vampire -> {
                inputConnection!!.commitText(context.getString(R.string.woman_vampire), 1)
            }
            R.id.button_man_vampire -> {
                inputConnection!!.commitText(context.getString(R.string.man_vampire), 1)
            }
            R.id.button_woman_zombie -> {
                inputConnection!!.commitText(context.getString(R.string.woman_zombie), 1)
            }
            R.id.button_man_zombie -> {
                inputConnection!!.commitText(context.getString(R.string.man_zombie), 1)
            }
            R.id.button_woman_genie -> {
                inputConnection!!.commitText(context.getString(R.string.woman_genie), 1)
            }
            R.id.button_man_genie -> {
                inputConnection!!.commitText(context.getString(R.string.man_genie), 1)
            }
            R.id.button_mermaid -> {
                inputConnection!!.commitText(context.getString(R.string.mermaid), 1)
            }
            R.id.button_merman -> {
                inputConnection!!.commitText(context.getString(R.string.merman), 1)
            }
            R.id.button_woman_fairy -> {
                inputConnection!!.commitText(context.getString(R.string.woman_fairy), 1)
            }
            R.id.button_man_fairy -> {
                inputConnection!!.commitText(context.getString(R.string.man_fairy), 1)
            }
            R.id.button_baby_angel -> {
                inputConnection!!.commitText(context.getString(R.string.baby_angel), 1)
            }
            R.id.button_pregnant_woman -> {
                inputConnection!!.commitText(context.getString(R.string.pregnant_woman), 1)
            }
            R.id.button_breast_feeding -> {
                inputConnection!!.commitText(context.getString(R.string.breast_feeding), 1)
            }
            R.id.button_woman_bowing -> {
                inputConnection!!.commitText(context.getString(R.string.woman_bowing), 1)
            }
            R.id.button_man_bowing -> {
                inputConnection!!.commitText(context.getString(R.string.man_bowing), 1)
            }
            R.id.button_woman_tipping_hand -> {
                inputConnection!!.commitText(context.getString(R.string.woman_tipping_hand), 1)
            }
            R.id.button_man_tipping_hand -> {
                inputConnection!!.commitText(context.getString(R.string.man_tipping_hand), 1)
            }
            R.id.button_woman_gesturing_no -> {
                inputConnection!!.commitText(context.getString(R.string.woman_gesturing_no), 1)
            }
            R.id.button_man_gesturing_no -> {
                inputConnection!!.commitText(context.getString(R.string.man_gesturing_no), 1)
            }
            R.id.button_woman_gesturing_ok -> {
                inputConnection!!.commitText(context.getString(R.string.woman_gesturing_ok), 1)
            }
            R.id.button_man_gesturing_ok -> {
                inputConnection!!.commitText(context.getString(R.string.man_gesturing_ok), 1)
            }
            R.id.button_woman_raising_hand -> {
                inputConnection!!.commitText(context.getString(R.string.woman_raising_hand), 1)
            }
            R.id.button_man_raising_hand -> {
                inputConnection!!.commitText(context.getString(R.string.man_raising_hand), 1)
            }
            R.id.button_woman_facepalming -> {
                inputConnection!!.commitText(context.getString(R.string.woman_facepalming), 1)
            }
            R.id.button_man_facepalming -> {
                inputConnection!!.commitText(context.getString(R.string.man_facepalming), 1)
            }
            R.id.button_woman_shrugging -> {
                inputConnection!!.commitText(context.getString(R.string.woman_shrugging), 1)
            }
            R.id.button_man_shrugging -> {
                inputConnection!!.commitText(context.getString(R.string.man_shrugging), 1)
            }
            R.id.button_woman_pouting -> {
                inputConnection!!.commitText(context.getString(R.string.woman_pouting), 1)
            }
            R.id.button_man_pouting -> {
                inputConnection!!.commitText(context.getString(R.string.man_pouting), 1)
            }
            R.id.button_woman_frowning -> {
                inputConnection!!.commitText(context.getString(R.string.woman_frowning), 1)
            }
            R.id.button_man_frowning -> {
                inputConnection!!.commitText(context.getString(R.string.man_frowning), 1)
            }
            R.id.button_woman_getting_haircut -> {
                inputConnection!!.commitText(context.getString(R.string.woman_getting_haircut), 1)
            }
            R.id.button_man_getting_haircut -> {
                inputConnection!!.commitText(context.getString(R.string.man_getting_haircut), 1)
            }
            R.id.button_woman_getting_massage -> {
                inputConnection!!.commitText(context.getString(R.string.woman_getting_massage), 1)
            }
            R.id.button_man_getting_massage -> {
                inputConnection!!.commitText(context.getString(R.string.man_getting_massage), 1)
            }
            R.id.button_woman_in_steamy_room -> {
                inputConnection!!.commitText(context.getString(R.string.woman_in_steamy_room), 1)
            }
            R.id.button_man_in_steamy_room -> {
                inputConnection!!.commitText(context.getString(R.string.man_in_steamy_room), 1)
            }
            R.id.button_nail_polish -> {
                inputConnection!!.commitText(context.getString(R.string.nail_polish), 1)
            }
            R.id.button_selfie -> {
                inputConnection!!.commitText(context.getString(R.string.selfie), 1)
            }
            R.id.button_woman_dancing -> {
                inputConnection!!.commitText(context.getString(R.string.woman_dancing), 1)
            }
            R.id.button_man_dancing -> {
                inputConnection!!.commitText(context.getString(R.string.man_dancing), 1)
            }
            R.id.button_women_with_bunny_ears_partying -> {
                inputConnection!!.commitText(context.getString(R.string.women_with_bunny_ears_partying), 1)
            }
            R.id.button_men_with_bunny_ears_partying -> {
                inputConnection!!.commitText(context.getString(R.string.men_with_bunny_ears_partying), 1)
            }
            R.id.button_man_in_business_suit_levitating -> {
                inputConnection!!.commitText(context.getString(R.string.man_in_business_suit_levitating), 1)
            }
            R.id.button_woman_walking -> {
                inputConnection!!.commitText(context.getString(R.string.woman_walking), 1)
            }
            R.id.button_man_walking -> {
                inputConnection!!.commitText(context.getString(R.string.man_walking), 1)
            }
            R.id.button_woman_running -> {
                inputConnection!!.commitText(context.getString(R.string.woman_running), 1)
            }
            R.id.button_man_running -> {
                inputConnection!!.commitText(context.getString(R.string.man_running), 1)
            }
            R.id.button_man_and_woman_holding_hands -> {
                inputConnection!!.commitText(context.getString(R.string.man_and_woman_holding_hands), 1)
            }
            R.id.button_two_women_holding_hands -> {
                inputConnection!!.commitText(context.getString(R.string.two_women_holding_hands), 1)
            }
            R.id.button_two_men_holding_hands -> {
                inputConnection!!.commitText(context.getString(R.string.two_men_holding_hands), 1)
            }
            R.id.button_couple_with_heart -> {
                inputConnection!!.commitText(context.getString(R.string.couple_with_heart), 1)
            }
            R.id.button_couple_with_heart_woman_woman -> {
                inputConnection!!.commitText(context.getString(R.string.couple_with_heart_woman_woman), 1)
            }
            R.id.button_couple_with_heart_man_man -> {
                inputConnection!!.commitText(context.getString(R.string.couple_with_heart_man_man), 1)
            }
            R.id.button_kiss -> {
                inputConnection!!.commitText(context.getString(R.string.kiss), 1)
            }
            R.id.button_kiss_woman_woman -> {
                inputConnection!!.commitText(context.getString(R.string.kiss_woman_woman), 1)
            }
            R.id.button_kiss_man_man -> {
                inputConnection!!.commitText(context.getString(R.string.kiss_man_man), 1)
            }
            R.id.button_family -> {
                inputConnection!!.commitText(context.getString(R.string.family), 1)
            }
            R.id.button_family_man_woman_girl -> {
                inputConnection!!.commitText(context.getString(R.string.family_man_woman_girl), 1)
            }
            R.id.button_family_man_woman_girl_boy -> {
                inputConnection!!.commitText(context.getString(R.string.family_man_woman_girl_boy), 1)
            }
            R.id.button_family_man_woman_boy_boy -> {
                inputConnection!!.commitText(context.getString(R.string.family_man_woman_boy_boy), 1)
            }
            R.id.button_family_man_woman_girl_girl -> {
                inputConnection!!.commitText(context.getString(R.string.family_man_woman_girl_girl), 1)
            }
            R.id.button_family_woman_woman_boy -> {
                inputConnection!!.commitText(context.getString(R.string.family_woman_woman_boy), 1)
            }
            R.id.button_family_woman_woman_girl -> {
                inputConnection!!.commitText(context.getString(R.string.family_woman_woman_girl), 1)
            }
            R.id.button_family_woman_woman_girl_boy -> {
                inputConnection!!.commitText(context.getString(R.string.family_woman_woman_girl_boy), 1)
            }
            R.id.button_family_woman_woman_boy_boy -> {
                inputConnection!!.commitText(context.getString(R.string.family_woman_woman_boy_boy), 1)
            }
            R.id.button_family_woman_woman_girl_girl -> {
                inputConnection!!.commitText(context.getString(R.string.family_woman_woman_girl_girl), 1)
            }
            R.id.button_family_man_man_boy -> {
                inputConnection!!.commitText(context.getString(R.string.family_man_man_boy), 1)
            }
            R.id.button_family_man_man_girl -> {
                inputConnection!!.commitText(context.getString(R.string.family_man_man_girl), 1)
            }
            R.id.button_family_man_man_girl_boy -> {
                inputConnection!!.commitText(context.getString(R.string.family_man_man_girl_boy), 1)
            }
            R.id.button_family_man_man_boy_boy -> {
                inputConnection!!.commitText(context.getString(R.string.family_man_man_boy_boy), 1)
            }
            R.id.button_family_man_man_girl_girl -> {
                inputConnection!!.commitText(context.getString(R.string.family_man_man_girl_girl), 1)
            }
            R.id.button_family_woman_boy -> {
                inputConnection!!.commitText(context.getString(R.string.family_woman_boy), 1)
            }
            R.id.button_family_woman_girl -> {
                inputConnection!!.commitText(context.getString(R.string.family_woman_girl), 1)
            }
            R.id.button_family_woman_girl_boy -> {
                inputConnection!!.commitText(context.getString(R.string.family_woman_girl_boy), 1)
            }
            R.id.button_family_woman_boy_boy -> {
                inputConnection!!.commitText(context.getString(R.string.family_woman_boy_boy), 1)
            }
            R.id.button_family_woman_girl_girl -> {
                inputConnection!!.commitText(context.getString(R.string.family_woman_girl_girl), 1)
            }
            R.id.button_family_man_boy -> {
                inputConnection!!.commitText(context.getString(R.string.family_man_boy), 1)
            }
            R.id.button_family_man_girl -> {
                inputConnection!!.commitText(context.getString(R.string.family_man_girl), 1)
            }
            R.id.button_family_man_girl_boy -> {
                inputConnection!!.commitText(context.getString(R.string.family_man_girl_boy), 1)
            }
            R.id.button_family_man_boy_boy -> {
                inputConnection!!.commitText(context.getString(R.string.family_man_boy_boy), 1)
            }
            R.id.button_family_man_girl_girl -> {
                inputConnection!!.commitText(context.getString(R.string.family_man_girl_girl), 1)
            }
            R.id.button_yarn -> {
                inputConnection!!.commitText(context.getString(R.string.yarn), 1)
            }
            R.id.button_thread -> {
                inputConnection!!.commitText(context.getString(R.string.thread), 1)
            }
            R.id.button_coat -> {
                inputConnection!!.commitText(context.getString(R.string.coat), 1)
            }
            R.id.button_lab_coat -> {
                inputConnection!!.commitText(context.getString(R.string.lab_coat), 1)
            }
            R.id.button_womans_clothes -> {
                inputConnection!!.commitText(context.getString(R.string.womans_clothes), 1)
            }
            R.id.button_t_shirt -> {
                inputConnection!!.commitText(context.getString(R.string.t_shirt), 1)
            }
            R.id.button_jeans -> {
                inputConnection!!.commitText(context.getString(R.string.jeans), 1)
            }
            R.id.button_necktie -> {
                inputConnection!!.commitText(context.getString(R.string.necktie), 1)
            }
            R.id.button_dress -> {
                inputConnection!!.commitText(context.getString(R.string.dress), 1)
            }
            R.id.button_bikini -> {
                inputConnection!!.commitText(context.getString(R.string.bikini), 1)
            }
            R.id.button_kimono -> {
                inputConnection!!.commitText(context.getString(R.string.kimono), 1)
            }
            R.id.button_womans_flat_shoe -> {
                inputConnection!!.commitText(context.getString(R.string.womans_flat_shoe), 1)
            }
            R.id.button_high_heeled_shoe -> {
                inputConnection!!.commitText(context.getString(R.string.high_heeled_shoe), 1)
            }
            R.id.button_womans_sandal -> {
                inputConnection!!.commitText(context.getString(R.string.womans_sandal), 1)
            }
            R.id.button_womans_boot -> {
                inputConnection!!.commitText(context.getString(R.string.womans_boot), 1)
            }
            R.id.button_mans_shoe -> {
                inputConnection!!.commitText(context.getString(R.string.mans_shoe), 1)
            }
            R.id.button_running_shoe -> {
                inputConnection!!.commitText(context.getString(R.string.running_shoe), 1)
            }
            R.id.button_hiking_boot -> {
                inputConnection!!.commitText(context.getString(R.string.hiking_boot), 1)
            }
            R.id.button_socks -> {
                inputConnection!!.commitText(context.getString(R.string.socks), 1)
            }
            R.id.button_gloves -> {
                inputConnection!!.commitText(context.getString(R.string.gloves), 1)
            }
            R.id.button_scarf -> {
                inputConnection!!.commitText(context.getString(R.string.scarf), 1)
            }
            R.id.button_top_hat -> {
                inputConnection!!.commitText(context.getString(R.string.top_hat), 1)
            }
            R.id.button_billed_cap -> {
                inputConnection!!.commitText(context.getString(R.string.billed_cap), 1)
            }
        }
    }

    fun setInputConnection(ic: InputConnection) {
        inputConnection = ic
    }
}