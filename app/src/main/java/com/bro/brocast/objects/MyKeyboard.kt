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

    var button1: Button? = null
    var button2: Button? = null
    var button3: Button? = null
    var button4: Button? = null

    var emoji_1 = 0x1F60A
    var emoji_2 = 0x1F601
    var emoji_3 = 0x1F346
    var emoji_4 = 0x1F34C

//    private val keyValues = SparseArray<String>()
    private var inputConnection: InputConnection? = null


    fun init(context: Context) {
        LayoutInflater.from(context).inflate(R.layout.keyboard, this, true)
        button1 = findViewById(R.id.button_1) as Button
        button1!!.setOnClickListener(clickButtonListener)
        button2 = findViewById(R.id.button_2) as Button
        button2!!.setOnClickListener(clickButtonListener)
        button3 = findViewById(R.id.button_3) as Button
        button3!!.setOnClickListener(clickButtonListener)
        button4 = findViewById(R.id.button_4) as Button
        button4!!.setOnClickListener(clickButtonListener)

        button1!!.setText(getEmojiByUnicode(emoji_1))
        button2!!.setText(getEmojiByUnicode(emoji_2))
        button3!!.setText(getEmojiByUnicode(emoji_3))
        button4!!.setText(getEmojiByUnicode(emoji_4))
    }

    private val clickButtonListener = View.OnClickListener { view ->
        when (view.getId()) {
            R.id.button_1 -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_1), 1)
            }
            R.id.button_2 -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_2), 1)
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