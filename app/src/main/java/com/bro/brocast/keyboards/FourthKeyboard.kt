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
            R.string.green_apple,
            R.string.red_apple,
            R.string.pear,
            R.string.tangerine,
            R.string.lemon,
            R.string.banana,
            R.string.watermelon,
            R.string.grapes,
            R.string.strawberry,
            R.string.melon,
            R.string.cherries,
            R.string.peach,
            R.string.mango,
            R.string.pineapple,
            R.string.coconut,
            R.string.kiwi_fruit,
            R.string.tomato,
            R.string.eggplant,
            R.string.avocado,
            R.string.broccoli,
            R.string.leafy_green,
            R.string.cucumber,
            R.string.hot_pepper,
            R.string.ear_of_corn,
            R.string.carrot,
            R.string.potato,
            R.string.roasted_sweet_potato,
            R.string.croissant,
            R.string.bagel,
            R.string.bread,
            R.string.baguette_bread,
            R.string.pretzel,
            R.string.cheese_wedge,
            R.string.egg,
            R.string.cooking,
            R.string.pancakes,
            R.string.bacon,
            R.string.cut_of_meat,
            R.string.poultry_leg,
            R.string.meat_on_bone,
            R.string.bone,
            R.string.hot_dog,
            R.string.hamburger,
            R.string.french_fries,
            R.string.pizza,
            R.string.sandwich,
            R.string.stuffed_flatbread,
            R.string.taco,
            R.string.burrito,
            R.string.green_salad,
            R.string.shallow_pan_of_food,
            R.string.canned_food,
            R.string.spaghetti,
            R.string.steaming_bowl,
            R.string.pot_of_food,
            R.string.curry_rice,
            R.string.sushi,
            R.string.bento_box,
            R.string.dumpling,
            R.string.fried_shrimp,
            R.string.rice_ball,
            R.string.cooked_rice,
            R.string.rice_cracker,
            R.string.fish_cake_with_swirl,
            R.string.fortune_cookie,
            R.string.moon_cake,
            R.string.oden,
            R.string.dango,
            R.string.shaved_ice,
            R.string.ice_cream,
            R.string.soft_ice_cream,
            R.string.pie,
            R.string.cupcake,
            R.string.shortcake,
            R.string.birthday_cake,
            R.string.custard,
            R.string.lollipop,
            R.string.candy,
            R.string.chocolate_bar,
            R.string.popcorn,
            R.string.doughnut,
            R.string.cookie,
            R.string.chestnut,
            R.string.peanuts,
            R.string.honey_pot,
            R.string.glass_of_milk,
            R.string.baby_bottle,
            R.string.hot_beverage,
            R.string.teacup_without_handle,
            R.string.cup_with_straw,
            R.string.sake,
            R.string.beer_mug,
            R.string.clinking_beer_mugs,
            R.string.clinking_glasses,
            R.string.wine_glass,
            R.string.tumbler_glass,
            R.string.cocktail_glass,
            R.string.tropical_drink,
            R.string.bottle_with_popping_cork,
            R.string.spoon,
            R.string.fork_and_knife,
            R.string.fork_and_knife_with_plate,
            R.string.bowl_with_spoon,
            R.string.takeout_box,
            R.string.chopsticks,
            R.string.salt
        )

        for (b in buttonIds) {
            findViewById<Button>(b).setOnClickListener(clickButtonListener)
        }
    }

    private val clickButtonListener = OnClickListener { view ->
        when (view.getId()) {
            R.id.button_green_apple -> {
                inputConnection!!.commitText(context.getString(R.string.green_apple), 1)
            }
            R.id.button_red_apple -> {
                inputConnection!!.commitText(context.getString(R.string.red_apple), 1)
            }
            R.id.button_pear -> {
                inputConnection!!.commitText(context.getString(R.string.pear), 1)
            }
            R.id.button_tangerine -> {
                inputConnection!!.commitText(context.getString(R.string.tangerine), 1)
            }
            R.id.button_lemon -> {
                inputConnection!!.commitText(context.getString(R.string.lemon), 1)
            }
            R.id.button_banana -> {
                inputConnection!!.commitText(context.getString(R.string.banana), 1)
            }
            R.id.button_watermelon -> {
                inputConnection!!.commitText(context.getString(R.string.watermelon), 1)
            }
            R.id.button_grapes -> {
                inputConnection!!.commitText(context.getString(R.string.grapes), 1)
            }
            R.id.button_strawberry -> {
                inputConnection!!.commitText(context.getString(R.string.strawberry), 1)
            }
            R.id.button_melon -> {
                inputConnection!!.commitText(context.getString(R.string.melon), 1)
            }
            R.id.button_cherries -> {
                inputConnection!!.commitText(context.getString(R.string.cherries), 1)
            }
            R.id.button_peach -> {
                inputConnection!!.commitText(context.getString(R.string.peach), 1)
            }
            R.id.button_mango -> {
                inputConnection!!.commitText(context.getString(R.string.mango), 1)
            }
            R.id.button_pineapple -> {
                inputConnection!!.commitText(context.getString(R.string.pineapple), 1)
            }
            R.id.button_coconut -> {
                inputConnection!!.commitText(context.getString(R.string.coconut), 1)
            }
            R.id.button_kiwi_fruit -> {
                inputConnection!!.commitText(context.getString(R.string.kiwi_fruit), 1)
            }
            R.id.button_tomato -> {
                inputConnection!!.commitText(context.getString(R.string.tomato), 1)
            }
            R.id.button_eggplant -> {
                inputConnection!!.commitText(context.getString(R.string.eggplant), 1)
            }
            R.id.button_avocado -> {
                inputConnection!!.commitText(context.getString(R.string.avocado), 1)
            }
            R.id.button_broccoli -> {
                inputConnection!!.commitText(context.getString(R.string.broccoli), 1)
            }
            R.id.button_leafy_green -> {
                inputConnection!!.commitText(context.getString(R.string.leafy_green), 1)
            }
            R.id.button_cucumber -> {
                inputConnection!!.commitText(context.getString(R.string.cucumber), 1)
            }
            R.id.button_hot_pepper -> {
                inputConnection!!.commitText(context.getString(R.string.hot_pepper), 1)
            }
            R.id.button_ear_of_corn -> {
                inputConnection!!.commitText(context.getString(R.string.ear_of_corn), 1)
            }
            R.id.button_carrot -> {
                inputConnection!!.commitText(context.getString(R.string.carrot), 1)
            }
            R.id.button_potato -> {
                inputConnection!!.commitText(context.getString(R.string.potato), 1)
            }
            R.id.button_roasted_sweet_potato -> {
                inputConnection!!.commitText(context.getString(R.string.roasted_sweet_potato), 1)
            }
            R.id.button_croissant -> {
                inputConnection!!.commitText(context.getString(R.string.croissant), 1)
            }
            R.id.button_bagel -> {
                inputConnection!!.commitText(context.getString(R.string.bagel), 1)
            }
            R.id.button_bread -> {
                inputConnection!!.commitText(context.getString(R.string.bread), 1)
            }
            R.id.button_baguette_bread -> {
                inputConnection!!.commitText(context.getString(R.string.baguette_bread), 1)
            }
            R.id.button_pretzel -> {
                inputConnection!!.commitText(context.getString(R.string.pretzel), 1)
            }
            R.id.button_cheese_wedge -> {
                inputConnection!!.commitText(context.getString(R.string.cheese_wedge), 1)
            }
            R.id.button_egg -> {
                inputConnection!!.commitText(context.getString(R.string.egg), 1)
            }
            R.id.button_cooking -> {
                inputConnection!!.commitText(context.getString(R.string.cooking), 1)
            }
            R.id.button_pancakes -> {
                inputConnection!!.commitText(context.getString(R.string.pancakes), 1)
            }
            R.id.button_bacon -> {
                inputConnection!!.commitText(context.getString(R.string.bacon), 1)
            }
            R.id.button_cut_of_meat -> {
                inputConnection!!.commitText(context.getString(R.string.cut_of_meat), 1)
            }
            R.id.button_poultry_leg -> {
                inputConnection!!.commitText(context.getString(R.string.poultry_leg), 1)
            }
            R.id.button_meat_on_bone -> {
                inputConnection!!.commitText(context.getString(R.string.meat_on_bone), 1)
            }
            R.id.button_bone -> {
                inputConnection!!.commitText(context.getString(R.string.bone), 1)
            }
            R.id.button_hot_dog -> {
                inputConnection!!.commitText(context.getString(R.string.hot_dog), 1)
            }
            R.id.button_hamburger -> {
                inputConnection!!.commitText(context.getString(R.string.hamburger), 1)
            }
            R.id.button_french_fries -> {
                inputConnection!!.commitText(context.getString(R.string.french_fries), 1)
            }
            R.id.button_pizza -> {
                inputConnection!!.commitText(context.getString(R.string.pizza), 1)
            }
            R.id.button_sandwich -> {
                inputConnection!!.commitText(context.getString(R.string.sandwich), 1)
            }
            R.id.button_stuffed_flatbread -> {
                inputConnection!!.commitText(context.getString(R.string.stuffed_flatbread), 1)
            }
            R.id.button_taco -> {
                inputConnection!!.commitText(context.getString(R.string.taco), 1)
            }
            R.id.button_burrito -> {
                inputConnection!!.commitText(context.getString(R.string.burrito), 1)
            }
            R.id.button_green_salad -> {
                inputConnection!!.commitText(context.getString(R.string.green_salad), 1)
            }
            R.id.button_shallow_pan_of_food -> {
                inputConnection!!.commitText(context.getString(R.string.shallow_pan_of_food), 1)
            }
            R.id.button_canned_food -> {
                inputConnection!!.commitText(context.getString(R.string.canned_food), 1)
            }
            R.id.button_spaghetti -> {
                inputConnection!!.commitText(context.getString(R.string.spaghetti), 1)
            }
            R.id.button_steaming_bowl -> {
                inputConnection!!.commitText(context.getString(R.string.steaming_bowl), 1)
            }
            R.id.button_pot_of_food -> {
                inputConnection!!.commitText(context.getString(R.string.pot_of_food), 1)
            }
            R.id.button_curry_rice -> {
                inputConnection!!.commitText(context.getString(R.string.curry_rice), 1)
            }
            R.id.button_sushi -> {
                inputConnection!!.commitText(context.getString(R.string.sushi), 1)
            }
            R.id.button_bento_box -> {
                inputConnection!!.commitText(context.getString(R.string.bento_box), 1)
            }
            R.id.button_dumpling -> {
                inputConnection!!.commitText(context.getString(R.string.dumpling), 1)
            }
            R.id.button_fried_shrimp -> {
                inputConnection!!.commitText(context.getString(R.string.fried_shrimp), 1)
            }
            R.id.button_rice_ball -> {
                inputConnection!!.commitText(context.getString(R.string.rice_ball), 1)
            }
            R.id.button_cooked_rice -> {
                inputConnection!!.commitText(context.getString(R.string.cooked_rice), 1)
            }
            R.id.button_rice_cracker -> {
                inputConnection!!.commitText(context.getString(R.string.rice_cracker), 1)
            }
            R.id.button_fish_cake_with_swirl -> {
                inputConnection!!.commitText(context.getString(R.string.fish_cake_with_swirl), 1)
            }
            R.id.button_fortune_cookie -> {
                inputConnection!!.commitText(context.getString(R.string.fortune_cookie), 1)
            }
            R.id.button_moon_cake -> {
                inputConnection!!.commitText(context.getString(R.string.moon_cake), 1)
            }
            R.id.button_oden -> {
                inputConnection!!.commitText(context.getString(R.string.oden), 1)
            }
            R.id.button_dango -> {
                inputConnection!!.commitText(context.getString(R.string.dango), 1)
            }
            R.id.button_shaved_ice -> {
                inputConnection!!.commitText(context.getString(R.string.shaved_ice), 1)
            }
            R.id.button_ice_cream -> {
                inputConnection!!.commitText(context.getString(R.string.ice_cream), 1)
            }
            R.id.button_soft_ice_cream -> {
                inputConnection!!.commitText(context.getString(R.string.soft_ice_cream), 1)
            }
            R.id.button_pie -> {
                inputConnection!!.commitText(context.getString(R.string.pie), 1)
            }
            R.id.button_cupcake -> {
                inputConnection!!.commitText(context.getString(R.string.cupcake), 1)
            }
            R.id.button_shortcake -> {
                inputConnection!!.commitText(context.getString(R.string.shortcake), 1)
            }
            R.id.button_birthday_cake -> {
                inputConnection!!.commitText(context.getString(R.string.birthday_cake), 1)
            }
            R.id.button_custard -> {
                inputConnection!!.commitText(context.getString(R.string.custard), 1)
            }
            R.id.button_lollipop -> {
                inputConnection!!.commitText(context.getString(R.string.lollipop), 1)
            }
            R.id.button_candy -> {
                inputConnection!!.commitText(context.getString(R.string.candy), 1)
            }
            R.id.button_chocolate_bar -> {
                inputConnection!!.commitText(context.getString(R.string.chocolate_bar), 1)
            }
            R.id.button_popcorn -> {
                inputConnection!!.commitText(context.getString(R.string.popcorn), 1)
            }
            R.id.button_doughnut -> {
                inputConnection!!.commitText(context.getString(R.string.doughnut), 1)
            }
            R.id.button_cookie -> {
                inputConnection!!.commitText(context.getString(R.string.cookie), 1)
            }
            R.id.button_chestnut -> {
                inputConnection!!.commitText(context.getString(R.string.chestnut), 1)
            }
            R.id.button_peanuts -> {
                inputConnection!!.commitText(context.getString(R.string.peanuts), 1)
            }
            R.id.button_honey_pot -> {
                inputConnection!!.commitText(context.getString(R.string.honey_pot), 1)
            }
            R.id.button_glass_of_milk -> {
                inputConnection!!.commitText(context.getString(R.string.glass_of_milk), 1)
            }
            R.id.button_baby_bottle -> {
                inputConnection!!.commitText(context.getString(R.string.baby_bottle), 1)
            }
            R.id.button_hot_beverage -> {
                inputConnection!!.commitText(context.getString(R.string.hot_beverage), 1)
            }
            R.id.button_teacup_without_handle -> {
                inputConnection!!.commitText(context.getString(R.string.teacup_without_handle), 1)
            }
            R.id.button_cup_with_straw -> {
                inputConnection!!.commitText(context.getString(R.string.cup_with_straw), 1)
            }
            R.id.button_sake -> {
                inputConnection!!.commitText(context.getString(R.string.sake), 1)
            }
            R.id.button_beer_mug -> {
                inputConnection!!.commitText(context.getString(R.string.beer_mug), 1)
            }
            R.id.button_clinking_beer_mugs -> {
                inputConnection!!.commitText(context.getString(R.string.clinking_beer_mugs), 1)
            }
            R.id.button_clinking_glasses -> {
                inputConnection!!.commitText(context.getString(R.string.clinking_glasses), 1)
            }
            R.id.button_wine_glass -> {
                inputConnection!!.commitText(context.getString(R.string.wine_glass), 1)
            }
            R.id.button_tumbler_glass -> {
                inputConnection!!.commitText(context.getString(R.string.tumbler_glass), 1)
            }
            R.id.button_cocktail_glass -> {
                inputConnection!!.commitText(context.getString(R.string.cocktail_glass), 1)
            }
            R.id.button_tropical_drink -> {
                inputConnection!!.commitText(context.getString(R.string.tropical_drink), 1)
            }
            R.id.button_bottle_with_popping_cork -> {
                inputConnection!!.commitText(context.getString(R.string.bottle_with_popping_cork), 1)
            }
            R.id.button_spoon -> {
                inputConnection!!.commitText(context.getString(R.string.spoon), 1)
            }
            R.id.button_fork_and_knife -> {
                inputConnection!!.commitText(context.getString(R.string.fork_and_knife), 1)
            }
            R.id.button_fork_and_knife_with_plate -> {
                inputConnection!!.commitText(context.getString(R.string.fork_and_knife_with_plate), 1)
            }
            R.id.button_bowl_with_spoon -> {
                inputConnection!!.commitText(context.getString(R.string.bowl_with_spoon), 1)
            }
            R.id.button_takeout_box -> {
                inputConnection!!.commitText(context.getString(R.string.takeout_box), 1)
            }
            R.id.button_chopsticks -> {
                inputConnection!!.commitText(context.getString(R.string.chopsticks), 1)
            }
            R.id.button_salt -> {
                inputConnection!!.commitText(context.getString(R.string.salt), 1)
            }
        }
    }

    fun setInputConnection(ic: InputConnection) {
        inputConnection = ic
    }
}