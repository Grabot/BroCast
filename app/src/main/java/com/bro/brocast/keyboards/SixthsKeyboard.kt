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

    private var inputConnection: InputConnection? = null

    fun init(context: Context) {
        LayoutInflater.from(context).inflate(R.layout.keyboard_6, this, true)

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
            R.id.button_airplane,
            R.id.button_airplane_departure,
            R.id.button_airplane_arrival,
            R.id.button_small_airplane,
            R.id.button_seat,
            R.id.button_satellite,
            R.id.button_rocket,
            R.id.button_flying_saucer,
            R.id.button_helicopter,
            R.id.button_canoe,
            R.id.button_sailboat,
            R.id.button_speedboat,
            R.id.button_motor_boat,
            R.id.button_passenger_ship,
            R.id.button_ferry,
            R.id.button_ship,
            R.id.button_anchor,
            R.id.button_fuel_pump,
            R.id.button_construction,
            R.id.button_vertical_traffic_light,
            R.id.button_horizontal_traffic_light,
            R.id.button_bus_stop,
            R.id.button_world_map,
            R.id.button_moai,
            R.id.button_statue_of_liberty,
            R.id.button_tokyo_tower,
            R.id.button_castle,
            R.id.button_japanese_castle,
            R.id.button_stadium,
            R.id.button_ferris_wheel,
            R.id.button_roller_coaster,
            R.id.button_carousel_horse,
            R.id.button_fountain,
            R.id.button_umbrella_on_ground,
            R.id.button_beach_with_umbrella,
            R.id.button_desert_island,
            R.id.button_desert,
            R.id.button_volcano,
            R.id.button_mountain,
            R.id.button_snow_capped_mountain,
            R.id.button_mount_fuji,
            R.id.button_camping,
            R.id.button_tent,
            R.id.button_house,
            R.id.button_house_with_garden,
            R.id.button_house_buildings,
            R.id.button_derelict_house,
            R.id.button_building_construction,
            R.id.button_factory,
            R.id.button_office_building,
            R.id.button_department_store,
            R.id.button_japanese_post_office,
            R.id.button_post_office,
            R.id.button_hospital,
            R.id.button_bank,
            R.id.button_hotel,
            R.id.button_convenience_store,
            R.id.button_school,
            R.id.button_love_hotel,
            R.id.button_wedding,
            R.id.button_classical_building,
            R.id.button_church,
            R.id.button_mosque,
            R.id.button_synagogue,
            R.id.button_kaaba,
            R.id.button_shinto_shrine,
            R.id.button_railway_track,
            R.id.button_motorway,
            R.id.button_map_of_japan,
            R.id.button_moon_viewing_ceremony,
            R.id.button_national_park,
            R.id.button_sunrise,
            R.id.button_sunrise_over_mountains,
            R.id.button_shooting_star,
            R.id.button_sparkler,
            R.id.button_fireworks,
            R.id.button_sunset,
            R.id.button_cityscape_at_dusk,
            R.id.button_cityscape,
            R.id.button_night_with_stars,
            R.id.button_milky_way,
            R.id.button_bridge_at_night,
            R.id.button_foggy
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
            R.id.button_airplane_departure -> {
                inputConnection!!.commitText(context.getString(R.string.airplane_departure), 1)
            }
            R.id.button_airplane_arrival -> {
                inputConnection!!.commitText(context.getString(R.string.airplane_arrival), 1)
            }
            R.id.button_small_airplane -> {
                inputConnection!!.commitText(context.getString(R.string.small_airplane), 1)
            }
            R.id.button_seat -> {
                inputConnection!!.commitText(context.getString(R.string.seat), 1)
            }
            R.id.button_satellite -> {
                inputConnection!!.commitText(context.getString(R.string.satellite), 1)
            }
            R.id.button_rocket -> {
                inputConnection!!.commitText(context.getString(R.string.rocket), 1)
            }
            R.id.button_flying_saucer -> {
                inputConnection!!.commitText(context.getString(R.string.flying_saucer), 1)
            }
            R.id.button_helicopter -> {
                inputConnection!!.commitText(context.getString(R.string.helicopter), 1)
            }
            R.id.button_canoe -> {
                inputConnection!!.commitText(context.getString(R.string.canoe), 1)
            }
            R.id.button_sailboat -> {
                inputConnection!!.commitText(context.getString(R.string.sailboat), 1)
            }
            R.id.button_speedboat -> {
                inputConnection!!.commitText(context.getString(R.string.speedboat), 1)
            }
            R.id.button_motor_boat -> {
                inputConnection!!.commitText(context.getString(R.string.motor_boat), 1)
            }
            R.id.button_passenger_ship -> {
                inputConnection!!.commitText(context.getString(R.string.passenger_ship), 1)
            }
            R.id.button_ferry -> {
                inputConnection!!.commitText(context.getString(R.string.ferry), 1)
            }
            R.id.button_ship -> {
                inputConnection!!.commitText(context.getString(R.string.ship), 1)
            }
            R.id.button_anchor -> {
                inputConnection!!.commitText(context.getString(R.string.anchor), 1)
            }
            R.id.button_fuel_pump -> {
                inputConnection!!.commitText(context.getString(R.string.fuel_pump), 1)
            }
            R.id.button_construction -> {
                inputConnection!!.commitText(context.getString(R.string.construction), 1)
            }
            R.id.button_vertical_traffic_light -> {
                inputConnection!!.commitText(context.getString(R.string.vertical_traffic_light), 1)
            }
            R.id.button_horizontal_traffic_light -> {
                inputConnection!!.commitText(context.getString(R.string.horizontal_traffic_light), 1)
            }
            R.id.button_bus_stop -> {
                inputConnection!!.commitText(context.getString(R.string.bus_stop), 1)
            }
            R.id.button_world_map -> {
                inputConnection!!.commitText(context.getString(R.string.world_map), 1)
            }
            R.id.button_moai -> {
                inputConnection!!.commitText(context.getString(R.string.moai), 1)
            }
            R.id.button_statue_of_liberty -> {
                inputConnection!!.commitText(context.getString(R.string.statue_of_liberty), 1)
            }
            R.id.button_tokyo_tower -> {
                inputConnection!!.commitText(context.getString(R.string.tokyo_tower), 1)
            }
            R.id.button_castle -> {
                inputConnection!!.commitText(context.getString(R.string.castle), 1)
            }
            R.id.button_japanese_castle -> {
                inputConnection!!.commitText(context.getString(R.string.japanese_castle), 1)
            }
            R.id.button_stadium -> {
                inputConnection!!.commitText(context.getString(R.string.stadium), 1)
            }
            R.id.button_ferris_wheel -> {
                inputConnection!!.commitText(context.getString(R.string.ferris_wheel), 1)
            }
            R.id.button_roller_coaster -> {
                inputConnection!!.commitText(context.getString(R.string.roller_coaster), 1)
            }
            R.id.button_carousel_horse -> {
                inputConnection!!.commitText(context.getString(R.string.carousel_horse), 1)
            }
            R.id.button_fountain -> {
                inputConnection!!.commitText(context.getString(R.string.fountain), 1)
            }
            R.id.button_umbrella_on_ground -> {
                inputConnection!!.commitText(context.getString(R.string.umbrella_on_ground), 1)
            }
            R.id.button_beach_with_umbrella -> {
                inputConnection!!.commitText(context.getString(R.string.beach_with_umbrella), 1)
            }
            R.id.button_desert_island -> {
                inputConnection!!.commitText(context.getString(R.string.desert_island), 1)
            }
            R.id.button_desert -> {
                inputConnection!!.commitText(context.getString(R.string.desert), 1)
            }
            R.id.button_volcano -> {
                inputConnection!!.commitText(context.getString(R.string.volcano), 1)
            }
            R.id.button_mountain -> {
                inputConnection!!.commitText(context.getString(R.string.mountain), 1)
            }
            R.id.button_snow_capped_mountain -> {
                inputConnection!!.commitText(context.getString(R.string.snow_capped_mountain), 1)
            }
            R.id.button_mount_fuji -> {
                inputConnection!!.commitText(context.getString(R.string.mount_fuji), 1)
            }
            R.id.button_camping -> {
                inputConnection!!.commitText(context.getString(R.string.camping), 1)
            }
            R.id.button_tent -> {
                inputConnection!!.commitText(context.getString(R.string.tent), 1)
            }
            R.id.button_house -> {
                inputConnection!!.commitText(context.getString(R.string.house), 1)
            }
            R.id.button_house_with_garden -> {
                inputConnection!!.commitText(context.getString(R.string.house_with_garden), 1)
            }
            R.id.button_house_buildings -> {
                inputConnection!!.commitText(context.getString(R.string.house_buildings), 1)
            }
            R.id.button_derelict_house -> {
                inputConnection!!.commitText(context.getString(R.string.derelict_house), 1)
            }
            R.id.button_building_construction -> {
                inputConnection!!.commitText(context.getString(R.string.building_construction), 1)
            }
            R.id.button_factory -> {
                inputConnection!!.commitText(context.getString(R.string.factory), 1)
            }
            R.id.button_office_building -> {
                inputConnection!!.commitText(context.getString(R.string.office_building), 1)
            }
            R.id.button_department_store -> {
                inputConnection!!.commitText(context.getString(R.string.department_store), 1)
            }
            R.id.button_japanese_post_office -> {
                inputConnection!!.commitText(context.getString(R.string.japanese_post_office), 1)
            }
            R.id.button_post_office -> {
                inputConnection!!.commitText(context.getString(R.string.post_office), 1)
            }
            R.id.button_hospital -> {
                inputConnection!!.commitText(context.getString(R.string.hospital), 1)
            }
            R.id.button_bank -> {
                inputConnection!!.commitText(context.getString(R.string.bank), 1)
            }
            R.id.button_hotel -> {
                inputConnection!!.commitText(context.getString(R.string.hotel), 1)
            }
            R.id.button_convenience_store -> {
                inputConnection!!.commitText(context.getString(R.string.convenience_store), 1)
            }
            R.id.button_school -> {
                inputConnection!!.commitText(context.getString(R.string.school), 1)
            }
            R.id.button_love_hotel -> {
                inputConnection!!.commitText(context.getString(R.string.love_hotel), 1)
            }
            R.id.button_wedding -> {
                inputConnection!!.commitText(context.getString(R.string.wedding), 1)
            }
            R.id.button_classical_building -> {
                inputConnection!!.commitText(context.getString(R.string.classical_building), 1)
            }
            R.id.button_church -> {
                inputConnection!!.commitText(context.getString(R.string.church), 1)
            }
            R.id.button_mosque -> {
                inputConnection!!.commitText(context.getString(R.string.mosque), 1)
            }
            R.id.button_synagogue -> {
                inputConnection!!.commitText(context.getString(R.string.synagogue), 1)
            }
            R.id.button_kaaba -> {
                inputConnection!!.commitText(context.getString(R.string.kaaba), 1)
            }
            R.id.button_shinto_shrine -> {
                inputConnection!!.commitText(context.getString(R.string.shinto_shrine), 1)
            }
            R.id.button_railway_track -> {
                inputConnection!!.commitText(context.getString(R.string.railway_track), 1)
            }
            R.id.button_motorway -> {
                inputConnection!!.commitText(context.getString(R.string.motorway), 1)
            }
            R.id.button_map_of_japan -> {
                inputConnection!!.commitText(context.getString(R.string.map_of_japan), 1)
            }
            R.id.button_moon_viewing_ceremony -> {
                inputConnection!!.commitText(context.getString(R.string.moon_viewing_ceremony), 1)
            }
            R.id.button_national_park -> {
                inputConnection!!.commitText(context.getString(R.string.national_park), 1)
            }
            R.id.button_sunrise -> {
                inputConnection!!.commitText(context.getString(R.string.sunrise), 1)
            }
            R.id.button_sunrise_over_mountains -> {
                inputConnection!!.commitText(context.getString(R.string.sunrise_over_mountains), 1)
            }
            R.id.button_shooting_star -> {
                inputConnection!!.commitText(context.getString(R.string.shooting_star), 1)
            }
            R.id.button_sparkler -> {
                inputConnection!!.commitText(context.getString(R.string.sparkler), 1)
            }
            R.id.button_fireworks -> {
                inputConnection!!.commitText(context.getString(R.string.fireworks), 1)
            }
            R.id.button_sunset -> {
                inputConnection!!.commitText(context.getString(R.string.sunset), 1)
            }
            R.id.button_cityscape_at_dusk -> {
                inputConnection!!.commitText(context.getString(R.string.cityscape_at_dusk), 1)
            }
            R.id.button_cityscape -> {
                inputConnection!!.commitText(context.getString(R.string.cityscape), 1)
            }
            R.id.button_night_with_stars -> {
                inputConnection!!.commitText(context.getString(R.string.night_with_stars), 1)
            }
            R.id.button_milky_way -> {
                inputConnection!!.commitText(context.getString(R.string.milky_way), 1)
            }
            R.id.button_bridge_at_night -> {
                inputConnection!!.commitText(context.getString(R.string.bridge_at_night), 1)
            }
            R.id.button_foggy -> {
                inputConnection!!.commitText(context.getString(R.string.foggy), 1)
            }
        }
    }

    fun setInputConnection(ic: InputConnection) {
        inputConnection = ic
    }
}