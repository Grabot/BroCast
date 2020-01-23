package com.bro.brocast.keyboards

import android.content.Context
import android.text.TextUtils
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.view.View.OnClickListener
import android.view.ViewGroup
import android.view.inputmethod.InputConnection
import android.widget.Button
import android.widget.ImageButton
import android.widget.LinearLayout
import android.widget.RelativeLayout
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

    var extraInputField: RelativeLayout? = null

    var questionButton: Button? = null
    var exclamationButton: Button? = null
    var backButton: ImageButton? = null

    private fun init(context: Context) {
        LayoutInflater.from(context).inflate(R.layout.keyboard_1, this, true)

        var stringIds = arrayOf(
                R.string.grinning_face,
                R.string.smiling_face_with_open_mouth,
                R.string.smiling_face_with_open_mouth_and_smiling_eyes,
                R.string.grinning_face_with_smiling_eyes,
                R.string.smiling_face_with_open_mouth_and_closed_eyes,
                R.string.smiling_face_with_open_mouth_and_cold_sweat,
                R.string.face_with_tears_of_joy,
                R.string.rolling_on_the_floor_laughing,
                R.string.smiling_face,
                R.string.smiling_face_with_smiling_eyes,
                R.string.smiling_face_with_halo,
                R.string.slightly_smiling_face,
                R.string.upside_down_face,
                R.string.winking_face,
                R.string.relieved_face,
                R.string.smiling_face_with_heart_eyes,
                R.string.smiling_face_with_3_hearts,
                R.string.face_blowing_a_kiss,
                R.string.kissing_face,
                R.string.kissing_face_with_smiling_eyes,
                R.string.kissing_face_with_closed_eyes,
                R.string.face_savouring_delicious_food,
                R.string.face_with_stuck_out_tongue,
                R.string.face_with_stuck_out_tongue_and_closed_eyes,
                R.string.face_with_stuck_out_tongue_and_winking_eye,
                R.string.crazy_face,
                R.string.face_with_raised_eyebrow,
                R.string.face_with_monocle,
                R.string.nerd_face,
                R.string.star_struck,
                R.string.smiling_face_with_sunglasses,
                R.string.partying_face,
                R.string.smirking_face,
                R.string.unamused_face,
                R.string.disappointed_face,
                R.string.pensive_face,
                R.string.worried_face,
                R.string.confused_face,
                R.string.slightly_frowning_face,
                R.string.frowning_face,
                R.string.persevering_face,
                R.string.confounded_face,
                R.string.tired_face,
                R.string.weary_face,
                R.string.pleading_face,
                R.string.crying_face,
                R.string.loudly_crying_face,
                R.string.face_with_steam_from_nose,
                R.string.angry_face,
                R.string.pouting_face,
                R.string.face_with_symbols_over_mouth,
                R.string.exploding_head,
                R.string.flushed_face,
                R.string.hot_face,
                R.string.cold_face,
                R.string.face_screaming_in_fear,
                R.string.fearful_face,
                R.string.face_with_open_mouth_and_cold_sweat,
                R.string.disappointed_but_relieved_face,
                R.string.face_with_cold_sweat,
                R.string.hugging_face,
                R.string.thinking_face,
                R.string.face_with_hand_over_mouth,
                R.string.shushing_face,
                R.string.lying_face,
                R.string.face_without_mouth,
                R.string.neutral_face,
                R.string.expressionless_face,
                R.string.grimacing_face,
                R.string.face_with_rolling_eyes,
                R.string.hushed_face,
                R.string.frowning_face_with_open_mouth,
                R.string.anguished_face,
                R.string.face_with_open_mouth,
                R.string.astonished_face,
                R.string.sleeping_face,
                R.string.drooling_face,
                R.string.sleepy_face,
                R.string.dizzy_face,
                R.string.zipper_mouth_face,
                R.string.woozy_face,
                R.string.nauseated_face,
                R.string.face_vomiting,
                R.string.sneezing_face,
                R.string.face_with_medical_mask,
                R.string.face_with_thermometer,
                R.string.face_with_head_bandage,
                R.string.money_mouth_face,
                R.string.cowboy_hat_face,
                R.string.smiling_face_with_horns,
                R.string.angry_face_with_horns,
                R.string.ogre,
                R.string.goblin,
                R.string.clown_face,
                R.string.pile_of_poo,
                R.string.ghost,
                R.string.skull,
                R.string.skull_and_crossbones,
                R.string.alien,
                R.string.alien_monster,
                R.string.robot_face,
                R.string.jack_o_lantern,
                R.string.smiling_cat_face_with_open_mouth,
                R.string.grinning_cat_face_with_smiling_eyes,
                R.string.cat_face_with_tears_of_joy,
                R.string.smiling_cat_face_with_heart_eyes,
                R.string.cat_face_with_wry_smile,
                R.string.kissing_cat_face_with_closed_eyes,
                R.string.weary_cat_face,
                R.string.crying_cat_face,
                R.string.pouting_cat_face,
                R.string.palms_up_together,
                R.string.open_hands,
                R.string.raising_hands,
                R.string.clapping_hands,
                R.string.handshake,
                R.string.thumbs_up,
                R.string.thumbs_down,
                R.string.oncoming_fist,
                R.string.raised_fist,
                R.string.left_facing_fist,
                R.string.right_facing_fist,
                R.string.crossed_fingers,
                R.string.victory_hand,
                R.string.love_you_gesture,
                R.string.sign_of_the_horns,
                R.string.ok_hand,
                R.string.backhand_index_pointing_left,
                R.string.backhand_index_pointing_right,
                R.string.backhand_index_pointing_up,
                R.string.backhand_index_pointing_down,
                R.string.index_pointing_up,
                R.string.raised_hand,
                R.string.raised_back_of_hand,
                R.string.raised_hand_with_fingers_splayed,
                R.string.vulcan_salute,
                R.string.waving_hand,
                R.string.call_me_hand,
                R.string.flexed_biceps,
                R.string.middle_finger,
                R.string.writing_hand,
                R.string.folded_hands,
                R.string.foot,
                R.string.leg,
                R.string.lipstick,
                R.string.kiss_mark,
                R.string.mouth,
                R.string.tooth,
                R.string.tongue,
                R.string.ear,
                R.string.nose,
                R.string.footprints,
                R.string.eye,
                R.string.eyes,
                R.string.brain,
                R.string.speaking_head,
                R.string.bust_in_silhouette,
                R.string.busts_in_silhouette,
                R.string.baby,
                R.string.girl,
                R.string.child,
                R.string.boy,
                R.string.woman,
                R.string.adult,
                R.string.man,
                R.string.woman_curly_haired,
                R.string.man_curly_haired,
                R.string.woman_red_haired,
                R.string.man_red_haired,
                R.string.blond_haired_woman,
                R.string.blond_haired_man,
                R.string.woman_white_haired,
                R.string.man_white_haired,
                R.string.woman_bald,
                R.string.man_bald,
                R.string.bearded_person,
                R.string.old_woman,
                R.string.older_adult,
                R.string.old_man,
                R.string.man_with_chinese_cap,
                R.string.woman_wearing_turban,
                R.string.man_wearing_turban,
                R.string.woman_with_headscarf,
                R.string.woman_police_officer,
                R.string.man_police_officer,
                R.string.woman_construction_worker,
                R.string.man_construction_worker,
                R.string.woman_guard,
                R.string.man_guard,
                R.string.woman_detective,
                R.string.man_detective,
                R.string.woman_health_worker,
                R.string.man_health_worker,
                R.string.woman_farmer,
                R.string.man_farmer,
                R.string.woman_cook,
                R.string.man_cook,
                R.string.woman_student,
                R.string.man_student,
                R.string.woman_singer,
                R.string.man_singer,
                R.string.woman_teacher,
                R.string.man_teacher,
                R.string.woman_factory_worker,
                R.string.man_factory_worker,
                R.string.woman_technologist,
                R.string.man_technologist,
                R.string.woman_office_worker,
                R.string.man_office_worker,
                R.string.woman_mechanic,
                R.string.man_mechanic,
                R.string.woman_scientist,
                R.string.man_scientist,
                R.string.woman_artist,
                R.string.man_artist,
                R.string.woman_firefighter,
                R.string.man_firefighter,
                R.string.woman_pilot,
                R.string.man_pilot,
                R.string.woman_astronaut,
                R.string.man_astronaut,
                R.string.woman_judge,
                R.string.man_judge,
                R.string.bride_with_veil,
                R.string.man_in_tuxedo,
                R.string.princess,
                R.string.prince,
                R.string.woman_superhero,
                R.string.man_superhero,
                R.string.woman_supervillain,
                R.string.man_supervillain,
                R.string.mrs_claus,
                R.string.santa_claus,
                R.string.woman_mage,
                R.string.man_mage,
                R.string.woman_elf,
                R.string.man_elf,
                R.string.woman_vampire,
                R.string.man_vampire,
                R.string.woman_zombie,
                R.string.man_zombie,
                R.string.woman_genie,
                R.string.man_genie,
                R.string.mermaid,
                R.string.merman,
                R.string.woman_fairy,
                R.string.man_fairy,
                R.string.baby_angel,
                R.string.pregnant_woman,
                R.string.breast_feeding,
                R.string.woman_bowing,
                R.string.man_bowing,
                R.string.woman_tipping_hand,
                R.string.man_tipping_hand,
                R.string.woman_gesturing_no,
                R.string.man_gesturing_no,
                R.string.woman_gesturing_ok,
                R.string.man_gesturing_ok,
                R.string.woman_raising_hand,
                R.string.man_raising_hand,
                R.string.woman_facepalming,
                R.string.man_facepalming,
                R.string.woman_shrugging,
                R.string.man_shrugging,
                R.string.woman_pouting,
                R.string.man_pouting,
                R.string.woman_frowning,
                R.string.man_frowning,
                R.string.woman_getting_haircut,
                R.string.man_getting_haircut,
                R.string.woman_getting_massage,
                R.string.man_getting_massage,
                R.string.woman_in_steamy_room,
                R.string.man_in_steamy_room,
                R.string.nail_polish,
                R.string.selfie,
                R.string.woman_dancing,
                R.string.man_dancing,
                R.string.women_with_bunny_ears_partying,
                R.string.men_with_bunny_ears_partying,
                R.string.man_in_business_suit_levitating,
                R.string.woman_walking,
                R.string.man_walking,
                R.string.woman_running,
                R.string.man_running,
                R.string.man_and_woman_holding_hands,
                R.string.two_women_holding_hands,
                R.string.two_men_holding_hands,
                R.string.couple_with_heart,
                R.string.couple_with_heart_woman_woman,
                R.string.couple_with_heart_man_man,
                R.string.kiss,
                R.string.kiss_woman_woman,
                R.string.kiss_man_man,
                R.string.family,
                R.string.family_man_woman_girl,
                R.string.family_man_woman_girl_boy,
                R.string.family_man_woman_boy_boy,
                R.string.family_man_woman_girl_girl,
                R.string.family_woman_woman_boy,
                R.string.family_woman_woman_girl,
                R.string.family_woman_woman_girl_boy,
                R.string.family_woman_woman_boy_boy,
                R.string.family_woman_woman_girl_girl,
                R.string.family_man_man_boy,
                R.string.family_man_man_girl,
                R.string.family_man_man_girl_boy,
                R.string.family_man_man_boy_boy,
                R.string.family_man_man_girl_girl,
                R.string.family_woman_boy,
                R.string.family_woman_girl,
                R.string.family_woman_girl_boy,
                R.string.family_woman_boy_boy,
                R.string.family_woman_girl_girl,
                R.string.family_man_boy,
                R.string.family_man_girl,
                R.string.family_man_girl_boy,
                R.string.family_man_boy_boy,
                R.string.family_man_girl_girl,
                R.string.yarn,
                R.string.thread,
                R.string.coat,
                R.string.lab_coat,
                R.string.womans_clothes,
                R.string.t_shirt,
                R.string.jeans,
                R.string.necktie,
                R.string.dress,
                R.string.bikini,
                R.string.kimono,
                R.string.womans_flat_shoe,
                R.string.high_heeled_shoe,
                R.string.womans_sandal,
                R.string.womans_boot,
                R.string.mans_shoe,
                R.string.running_shoe,
                R.string.hiking_boot,
                R.string.socks,
                R.string.gloves,
                R.string.scarf,
                R.string.top_hat,
                R.string.billed_cap,
                R.string.womans_hat,
                R.string.graduation_cap,
                R.string.rescue_workers_helmet,
                R.string.crown,
                R.string.ring,
                R.string.clutch_bag,
                R.string.purse,
                R.string.handbag,
                R.string.school_backpack,
                R.string.luggage,
                R.string.glasses,
                R.string.sunglasses,
                R.string.goggles,
                R.string.closed_umbrella
        )

        while ((stringIds.size % 8) != 0) {
            stringIds += 0
        }

        // The outer and main layer of the keyboard
        val mainLayout = findViewById<LinearLayout>(R.id.main_keyboard_layout)

        // creating the button
        val layers = createLayers(context, stringIds)
        for (layer in layers) {
            mainLayout.addView(layer)
        }

        // Create another layer, which is empty. This is to give some space at the bottom
        val spaceLayer = LinearLayout(context)
        val layout = LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, 80)
        layout.weight = 1f
        spaceLayer.layoutParams = layout
        mainLayout.addView(spaceLayer)

    }

    fun setClickListenerExtraFields() {
        questionButton!!.setOnClickListener(clickButtonListener)
        exclamationButton!!.setOnClickListener(clickButtonListener)
        backButton!!.setOnClickListener(clickButtonListener)
    }

    private fun createLayers(context: Context, stringIdArray: Array<Int>): ArrayList<LinearLayout> {
        var layers: ArrayList<LinearLayout> = ArrayList()
        for(n in stringIdArray.indices step 8) {
            val layer = arrayOf(
                stringIdArray[n],
                stringIdArray[n+1],
                stringIdArray[n+2],
                stringIdArray[n+3],
                stringIdArray[n+4],
                stringIdArray[n+5],
                stringIdArray[n+6],
                stringIdArray[n+7]
            )
            val layoutLayer = createLayoutLayer(context, layer)
            layers.add(layoutLayer)
        }
        return layers
    }

    private fun createLayoutLayer(
        context: Context,
        stringIdArray: Array<Int>
    ): LinearLayout {
        val newLayer = LinearLayout(context)
        for (stringId in stringIdArray) {
            val button = createButton(context, stringId)
            newLayer.addView(button)
        }
        return newLayer
    }

    private fun createButton(context: Context, buttonId: Int): Button {
        val button = Button(context, null, android.R.attr.borderlessButtonStyle)
        val layout = LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT)
        layout.weight = 1f
        button.layoutParams = layout
        button.textSize = 19f
        if (buttonId != 0) {
            button.id = View.generateViewId()
            button.text = context.getString(buttonId)
            button.setOnClickListener(clickButtonListener)
        } else {
            button.text = ""
            button.isClickable = false
        }
        return button
    }

    private val clickButtonListener = OnClickListener { view ->
        when (view.id) {
            R.id.button_back -> {
                val selectedText = inputConnection!!.getSelectedText(0)
                var test = inputConnection!!.getTextBeforeCursor(1, 0)

                if (TextUtils.isEmpty(selectedText)) {
                    inputConnection!!.deleteSurroundingText(1, 0)
                } else {
                    inputConnection!!.commitText("", 1)
                }
            }
            R.id.button_question -> {
                inputConnection!!.commitText("?", 1)
            }
            R.id.button_exclamation -> {
                inputConnection!!.commitText("!", 1)
            }
            else -> {
                val button = findViewById<Button>(view.id)
                inputConnection!!.commitText(button.text, 1)

                if (extraInputField!!.visibility != View.VISIBLE) {
                    extraInputField!!.visibility = View.VISIBLE
                }
            }
        }
    }

    fun setInputConnection(ic: InputConnection) {
        inputConnection = ic
    }
}