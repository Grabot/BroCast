package com.bro.brocast.keyboards

import android.content.Context
import android.text.TextUtils
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View.OnClickListener
import android.view.inputmethod.InputConnection
import android.widget.Button
import android.widget.LinearLayout
import com.bro.brocast.R


class SecondKeyboard: LinearLayout {

    constructor(context: Context) : super(context){
        init(context)
    }

    constructor(context: Context, attrs: AttributeSet):    super(context, attrs){
        init(context)
    }

    constructor(context: Context, attrs: AttributeSet?,    defStyleAttr: Int) : super(context, attrs, defStyleAttr) {
        init(context)
    }

    private var inputConnection: InputConnection? = null


    fun init(context: Context) {
        LayoutInflater.from(context).inflate(R.layout.keyboard_2, this, true)

        val buttonIds = arrayOf(
            R.id.button_dog_face,
            R.id.button_cat_face,
            R.id.button_mouse_face,
            R.id.button_hamster_face,
            R.id.button_rabbit_face,
            R.id.button_fox_face,
            R.id.button_bear_face,
            R.id.button_panda_face,
            R.id.button_koala,
            R.id.button_tiger_face,
            R.id.button_lion_face,
            R.id.button_cow_face,
            R.id.button_pig_face,
            R.id.button_pig_nose,
            R.id.button_frog_face,
            R.id.button_monkey_face,
            R.id.button_see_no_evil_monkey,
            R.id.button_hear_no_evil_monkey,
            R.id.button_speak_no_evil_monkey,
            R.id.button_monkey,
            R.id.button_chicken,
            R.id.button_penguin,
            R.id.button_bird,
            R.id.button_baby_chick,
            R.id.button_hatching_chick,
            R.id.button_front_facing_baby_chick,
            R.id.button_duck,
            R.id.button_eagle,
            R.id.button_owl,
            R.id.button_bat,
            R.id.button_wolf_face,
            R.id.button_boar,
            R.id.button_horse_face,
            R.id.button_unicorn_face,
            R.id.button_honeybee,
            R.id.button_bug,
            R.id.button_butterfly,
            R.id.button_snail,
            R.id.button_lady_beetle,
            R.id.button_ant,
            R.id.button_mosquito,
            R.id.button_cricket,
            R.id.button_spider,
            R.id.button_spider_web,
            R.id.button_scorpion,
            R.id.button_turtle,
            R.id.button_snake,
            R.id.button_lizard,
            R.id.button_t_rex,
            R.id.button_sauropod,
            R.id.button_octopus,
            R.id.button_squid,
            R.id.button_shrimp,
            R.id.button_lobster,
            R.id.button_crab,
            R.id.button_blowfish,
            R.id.button_tropical_fish,
            R.id.button_fish,
            R.id.button_dolphin,
            R.id.button_spouting_whale,
            R.id.button_whale,
            R.id.button_shark,
            R.id.button_crocodile,
            R.id.button_tiger,
            R.id.button_leopard,
            R.id.button_zebra,
            R.id.button_gorilla,
            R.id.button_elephant,
            R.id.button_hippopotamus,
            R.id.button_rhinoceros,
            R.id.button_camel,
            R.id.button_two_hump_camel,
            R.id.button_giraffe,
            R.id.button_kangaroo,
            R.id.button_water_buffalo,
            R.id.button_ox,
            R.id.button_cow,
            R.id.button_horse,
            R.id.button_pig,
            R.id.button_ram,
            R.id.button_ewe,
            R.id.button_llama,
            R.id.button_goat,
            R.id.button_deer,
            R.id.button_dog,
            R.id.button_poodle,
            R.id.button_cat,
            R.id.button_rooster,
            R.id.button_turkey,
            R.id.button_peacock,
            R.id.button_parrot,
            R.id.button_swan,
            R.id.button_dove,
            R.id.button_rabbit,
            R.id.button_raccoon,
            R.id.button_badger,
            R.id.button_mouse,
            R.id.button_rat,
            R.id.button_chipmunk,
            R.id.button_hedgehog,
            R.id.button_paw_prints,
            R.id.button_dragon,
            R.id.button_dragon_face,
            R.id.button_cactus,
            R.id.button_christmas_tree,
            R.id.button_evergreen_tree,
            R.id.button_deciduous_tree,
            R.id.button_palm_tree,
            R.id.button_seedling,
            R.id.button_herb,
            R.id.button_shamrock,
            R.id.button_four_leaf_clover,
            R.id.button_pine_decoration,
            R.id.button_tanabata_tree,
            R.id.button_leaf_fluttering_in_wind,
            R.id.button_fallen_leaf,
            R.id.button_maple_leaf,
            R.id.button_mushroom,
            R.id.button_spiral_shell,
            R.id.button_sheaf_of_rice,
            R.id.button_bouquet,
            R.id.button_tulip,
            R.id.button_rose,
            R.id.button_wilted_flower,
            R.id.button_hibiscus,
            R.id.button_cherry_blossom,
            R.id.button_blossom,
            R.id.button_sunflower,
            R.id.button_sun_with_face,
            R.id.button_full_moon_with_face,
            R.id.button_first_quarter_moon_with_face,
            R.id.button_last_quarter_moon_with_face,
            R.id.button_new_moon_face,
            R.id.button_full_moon,
            R.id.button_waning_gibbous_moon,
            R.id.button_last_quarter_moon,
            R.id.button_waning_crescent_moon,
            R.id.button_new_moon,
            R.id.button_waxing_crescent_moon,
            R.id.button_first_quarter_moon,
            R.id.button_waxing_gibbous_moon,
            R.id.button_crescent_moon,
            R.id.button_globe_showing_americas,
            R.id.button_globe_showing_europe_africa,
            R.id.button_globe_showing_asia_australia,
            R.id.button_dizzy,
            R.id.button_white_medium_star,
            R.id.button_glowing_star,
            R.id.button_sparkles,
            R.id.button_high_voltage,
            R.id.button_comet,
            R.id.button_collision
        )

        for (b in buttonIds) {
            findViewById<Button>(b).setOnClickListener(clickButtonListener)
        }
    }

    private val clickButtonListener = OnClickListener { view ->
        when (view.getId()) {
            R.id.button_dog_face -> {
                inputConnection!!.commitText(context.getString(R.string.dog_face), 1)
            }
            R.id.button_cat_face -> {
                inputConnection!!.commitText(context.getString(R.string.cat_face), 1)
            }
            R.id.button_mouse_face -> {
                inputConnection!!.commitText(context.getString(R.string.mouse_face), 1)
            }
            R.id.button_hamster_face -> {
                inputConnection!!.commitText(context.getString(R.string.hamster_face), 1)
            }
            R.id.button_rabbit_face -> {
                inputConnection!!.commitText(context.getString(R.string.rabbit_face), 1)
            }
            R.id.button_fox_face -> {
                inputConnection!!.commitText(context.getString(R.string.fox_face), 1)
            }
            R.id.button_bear_face -> {
                inputConnection!!.commitText(context.getString(R.string.bear_face), 1)
            }
            R.id.button_panda_face -> {
                inputConnection!!.commitText(context.getString(R.string.panda_face), 1)
            }
            R.id.button_koala -> {
                inputConnection!!.commitText(context.getString(R.string.koala), 1)
            }
            R.id.button_tiger_face -> {
                inputConnection!!.commitText(context.getString(R.string.tiger_face), 1)
            }
            R.id.button_lion_face -> {
                inputConnection!!.commitText(context.getString(R.string.lion_face), 1)
            }
            R.id.button_cow_face -> {
                inputConnection!!.commitText(context.getString(R.string.cow_face), 1)
            }
            R.id.button_pig_face -> {
                inputConnection!!.commitText(context.getString(R.string.pig_face), 1)
            }
            R.id.button_pig_nose -> {
                inputConnection!!.commitText(context.getString(R.string.pig_nose), 1)
            }
            R.id.button_frog_face -> {
                inputConnection!!.commitText(context.getString(R.string.frog_face), 1)
            }
            R.id.button_monkey_face -> {
                inputConnection!!.commitText(context.getString(R.string.monkey_face), 1)
            }
            R.id.button_see_no_evil_monkey -> {
                inputConnection!!.commitText(context.getString(R.string.see_no_evil_monkey), 1)
            }
            R.id.button_hear_no_evil_monkey -> {
                inputConnection!!.commitText(context.getString(R.string.hear_no_evil_monkey), 1)
            }
            R.id.button_speak_no_evil_monkey -> {
                inputConnection!!.commitText(context.getString(R.string.speak_no_evil_monkey), 1)
            }
            R.id.button_monkey -> {
                inputConnection!!.commitText(context.getString(R.string.monkey), 1)
            }
            R.id.button_chicken -> {
                inputConnection!!.commitText(context.getString(R.string.chicken), 1)
            }
            R.id.button_penguin -> {
                inputConnection!!.commitText(context.getString(R.string.penguin), 1)
            }
            R.id.button_bird -> {
                inputConnection!!.commitText(context.getString(R.string.bird), 1)
            }
            R.id.button_baby_chick -> {
                inputConnection!!.commitText(context.getString(R.string.baby_chick), 1)
            }
            R.id.button_hatching_chick -> {
                inputConnection!!.commitText(context.getString(R.string.hatching_chick), 1)
            }
            R.id.button_front_facing_baby_chick -> {
                inputConnection!!.commitText(context.getString(R.string.front_facing_baby_chick), 1)
            }
            R.id.button_duck -> {
                inputConnection!!.commitText(context.getString(R.string.duck), 1)
            }
            R.id.button_eagle -> {
                inputConnection!!.commitText(context.getString(R.string.eagle), 1)
            }
            R.id.button_owl -> {
                inputConnection!!.commitText(context.getString(R.string.owl), 1)
            }
            R.id.button_bat -> {
                inputConnection!!.commitText(context.getString(R.string.bat), 1)
            }
            R.id.button_wolf_face -> {
                inputConnection!!.commitText(context.getString(R.string.wolf_face), 1)
            }
            R.id.button_boar -> {
                inputConnection!!.commitText(context.getString(R.string.boar), 1)
            }
            R.id.button_horse_face -> {
                inputConnection!!.commitText(context.getString(R.string.horse_face), 1)
            }
            R.id.button_unicorn_face -> {
                inputConnection!!.commitText(context.getString(R.string.unicorn_face), 1)
            }
            R.id.button_honeybee -> {
                inputConnection!!.commitText(context.getString(R.string.honeybee), 1)
            }
            R.id.button_bug -> {
                inputConnection!!.commitText(context.getString(R.string.bug), 1)
            }
            R.id.button_butterfly -> {
                inputConnection!!.commitText(context.getString(R.string.butterfly), 1)
            }
            R.id.button_snail -> {
                inputConnection!!.commitText(context.getString(R.string.snail), 1)
            }
            R.id.button_lady_beetle -> {
                inputConnection!!.commitText(context.getString(R.string.lady_beetle), 1)
            }
            R.id.button_ant -> {
                inputConnection!!.commitText(context.getString(R.string.ant), 1)
            }
            R.id.button_mosquito -> {
                inputConnection!!.commitText(context.getString(R.string.mosquito), 1)
            }
            R.id.button_cricket -> {
                inputConnection!!.commitText(context.getString(R.string.cricket), 1)
            }
            R.id.button_spider -> {
                inputConnection!!.commitText(context.getString(R.string.spider), 1)
            }
            R.id.button_spider_web -> {
                inputConnection!!.commitText(context.getString(R.string.spider_web), 1)
            }
            R.id.button_scorpion -> {
                inputConnection!!.commitText(context.getString(R.string.scorpion), 1)
            }
            R.id.button_turtle -> {
                inputConnection!!.commitText(context.getString(R.string.turtle), 1)
            }
            R.id.button_snake -> {
                inputConnection!!.commitText(context.getString(R.string.snake), 1)
            }
            R.id.button_lizard -> {
                inputConnection!!.commitText(context.getString(R.string.lizard), 1)
            }
            R.id.button_t_rex -> {
                inputConnection!!.commitText(context.getString(R.string.t_rex), 1)
            }
            R.id.button_sauropod -> {
                inputConnection!!.commitText(context.getString(R.string.sauropod), 1)
            }
            R.id.button_octopus -> {
                inputConnection!!.commitText(context.getString(R.string.octopus), 1)
            }
            R.id.button_squid -> {
                inputConnection!!.commitText(context.getString(R.string.squid), 1)
            }
            R.id.button_shrimp -> {
                inputConnection!!.commitText(context.getString(R.string.shrimp), 1)
            }
            R.id.button_lobster -> {
                inputConnection!!.commitText(context.getString(R.string.lobster), 1)
            }
            R.id.button_crab -> {
                inputConnection!!.commitText(context.getString(R.string.crab), 1)
            }
            R.id.button_blowfish -> {
                inputConnection!!.commitText(context.getString(R.string.blowfish), 1)
            }
            R.id.button_tropical_fish -> {
                inputConnection!!.commitText(context.getString(R.string.tropical_fish), 1)
            }
            R.id.button_fish -> {
                inputConnection!!.commitText(context.getString(R.string.fish), 1)
            }
            R.id.button_dolphin -> {
                inputConnection!!.commitText(context.getString(R.string.dolphin), 1)
            }
            R.id.button_spouting_whale -> {
                inputConnection!!.commitText(context.getString(R.string.spouting_whale), 1)
            }
            R.id.button_whale -> {
                inputConnection!!.commitText(context.getString(R.string.whale), 1)
            }
            R.id.button_shark -> {
                inputConnection!!.commitText(context.getString(R.string.shark), 1)
            }
            R.id.button_crocodile -> {
                inputConnection!!.commitText(context.getString(R.string.crocodile), 1)
            }
            R.id.button_tiger -> {
                inputConnection!!.commitText(context.getString(R.string.tiger), 1)
            }
            R.id.button_leopard -> {
                inputConnection!!.commitText(context.getString(R.string.leopard), 1)
            }
            R.id.button_zebra -> {
                inputConnection!!.commitText(context.getString(R.string.zebra), 1)
            }
            R.id.button_gorilla -> {
                inputConnection!!.commitText(context.getString(R.string.gorilla), 1)
            }
            R.id.button_elephant -> {
                inputConnection!!.commitText(context.getString(R.string.elephant), 1)
            }
            R.id.button_hippopotamus -> {
                inputConnection!!.commitText(context.getString(R.string.hippopotamus), 1)
            }
            R.id.button_rhinoceros -> {
                inputConnection!!.commitText(context.getString(R.string.rhinoceros), 1)
            }
            R.id.button_camel -> {
                inputConnection!!.commitText(context.getString(R.string.camel), 1)
            }
            R.id.button_two_hump_camel -> {
                inputConnection!!.commitText(context.getString(R.string.two_hump_camel), 1)
            }
            R.id.button_giraffe -> {
                inputConnection!!.commitText(context.getString(R.string.giraffe), 1)
            }
            R.id.button_kangaroo -> {
                inputConnection!!.commitText(context.getString(R.string.kangaroo), 1)
            }
            R.id.button_water_buffalo -> {
                inputConnection!!.commitText(context.getString(R.string.water_buffalo), 1)
            }
            R.id.button_ox -> {
                inputConnection!!.commitText(context.getString(R.string.ox), 1)
            }
            R.id.button_cow -> {
                inputConnection!!.commitText(context.getString(R.string.cow), 1)
            }
            R.id.button_horse -> {
                inputConnection!!.commitText(context.getString(R.string.horse), 1)
            }
            R.id.button_pig -> {
                inputConnection!!.commitText(context.getString(R.string.pig), 1)
            }
            R.id.button_ram -> {
                inputConnection!!.commitText(context.getString(R.string.ram), 1)
            }
            R.id.button_ewe -> {
                inputConnection!!.commitText(context.getString(R.string.ewe), 1)
            }
            R.id.button_llama -> {
                inputConnection!!.commitText(context.getString(R.string.llama), 1)
            }
            R.id.button_goat -> {
                inputConnection!!.commitText(context.getString(R.string.goat), 1)
            }
            R.id.button_deer -> {
                inputConnection!!.commitText(context.getString(R.string.deer), 1)
            }
            R.id.button_dog -> {
                inputConnection!!.commitText(context.getString(R.string.dog), 1)
            }
            R.id.button_poodle -> {
                inputConnection!!.commitText(context.getString(R.string.poodle), 1)
            }
            R.id.button_cat -> {
                inputConnection!!.commitText(context.getString(R.string.cat), 1)
            }
            R.id.button_rooster -> {
                inputConnection!!.commitText(context.getString(R.string.rooster), 1)
            }
            R.id.button_turkey -> {
                inputConnection!!.commitText(context.getString(R.string.turkey), 1)
            }
            R.id.button_peacock -> {
                inputConnection!!.commitText(context.getString(R.string.peacock), 1)
            }
            R.id.button_parrot -> {
                inputConnection!!.commitText(context.getString(R.string.parrot), 1)
            }
            R.id.button_swan -> {
                inputConnection!!.commitText(context.getString(R.string.swan), 1)
            }
            R.id.button_dove -> {
                inputConnection!!.commitText(context.getString(R.string.dove), 1)
            }
            R.id.button_rabbit -> {
                inputConnection!!.commitText(context.getString(R.string.rabbit), 1)
            }
            R.id.button_raccoon -> {
                inputConnection!!.commitText(context.getString(R.string.raccoon), 1)
            }
            R.id.button_badger -> {
                inputConnection!!.commitText(context.getString(R.string.badger), 1)
            }
            R.id.button_mouse -> {
                inputConnection!!.commitText(context.getString(R.string.mouse), 1)
            }
            R.id.button_rat -> {
                inputConnection!!.commitText(context.getString(R.string.rat), 1)
            }
            R.id.button_chipmunk -> {
                inputConnection!!.commitText(context.getString(R.string.chipmunk), 1)
            }
            R.id.button_hedgehog -> {
                inputConnection!!.commitText(context.getString(R.string.hedgehog), 1)
            }
            R.id.button_paw_prints -> {
                inputConnection!!.commitText(context.getString(R.string.paw_prints), 1)
            }
            R.id.button_dragon -> {
                inputConnection!!.commitText(context.getString(R.string.dragon), 1)
            }
            R.id.button_dragon_face -> {
                inputConnection!!.commitText(context.getString(R.string.dragon_face), 1)
            }
            R.id.button_cactus -> {
                inputConnection!!.commitText(context.getString(R.string.cactus), 1)
            }
            R.id.button_christmas_tree -> {
                inputConnection!!.commitText(context.getString(R.string.christmas_tree), 1)
            }
            R.id.button_evergreen_tree -> {
                inputConnection!!.commitText(context.getString(R.string.evergreen_tree), 1)
            }
            R.id.button_deciduous_tree -> {
                inputConnection!!.commitText(context.getString(R.string.deciduous_tree), 1)
            }
            R.id.button_palm_tree -> {
                inputConnection!!.commitText(context.getString(R.string.palm_tree), 1)
            }
            R.id.button_seedling -> {
                inputConnection!!.commitText(context.getString(R.string.seedling), 1)
            }
            R.id.button_herb -> {
                inputConnection!!.commitText(context.getString(R.string.herb), 1)
            }
            R.id.button_shamrock -> {
                inputConnection!!.commitText(context.getString(R.string.shamrock), 1)
            }
            R.id.button_four_leaf_clover -> {
                inputConnection!!.commitText(context.getString(R.string.four_leaf_clover), 1)
            }
            R.id.button_pine_decoration -> {
                inputConnection!!.commitText(context.getString(R.string.pine_decoration), 1)
            }
            R.id.button_tanabata_tree -> {
                inputConnection!!.commitText(context.getString(R.string.tanabata_tree), 1)
            }
            R.id.button_leaf_fluttering_in_wind -> {
                inputConnection!!.commitText(context.getString(R.string.leaf_fluttering_in_wind), 1)
            }
            R.id.button_fallen_leaf -> {
                inputConnection!!.commitText(context.getString(R.string.fallen_leaf), 1)
            }
            R.id.button_maple_leaf -> {
                inputConnection!!.commitText(context.getString(R.string.maple_leaf), 1)
            }
            R.id.button_mushroom -> {
                inputConnection!!.commitText(context.getString(R.string.mushroom), 1)
            }
            R.id.button_spiral_shell -> {
                inputConnection!!.commitText(context.getString(R.string.spiral_shell), 1)
            }
            R.id.button_sheaf_of_rice -> {
                inputConnection!!.commitText(context.getString(R.string.sheaf_of_rice), 1)
            }
            R.id.button_bouquet -> {
                inputConnection!!.commitText(context.getString(R.string.bouquet), 1)
            }
            R.id.button_tulip -> {
                inputConnection!!.commitText(context.getString(R.string.tulip), 1)
            }
            R.id.button_rose -> {
                inputConnection!!.commitText(context.getString(R.string.rose), 1)
            }
            R.id.button_wilted_flower -> {
                inputConnection!!.commitText(context.getString(R.string.wilted_flower), 1)
            }
            R.id.button_hibiscus -> {
                inputConnection!!.commitText(context.getString(R.string.hibiscus), 1)
            }
            R.id.button_cherry_blossom -> {
                inputConnection!!.commitText(context.getString(R.string.cherry_blossom), 1)
            }
            R.id.button_blossom -> {
                inputConnection!!.commitText(context.getString(R.string.blossom), 1)
            }
            R.id.button_sunflower -> {
                inputConnection!!.commitText(context.getString(R.string.sunflower), 1)
            }
            R.id.button_sun_with_face -> {
                inputConnection!!.commitText(context.getString(R.string.sun_with_face), 1)
            }
            R.id.button_full_moon_with_face -> {
                inputConnection!!.commitText(context.getString(R.string.full_moon_with_face), 1)
            }
            R.id.button_first_quarter_moon_with_face -> {
                inputConnection!!.commitText(context.getString(R.string.first_quarter_moon_with_face), 1)
            }
            R.id.button_last_quarter_moon_with_face -> {
                inputConnection!!.commitText(context.getString(R.string.last_quarter_moon_with_face), 1)
            }
            R.id.button_new_moon_face -> {
                inputConnection!!.commitText(context.getString(R.string.new_moon_face), 1)
            }
            R.id.button_full_moon -> {
                inputConnection!!.commitText(context.getString(R.string.full_moon), 1)
            }
            R.id.button_waning_gibbous_moon -> {
                inputConnection!!.commitText(context.getString(R.string.waning_gibbous_moon), 1)
            }
            R.id.button_last_quarter_moon -> {
                inputConnection!!.commitText(context.getString(R.string.last_quarter_moon), 1)
            }
            R.id.button_waning_crescent_moon -> {
                inputConnection!!.commitText(context.getString(R.string.waning_crescent_moon), 1)
            }
            R.id.button_new_moon -> {
                inputConnection!!.commitText(context.getString(R.string.new_moon), 1)
            }
            R.id.button_waxing_crescent_moon -> {
                inputConnection!!.commitText(context.getString(R.string.waxing_crescent_moon), 1)
            }
            R.id.button_first_quarter_moon -> {
                inputConnection!!.commitText(context.getString(R.string.first_quarter_moon), 1)
            }
            R.id.button_waxing_gibbous_moon -> {
                inputConnection!!.commitText(context.getString(R.string.waxing_gibbous_moon), 1)
            }
            R.id.button_crescent_moon -> {
                inputConnection!!.commitText(context.getString(R.string.crescent_moon), 1)
            }
            R.id.button_globe_showing_americas -> {
                inputConnection!!.commitText(context.getString(R.string.globe_showing_americas), 1)
            }
            R.id.button_globe_showing_europe_africa -> {
                inputConnection!!.commitText(context.getString(R.string.globe_showing_europe_africa), 1)
            }
            R.id.button_globe_showing_asia_australia -> {
                inputConnection!!.commitText(context.getString(R.string.globe_showing_asia_australia), 1)
            }
            R.id.button_dizzy -> {
                inputConnection!!.commitText(context.getString(R.string.dizzy), 1)
            }
            R.id.button_white_medium_star -> {
                inputConnection!!.commitText(context.getString(R.string.white_medium_star), 1)
            }
            R.id.button_glowing_star -> {
                inputConnection!!.commitText(context.getString(R.string.glowing_star), 1)
            }
            R.id.button_sparkles -> {
                inputConnection!!.commitText(context.getString(R.string.sparkles), 1)
            }
            R.id.button_high_voltage -> {
                inputConnection!!.commitText(context.getString(R.string.high_voltage), 1)
            }
            R.id.button_comet -> {
                inputConnection!!.commitText(context.getString(R.string.comet), 1)
            }
            R.id.button_collision -> {
                inputConnection!!.commitText(context.getString(R.string.collision), 1)
            }
        }
    }

    fun setInputConnection(ic: InputConnection) {
        inputConnection = ic
    }
}