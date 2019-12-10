package com.bro.brocast

import android.os.Bundle
import android.text.InputType
import android.view.inputmethod.EditorInfo
import android.widget.EditText
import androidx.appcompat.app.AppCompatActivity


class KeyboardTestActivtiy: AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
//        https://stackoverflow.com/questions/9577304/how-can-you-make-a-custom-keyboard-in-android/45005691#45005691
        super.onCreate(savedInstanceState)
        setContentView(R.layout.test)

        val editText = findViewById(R.id.editText) as EditText
        val keyboard = findViewById(R.id.keyboard) as MyKeyboard

        // prevent system keyboard from appearing when EditText is tapped
        editText.setRawInputType(InputType.TYPE_CLASS_TEXT)
        editText.setTextIsSelectable(true)

        // pass the InputConnection from the EditText to the keyboard
        val ic = editText.onCreateInputConnection(EditorInfo())
        keyboard.setInputConnection(ic)
    }
}