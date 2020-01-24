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
            R.string.soccer_ball,
            R.string.basketball,
            R.string.american_football,
            R.string.baseball,
            R.string.softball,
            R.string.tennis,
            R.string.volleyball,
            R.string.rugby_football,
            R.string.flying_disc,
            R.string.pool_8_ball,
            R.string.ping_pong,
            R.string.badminton,
            R.string.ice_hockey,
            R.string.field_hockey,
            R.string.lacrosse,
            R.string.cricket_sport,
            R.string.goal_net,
            R.string.flag_in_hole,
            R.string.bow_and_arrow,
            R.string.fishing_pole,
            R.string.boxing_glove,
            R.string.martial_arts_uniform,
            R.string.running_shirt,
            R.string.skateboard,
            R.string.sled,
            R.string.ice_skate,
            R.string.curling_stone,
            R.string.skis,
            R.string.skier,
            R.string.snowboarder,
            R.string.woman_lifting_weights,
            R.string.man_lifting_weights,
            R.string.women_wrestling,
            R.string.men_wrestling,
            R.string.woman_cartwheeling,
            R.string.man_cartwheeling,
            R.string.woman_bouncing_ball,
            R.string.man_bouncing_ball,
            R.string.person_fencing,
            R.string.woman_playing_handball,
            R.string.man_playing_handball,
            R.string.woman_golfing,
            R.string.man_golfing,
            R.string.horse_racing,
            R.string.woman_in_lotus_position,
            R.string.man_in_lotus_position,
            R.string.woman_surfing,
            R.string.man_surfing,
            R.string.woman_swimming,
            R.string.man_swimming,
            R.string.woman_playing_water_polo,
            R.string.man_playing_water_polo,
            R.string.woman_rowing_boat,
            R.string.man_rowing_boat,
            R.string.woman_climbing,
            R.string.man_climbing,
            R.string.woman_mountain_biking,
            R.string.man_mountain_biking,
            R.string.woman_biking,
            R.string.man_biking,
            R.string.trophy,
            R.string.first_place_medal,
            R.string.second_place_medal,
            R.string.third_place_medal,
            R.string.sports_medal,
            R.string.military_medal,
            R.string.rosette,
            R.string.reminder_ribbon,
            R.string.ticket,
            R.string.admission_tickets,
            R.string.circus_tent,
            R.string.woman_juggling,
            R.string.man_juggling,
            R.string.performing_arts,
            R.string.artist_palette,
            R.string.clapper_board,
            R.string.microphone,
            R.string.headphone,
            R.string.musical_score,
            R.string.musical_keyboard,
            R.string.drum,
            R.string.saxophone,
            R.string.trumpet,
            R.string.guitar,
            R.string.violin,
            R.string.game_die,
            R.string.chess_pawn,
            R.string.direct_hit,
            R.string.bowling,
            R.string.video_game,
            R.string.slot_machine,
            R.string.jigsaw
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
            R.id.button_microphone -> {
                inputConnection!!.commitText(context.getString(R.string.microphone), 1)
            }
            R.id.button_headphone -> {
                inputConnection!!.commitText(context.getString(R.string.headphone), 1)
            }
            R.id.button_musical_score -> {
                inputConnection!!.commitText(context.getString(R.string.musical_score), 1)
            }
            R.id.button_musical_keyboard -> {
                inputConnection!!.commitText(context.getString(R.string.musical_keyboard), 1)
            }
            R.id.button_drum -> {
                inputConnection!!.commitText(context.getString(R.string.drum), 1)
            }
            R.id.button_saxophone -> {
                inputConnection!!.commitText(context.getString(R.string.saxophone), 1)
            }
            R.id.button_trumpet -> {
                inputConnection!!.commitText(context.getString(R.string.trumpet), 1)
            }
            R.id.button_guitar -> {
                inputConnection!!.commitText(context.getString(R.string.guitar), 1)
            }
            R.id.button_violin -> {
                inputConnection!!.commitText(context.getString(R.string.violin), 1)
            }
            R.id.button_game_die -> {
                inputConnection!!.commitText(context.getString(R.string.game_die), 1)
            }
            R.id.button_chess_pawn -> {
                inputConnection!!.commitText(context.getString(R.string.chess_pawn), 1)
            }
            R.id.button_direct_hit -> {
                inputConnection!!.commitText(context.getString(R.string.direct_hit), 1)
            }
            R.id.button_bowling -> {
                inputConnection!!.commitText(context.getString(R.string.bowling), 1)
            }
            R.id.button_video_game -> {
                inputConnection!!.commitText(context.getString(R.string.video_game), 1)
            }
            R.id.button_slot_machine -> {
                inputConnection!!.commitText(context.getString(R.string.slot_machine), 1)
            }
            R.id.button_jigsaw -> {
                inputConnection!!.commitText(context.getString(R.string.jigsaw), 1)
            }
        }
    }

    fun setInputConnection(ic: InputConnection) {
        inputConnection = ic
    }
}