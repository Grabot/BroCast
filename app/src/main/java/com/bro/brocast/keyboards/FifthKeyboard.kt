package com.bro.brocast.keyboards

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View.OnClickListener
import android.view.inputmethod.InputConnection
import android.widget.Button
import android.widget.LinearLayout
import com.bro.brocast.R


class FifthKeyboard: LinearLayout {

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

    private var inputConnection: InputConnection? = null

    fun init(context: Context) {
        LayoutInflater.from(context).inflate(R.layout.keyboard_5, this, true)

        val buttonIds = arrayOf(
            R.id.button_automobile,
            R.id.button_taxi,
            R.id.button_sport_utility_vehicle,
            R.id.button_bus,
            R.id.button_trolleybus,
            R.id.button_racing_car,
            R.id.button_police_car,
            R.id.button_ambulance,
            R.id.button_fire_engine,
            R.id.button_minibus,
            R.id.button_delivery_truck,
            R.id.button_articulated_lorry,
            R.id.button_tractor,
            R.id.button_kick_scooter,
            R.id.button_bicycle,
            R.id.button_motor_scooter,
            R.id.button_motorcycle,
            R.id.button_police_car_light,
            R.id.button_oncoming_police_car,
            R.id.button_oncoming_bus,
            R.id.button_oncoming_automobile,
            R.id.button_oncoming_taxi,
            R.id.button_aerial_tramway,
            R.id.button_mountain_cableway,
            R.id.button_suspension_railway,
            R.id.button_railway_car,
            R.id.button_tram_car,
            R.id.button_mountain_railway,
            R.id.button_monorail,
            R.id.button_high_speed_train,
            R.id.button_high_speed_train_with_bullet_nose,
            R.id.button_light_rail,
            R.id.button_locomotive,
            R.id.button_train,
            R.id.button_metro,
            R.id.button_tram,
            R.id.button_station,
            R.id.button_airplane
        )

        for (b in buttonIds) {
            findViewById<Button>(b).setOnClickListener(clickButtonListener)
        }
    }

    private val clickButtonListener = OnClickListener { view ->
        when (view.getId()) {
            R.id.button_automobile -> {
                inputConnection!!.commitText(context.getString(R.string.automobile), 1)
            }
            R.id.button_taxi -> {
                inputConnection!!.commitText(context.getString(R.string.taxi), 1)
            }
            R.id.button_sport_utility_vehicle -> {
                inputConnection!!.commitText(context.getString(R.string.sport_utility_vehicle), 1)
            }
            R.id.button_bus -> {
                inputConnection!!.commitText(context.getString(R.string.bus), 1)
            }
            R.id.button_trolleybus -> {
                inputConnection!!.commitText(context.getString(R.string.trolleybus), 1)
            }
            R.id.button_racing_car -> {
                inputConnection!!.commitText(context.getString(R.string.racing_car), 1)
            }
            R.id.button_police_car -> {
                inputConnection!!.commitText(context.getString(R.string.police_car), 1)
            }
            R.id.button_ambulance -> {
                inputConnection!!.commitText(context.getString(R.string.ambulance), 1)
            }
            R.id.button_fire_engine -> {
                inputConnection!!.commitText(context.getString(R.string.fire_engine), 1)
            }
            R.id.button_minibus -> {
                inputConnection!!.commitText(context.getString(R.string.minibus), 1)
            }
            R.id.button_delivery_truck -> {
                inputConnection!!.commitText(context.getString(R.string.delivery_truck), 1)
            }
            R.id.button_articulated_lorry -> {
                inputConnection!!.commitText(context.getString(R.string.articulated_lorry), 1)
            }
            R.id.button_tractor -> {
                inputConnection!!.commitText(context.getString(R.string.tractor), 1)
            }
            R.id.button_kick_scooter -> {
                inputConnection!!.commitText(context.getString(R.string.kick_scooter), 1)
            }
            R.id.button_bicycle -> {
                inputConnection!!.commitText(context.getString(R.string.bicycle), 1)
            }
            R.id.button_motor_scooter -> {
                inputConnection!!.commitText(context.getString(R.string.motor_scooter), 1)
            }
            R.id.button_motorcycle -> {
                inputConnection!!.commitText(context.getString(R.string.motorcycle), 1)
            }
            R.id.button_police_car_light -> {
                inputConnection!!.commitText(context.getString(R.string.police_car_light), 1)
            }
            R.id.button_oncoming_police_car -> {
                inputConnection!!.commitText(context.getString(R.string.oncoming_police_car), 1)
            }
            R.id.button_oncoming_bus -> {
                inputConnection!!.commitText(context.getString(R.string.oncoming_bus), 1)
            }
            R.id.button_oncoming_automobile -> {
                inputConnection!!.commitText(context.getString(R.string.oncoming_automobile), 1)
            }
            R.id.button_oncoming_taxi -> {
                inputConnection!!.commitText(context.getString(R.string.oncoming_taxi), 1)
            }
            R.id.button_aerial_tramway -> {
                inputConnection!!.commitText(context.getString(R.string.aerial_tramway), 1)
            }
            R.id.button_mountain_cableway -> {
                inputConnection!!.commitText(context.getString(R.string.mountain_cableway), 1)
            }
            R.id.button_suspension_railway -> {
                inputConnection!!.commitText(context.getString(R.string.suspension_railway), 1)
            }
            R.id.button_railway_car -> {
                inputConnection!!.commitText(context.getString(R.string.railway_car), 1)
            }
            R.id.button_tram_car -> {
                inputConnection!!.commitText(context.getString(R.string.tram_car), 1)
            }
            R.id.button_mountain_railway -> {
                inputConnection!!.commitText(context.getString(R.string.mountain_railway), 1)
            }
            R.id.button_monorail -> {
                inputConnection!!.commitText(context.getString(R.string.monorail), 1)
            }
            R.id.button_high_speed_train -> {
                inputConnection!!.commitText(context.getString(R.string.high_speed_train), 1)
            }
            R.id.button_high_speed_train_with_bullet_nose -> {
                inputConnection!!.commitText(context.getString(R.string.high_speed_train_with_bullet_nose), 1)
            }
            R.id.button_light_rail -> {
                inputConnection!!.commitText(context.getString(R.string.light_rail), 1)
            }
            R.id.button_locomotive -> {
                inputConnection!!.commitText(context.getString(R.string.locomotive), 1)
            }
            R.id.button_train -> {
                inputConnection!!.commitText(context.getString(R.string.train), 1)
            }
            R.id.button_metro -> {
                inputConnection!!.commitText(context.getString(R.string.metro), 1)
            }
            R.id.button_tram -> {
                inputConnection!!.commitText(context.getString(R.string.tram), 1)
            }
            R.id.button_station -> {
                inputConnection!!.commitText(context.getString(R.string.station), 1)
            }
            R.id.button_airplane -> {
                inputConnection!!.commitText(context.getString(R.string.airplane), 1)
            }
        }
    }

    fun setInputConnection(ic: InputConnection) {
        inputConnection = ic
    }
}