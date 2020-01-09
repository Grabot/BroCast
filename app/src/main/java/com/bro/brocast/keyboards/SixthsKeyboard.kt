package com.bro.brocast.keyboards

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View.OnClickListener
import android.view.inputmethod.InputConnection
import android.widget.Button
import android.widget.LinearLayout
import com.bro.brocast.R


class SixthsKeyboard: LinearLayout {

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

    var buttonSmile: Button? = null

    val emoji_Smile = 0x1F604

    private var inputConnection: InputConnection? = null

    fun init(context: Context) {
        LayoutInflater.from(context).inflate(R.layout.keyboard_6, this, true)

        buttonSmile = findViewById(R.id.button_smile_6)
        buttonSmile!!.setOnClickListener(clickButtonListener)

        buttonSmile!!.text = getEmojiByUnicode(emoji_Smile)
    }

    private val clickButtonListener = OnClickListener { view ->
        when (view.getId()) {
            R.id.button_smile_6 -> {
                inputConnection!!.commitText(getEmojiByUnicode(emoji_Smile), 1)
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