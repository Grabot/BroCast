package com.bro.brocast.keyboards

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View.OnClickListener
import android.view.inputmethod.InputConnection
import android.widget.Button
import android.widget.LinearLayout
import com.bro.brocast.R


class SeventhKeyboard: LinearLayout {

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
        LayoutInflater.from(context).inflate(R.layout.keyboard_7, this, true)

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
            R.id.button_wrench,
            R.id.button_hammer,
            R.id.button_hammer_and_pick,
            R.id.button_hammer_and_wrench,
            R.id.button_pick,
            R.id.button_nut_and_bolt,
            R.id.button_gear,
            R.id.button_bricks,
            R.id.button_chains,
            R.id.button_magnet,
            R.id.button_pistol,
            R.id.button_bomb,
            R.id.button_firecracker,
            R.id.button_kitchen_knife,
            R.id.button_dagger,
            R.id.button_crossed_swords,
            R.id.button_shield,
            R.id.button_cigarette,
            R.id.button_coffin,
            R.id.button_funeral_urn,
            R.id.button_amphora,
            R.id.button_crystal_ball,
            R.id.button_prayer_beads,
            R.id.button_nazar_amulet,
            R.id.button_barber_pole,
            R.id.button_alembic,
            R.id.button_telescope,
            R.id.button_microscope,
            R.id.button_hole,
            R.id.button_pill,
            R.id.button_syringe,
            R.id.button_dna,
            R.id.button_microbe,
            R.id.button_petri_dish,
            R.id.button_test_tube,
            R.id.button_thermometer,
            R.id.button_broom,
            R.id.button_basket,
            R.id.button_roll_of_paper,
            R.id.button_toilet,
            R.id.button_faucet,
            R.id.button_shower,
            R.id.button_bathtub,
            R.id.button_person_taking_bath,
            R.id.button_soap,
            R.id.button_sponge,
            R.id.button_lotion_bottle,
            R.id.button_bellhop_bell,
            R.id.button_key,
            R.id.button_old_key,
            R.id.button_door,
            R.id.button_couch_and_lamp,
            R.id.button_bed,
            R.id.button_person_in_bed,
            R.id.button_teddy_bear,
            R.id.button_framed_picture,
            R.id.button_shopping_bags,
            R.id.button_shopping_cart,
            R.id.button_wrapped_gift,
            R.id.button_balloon,
            R.id.button_carp_streamer,
            R.id.button_ribbon,
            R.id.button_confetti_ball,
            R.id.button_party_popper,
            R.id.button_japanese_dolls,
            R.id.button_red_paper_lantern,
            R.id.button_wind_chime,
            R.id.button_red_envelope,
            R.id.button_envelope,
            R.id.button_envelope_with_arrow,
            R.id.button_incoming_envelope,
            R.id.button_e_mail,
            R.id.button_love_letter,
            R.id.button_inbox_tray,
            R.id.button_outbox_tray,
            R.id.button_package_emoji,
            R.id.button_label,
            R.id.button_closed_mailbox_with_lowered_flag,
            R.id.button_closed_mailbox_with_raised_flag,
            R.id.button_open_mailbox_with_raised_flag,
            R.id.button_open_mailbox_with_lowered_flag,
            R.id.button_postbox,
            R.id.button_postal_horn,
            R.id.button_scroll,
            R.id.button_page_with_curl,
            R.id.button_page_facing_up,
            R.id.button_bookmark_tabs,
            R.id.button_receipt,
            R.id.button_bar_chart,
            R.id.button_chart_increasing,
            R.id.button_chart_decreasing,
            R.id.button_spiral_notepad,
            R.id.button_spiral_calendar,
            R.id.button_tear_off_calendar,
            R.id.button_calendar,
            R.id.button_wastebasket,
            R.id.button_card_index,
            R.id.button_card_file_box,
            R.id.button_ballot_box_with_ballot,
            R.id.button_file_cabinet,
            R.id.button_clipboard,
            R.id.button_file_folder,
            R.id.button_open_file_folder,
            R.id.button_card_index_dividers,
            R.id.button_rolled_up_newspaper,
            R.id.button_newspaper,
            R.id.button_notebook,
            R.id.button_notebook_with_decorative_cover,
            R.id.button_ledger,
            R.id.button_closed_book,
            R.id.button_green_book,
            R.id.button_blue_book,
            R.id.button_orange_book,
            R.id.button_books,
            R.id.button_open_book,
            R.id.button_bookmark,
            R.id.button_safety_pin,
            R.id.button_link,
            R.id.button_paperclip,
            R.id.button_linked_paperclips,
            R.id.button_triangular_ruler,
            R.id.button_straight_ruler,
            R.id.button_abacus,
            R.id.button_pushpin,
            R.id.button_round_pushpin,
            R.id.button_scissors,
            R.id.button_pen,
            R.id.button_fountain_pen,
            R.id.button_black_nib,
            R.id.button_paintbrush,
            R.id.button_crayon,
            R.id.button_memo,
            R.id.button_pencil,
            R.id.button_left_pointing_magnifying_glass,
            R.id.button_right_pointing_magnifying_glass,
            R.id.button_locked_with_pen,
            R.id.button_locked_with_key,
            R.id.button_locked,
            R.id.button_unlocked
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
            R.id.button_hammer -> {
                inputConnection!!.commitText(context.getString(R.string.hammer), 1)
            }
            R.id.button_hammer_and_pick -> {
                inputConnection!!.commitText(context.getString(R.string.hammer_and_pick), 1)
            }
            R.id.button_hammer_and_wrench -> {
                inputConnection!!.commitText(context.getString(R.string.hammer_and_wrench), 1)
            }
            R.id.button_pick -> {
                inputConnection!!.commitText(context.getString(R.string.pick), 1)
            }
            R.id.button_nut_and_bolt -> {
                inputConnection!!.commitText(context.getString(R.string.nut_and_bolt), 1)
            }
            R.id.button_gear -> {
                inputConnection!!.commitText(context.getString(R.string.gear), 1)
            }
            R.id.button_bricks -> {
                inputConnection!!.commitText(context.getString(R.string.bricks), 1)
            }
            R.id.button_chains -> {
                inputConnection!!.commitText(context.getString(R.string.chains), 1)
            }
            R.id.button_magnet -> {
                inputConnection!!.commitText(context.getString(R.string.magnet), 1)
            }
            R.id.button_pistol -> {
                inputConnection!!.commitText(context.getString(R.string.pistol), 1)
            }
            R.id.button_bomb -> {
                inputConnection!!.commitText(context.getString(R.string.bomb), 1)
            }
            R.id.button_firecracker -> {
                inputConnection!!.commitText(context.getString(R.string.firecracker), 1)
            }
            R.id.button_kitchen_knife -> {
                inputConnection!!.commitText(context.getString(R.string.kitchen_knife), 1)
            }
            R.id.button_dagger -> {
                inputConnection!!.commitText(context.getString(R.string.dagger), 1)
            }
            R.id.button_crossed_swords -> {
                inputConnection!!.commitText(context.getString(R.string.crossed_swords), 1)
            }
            R.id.button_shield -> {
                inputConnection!!.commitText(context.getString(R.string.shield), 1)
            }
            R.id.button_cigarette -> {
                inputConnection!!.commitText(context.getString(R.string.cigarette), 1)
            }
            R.id.button_coffin -> {
                inputConnection!!.commitText(context.getString(R.string.coffin), 1)
            }
            R.id.button_funeral_urn -> {
                inputConnection!!.commitText(context.getString(R.string.funeral_urn), 1)
            }
            R.id.button_amphora -> {
                inputConnection!!.commitText(context.getString(R.string.amphora), 1)
            }
            R.id.button_crystal_ball -> {
                inputConnection!!.commitText(context.getString(R.string.crystal_ball), 1)
            }
            R.id.button_prayer_beads -> {
                inputConnection!!.commitText(context.getString(R.string.prayer_beads), 1)
            }
            R.id.button_nazar_amulet -> {
                inputConnection!!.commitText(context.getString(R.string.nazar_amulet), 1)
            }
            R.id.button_barber_pole -> {
                inputConnection!!.commitText(context.getString(R.string.barber_pole), 1)
            }
            R.id.button_alembic -> {
                inputConnection!!.commitText(context.getString(R.string.alembic), 1)
            }
            R.id.button_telescope -> {
                inputConnection!!.commitText(context.getString(R.string.telescope), 1)
            }
            R.id.button_microscope -> {
                inputConnection!!.commitText(context.getString(R.string.microscope), 1)
            }
            R.id.button_hole -> {
                inputConnection!!.commitText(context.getString(R.string.hole), 1)
            }
            R.id.button_pill -> {
                inputConnection!!.commitText(context.getString(R.string.pill), 1)
            }
            R.id.button_syringe -> {
                inputConnection!!.commitText(context.getString(R.string.syringe), 1)
            }
            R.id.button_dna -> {
                inputConnection!!.commitText(context.getString(R.string.dna), 1)
            }
            R.id.button_microbe -> {
                inputConnection!!.commitText(context.getString(R.string.microbe), 1)
            }
            R.id.button_petri_dish -> {
                inputConnection!!.commitText(context.getString(R.string.petri_dish), 1)
            }
            R.id.button_test_tube -> {
                inputConnection!!.commitText(context.getString(R.string.test_tube), 1)
            }
            R.id.button_thermometer -> {
                inputConnection!!.commitText(context.getString(R.string.thermometer), 1)
            }
            R.id.button_broom -> {
                inputConnection!!.commitText(context.getString(R.string.broom), 1)
            }
            R.id.button_basket -> {
                inputConnection!!.commitText(context.getString(R.string.basket), 1)
            }
            R.id.button_roll_of_paper -> {
                inputConnection!!.commitText(context.getString(R.string.roll_of_paper), 1)
            }
            R.id.button_toilet -> {
                inputConnection!!.commitText(context.getString(R.string.toilet), 1)
            }
            R.id.button_faucet -> {
                inputConnection!!.commitText(context.getString(R.string.faucet), 1)
            }
            R.id.button_shower -> {
                inputConnection!!.commitText(context.getString(R.string.shower), 1)
            }
            R.id.button_bathtub -> {
                inputConnection!!.commitText(context.getString(R.string.bathtub), 1)
            }
            R.id.button_person_taking_bath -> {
                inputConnection!!.commitText(context.getString(R.string.person_taking_bath), 1)
            }
            R.id.button_soap -> {
                inputConnection!!.commitText(context.getString(R.string.soap), 1)
            }
            R.id.button_sponge -> {
                inputConnection!!.commitText(context.getString(R.string.sponge), 1)
            }
            R.id.button_lotion_bottle -> {
                inputConnection!!.commitText(context.getString(R.string.lotion_bottle), 1)
            }
            R.id.button_bellhop_bell -> {
                inputConnection!!.commitText(context.getString(R.string.bellhop_bell), 1)
            }
            R.id.button_key -> {
                inputConnection!!.commitText(context.getString(R.string.key), 1)
            }
            R.id.button_old_key -> {
                inputConnection!!.commitText(context.getString(R.string.old_key), 1)
            }
            R.id.button_door -> {
                inputConnection!!.commitText(context.getString(R.string.door), 1)
            }
            R.id.button_couch_and_lamp -> {
                inputConnection!!.commitText(context.getString(R.string.couch_and_lamp), 1)
            }
            R.id.button_bed -> {
                inputConnection!!.commitText(context.getString(R.string.bed), 1)
            }
            R.id.button_person_in_bed -> {
                inputConnection!!.commitText(context.getString(R.string.person_in_bed), 1)
            }
            R.id.button_teddy_bear -> {
                inputConnection!!.commitText(context.getString(R.string.teddy_bear), 1)
            }
            R.id.button_framed_picture -> {
                inputConnection!!.commitText(context.getString(R.string.framed_picture), 1)
            }
            R.id.button_shopping_bags -> {
                inputConnection!!.commitText(context.getString(R.string.shopping_bags), 1)
            }
            R.id.button_shopping_cart -> {
                inputConnection!!.commitText(context.getString(R.string.shopping_cart), 1)
            }
            R.id.button_wrapped_gift -> {
                inputConnection!!.commitText(context.getString(R.string.wrapped_gift), 1)
            }
            R.id.button_balloon -> {
                inputConnection!!.commitText(context.getString(R.string.balloon), 1)
            }
            R.id.button_carp_streamer -> {
                inputConnection!!.commitText(context.getString(R.string.carp_streamer), 1)
            }
            R.id.button_ribbon -> {
                inputConnection!!.commitText(context.getString(R.string.ribbon), 1)
            }
            R.id.button_confetti_ball -> {
                inputConnection!!.commitText(context.getString(R.string.confetti_ball), 1)
            }
            R.id.button_party_popper -> {
                inputConnection!!.commitText(context.getString(R.string.party_popper), 1)
            }
            R.id.button_japanese_dolls -> {
                inputConnection!!.commitText(context.getString(R.string.japanese_dolls), 1)
            }
            R.id.button_red_paper_lantern -> {
                inputConnection!!.commitText(context.getString(R.string.red_paper_lantern), 1)
            }
            R.id.button_wind_chime -> {
                inputConnection!!.commitText(context.getString(R.string.wind_chime), 1)
            }
            R.id.button_red_envelope -> {
                inputConnection!!.commitText(context.getString(R.string.red_envelope), 1)
            }
            R.id.button_envelope -> {
                inputConnection!!.commitText(context.getString(R.string.envelope), 1)
            }
            R.id.button_envelope_with_arrow -> {
                inputConnection!!.commitText(context.getString(R.string.envelope_with_arrow), 1)
            }
            R.id.button_incoming_envelope -> {
                inputConnection!!.commitText(context.getString(R.string.incoming_envelope), 1)
            }
            R.id.button_e_mail -> {
                inputConnection!!.commitText(context.getString(R.string.e_mail), 1)
            }
            R.id.button_love_letter -> {
                inputConnection!!.commitText(context.getString(R.string.love_letter), 1)
            }
            R.id.button_inbox_tray -> {
                inputConnection!!.commitText(context.getString(R.string.inbox_tray), 1)
            }
            R.id.button_outbox_tray -> {
                inputConnection!!.commitText(context.getString(R.string.outbox_tray), 1)
            }
            R.id.button_package_emoji -> {
                inputConnection!!.commitText(context.getString(R.string.package_emoji), 1)
            }
            R.id.button_label -> {
                inputConnection!!.commitText(context.getString(R.string.label), 1)
            }
            R.id.button_closed_mailbox_with_lowered_flag -> {
                inputConnection!!.commitText(context.getString(R.string.closed_mailbox_with_lowered_flag), 1)
            }
            R.id.button_closed_mailbox_with_raised_flag -> {
                inputConnection!!.commitText(context.getString(R.string.closed_mailbox_with_raised_flag), 1)
            }
            R.id.button_open_mailbox_with_raised_flag -> {
                inputConnection!!.commitText(context.getString(R.string.open_mailbox_with_raised_flag), 1)
            }
            R.id.button_open_mailbox_with_lowered_flag -> {
                inputConnection!!.commitText(context.getString(R.string.open_mailbox_with_lowered_flag), 1)
            }
            R.id.button_postbox -> {
                inputConnection!!.commitText(context.getString(R.string.postbox), 1)
            }
            R.id.button_postal_horn -> {
                inputConnection!!.commitText(context.getString(R.string.postal_horn), 1)
            }
            R.id.button_scroll -> {
                inputConnection!!.commitText(context.getString(R.string.scroll), 1)
            }
            R.id.button_page_with_curl -> {
                inputConnection!!.commitText(context.getString(R.string.page_with_curl), 1)
            }
            R.id.button_page_facing_up -> {
                inputConnection!!.commitText(context.getString(R.string.page_facing_up), 1)
            }
            R.id.button_bookmark_tabs -> {
                inputConnection!!.commitText(context.getString(R.string.bookmark_tabs), 1)
            }
            R.id.button_receipt -> {
                inputConnection!!.commitText(context.getString(R.string.receipt), 1)
            }
            R.id.button_bar_chart -> {
                inputConnection!!.commitText(context.getString(R.string.bar_chart), 1)
            }
            R.id.button_chart_increasing -> {
                inputConnection!!.commitText(context.getString(R.string.chart_increasing), 1)
            }
            R.id.button_chart_decreasing -> {
                inputConnection!!.commitText(context.getString(R.string.chart_decreasing), 1)
            }
            R.id.button_spiral_notepad -> {
                inputConnection!!.commitText(context.getString(R.string.spiral_notepad), 1)
            }
            R.id.button_spiral_calendar -> {
                inputConnection!!.commitText(context.getString(R.string.spiral_calendar), 1)
            }
            R.id.button_tear_off_calendar -> {
                inputConnection!!.commitText(context.getString(R.string.tear_off_calendar), 1)
            }
            R.id.button_calendar -> {
                inputConnection!!.commitText(context.getString(R.string.calendar), 1)
            }
            R.id.button_wastebasket -> {
                inputConnection!!.commitText(context.getString(R.string.wastebasket), 1)
            }
            R.id.button_card_index -> {
                inputConnection!!.commitText(context.getString(R.string.card_index), 1)
            }
            R.id.button_card_file_box -> {
                inputConnection!!.commitText(context.getString(R.string.card_file_box), 1)
            }
            R.id.button_ballot_box_with_ballot -> {
                inputConnection!!.commitText(context.getString(R.string.ballot_box_with_ballot), 1)
            }
            R.id.button_file_cabinet -> {
                inputConnection!!.commitText(context.getString(R.string.file_cabinet), 1)
            }
            R.id.button_clipboard -> {
                inputConnection!!.commitText(context.getString(R.string.clipboard), 1)
            }
            R.id.button_file_folder -> {
                inputConnection!!.commitText(context.getString(R.string.file_folder), 1)
            }
            R.id.button_open_file_folder -> {
                inputConnection!!.commitText(context.getString(R.string.open_file_folder), 1)
            }
            R.id.button_card_index_dividers -> {
                inputConnection!!.commitText(context.getString(R.string.card_index_dividers), 1)
            }
            R.id.button_rolled_up_newspaper -> {
                inputConnection!!.commitText(context.getString(R.string.rolled_up_newspaper), 1)
            }
            R.id.button_newspaper -> {
                inputConnection!!.commitText(context.getString(R.string.newspaper), 1)
            }
            R.id.button_notebook -> {
                inputConnection!!.commitText(context.getString(R.string.notebook), 1)
            }
            R.id.button_notebook_with_decorative_cover -> {
                inputConnection!!.commitText(context.getString(R.string.notebook_with_decorative_cover), 1)
            }
            R.id.button_ledger -> {
                inputConnection!!.commitText(context.getString(R.string.ledger), 1)
            }
            R.id.button_closed_book -> {
                inputConnection!!.commitText(context.getString(R.string.closed_book), 1)
            }
            R.id.button_green_book -> {
                inputConnection!!.commitText(context.getString(R.string.green_book), 1)
            }
            R.id.button_blue_book -> {
                inputConnection!!.commitText(context.getString(R.string.blue_book), 1)
            }
            R.id.button_orange_book -> {
                inputConnection!!.commitText(context.getString(R.string.orange_book), 1)
            }
            R.id.button_books -> {
                inputConnection!!.commitText(context.getString(R.string.books), 1)
            }
            R.id.button_open_book -> {
                inputConnection!!.commitText(context.getString(R.string.open_book), 1)
            }
            R.id.button_bookmark -> {
                inputConnection!!.commitText(context.getString(R.string.bookmark), 1)
            }
            R.id.button_safety_pin -> {
                inputConnection!!.commitText(context.getString(R.string.safety_pin), 1)
            }
            R.id.button_link -> {
                inputConnection!!.commitText(context.getString(R.string.link), 1)
            }
            R.id.button_paperclip -> {
                inputConnection!!.commitText(context.getString(R.string.paperclip), 1)
            }
            R.id.button_linked_paperclips -> {
                inputConnection!!.commitText(context.getString(R.string.linked_paperclips), 1)
            }
            R.id.button_triangular_ruler -> {
                inputConnection!!.commitText(context.getString(R.string.triangular_ruler), 1)
            }
            R.id.button_straight_ruler -> {
                inputConnection!!.commitText(context.getString(R.string.straight_ruler), 1)
            }
            R.id.button_abacus -> {
                inputConnection!!.commitText(context.getString(R.string.abacus), 1)
            }
            R.id.button_pushpin -> {
                inputConnection!!.commitText(context.getString(R.string.pushpin), 1)
            }
            R.id.button_round_pushpin -> {
                inputConnection!!.commitText(context.getString(R.string.round_pushpin), 1)
            }
            R.id.button_scissors -> {
                inputConnection!!.commitText(context.getString(R.string.scissors), 1)
            }
            R.id.button_pen -> {
                inputConnection!!.commitText(context.getString(R.string.pen), 1)
            }
            R.id.button_fountain_pen -> {
                inputConnection!!.commitText(context.getString(R.string.fountain_pen), 1)
            }
            R.id.button_black_nib -> {
                inputConnection!!.commitText(context.getString(R.string.black_nib), 1)
            }
            R.id.button_paintbrush -> {
                inputConnection!!.commitText(context.getString(R.string.paintbrush), 1)
            }
            R.id.button_crayon -> {
                inputConnection!!.commitText(context.getString(R.string.crayon), 1)
            }
            R.id.button_memo -> {
                inputConnection!!.commitText(context.getString(R.string.memo), 1)
            }
            R.id.button_pencil -> {
                inputConnection!!.commitText(context.getString(R.string.pencil), 1)
            }
            R.id.button_left_pointing_magnifying_glass -> {
                inputConnection!!.commitText(context.getString(R.string.left_pointing_magnifying_glass), 1)
            }
            R.id.button_right_pointing_magnifying_glass -> {
                inputConnection!!.commitText(context.getString(R.string.right_pointing_magnifying_glass), 1)
            }
            R.id.button_locked_with_pen -> {
                inputConnection!!.commitText(context.getString(R.string.locked_with_pen), 1)
            }
            R.id.button_locked_with_key -> {
                inputConnection!!.commitText(context.getString(R.string.locked_with_key), 1)
            }
            R.id.button_locked -> {
                inputConnection!!.commitText(context.getString(R.string.locked), 1)
            }
            R.id.button_unlocked -> {
                inputConnection!!.commitText(context.getString(R.string.unlocked), 1)
            }
        }
    }

    fun setInputConnection(ic: InputConnection) {
        inputConnection = ic
    }
}