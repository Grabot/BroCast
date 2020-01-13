package com.bro.brocast.keyboards

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View.OnClickListener
import android.view.inputmethod.InputConnection
import android.widget.Button
import android.widget.LinearLayout
import com.bro.brocast.R


class FourthKeyboard: LinearLayout {

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
        LayoutInflater.from(context).inflate(R.layout.keyboard_4, this, true)

        val buttonIds = arrayOf(
            R.id.button_soccer_ball,
            R.id.button_basketball,
            R.id.button_american_football,
            R.id.button_baseball,
            R.id.button_softball,
            R.id.button_tennis,
            R.id.button_volleyball,
            R.id.button_rugby_football,
            R.id.button_flying_disc,
            R.id.button_pool_8_ball,
            R.id.button_ping_pong,
            R.id.button_badminton,
            R.id.button_ice_hockey,
            R.id.button_field_hockey,
            R.id.button_lacrosse,
            R.id.button_cricket_sport,
            R.id.button_goal_net,
            R.id.button_flag_in_hole,
            R.id.button_bow_and_arrow,
            R.id.button_fishing_pole,
            R.id.button_boxing_glove,
            R.id.button_martial_arts_uniform,
            R.id.button_running_shirt,
            R.id.button_skateboard,
            R.id.button_sled,
            R.id.button_ice_skate,
            R.id.button_curling_stone,
            R.id.button_skis,
            R.id.button_skier,
            R.id.button_snowboarder,
            R.id.button_woman_lifting_weights,
            R.id.button_man_lifting_weights,
            R.id.button_women_wrestling,
            R.id.button_men_wrestling,
            R.id.button_woman_cartwheeling,
            R.id.button_man_cartwheeling,
            R.id.button_woman_bouncing_ball,
            R.id.button_man_bouncing_ball,
            R.id.button_person_fencing,
            R.id.button_woman_playing_handball,
            R.id.button_man_playing_handball,
            R.id.button_woman_golfing,
            R.id.button_man_golfing,
            R.id.button_horse_racing,
            R.id.button_woman_in_lotus_position,
            R.id.button_man_in_lotus_position,
            R.id.button_woman_surfing,
            R.id.button_man_surfing,
            R.id.button_woman_swimming,
            R.id.button_man_swimming,
            R.id.button_woman_playing_water_polo,
            R.id.button_man_playing_water_polo,
            R.id.button_woman_rowing_boat,
            R.id.button_man_rowing_boat,
            R.id.button_woman_climbing,
            R.id.button_man_climbing,
            R.id.button_woman_mountain_biking,
            R.id.button_man_mountain_biking,
            R.id.button_woman_biking,
            R.id.button_man_biking,
            R.id.button_trophy,
            R.id.button_first_place_medal,
            R.id.button_second_place_medal,
            R.id.button_third_place_medal,
            R.id.button_sports_medal,
            R.id.button_military_medal,
            R.id.button_rosette,
            R.id.button_reminder_ribbon,
            R.id.button_ticket,
            R.id.button_admission_tickets,
            R.id.button_circus_tent,
            R.id.button_woman_juggling,
            R.id.button_man_juggling,
            R.id.button_performing_arts,
            R.id.button_artist_palette,
            R.id.button_clapper_board
        )

        for (b in buttonIds) {
            findViewById<Button>(b).setOnClickListener(clickButtonListener)
        }
    }

    private val clickButtonListener = OnClickListener { view ->
        when (view.getId()) {
            R.id.button_soccer_ball -> {
                inputConnection!!.commitText(context.getString(R.string.soccer_ball), 1)
            }
            R.id.button_basketball -> {
                inputConnection!!.commitText(context.getString(R.string.basketball), 1)
            }
            R.id.button_american_football -> {
                inputConnection!!.commitText(context.getString(R.string.american_football), 1)
            }
            R.id.button_baseball -> {
                inputConnection!!.commitText(context.getString(R.string.baseball), 1)
            }
            R.id.button_softball -> {
                inputConnection!!.commitText(context.getString(R.string.softball), 1)
            }
            R.id.button_tennis -> {
                inputConnection!!.commitText(context.getString(R.string.tennis), 1)
            }
            R.id.button_volleyball -> {
                inputConnection!!.commitText(context.getString(R.string.volleyball), 1)
            }
            R.id.button_rugby_football -> {
                inputConnection!!.commitText(context.getString(R.string.rugby_football), 1)
            }
            R.id.button_flying_disc -> {
                inputConnection!!.commitText(context.getString(R.string.flying_disc), 1)
            }
            R.id.button_pool_8_ball -> {
                inputConnection!!.commitText(context.getString(R.string.pool_8_ball), 1)
            }
            R.id.button_ping_pong -> {
                inputConnection!!.commitText(context.getString(R.string.ping_pong), 1)
            }
            R.id.button_badminton -> {
                inputConnection!!.commitText(context.getString(R.string.badminton), 1)
            }
            R.id.button_ice_hockey -> {
                inputConnection!!.commitText(context.getString(R.string.ice_hockey), 1)
            }
            R.id.button_field_hockey -> {
                inputConnection!!.commitText(context.getString(R.string.field_hockey), 1)
            }
            R.id.button_lacrosse -> {
                inputConnection!!.commitText(context.getString(R.string.lacrosse), 1)
            }
            R.id.button_cricket_sport -> {
                inputConnection!!.commitText(context.getString(R.string.cricket_sport), 1)
            }
            R.id.button_goal_net -> {
                inputConnection!!.commitText(context.getString(R.string.goal_net), 1)
            }
            R.id.button_flag_in_hole -> {
                inputConnection!!.commitText(context.getString(R.string.flag_in_hole), 1)
            }
            R.id.button_bow_and_arrow -> {
                inputConnection!!.commitText(context.getString(R.string.bow_and_arrow), 1)
            }
            R.id.button_fishing_pole -> {
                inputConnection!!.commitText(context.getString(R.string.fishing_pole), 1)
            }
            R.id.button_boxing_glove -> {
                inputConnection!!.commitText(context.getString(R.string.boxing_glove), 1)
            }
            R.id.button_martial_arts_uniform -> {
                inputConnection!!.commitText(context.getString(R.string.martial_arts_uniform), 1)
            }
            R.id.button_running_shirt -> {
                inputConnection!!.commitText(context.getString(R.string.running_shirt), 1)
            }
            R.id.button_skateboard -> {
                inputConnection!!.commitText(context.getString(R.string.skateboard), 1)
            }
            R.id.button_sled -> {
                inputConnection!!.commitText(context.getString(R.string.sled), 1)
            }
            R.id.button_ice_skate -> {
                inputConnection!!.commitText(context.getString(R.string.ice_skate), 1)
            }
            R.id.button_curling_stone -> {
                inputConnection!!.commitText(context.getString(R.string.curling_stone), 1)
            }
            R.id.button_skis -> {
                inputConnection!!.commitText(context.getString(R.string.skis), 1)
            }
            R.id.button_skier -> {
                inputConnection!!.commitText(context.getString(R.string.skier), 1)
            }
            R.id.button_snowboarder -> {
                inputConnection!!.commitText(context.getString(R.string.snowboarder), 1)
            }
            R.id.button_woman_lifting_weights -> {
                inputConnection!!.commitText(context.getString(R.string.woman_lifting_weights), 1)
            }
            R.id.button_man_lifting_weights -> {
                inputConnection!!.commitText(context.getString(R.string.man_lifting_weights), 1)
            }
            R.id.button_women_wrestling -> {
                inputConnection!!.commitText(context.getString(R.string.women_wrestling), 1)
            }
            R.id.button_men_wrestling -> {
                inputConnection!!.commitText(context.getString(R.string.men_wrestling), 1)
            }
            R.id.button_woman_cartwheeling -> {
                inputConnection!!.commitText(context.getString(R.string.woman_cartwheeling), 1)
            }
            R.id.button_man_cartwheeling -> {
                inputConnection!!.commitText(context.getString(R.string.man_cartwheeling), 1)
            }
            R.id.button_woman_bouncing_ball -> {
                inputConnection!!.commitText(context.getString(R.string.woman_bouncing_ball), 1)
            }
            R.id.button_man_bouncing_ball -> {
                inputConnection!!.commitText(context.getString(R.string.man_bouncing_ball), 1)
            }
            R.id.button_person_fencing -> {
                inputConnection!!.commitText(context.getString(R.string.person_fencing), 1)
            }
            R.id.button_woman_playing_handball -> {
                inputConnection!!.commitText(context.getString(R.string.woman_playing_handball), 1)
            }
            R.id.button_man_playing_handball -> {
                inputConnection!!.commitText(context.getString(R.string.man_playing_handball), 1)
            }
            R.id.button_woman_golfing -> {
                inputConnection!!.commitText(context.getString(R.string.woman_golfing), 1)
            }
            R.id.button_man_golfing -> {
                inputConnection!!.commitText(context.getString(R.string.man_golfing), 1)
            }
            R.id.button_horse_racing -> {
                inputConnection!!.commitText(context.getString(R.string.horse_racing), 1)
            }
            R.id.button_woman_in_lotus_position -> {
                inputConnection!!.commitText(context.getString(R.string.woman_in_lotus_position), 1)
            }
            R.id.button_man_in_lotus_position -> {
                inputConnection!!.commitText(context.getString(R.string.man_in_lotus_position), 1)
            }
            R.id.button_woman_surfing -> {
                inputConnection!!.commitText(context.getString(R.string.woman_surfing), 1)
            }
            R.id.button_man_surfing -> {
                inputConnection!!.commitText(context.getString(R.string.man_surfing), 1)
            }
            R.id.button_woman_swimming -> {
                inputConnection!!.commitText(context.getString(R.string.woman_swimming), 1)
            }
            R.id.button_man_swimming -> {
                inputConnection!!.commitText(context.getString(R.string.man_swimming), 1)
            }
            R.id.button_woman_playing_water_polo -> {
                inputConnection!!.commitText(context.getString(R.string.woman_playing_water_polo), 1)
            }
            R.id.button_man_playing_water_polo -> {
                inputConnection!!.commitText(context.getString(R.string.man_playing_water_polo), 1)
            }
            R.id.button_woman_rowing_boat -> {
                inputConnection!!.commitText(context.getString(R.string.woman_rowing_boat), 1)
            }
            R.id.button_man_rowing_boat -> {
                inputConnection!!.commitText(context.getString(R.string.man_rowing_boat), 1)
            }
            R.id.button_woman_climbing -> {
                inputConnection!!.commitText(context.getString(R.string.woman_climbing), 1)
            }
            R.id.button_man_climbing -> {
                inputConnection!!.commitText(context.getString(R.string.man_climbing), 1)
            }
            R.id.button_woman_mountain_biking -> {
                inputConnection!!.commitText(context.getString(R.string.woman_mountain_biking), 1)
            }
            R.id.button_man_mountain_biking -> {
                inputConnection!!.commitText(context.getString(R.string.man_mountain_biking), 1)
            }
            R.id.button_woman_biking -> {
                inputConnection!!.commitText(context.getString(R.string.woman_biking), 1)
            }
            R.id.button_man_biking -> {
                inputConnection!!.commitText(context.getString(R.string.man_biking), 1)
            }
            R.id.button_trophy -> {
                inputConnection!!.commitText(context.getString(R.string.trophy), 1)
            }
            R.id.button_first_place_medal -> {
                inputConnection!!.commitText(context.getString(R.string.first_place_medal), 1)
            }
            R.id.button_second_place_medal -> {
                inputConnection!!.commitText(context.getString(R.string.second_place_medal), 1)
            }
            R.id.button_third_place_medal -> {
                inputConnection!!.commitText(context.getString(R.string.third_place_medal), 1)
            }
            R.id.button_sports_medal -> {
                inputConnection!!.commitText(context.getString(R.string.sports_medal), 1)
            }
            R.id.button_military_medal -> {
                inputConnection!!.commitText(context.getString(R.string.military_medal), 1)
            }
            R.id.button_rosette -> {
                inputConnection!!.commitText(context.getString(R.string.rosette), 1)
            }
            R.id.button_reminder_ribbon -> {
                inputConnection!!.commitText(context.getString(R.string.reminder_ribbon), 1)
            }
            R.id.button_ticket -> {
                inputConnection!!.commitText(context.getString(R.string.ticket), 1)
            }
            R.id.button_admission_tickets -> {
                inputConnection!!.commitText(context.getString(R.string.admission_tickets), 1)
            }
            R.id.button_circus_tent -> {
                inputConnection!!.commitText(context.getString(R.string.circus_tent), 1)
            }
            R.id.button_woman_juggling -> {
                inputConnection!!.commitText(context.getString(R.string.woman_juggling), 1)
            }
            R.id.button_man_juggling -> {
                inputConnection!!.commitText(context.getString(R.string.man_juggling), 1)
            }
            R.id.button_performing_arts -> {
                inputConnection!!.commitText(context.getString(R.string.performing_arts), 1)
            }
            R.id.button_artist_palette -> {
                inputConnection!!.commitText(context.getString(R.string.artist_palette), 1)
            }
            R.id.button_clapper_board -> {
                inputConnection!!.commitText(context.getString(R.string.clapper_board), 1)
            }
        }
    }

    fun setInputConnection(ic: InputConnection) {
        inputConnection = ic
    }
}