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

        val buttonIds = arrayOf(
            R.id.button_watch,
            R.id.button_mobile_phone,
            R.id.button_mobile_phone_with_arrow,
            R.id.button_laptop_computer,
            R.id.button_keyboard,
            R.id.button_desktop_computer,
            R.id.button_printer,
            R.id.button_computer_mouse,
            R.id.button_trackball,
            R.id.button_joystick,
            R.id.button_clamp,
            R.id.button_computer_disk,
            R.id.button_floppy_disk,
            R.id.button_optical_disk,
            R.id.button_dvd,
            R.id.button_videocassette,
            R.id.button_camera,
            R.id.button_camera_with_flash,
            R.id.button_video_camera
        )

        for (b in buttonIds) {
            findViewById<Button>(b).setOnClickListener(clickButtonListener)
        }
    }

    private val clickButtonListener = OnClickListener { view ->
        when (view.getId()) {
            R.id.button_watch -> {
                inputConnection!!.commitText(context.getString(R.string.watch), 1)
            }
            R.id.button_mobile_phone -> {
                inputConnection!!.commitText(context.getString(R.string.mobile_phone), 1)
            }
            R.id.button_mobile_phone_with_arrow -> {
                inputConnection!!.commitText(context.getString(R.string.mobile_phone_with_arrow), 1)
            }
            R.id.button_laptop_computer -> {
                inputConnection!!.commitText(context.getString(R.string.laptop_computer), 1)
            }
            R.id.button_keyboard -> {
                inputConnection!!.commitText(context.getString(R.string.keyboard), 1)
            }
            R.id.button_desktop_computer -> {
                inputConnection!!.commitText(context.getString(R.string.desktop_computer), 1)
            }
            R.id.button_printer -> {
                inputConnection!!.commitText(context.getString(R.string.printer), 1)
            }
            R.id.button_computer_mouse -> {
                inputConnection!!.commitText(context.getString(R.string.computer_mouse), 1)
            }
            R.id.button_trackball -> {
                inputConnection!!.commitText(context.getString(R.string.trackball), 1)
            }
            R.id.button_joystick -> {
                inputConnection!!.commitText(context.getString(R.string.joystick), 1)
            }
            R.id.button_clamp -> {
                inputConnection!!.commitText(context.getString(R.string.clamp), 1)
            }
            R.id.button_computer_disk -> {
                inputConnection!!.commitText(context.getString(R.string.computer_disk), 1)
            }
            R.id.button_floppy_disk -> {
                inputConnection!!.commitText(context.getString(R.string.floppy_disk), 1)
            }
            R.id.button_optical_disk -> {
                inputConnection!!.commitText(context.getString(R.string.optical_disk), 1)
            }
            R.id.button_dvd -> {
                inputConnection!!.commitText(context.getString(R.string.dvd), 1)
            }
            R.id.button_videocassette -> {
                inputConnection!!.commitText(context.getString(R.string.videocassette), 1)
            }
            R.id.button_camera -> {
                inputConnection!!.commitText(context.getString(R.string.camera), 1)
            }
            R.id.button_camera_with_flash -> {
                inputConnection!!.commitText(context.getString(R.string.camera_with_flash), 1)
            }
            R.id.button_video_camera -> {
                inputConnection!!.commitText(context.getString(R.string.video_camera), 1)
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