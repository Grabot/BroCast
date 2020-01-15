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

//        val buttonIds = arrayOf(
//            R.id.button_grinning_face
//        )
//
//        for (b in buttonIds) {
//            findViewById<Button>(b).setOnClickListener(clickButtonListener)
//        }
    }

    private val clickButtonListener = OnClickListener { view ->
        when (view.id) {
        }
    }

    fun setInputConnection(ic: InputConnection) {
        inputConnection = ic
    }
}