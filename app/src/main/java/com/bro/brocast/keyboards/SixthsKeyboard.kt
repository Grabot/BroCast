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
            R.id.button_video_camera,
            R.id.button_movie_camera,
            R.id.button_film_projector,
            R.id.button_film_frames,
            R.id.button_telephone_receiver,
            R.id.button_telephone,
            R.id.button_pager,
            R.id.button_fax_machine,
            R.id.button_television,
            R.id.button_radio,
            R.id.button_studio_microphone,
            R.id.button_level_slider,
            R.id.button_control_knobs,
            R.id.button_compass,
            R.id.button_stopwatch,
            R.id.button_timer_clock,
            R.id.button_alarm_clock,
            R.id.button_mantelpiece_clock,
            R.id.button_hourglass,
            R.id.button_hourglass_with_flowing_sand,
            R.id.button_satellite_antenna,
            R.id.button_battery,
            R.id.button_electric_plug,
            R.id.button_light_bulb,
            R.id.button_flashlight,
            R.id.button_candle,
            R.id.button_fire_extinguisher,
            R.id.button_oil_drum,
            R.id.button_money_with_wings,
            R.id.button_dollar_banknote,
            R.id.button_yen_banknote,
            R.id.button_euro_banknote,
            R.id.button_pound_banknote,
            R.id.button_money_bag,
            R.id.button_credit_card,
            R.id.button_gem_stone,
            R.id.button_balance_scale,
            R.id.button_toolbox,
            R.id.button_wrench
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
            R.id.button_movie_camera -> {
                inputConnection!!.commitText(context.getString(R.string.movie_camera), 1)
            }
            R.id.button_film_projector -> {
                inputConnection!!.commitText(context.getString(R.string.film_projector), 1)
            }
            R.id.button_film_frames -> {
                inputConnection!!.commitText(context.getString(R.string.film_frames), 1)
            }
            R.id.button_telephone_receiver -> {
                inputConnection!!.commitText(context.getString(R.string.telephone_receiver), 1)
            }
            R.id.button_telephone -> {
                inputConnection!!.commitText(context.getString(R.string.telephone), 1)
            }
            R.id.button_pager -> {
                inputConnection!!.commitText(context.getString(R.string.pager), 1)
            }
            R.id.button_fax_machine -> {
                inputConnection!!.commitText(context.getString(R.string.fax_machine), 1)
            }
            R.id.button_television -> {
                inputConnection!!.commitText(context.getString(R.string.television), 1)
            }
            R.id.button_radio -> {
                inputConnection!!.commitText(context.getString(R.string.radio), 1)
            }
            R.id.button_studio_microphone -> {
                inputConnection!!.commitText(context.getString(R.string.studio_microphone), 1)
            }
            R.id.button_level_slider -> {
                inputConnection!!.commitText(context.getString(R.string.level_slider), 1)
            }
            R.id.button_control_knobs -> {
                inputConnection!!.commitText(context.getString(R.string.control_knobs), 1)
            }
            R.id.button_compass -> {
                inputConnection!!.commitText(context.getString(R.string.compass), 1)
            }
            R.id.button_stopwatch -> {
                inputConnection!!.commitText(context.getString(R.string.stopwatch), 1)
            }
            R.id.button_timer_clock -> {
                inputConnection!!.commitText(context.getString(R.string.timer_clock), 1)
            }
            R.id.button_alarm_clock -> {
                inputConnection!!.commitText(context.getString(R.string.alarm_clock), 1)
            }
            R.id.button_mantelpiece_clock -> {
                inputConnection!!.commitText(context.getString(R.string.mantelpiece_clock), 1)
            }
            R.id.button_hourglass -> {
                inputConnection!!.commitText(context.getString(R.string.hourglass), 1)
            }
            R.id.button_hourglass_with_flowing_sand -> {
                inputConnection!!.commitText(context.getString(R.string.hourglass_with_flowing_sand), 1)
            }
            R.id.button_satellite_antenna -> {
                inputConnection!!.commitText(context.getString(R.string.satellite_antenna), 1)
            }
            R.id.button_battery -> {
                inputConnection!!.commitText(context.getString(R.string.battery), 1)
            }
            R.id.button_electric_plug -> {
                inputConnection!!.commitText(context.getString(R.string.electric_plug), 1)
            }
            R.id.button_light_bulb -> {
                inputConnection!!.commitText(context.getString(R.string.light_bulb), 1)
            }
            R.id.button_flashlight -> {
                inputConnection!!.commitText(context.getString(R.string.flashlight), 1)
            }
            R.id.button_candle -> {
                inputConnection!!.commitText(context.getString(R.string.candle), 1)
            }
            R.id.button_fire_extinguisher -> {
                inputConnection!!.commitText(context.getString(R.string.fire_extinguisher), 1)
            }
            R.id.button_oil_drum -> {
                inputConnection!!.commitText(context.getString(R.string.oil_drum), 1)
            }
            R.id.button_money_with_wings -> {
                inputConnection!!.commitText(context.getString(R.string.money_with_wings), 1)
            }
            R.id.button_dollar_banknote -> {
                inputConnection!!.commitText(context.getString(R.string.dollar_banknote), 1)
            }
            R.id.button_yen_banknote -> {
                inputConnection!!.commitText(context.getString(R.string.yen_banknote), 1)
            }
            R.id.button_euro_banknote -> {
                inputConnection!!.commitText(context.getString(R.string.euro_banknote), 1)
            }
            R.id.button_pound_banknote -> {
                inputConnection!!.commitText(context.getString(R.string.pound_banknote), 1)
            }
            R.id.button_money_bag -> {
                inputConnection!!.commitText(context.getString(R.string.money_bag), 1)
            }
            R.id.button_credit_card -> {
                inputConnection!!.commitText(context.getString(R.string.credit_card), 1)
            }
            R.id.button_gem_stone -> {
                inputConnection!!.commitText(context.getString(R.string.gem_stone), 1)
            }
            R.id.button_balance_scale -> {
                inputConnection!!.commitText(context.getString(R.string.balance_scale), 1)
            }
            R.id.button_toolbox -> {
                inputConnection!!.commitText(context.getString(R.string.toolbox), 1)
            }
            R.id.button_wrench -> {
                inputConnection!!.commitText(context.getString(R.string.wrench), 1)
            }
        }
    }

    fun setInputConnection(ic: InputConnection) {
        inputConnection = ic
    }
}