package com.bro.brocast.objects

import android.content.Context
import android.text.TextUtils
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View.OnClickListener
import android.view.inputmethod.InputConnection
import android.widget.Button
import android.widget.LinearLayout
import com.bro.brocast.R


class MyKeyboard: LinearLayout {

    constructor(context: Context) : super(context){
        init(context)
    }

    constructor(context: Context, attrs: AttributeSet):    super(context, attrs){
        init(context)
    }

    constructor(context: Context, attrs: AttributeSet?,    defStyleAttr: Int) : super(context, attrs, defStyleAttr) {
        init(context)
    }

    var buttonSmile: Button? = null
    var buttonWink: Button? = null
    var buttonThrowingAKiss: Button? = null
    var buttonBack: Button? = null
    var buttonEggplant: Button? = null
    var buttonBanana: Button? = null
    var buttonTearsOfJoy: Button? = null
    var buttonHeartShapedEyes: Button? = null

    val emoji_Smile = 0x1F604
    val emoji_Wink = 0x1F609
    val emoji_throwing_a_kiss = 0x1F618
    val emoji_eggplant = 0x1F346
    val emoji_banana = 0x1F34C
    val emoji_tears_of_joy = 0x1F602
    val emoji_heart_shaped_eyes = 0x1F60D

//    private val keyValues = SparseArray<String>()
    private var inputConnection: InputConnection? = null


    fun init(context: Context) {
        LayoutInflater.from(context).inflate(R.layout.keyboard, this, true)
        buttonSmile = findViewById(R.id.button_smile) as Button
        buttonSmile!!.setOnClickListener(clickButtonListener)
        buttonWink = findViewById(R.id.button_wink) as Button
        buttonWink!!.setOnClickListener(clickButtonListener)
        buttonThrowingAKiss = findViewById(R.id.button_throwing_a_kiss)
        buttonThrowingAKiss!!.setOnClickListener(clickButtonListener)
        buttonBack = findViewById(R.id.button_back) as Button
        buttonBack!!.setOnClickListener(clickButtonListener)
        buttonEggplant = findViewById(R.id.button_eggplant) as Button
        buttonEggplant!!.setOnClickListener(clickButtonListener)
        buttonBanana = findViewById(R.id.button_banana) as Button
        buttonBanana!!.setOnClickListener(clickButtonListener)
        buttonTearsOfJoy = findViewById(R.id.button_tears_of_joy)
        buttonTearsOfJoy!!.setOnClickListener(clickButtonListener)
        buttonHeartShapedEyes = findViewById(R.id.button_heart_shaped_eyes)
        buttonHeartShapedEyes!!.setOnClickListener(clickButtonListener)

        buttonSmile!!.setText(getEmojiByUnicode(emoji_Smile))
        buttonWink!!.setText(getEmojiByUnicode(emoji_Wink))
        buttonThrowingAKiss!!.setText(getEmojiByUnicode(emoji_throwing_a_kiss))
        buttonEggplant!!.setText(getEmojiByUnicode(emoji_eggplant))
        buttonBanana!!.setText(getEmojiByUnicode(emoji_banana))
        buttonTearsOfJoy!!.setText(getEmojiByUnicode(emoji_tears_of_joy))
        buttonHeartShapedEyes!!.setText(getEmojiByUnicode(emoji_heart_shaped_eyes))
    }

    private val clickButtonListener = OnClickListener { view ->
        when (view.getId()) {
            R.id.button_back -> {
                val selectedText = inputConnection!!.getSelectedText(0)

                if (TextUtils.isEmpty(selectedText)) {
                    // We assume that the emoji will always have length 2
                    inputConnection!!.deleteSurroundingText(2, 0)
                } else {
                    inputConnection!!.commitText("", 1)
                }
            }
            R.id.button_smile -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_Smile), 1)
            }
            R.id.button_wink -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_Wink), 1)
            }
            R.id.button_throwing_a_kiss -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_throwing_a_kiss), 1)
            }
            R.id.button_eggplant -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_eggplant), 1)
            }
            R.id.button_banana -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_banana), 1)
            }
            R.id.button_tears_of_joy -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_tears_of_joy), 1)
            }
            R.id.button_heart_shaped_eyes -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_heart_shaped_eyes), 1)
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