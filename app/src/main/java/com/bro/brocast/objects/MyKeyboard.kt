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

//    private val keyValues = SparseArray<String>()
    private var inputConnection: InputConnection? = null


    fun init(context: Context) {
        LayoutInflater.from(context).inflate(R.layout.keyboard, this, true)
        button1 = findViewById(R.id.button_1) as Button
        button1!!.setOnClickListener(clickButtonListener)
        button2 = findViewById(R.id.button_2) as Button
        button2!!.setOnClickListener(clickButtonListener)

    }

    private val clickButtonListener = View.OnClickListener { view ->
        when (view.getId()) {
            R.id.button_1 -> {
                inputConnection!!.commitText("1", 1)
            }
            R.id.button_2 -> {
                inputConnection!!.commitText("2", 1)
            }
        }
    }

    fun setInputConnection(ic: InputConnection) {
        inputConnection = ic
    }
}