package com.bro.brocast.objects

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
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
    var button3: Button? = null
    var button4: Button? = null

    var emoji_Smile = 0x1F604
    var emoji_Wink = 0x1F609
    var emoji_3 = 0x1F346
    var emoji_4 = 0x1F34C

//    private val keyValues = SparseArray<String>()
    private var inputConnection: InputConnection? = null


    fun init(context: Context) {
        LayoutInflater.from(context).inflate(R.layout.keyboard, this, true)
        buttonSmile = findViewById(R.id.button_smile) as Button
        buttonSmile!!.setOnClickListener(clickButtonListener)
        buttonWink = findViewById(R.id.button_wink) as Button
        buttonWink!!.setOnClickListener(clickButtonListener)
        button3 = findViewById(R.id.button_3) as Button
        button3!!.setOnClickListener(clickButtonListener)
        button4 = findViewById(R.id.button_4) as Button
        button4!!.setOnClickListener(clickButtonListener)

        buttonSmile!!.setText(getEmojiByUnicode(emoji_Smile))
        buttonWink!!.setText(getEmojiByUnicode(emoji_Wink))
        button3!!.setText(getEmojiByUnicode(emoji_3))
        button4!!.setText(getEmojiByUnicode(emoji_4))
    }

    private val clickButtonListener = View.OnClickListener { view ->
        when (view.getId()) {
            R.id.button_smile -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_Smile), 1)
            }
            R.id.button_wink -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_Wink), 1)
            }
            R.id.button_3 -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_3), 1)
            }
            R.id.button_4 -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_4), 1)
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