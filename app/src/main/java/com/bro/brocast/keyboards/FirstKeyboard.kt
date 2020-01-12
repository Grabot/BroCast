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
            R.id.button_raising_hands
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
        }
    }

    fun setInputConnection(ic: InputConnection) {
        inputConnection = ic
    }
}