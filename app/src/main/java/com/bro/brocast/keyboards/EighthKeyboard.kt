package com.bro.brocast.keyboards

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View.OnClickListener
import android.view.inputmethod.InputConnection
import android.widget.Button
import android.widget.LinearLayout
import com.bro.brocast.R


class EighthKeyboard: LinearLayout {

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
        LayoutInflater.from(context).inflate(R.layout.keyboard_8, this, true)

        val buttonIds = arrayOf(
            R.id.button_white_flag,
            R.id.button_black_flag,
            R.id.button_pirate_flag,
            R.id.button_chequered_flag,
            R.id.button_triangular_flag,
            R.id.button_rainbow_flag,
            R.id.button_united_nations,
            R.id.button_afghanistan,
            R.id.button_aland_islands,
            R.id.button_albania,
            R.id.button_algeria,
            R.id.button_american_samoa,
            R.id.button_andorra,
            R.id.button_angola,
            R.id.button_anguilla,
            R.id.button_antarctica,
            R.id.button_antigua_and_barbuda,
            R.id.button_argentina,
            R.id.button_armenia,
            R.id.button_aruba,
            R.id.button_australia,
            R.id.button_austria,
            R.id.button_azerbaijan,
            R.id.button_bahamas,
            R.id.button_bahrain,
            R.id.button_bangladesh,
            R.id.button_barbados,
            R.id.button_belarus,
            R.id.button_belgium,
            R.id.button_belize,
            R.id.button_benin,
            R.id.button_bermuda,
            R.id.button_bhutan,
            R.id.button_bolivia,
            R.id.button_bosnia_and_herzegovina,
            R.id.button_botswana,
            R.id.button_brazil,
            R.id.button_british_indian_ocean_territory,
            R.id.button_british_virgin_islands,
            R.id.button_brunei,
            R.id.button_bulgaria,
            R.id.button_burkina_faso,
            R.id.button_burundi,
            R.id.button_cambodia,
            R.id.button_cameroon,
            R.id.button_canada,
            R.id.button_canary_islands,
            R.id.button_cape_verde,
            R.id.button_caribbean_netherlands,
            R.id.button_cayman_islands,
            R.id.button_central_african_republic,
            R.id.button_chad,
            R.id.button_chile,
            R.id.button_china,
            R.id.button_christmas_island,
            R.id.button_cocos_keeling_islands,
            R.id.button_colombia,
            R.id.button_comoros,
            R.id.button_congo_brazzaville,
            R.id.button_congo_kinshasa,
            R.id.button_cook_islands,
            R.id.button_costa_rica,
            R.id.button_cote_d_ivoire,
            R.id.button_croatia,
            R.id.button_cuba,
            R.id.button_curacao,
            R.id.button_cyprus,
            R.id.button_czechia,
            R.id.button_denmark,
            R.id.button_djibouti,
            R.id.button_dominica,
            R.id.button_dominican_republic,
            R.id.button_ecuador,
            R.id.button_egypt,
            R.id.button_el_salvador,
            R.id.button_equatorial_guinea,
            R.id.button_eritrea,
            R.id.button_estonia,
            R.id.button_ethiopia,
            R.id.button_european_union,
            R.id.button_falkland_islands,
            R.id.button_faroe_islands,
            R.id.button_fiji,
            R.id.button_finland,
            R.id.button_france,
            R.id.button_french_guiana,
            R.id.button_french_polynesia,
            R.id.button_french_southern_territories,
            R.id.button_gabon,
            R.id.button_gambia,
            R.id.button_georgia,
            R.id.button_germany,
            R.id.button_ghana,
            R.id.button_gibraltar,
            R.id.button_greece,
            R.id.button_greenland,
            R.id.button_grenada,
            R.id.button_guadeloupe,
            R.id.button_guam,
            R.id.button_guatemala,
            R.id.button_guernsey,
            R.id.button_guinea,
            R.id.button_guinea_bissau,
            R.id.button_guyana,
            R.id.button_haiti,
            R.id.button_honduras,
            R.id.button_hong_kong,
            R.id.button_hungary,
            R.id.button_iceland,
            R.id.button_india,
            R.id.button_indonesia,
            R.id.button_iran,
            R.id.button_iraq,
            R.id.button_ireland,
            R.id.button_isle_of_man,
            R.id.button_israel,
            R.id.button_italy,
            R.id.button_jamaica,
            R.id.button_japan,
            R.id.button_crossed_flags,
            R.id.button_jersey,
            R.id.button_jordan,
            R.id.button_kazakhstan,
            R.id.button_kenya,
            R.id.button_kiribati,
            R.id.button_kosovo,
            R.id.button_kuwait,
            R.id.button_kyrgyzstan,
            R.id.button_laos,
            R.id.button_latvia,
            R.id.button_lebanon,
            R.id.button_lesotho,
            R.id.button_liberia,
            R.id.button_libya,
            R.id.button_liechtenstein,
            R.id.button_lithuania,
            R.id.button_luxembourg,
            R.id.button_macau_sar_china,
            R.id.button_macedonia,
            R.id.button_madagascar,
            R.id.button_malawi,
            R.id.button_malaysia,
            R.id.button_maldives,
            R.id.button_mali,
            R.id.button_malta,
            R.id.button_marshall_islands,
            R.id.button_martinique,
            R.id.button_mauritania,
            R.id.button_mauritius,
            R.id.button_mayotte,
            R.id.button_mexico,
            R.id.button_micronesia,
            R.id.button_moldova,
            R.id.button_monaco,
            R.id.button_mongolia,
            R.id.button_montenegro,
            R.id.button_montserrat,
            R.id.button_morocco,
            R.id.button_mozambique,
            R.id.button_myanmar_burma,
            R.id.button_namibia,
            R.id.button_nauru,
            R.id.button_nepal,
            R.id.button_netherlands,
            R.id.button_new_caledonia,
            R.id.button_new_zealand,
            R.id.button_nicaragua,
            R.id.button_niger,
            R.id.button_nigeria,
            R.id.button_niue,
            R.id.button_norfolk_island
        )

        for (b in buttonIds) {
            findViewById<Button>(b).setOnClickListener(clickButtonListener)
        }
    }

    private val clickButtonListener = OnClickListener { view ->
        when (view.getId()) {
            R.id.button_white_flag -> {
                inputConnection!!.commitText(context.getString(R.string.white_flag), 1)
            }
            R.id.button_black_flag -> {
                inputConnection!!.commitText(context.getString(R.string.black_flag), 1)
            }
            R.id.button_pirate_flag -> {
                inputConnection!!.commitText(context.getString(R.string.pirate_flag), 1)
            }
            R.id.button_chequered_flag -> {
                inputConnection!!.commitText(context.getString(R.string.chequered_flag), 1)
            }
            R.id.button_triangular_flag -> {
                inputConnection!!.commitText(context.getString(R.string.triangular_flag), 1)
            }
            R.id.button_rainbow_flag -> {
                inputConnection!!.commitText(context.getString(R.string.rainbow_flag), 1)
            }
            R.id.button_united_nations -> {
                inputConnection!!.commitText(context.getString(R.string.united_nations), 1)
            }
            R.id.button_afghanistan -> {
                inputConnection!!.commitText(context.getString(R.string.afghanistan), 1)
            }
            R.id.button_aland_islands -> {
                inputConnection!!.commitText(context.getString(R.string.aland_islands), 1)
            }
            R.id.button_albania -> {
                inputConnection!!.commitText(context.getString(R.string.albania), 1)
            }
            R.id.button_algeria -> {
                inputConnection!!.commitText(context.getString(R.string.algeria), 1)
            }
            R.id.button_american_samoa -> {
                inputConnection!!.commitText(context.getString(R.string.american_samoa), 1)
            }
            R.id.button_andorra -> {
                inputConnection!!.commitText(context.getString(R.string.andorra), 1)
            }
            R.id.button_angola -> {
                inputConnection!!.commitText(context.getString(R.string.angola), 1)
            }
            R.id.button_anguilla -> {
                inputConnection!!.commitText(context.getString(R.string.anguilla), 1)
            }
            R.id.button_antarctica -> {
                inputConnection!!.commitText(context.getString(R.string.antarctica), 1)
            }
            R.id.button_antigua_and_barbuda -> {
                inputConnection!!.commitText(context.getString(R.string.antigua_and_barbuda), 1)
            }
            R.id.button_argentina -> {
                inputConnection!!.commitText(context.getString(R.string.argentina), 1)
            }
            R.id.button_armenia -> {
                inputConnection!!.commitText(context.getString(R.string.armenia), 1)
            }
            R.id.button_aruba -> {
                inputConnection!!.commitText(context.getString(R.string.aruba), 1)
            }
            R.id.button_australia -> {
                inputConnection!!.commitText(context.getString(R.string.australia), 1)
            }
            R.id.button_austria -> {
                inputConnection!!.commitText(context.getString(R.string.austria), 1)
            }
            R.id.button_azerbaijan -> {
                inputConnection!!.commitText(context.getString(R.string.azerbaijan), 1)
            }
            R.id.button_bahamas -> {
                inputConnection!!.commitText(context.getString(R.string.bahamas), 1)
            }
            R.id.button_bahrain -> {
                inputConnection!!.commitText(context.getString(R.string.bahrain), 1)
            }
            R.id.button_bangladesh -> {
                inputConnection!!.commitText(context.getString(R.string.bangladesh), 1)
            }
            R.id.button_barbados -> {
                inputConnection!!.commitText(context.getString(R.string.barbados), 1)
            }
            R.id.button_belarus -> {
                inputConnection!!.commitText(context.getString(R.string.belarus), 1)
            }
            R.id.button_belgium -> {
                inputConnection!!.commitText(context.getString(R.string.belgium), 1)
            }
            R.id.button_belize -> {
                inputConnection!!.commitText(context.getString(R.string.belize), 1)
            }
            R.id.button_benin -> {
                inputConnection!!.commitText(context.getString(R.string.benin), 1)
            }
            R.id.button_bermuda -> {
                inputConnection!!.commitText(context.getString(R.string.bermuda), 1)
            }
            R.id.button_bhutan -> {
                inputConnection!!.commitText(context.getString(R.string.bhutan), 1)
            }
            R.id.button_bolivia -> {
                inputConnection!!.commitText(context.getString(R.string.bolivia), 1)
            }
            R.id.button_bosnia_and_herzegovina -> {
                inputConnection!!.commitText(context.getString(R.string.bosnia_and_herzegovina), 1)
            }
            R.id.button_botswana -> {
                inputConnection!!.commitText(context.getString(R.string.botswana), 1)
            }
            R.id.button_brazil -> {
                inputConnection!!.commitText(context.getString(R.string.brazil), 1)
            }
            R.id.button_british_indian_ocean_territory -> {
                inputConnection!!.commitText(context.getString(R.string.british_indian_ocean_territory), 1)
            }
            R.id.button_british_virgin_islands -> {
                inputConnection!!.commitText(context.getString(R.string.british_virgin_islands), 1)
            }
            R.id.button_brunei -> {
                inputConnection!!.commitText(context.getString(R.string.brunei), 1)
            }
            R.id.button_bulgaria -> {
                inputConnection!!.commitText(context.getString(R.string.bulgaria), 1)
            }
            R.id.button_burkina_faso -> {
                inputConnection!!.commitText(context.getString(R.string.burkina_faso), 1)
            }
            R.id.button_burundi -> {
                inputConnection!!.commitText(context.getString(R.string.burundi), 1)
            }
            R.id.button_cambodia -> {
                inputConnection!!.commitText(context.getString(R.string.cambodia), 1)
            }
            R.id.button_cameroon -> {
                inputConnection!!.commitText(context.getString(R.string.cameroon), 1)
            }
            R.id.button_canada -> {
                inputConnection!!.commitText(context.getString(R.string.canada), 1)
            }
            R.id.button_canary_islands -> {
                inputConnection!!.commitText(context.getString(R.string.canary_islands), 1)
            }
            R.id.button_cape_verde -> {
                inputConnection!!.commitText(context.getString(R.string.cape_verde), 1)
            }
            R.id.button_caribbean_netherlands -> {
                inputConnection!!.commitText(context.getString(R.string.caribbean_netherlands), 1)
            }
            R.id.button_cayman_islands -> {
                inputConnection!!.commitText(context.getString(R.string.cayman_islands), 1)
            }
            R.id.button_central_african_republic -> {
                inputConnection!!.commitText(context.getString(R.string.central_african_republic), 1)
            }
            R.id.button_chad -> {
                inputConnection!!.commitText(context.getString(R.string.chad), 1)
            }
            R.id.button_chile -> {
                inputConnection!!.commitText(context.getString(R.string.chile), 1)
            }
            R.id.button_china -> {
                inputConnection!!.commitText(context.getString(R.string.china), 1)
            }
            R.id.button_christmas_island -> {
                inputConnection!!.commitText(context.getString(R.string.christmas_island), 1)
            }
            R.id.button_cocos_keeling_islands -> {
                inputConnection!!.commitText(context.getString(R.string.cocos_keeling_islands), 1)
            }
            R.id.button_colombia -> {
                inputConnection!!.commitText(context.getString(R.string.colombia), 1)
            }
            R.id.button_comoros -> {
                inputConnection!!.commitText(context.getString(R.string.comoros), 1)
            }
            R.id.button_congo_brazzaville -> {
                inputConnection!!.commitText(context.getString(R.string.congo_brazzaville), 1)
            }
            R.id.button_congo_kinshasa -> {
                inputConnection!!.commitText(context.getString(R.string.congo_kinshasa), 1)
            }
            R.id.button_cook_islands -> {
                inputConnection!!.commitText(context.getString(R.string.cook_islands), 1)
            }
            R.id.button_costa_rica -> {
                inputConnection!!.commitText(context.getString(R.string.costa_rica), 1)
            }
            R.id.button_cote_d_ivoire -> {
                inputConnection!!.commitText(context.getString(R.string.cote_d_ivoire), 1)
            }
            R.id.button_croatia -> {
                inputConnection!!.commitText(context.getString(R.string.croatia), 1)
            }
            R.id.button_cuba -> {
                inputConnection!!.commitText(context.getString(R.string.cuba), 1)
            }
            R.id.button_curacao -> {
                inputConnection!!.commitText(context.getString(R.string.curacao), 1)
            }
            R.id.button_cyprus -> {
                inputConnection!!.commitText(context.getString(R.string.cyprus), 1)
            }
            R.id.button_czechia -> {
                inputConnection!!.commitText(context.getString(R.string.czechia), 1)
            }
            R.id.button_denmark -> {
                inputConnection!!.commitText(context.getString(R.string.denmark), 1)
            }
            R.id.button_djibouti -> {
                inputConnection!!.commitText(context.getString(R.string.djibouti), 1)
            }
            R.id.button_dominica -> {
                inputConnection!!.commitText(context.getString(R.string.dominica), 1)
            }
            R.id.button_dominican_republic -> {
                inputConnection!!.commitText(context.getString(R.string.dominican_republic), 1)
            }
            R.id.button_ecuador -> {
                inputConnection!!.commitText(context.getString(R.string.ecuador), 1)
            }
            R.id.button_egypt -> {
                inputConnection!!.commitText(context.getString(R.string.egypt), 1)
            }
            R.id.button_el_salvador -> {
                inputConnection!!.commitText(context.getString(R.string.el_salvador), 1)
            }
            R.id.button_equatorial_guinea -> {
                inputConnection!!.commitText(context.getString(R.string.equatorial_guinea), 1)
            }
            R.id.button_eritrea -> {
                inputConnection!!.commitText(context.getString(R.string.eritrea), 1)
            }
            R.id.button_estonia -> {
                inputConnection!!.commitText(context.getString(R.string.estonia), 1)
            }
            R.id.button_ethiopia -> {
                inputConnection!!.commitText(context.getString(R.string.ethiopia), 1)
            }
            R.id.button_european_union -> {
                inputConnection!!.commitText(context.getString(R.string.european_union), 1)
            }
            R.id.button_falkland_islands -> {
                inputConnection!!.commitText(context.getString(R.string.falkland_islands), 1)
            }
            R.id.button_faroe_islands -> {
                inputConnection!!.commitText(context.getString(R.string.faroe_islands), 1)
            }
            R.id.button_fiji -> {
                inputConnection!!.commitText(context.getString(R.string.fiji), 1)
            }
            R.id.button_finland -> {
                inputConnection!!.commitText(context.getString(R.string.finland), 1)
            }
            R.id.button_france -> {
                inputConnection!!.commitText(context.getString(R.string.france), 1)
            }
            R.id.button_french_guiana -> {
                inputConnection!!.commitText(context.getString(R.string.french_guiana), 1)
            }
            R.id.button_french_polynesia -> {
                inputConnection!!.commitText(context.getString(R.string.french_polynesia), 1)
            }
            R.id.button_french_southern_territories -> {
                inputConnection!!.commitText(context.getString(R.string.french_southern_territories), 1)
            }
            R.id.button_gabon -> {
                inputConnection!!.commitText(context.getString(R.string.gabon), 1)
            }
            R.id.button_gambia -> {
                inputConnection!!.commitText(context.getString(R.string.gambia), 1)
            }
            R.id.button_georgia -> {
                inputConnection!!.commitText(context.getString(R.string.georgia), 1)
            }
            R.id.button_germany -> {
                inputConnection!!.commitText(context.getString(R.string.germany), 1)
            }
            R.id.button_ghana -> {
                inputConnection!!.commitText(context.getString(R.string.ghana), 1)
            }
            R.id.button_gibraltar -> {
                inputConnection!!.commitText(context.getString(R.string.gibraltar), 1)
            }
            R.id.button_greece -> {
                inputConnection!!.commitText(context.getString(R.string.greece), 1)
            }
            R.id.button_greenland -> {
                inputConnection!!.commitText(context.getString(R.string.greenland), 1)
            }
            R.id.button_grenada -> {
                inputConnection!!.commitText(context.getString(R.string.grenada), 1)
            }
            R.id.button_guadeloupe -> {
                inputConnection!!.commitText(context.getString(R.string.guadeloupe), 1)
            }
            R.id.button_guam -> {
                inputConnection!!.commitText(context.getString(R.string.guam), 1)
            }
            R.id.button_guatemala -> {
                inputConnection!!.commitText(context.getString(R.string.guatemala), 1)
            }
            R.id.button_guernsey -> {
                inputConnection!!.commitText(context.getString(R.string.guernsey), 1)
            }
            R.id.button_guinea -> {
                inputConnection!!.commitText(context.getString(R.string.guinea), 1)
            }
            R.id.button_guinea_bissau -> {
                inputConnection!!.commitText(context.getString(R.string.guinea_bissau), 1)
            }
            R.id.button_guyana -> {
                inputConnection!!.commitText(context.getString(R.string.guyana), 1)
            }
            R.id.button_haiti -> {
                inputConnection!!.commitText(context.getString(R.string.haiti), 1)
            }
            R.id.button_honduras -> {
                inputConnection!!.commitText(context.getString(R.string.honduras), 1)
            }
            R.id.button_hong_kong -> {
                inputConnection!!.commitText(context.getString(R.string.hong_kong), 1)
            }
            R.id.button_hungary -> {
                inputConnection!!.commitText(context.getString(R.string.hungary), 1)
            }
            R.id.button_iceland -> {
                inputConnection!!.commitText(context.getString(R.string.iceland), 1)
            }
            R.id.button_india -> {
                inputConnection!!.commitText(context.getString(R.string.india), 1)
            }
            R.id.button_indonesia -> {
                inputConnection!!.commitText(context.getString(R.string.indonesia), 1)
            }
            R.id.button_iran -> {
                inputConnection!!.commitText(context.getString(R.string.iran), 1)
            }
            R.id.button_iraq -> {
                inputConnection!!.commitText(context.getString(R.string.iraq), 1)
            }
            R.id.button_ireland -> {
                inputConnection!!.commitText(context.getString(R.string.ireland), 1)
            }
            R.id.button_isle_of_man -> {
                inputConnection!!.commitText(context.getString(R.string.isle_of_man), 1)
            }
            R.id.button_israel -> {
                inputConnection!!.commitText(context.getString(R.string.israel), 1)
            }
            R.id.button_italy -> {
                inputConnection!!.commitText(context.getString(R.string.italy), 1)
            }
            R.id.button_jamaica -> {
                inputConnection!!.commitText(context.getString(R.string.jamaica), 1)
            }
            R.id.button_japan -> {
                inputConnection!!.commitText(context.getString(R.string.japan), 1)
            }
            R.id.button_crossed_flags -> {
                inputConnection!!.commitText(context.getString(R.string.crossed_flags), 1)
            }
            R.id.button_jersey -> {
                inputConnection!!.commitText(context.getString(R.string.jersey), 1)
            }
            R.id.button_jordan -> {
                inputConnection!!.commitText(context.getString(R.string.jordan), 1)
            }
            R.id.button_kazakhstan -> {
                inputConnection!!.commitText(context.getString(R.string.kazakhstan), 1)
            }
            R.id.button_kenya -> {
                inputConnection!!.commitText(context.getString(R.string.kenya), 1)
            }
            R.id.button_kiribati -> {
                inputConnection!!.commitText(context.getString(R.string.kiribati), 1)
            }
            R.id.button_kosovo -> {
                inputConnection!!.commitText(context.getString(R.string.kosovo), 1)
            }
            R.id.button_kuwait -> {
                inputConnection!!.commitText(context.getString(R.string.kuwait), 1)
            }
            R.id.button_kyrgyzstan -> {
                inputConnection!!.commitText(context.getString(R.string.kyrgyzstan), 1)
            }
            R.id.button_laos -> {
                inputConnection!!.commitText(context.getString(R.string.laos), 1)
            }
            R.id.button_latvia -> {
                inputConnection!!.commitText(context.getString(R.string.latvia), 1)
            }
            R.id.button_lebanon -> {
                inputConnection!!.commitText(context.getString(R.string.lebanon), 1)
            }
            R.id.button_lesotho -> {
                inputConnection!!.commitText(context.getString(R.string.lesotho), 1)
            }
            R.id.button_liberia -> {
                inputConnection!!.commitText(context.getString(R.string.liberia), 1)
            }
            R.id.button_libya -> {
                inputConnection!!.commitText(context.getString(R.string.libya), 1)
            }
            R.id.button_liechtenstein -> {
                inputConnection!!.commitText(context.getString(R.string.liechtenstein), 1)
            }
            R.id.button_lithuania -> {
                inputConnection!!.commitText(context.getString(R.string.lithuania), 1)
            }
            R.id.button_luxembourg -> {
                inputConnection!!.commitText(context.getString(R.string.luxembourg), 1)
            }
            R.id.button_macau_sar_china -> {
                inputConnection!!.commitText(context.getString(R.string.macau_sar_china), 1)
            }
            R.id.button_macedonia -> {
                inputConnection!!.commitText(context.getString(R.string.macedonia), 1)
            }
            R.id.button_madagascar -> {
                inputConnection!!.commitText(context.getString(R.string.madagascar), 1)
            }
            R.id.button_malawi -> {
                inputConnection!!.commitText(context.getString(R.string.malawi), 1)
            }
            R.id.button_malaysia -> {
                inputConnection!!.commitText(context.getString(R.string.malaysia), 1)
            }
            R.id.button_maldives -> {
                inputConnection!!.commitText(context.getString(R.string.maldives), 1)
            }
            R.id.button_mali -> {
                inputConnection!!.commitText(context.getString(R.string.mali), 1)
            }
            R.id.button_malta -> {
                inputConnection!!.commitText(context.getString(R.string.malta), 1)
            }
            R.id.button_marshall_islands -> {
                inputConnection!!.commitText(context.getString(R.string.marshall_islands), 1)
            }
            R.id.button_martinique -> {
                inputConnection!!.commitText(context.getString(R.string.martinique), 1)
            }
            R.id.button_mauritania -> {
                inputConnection!!.commitText(context.getString(R.string.mauritania), 1)
            }
            R.id.button_mauritius -> {
                inputConnection!!.commitText(context.getString(R.string.mauritius), 1)
            }
            R.id.button_mayotte -> {
                inputConnection!!.commitText(context.getString(R.string.mayotte), 1)
            }
            R.id.button_mexico -> {
                inputConnection!!.commitText(context.getString(R.string.mexico), 1)
            }
            R.id.button_micronesia -> {
                inputConnection!!.commitText(context.getString(R.string.micronesia), 1)
            }
            R.id.button_moldova -> {
                inputConnection!!.commitText(context.getString(R.string.moldova), 1)
            }
            R.id.button_monaco -> {
                inputConnection!!.commitText(context.getString(R.string.monaco), 1)
            }
            R.id.button_mongolia -> {
                inputConnection!!.commitText(context.getString(R.string.mongolia), 1)
            }
            R.id.button_montenegro -> {
                inputConnection!!.commitText(context.getString(R.string.montenegro), 1)
            }
            R.id.button_montserrat -> {
                inputConnection!!.commitText(context.getString(R.string.montserrat), 1)
            }
            R.id.button_morocco -> {
                inputConnection!!.commitText(context.getString(R.string.morocco), 1)
            }
            R.id.button_mozambique -> {
                inputConnection!!.commitText(context.getString(R.string.mozambique), 1)
            }
            R.id.button_myanmar_burma -> {
                inputConnection!!.commitText(context.getString(R.string.myanmar_burma), 1)
            }
            R.id.button_namibia -> {
                inputConnection!!.commitText(context.getString(R.string.namibia), 1)
            }
            R.id.button_nauru -> {
                inputConnection!!.commitText(context.getString(R.string.nauru), 1)
            }
            R.id.button_nepal -> {
                inputConnection!!.commitText(context.getString(R.string.nepal), 1)
            }
            R.id.button_netherlands -> {
                inputConnection!!.commitText(context.getString(R.string.netherlands), 1)
            }
            R.id.button_new_caledonia -> {
                inputConnection!!.commitText(context.getString(R.string.new_caledonia), 1)
            }
            R.id.button_new_zealand -> {
                inputConnection!!.commitText(context.getString(R.string.new_zealand), 1)
            }
            R.id.button_nicaragua -> {
                inputConnection!!.commitText(context.getString(R.string.nicaragua), 1)
            }
            R.id.button_niger -> {
                inputConnection!!.commitText(context.getString(R.string.niger), 1)
            }
            R.id.button_nigeria -> {
                inputConnection!!.commitText(context.getString(R.string.nigeria), 1)
            }
            R.id.button_niue -> {
                inputConnection!!.commitText(context.getString(R.string.niue), 1)
            }
            R.id.button_norfolk_island -> {
                inputConnection!!.commitText(context.getString(R.string.norfolk_island), 1)
            }
        }
    }

    fun setInputConnection(ic: InputConnection) {
        inputConnection = ic
    }
}