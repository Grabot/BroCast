package com.bro.brocast

import android.os.Build
import android.os.Bundle
import android.text.InputType
import android.view.inputmethod.EditorInfo
import android.widget.EditText
import androidx.appcompat.app.AppCompatActivity
import com.bro.brocast.objects.MyKeyboard


class KeyboardTestActivtiy: AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.test)

        val editText = findViewById(R.id.editText) as EditText
        val keyboard = findViewById(R.id.keyboard) as MyKeyboard

        editText.setRawInputType(InputType.TYPE_CLASS_TEXT)
        editText.setTextIsSelectable(true)
        // TODO @Skools: set the minimum SDK to this version (LOLLIPOP).
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            editText.requestFocus()
            editText.showSoftInputOnFocus = false
        }

        val ic = editText.onCreateInputConnection(EditorInfo())
        keyboard.setInputConnection(ic)
    }
}