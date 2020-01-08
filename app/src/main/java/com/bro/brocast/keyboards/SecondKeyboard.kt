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

    var buttonBack: Button? = null
    // button row 1
    var buttonSmile: Button? = null
    var buttonWink: Button? = null
    var buttonKissingFaceClosedEyes: Button? = null
    var buttonStuckOutTongue: Button? = null
    var buttonColdSweat: Button? = null
    var buttonPensive: Button? = null

    // button row 2
    var buttonEggplant: Button? = null
    var buttonBanana: Button? = null
    var buttonHeart: Button? = null
    var buttonRollingOnTheFloor: Button? = null
    var buttonFaceWithHearts: Button? = null
    var buttonFoldedHands: Button? = null
    var buttonLoudlyCrying: Button? = null
    var buttonRightFacingFist: Button? = null
    var buttonLeftFacingFist: Button? = null

    // button row 3
    var buttonTearsOfJoy: Button? = null
    var buttonSweatDroplets: Button? = null
    var buttonHeartShapedEyes: Button? = null
    var buttonThumbsUp: Button? = null
    var buttonFire: Button? = null
    var buttonRainbow: Button? = null
    var buttonClinkingBeerMugs: Button? = null
    var buttonThinkingFace: Button? = null
    var buttonWineGlass: Button? = null

    // button row 4
    var buttonMushroom: Button? = null
    var buttonPeach: Button? = null
    var buttonPileOfPoo: Button? = null
    var buttonPersonFacepalming: Button? = null
    var buttonFireworks: Button? = null
    var buttonPartyPoppers: Button? = null
    var buttonConfettiBall: Button? = null
    var buttonExlamationMark: Button? = null
    var buttonQuestionMark: Button? = null

    // emoji row 1
    val emoji_Smile = 0x1F604
    val emoji_Wink = 0x1F609
    val emoji_throwing_a_kiss = 0x1F618
    val emoji_kissing_face_closed_eyes = 0x1F61A
    val emoji_stuck_out_tongue = 0x1F61B
    val emoji_cold_sweat = 0x1F613
    val emoji_pensive = 0x1F614

    // emoji row 2
    val emoji_eggplant = 0x1F346
    val emoji_banana = 0x1F34C
    val emoji_heart = 0x2764
    val emoji_rolling_on_the_floor = 0x1F923
    val emoji_face_with_hearts = 0x1F970
    val emoji_folded_hands = 0x1F64F
    val emoji_loudly_crying = 0x1F62D
    val emoji_right_facing_fist = 0x1F91C
    val emoji_left_facing_fist = 0x1F91B

    // emoji row 3
    val emoji_tears_of_joy = 0x1F602
    val emoji_sweat_droplets = 0x1F4A6
    val emoji_heart_shaped_eyes = 0x1F60D
    val emoji_thumbs_up = 0x1F44D
    val emoji_fire = 0x1F525
    val emoji_rainbow = 0x1F308
    val emoji_clinking_beer_mugs = 0x1F37B
    val emoji_thinking_face = 0x1F914
    val emoji_wine_glass = 0x1F377

    // emoji row 4
    val emoji_mushroom = 0x1F344
    val emoji_peach = 0x1F351
    val emoji_pile_of_poo = 0x1F4A9
    val emoji_person_facepalming = 0x1F926
    val emoji_fireworks = 0x1F386
    val emoji_party_poppers = 0x1F389
    val emoji_confetti_ball = 0x1F38A

    private var inputConnection: InputConnection? = null


    fun init(context: Context) {
        LayoutInflater.from(context).inflate(R.layout.keyboard_second, this, true)

        buttonBack = findViewById(R.id.button_back_2)
        buttonBack!!.setOnClickListener(clickButtonListener)
        // row 1
        buttonSmile = findViewById(R.id.button_smile_2)
        buttonSmile!!.setOnClickListener(clickButtonListener)
        buttonWink = findViewById(R.id.button_wink_2)
        buttonWink!!.setOnClickListener(clickButtonListener)
        buttonKissingFaceClosedEyes = findViewById(R.id.button_kissing_face_closed_eyes_2)
        buttonKissingFaceClosedEyes!!.setOnClickListener(clickButtonListener)
        buttonStuckOutTongue = findViewById(R.id.button_stuck_out_tongue_2)
        buttonStuckOutTongue!!.setOnClickListener(clickButtonListener)
        buttonColdSweat = findViewById(R.id.button_cold_sweat_2)
        buttonColdSweat!!.setOnClickListener(clickButtonListener)
        buttonPensive = findViewById(R.id.button_pensive_2)
        buttonPensive!!.setOnClickListener(clickButtonListener)

        // row 2
        buttonTearsOfJoy = findViewById(R.id.button_tears_of_joy_2)
        buttonTearsOfJoy!!.setOnClickListener(clickButtonListener)
        buttonHeartShapedEyes = findViewById(R.id.button_heart_shaped_eyes_2)
        buttonHeartShapedEyes!!.setOnClickListener(clickButtonListener)
        buttonHeart = findViewById(R.id.button_heart_2)
        buttonHeart!!.setOnClickListener(clickButtonListener)
        buttonRollingOnTheFloor = findViewById(R.id.button_rolling_on_the_floor_2)
        buttonRollingOnTheFloor!!.setOnClickListener(clickButtonListener)
        buttonFaceWithHearts = findViewById(R.id.button_face_with_hearts_2)
        buttonFaceWithHearts!!.setOnClickListener(clickButtonListener)
        buttonFoldedHands = findViewById(R.id.button_folded_hands_2)
        buttonFoldedHands!!.setOnClickListener(clickButtonListener)
        buttonLoudlyCrying = findViewById(R.id.button_loudly_crying_2)
        buttonLoudlyCrying!!.setOnClickListener(clickButtonListener)
        buttonRightFacingFist = findViewById(R.id.button_right_facing_fist_2)
        buttonRightFacingFist!!.setOnClickListener(clickButtonListener)
        buttonLeftFacingFist = findViewById(R.id.button_left_facing_fist_2)
        buttonLeftFacingFist!!.setOnClickListener(clickButtonListener)

        // row 3
        buttonEggplant = findViewById(R.id.button_eggplant_2)
        buttonEggplant!!.setOnClickListener(clickButtonListener)
        buttonSweatDroplets = findViewById(R.id.button_sweat_droplets_2)
        buttonSweatDroplets!!.setOnClickListener(clickButtonListener)
        buttonBanana = findViewById(R.id.button_banana_2)
        buttonBanana!!.setOnClickListener(clickButtonListener)
        buttonThumbsUp = findViewById(R.id.button_thumbs_up_2)
        buttonThumbsUp!!.setOnClickListener(clickButtonListener)
        buttonFire = findViewById(R.id.button_fire_2)
        buttonFire!!.setOnClickListener((clickButtonListener))
        buttonRainbow = findViewById(R.id.button_rainbow_2)
        buttonRainbow!!.setOnClickListener(clickButtonListener)
        buttonClinkingBeerMugs = findViewById(R.id.button_clinking_beer_mugs_2)
        buttonClinkingBeerMugs!!.setOnClickListener(clickButtonListener)
        buttonThinkingFace = findViewById(R.id.button_thinking_face_2)
        buttonThinkingFace!!.setOnClickListener(clickButtonListener)
        buttonWineGlass = findViewById(R.id.button_wine_glass_2)
        buttonWineGlass!!.setOnClickListener(clickButtonListener)

        // row 4
        buttonMushroom = findViewById(R.id.button_mushroom_2)
        buttonMushroom!!.setOnClickListener(clickButtonListener)
        buttonPeach = findViewById(R.id.button_peach_2)
        buttonPeach!!.setOnClickListener(clickButtonListener)
        buttonExlamationMark = findViewById(R.id.button_exlamation_mark_2)
        buttonExlamationMark!!.setOnClickListener(clickButtonListener)
        buttonQuestionMark = findViewById(R.id.button_question_mark_2)
        buttonQuestionMark!!.setOnClickListener(clickButtonListener)
        buttonPileOfPoo = findViewById(R.id.button_pile_of_poo_2)
        buttonPileOfPoo!!.setOnClickListener(clickButtonListener)
        buttonPersonFacepalming = findViewById(R.id.button_person_facepalming_2)
        buttonPersonFacepalming!!.setOnClickListener(clickButtonListener)
        buttonFireworks = findViewById(R.id.button_fireworks_2)
        buttonFireworks!!.setOnClickListener(clickButtonListener)
        buttonPartyPoppers = findViewById(R.id.button_party_poppers_2)
        buttonPartyPoppers!!.setOnClickListener(clickButtonListener)
        buttonConfettiBall = findViewById(R.id.button_confetti_ball_2)
        buttonConfettiBall!!.setOnClickListener(clickButtonListener)

        // row 1
        buttonSmile!!.text = getEmojiByUnicode(emoji_Smile)
        buttonWink!!.text = getEmojiByUnicode(emoji_Wink)
        buttonKissingFaceClosedEyes!!.text = getEmojiByUnicode(emoji_kissing_face_closed_eyes)
        buttonStuckOutTongue!!.text = getEmojiByUnicode(emoji_stuck_out_tongue)
        buttonColdSweat!!.text = getEmojiByUnicode(emoji_cold_sweat)
        buttonPensive!!.text = getEmojiByUnicode(emoji_pensive)

        // row 2
        buttonTearsOfJoy!!.text = getEmojiByUnicode(emoji_tears_of_joy)
        buttonHeartShapedEyes!!.text = getEmojiByUnicode(emoji_heart_shaped_eyes)
        buttonHeart!!.text = getEmojiByUnicode(emoji_heart)
        buttonRollingOnTheFloor!!.text = getEmojiByUnicode(emoji_rolling_on_the_floor)
        buttonFoldedHands!!.text = getEmojiByUnicode(emoji_folded_hands)
        buttonLoudlyCrying!!.text = getEmojiByUnicode(emoji_loudly_crying)
        buttonRightFacingFist!!.text = getEmojiByUnicode(emoji_right_facing_fist)
        buttonLeftFacingFist!!.text = getEmojiByUnicode(emoji_left_facing_fist)

        // row 3
        buttonEggplant!!.text = getEmojiByUnicode(emoji_eggplant)
        buttonSweatDroplets!!.text = getEmojiByUnicode(emoji_sweat_droplets)
        buttonBanana!!.text = getEmojiByUnicode(emoji_banana)
        buttonThumbsUp!!.text = getEmojiByUnicode(emoji_thumbs_up)
        buttonFire!!.text = getEmojiByUnicode(emoji_fire)
        buttonRainbow!!.text = getEmojiByUnicode(emoji_rainbow)
        buttonClinkingBeerMugs!!.text = getEmojiByUnicode(emoji_clinking_beer_mugs)
        buttonThinkingFace!!.text = getEmojiByUnicode(emoji_thinking_face)
        buttonWineGlass!!.text = getEmojiByUnicode(emoji_wine_glass)

        // row 4
        buttonMushroom!!.text = getEmojiByUnicode(emoji_mushroom)
        buttonPeach!!.text = getEmojiByUnicode(emoji_peach)
        buttonPileOfPoo!!.text = getEmojiByUnicode(emoji_pile_of_poo)
        buttonPersonFacepalming!!.text = getEmojiByUnicode(emoji_person_facepalming)
        buttonFireworks!!.text = getEmojiByUnicode(emoji_fireworks)
        buttonPartyPoppers!!.text = getEmojiByUnicode(emoji_party_poppers)
        buttonConfettiBall!!.text = getEmojiByUnicode(emoji_confetti_ball)
        buttonExlamationMark!!.text = "!"
        buttonQuestionMark!!.text = "?"
    }

    private val clickButtonListener = OnClickListener { view ->
        when (view.getId()) {
            R.id.button_back_2 -> {
                val selectedText = inputConnection!!.getSelectedText(0)

                if (TextUtils.isEmpty(selectedText)) {
                    // We assume that the emoji will always have length 2
                    // TODO @Skools: sometimes the emoji is NOT length 2. Fix this!
                    //  Possibly a complete Emoji overhaul
                    if (inputConnection!!.getTextBeforeCursor(1, 1).toString().equals("❤")
                        || inputConnection!!.getTextBeforeCursor(1, 1).toString().equals("!")
                        || inputConnection!!.getTextBeforeCursor(1, 1).toString().equals("?")) {
                        // Simple solution to fix the emoji's and characters of length 1
                        inputConnection!!.deleteSurroundingText(1, 0)
                    } else {
                        inputConnection!!.deleteSurroundingText(2, 0)
                    }
                } else {
                    inputConnection!!.commitText("", 1)
                }
            }
            // row 1
            R.id.button_smile_2 -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_Smile), 1)
            }
            R.id.button_wink_2 -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_Wink), 1)
            }
            R.id.button_kissing_face_closed_eyes_2 -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_kissing_face_closed_eyes), 1)
            }
            R.id.button_stuck_out_tongue_2 -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_stuck_out_tongue), 1)
            }
            R.id.button_cold_sweat_2 -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_cold_sweat), 1)
            }
            R.id.button_pensive_2 -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_pensive), 1)
            }
            // row 2
            R.id.button_tears_of_joy_2 -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_tears_of_joy), 1)
            }
            R.id.button_heart_shaped_eyes_2 -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_heart_shaped_eyes), 1)
            }
            R.id.button_heart_2 -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_heart), 1)
            }
            R.id.button_rolling_on_the_floor_2 -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_rolling_on_the_floor), 1)
            }
            R.id.button_face_with_hearts_2 -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_face_with_hearts), 1)
            }
            R.id.button_folded_hands_2 -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_folded_hands), 1)
            }
            R.id.button_loudly_crying_2 -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_loudly_crying), 1)
            }
            R.id.button_right_facing_fist_2 -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_right_facing_fist), 1)
            }
            R.id.button_left_facing_fist_2 -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_left_facing_fist), 1)
            }
            // row 3
            R.id.button_eggplant_2 -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_eggplant), 1)
            }
            R.id.button_sweat_droplets_2 -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_sweat_droplets), 1)
            }
            R.id.button_banana_2 -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_banana), 1)
            }
            R.id.button_thumbs_up_2 -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_thumbs_up), 1)
            }
            R.id.button_fire_2 -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_fire), 1)
            }
            R.id.button_rainbow_2 -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_rainbow), 1)
            }
            R.id.button_clinking_beer_mugs_2 -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_clinking_beer_mugs), 1)
            }
            R.id.button_thinking_face_2 -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_thinking_face), 1)
            }
            R.id.button_wine_glass_2 -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_wine_glass), 1)
            }

            // row 4
            R.id.button_mushroom_2 -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_mushroom), 1)
            }
            R.id.button_peach_2 -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_peach), 1)
            }
            R.id.button_pile_of_poo_2 -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_pile_of_poo), 1)
            }
            R.id.button_person_facepalming_2 -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_person_facepalming), 1)
            }
            R.id.button_fireworks_2 -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_fireworks), 1)
            }
            R.id.button_party_poppers_2 -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_party_poppers), 1)
            }
            R.id.button_confetti_ball_2 -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_confetti_ball), 1)
            }
            R.id.button_exlamation_mark_2 -> {
                inputConnection!!.commitText("!", 1)
            }
            R.id.button_question_mark_2 -> {
                inputConnection!!.commitText("?", 1)
            }
        }
    }

    private fun getEmojiByUnicode(unicode: Int): String {
        return String(Character.toChars(unicode))
    }


    fun setInputConnection(ic: InputConnection) {
        inputConnection = ic
    }
}