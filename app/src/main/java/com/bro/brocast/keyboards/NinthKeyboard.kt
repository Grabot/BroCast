package com.bro.brocast.keyboards

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View.OnClickListener
import android.view.inputmethod.InputConnection
import android.widget.Button
import android.widget.LinearLayout
import com.bro.brocast.R


class NinthKeyboard: LinearLayout {

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
        LayoutInflater.from(context).inflate(R.layout.keyboard_9, this, true)

        val buttonIds = arrayOf(
            R.string.white_flag,
            R.string.black_flag,
            R.string.pirate_flag,
            R.string.chequered_flag,
            R.string.triangular_flag,
            R.string.rainbow_flag,
            R.string.united_nations,
            R.string.afghanistan,
            R.string.aland_islands,
            R.string.albania,
            R.string.algeria,
            R.string.american_samoa,
            R.string.andorra,
            R.string.angola,
            R.string.anguilla,
            R.string.antarctica,
            R.string.antigua_and_barbuda,
            R.string.argentina,
            R.string.armenia,
            R.string.aruba,
            R.string.australia,
            R.string.austria,
            R.string.azerbaijan,
            R.string.bahamas,
            R.string.bahrain,
            R.string.bangladesh,
            R.string.barbados,
            R.string.belarus,
            R.string.belgium,
            R.string.belize,
            R.string.benin,
            R.string.bermuda,
            R.string.bhutan,
            R.string.bolivia,
            R.string.bosnia_and_herzegovina,
            R.string.botswana,
            R.string.brazil,
            R.string.british_indian_ocean_territory,
            R.string.british_virgin_islands,
            R.string.brunei,
            R.string.bulgaria,
            R.string.burkina_faso,
            R.string.burundi,
            R.string.cambodia,
            R.string.cameroon,
            R.string.canada,
            R.string.canary_islands,
            R.string.cape_verde,
            R.string.cayman_islands,
            R.string.central_african_republic,
            R.string.chad,
            R.string.chile,
            R.string.china,
            R.string.christmas_island,
            R.string.cocos_keeling_islands,
            R.string.colombia,
            R.string.comoros,
            R.string.congo_brazzaville,
            R.string.congo_kinshasa,
            R.string.cook_islands,
            R.string.costa_rica,
            R.string.cote_d_ivoire,
            R.string.croatia,
            R.string.cuba,
            R.string.curacao,
            R.string.cyprus,
            R.string.czechia,
            R.string.denmark,
            R.string.djibouti,
            R.string.dominica,
            R.string.dominican_republic,
            R.string.ecuador,
            R.string.egypt,
            R.string.el_salvador,
            R.string.equatorial_guinea,
            R.string.eritrea,
            R.string.estonia,
            R.string.ethiopia,
            R.string.european_union,
            R.string.falkland_islands,
            R.string.faroe_islands,
            R.string.fiji,
            R.string.finland,
            R.string.france,
            R.string.french_guiana,
            R.string.french_polynesia,
            R.string.gabon,
            R.string.gambia,
            R.string.georgia,
            R.string.germany,
            R.string.ghana,
            R.string.gibraltar,
            R.string.greece,
            R.string.greenland,
            R.string.grenada,
            R.string.guadeloupe,
            R.string.guam,
            R.string.guatemala,
            R.string.guernsey,
            R.string.guinea,
            R.string.guinea_bissau,
            R.string.guyana,
            R.string.haiti,
            R.string.honduras,
            R.string.hong_kong,
            R.string.hungary,
            R.string.iceland,
            R.string.india,
            R.string.indonesia,
            R.string.iran,
            R.string.iraq,
            R.string.ireland,
            R.string.isle_of_man,
            R.string.israel,
            R.string.italy,
            R.string.jamaica,
            R.string.japan,
            R.string.crossed_flags,
            R.string.jersey,
            R.string.jordan,
            R.string.kazakhstan,
            R.string.kenya,
            R.string.kiribati,
            R.string.kosovo,
            R.string.kuwait,
            R.string.kyrgyzstan,
            R.string.laos,
            R.string.latvia,
            R.string.lebanon,
            R.string.lesotho,
            R.string.liberia,
            R.string.libya,
            R.string.liechtenstein,
            R.string.lithuania,
            R.string.luxembourg,
            R.string.macau_sar_china,
            R.string.macedonia,
            R.string.madagascar,
            R.string.malawi,
            R.string.malaysia,
            R.string.maldives,
            R.string.mali,
            R.string.malta,
            R.string.marshall_islands,
            R.string.mauritania,
            R.string.mauritius,
            R.string.mayotte,
            R.string.mexico,
            R.string.micronesia,
            R.string.moldova,
            R.string.monaco,
            R.string.mongolia,
            R.string.montenegro,
            R.string.montserrat,
            R.string.morocco,
            R.string.mozambique,
            R.string.myanmar_burma,
            R.string.namibia,
            R.string.nauru,
            R.string.nepal,
            R.string.netherlands,
            R.string.new_caledonia,
            R.string.new_zealand,
            R.string.nicaragua,
            R.string.niger,
            R.string.nigeria,
            R.string.niue,
            R.string.norfolk_island,
            R.string.north_korea,
            R.string.northern_mariana_islands,
            R.string.norway,
            R.string.oman,
            R.string.pakistan,
            R.string.palau,
            R.string.palestinian_territories,
            R.string.panama,
            R.string.papua_new_guinea,
            R.string.paraguay,
            R.string.peru,
            R.string.philippines,
            R.string.pitcairn_islands,
            R.string.poland,
            R.string.portugal,
            R.string.puerto_rico,
            R.string.qatar,
            R.string.romania,
            R.string.russia,
            R.string.rwanda,
            R.string.samoa,
            R.string.san_marino,
            R.string.sao_tome_and_principe,
            R.string.saudi_arabia,
            R.string.senegal,
            R.string.seychelles,
            R.string.serbia,
            R.string.sierra_leone,
            R.string.singapore,
            R.string.sint_maarten,
            R.string.slovakia,
            R.string.slovenia,
            R.string.south_georgia_and_south_sandwich_islands,
            R.string.solomon_islands,
            R.string.somalia,
            R.string.south_africa,
            R.string.south_korea,
            R.string.south_sudan,
            R.string.spain,
            R.string.sri_lanka,
            R.string.st_helena,
            R.string.st_kitts_and_nevis,
            R.string.st_lucia,
            R.string.st_pierre_and_miquelon,
            R.string.st_vincent_and_grenadines,
            R.string.sudan,
            R.string.suriname,
            R.string.swaziland,
            R.string.sweden,
            R.string.switzerland,
            R.string.syria,
            R.string.taiwan,
            R.string.tajikistan,
            R.string.tanzania,
            R.string.thailand,
            R.string.timor_leste,
            R.string.togo,
            R.string.tokelau,
            R.string.tonga,
            R.string.trinidad_and_tobago,
            R.string.tunisia,
            R.string.flag_of_turkey,
            R.string.turkmenistan,
            R.string.turks_and_caicos_islands,
            R.string.tuvalu,
            R.string.us_virgin_islands,
            R.string.uganda,
            R.string.ukraine,
            R.string.united_arab_emirates,
            R.string.united_kingdom,
            R.string.england,
            R.string.scotland,
            R.string.wales,
            R.string.united_states,
            R.string.uruguay,
            R.string.uzbekistan,
            R.string.vanuatu,
            R.string.vatican_city,
            R.string.venezuela,
            R.string.vietnam,
            R.string.wallis_and_futuna,
            R.string.western_sahara,
            R.string.yemen,
            R.string.zambia,
            R.string.zimbabwe
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
            R.id.button_north_korea -> {
                inputConnection!!.commitText(context.getString(R.string.north_korea), 1)
            }
            R.id.button_northern_mariana_islands -> {
                inputConnection!!.commitText(context.getString(R.string.northern_mariana_islands), 1)
            }
            R.id.button_norway -> {
                inputConnection!!.commitText(context.getString(R.string.norway), 1)
            }
            R.id.button_oman -> {
                inputConnection!!.commitText(context.getString(R.string.oman), 1)
            }
            R.id.button_pakistan -> {
                inputConnection!!.commitText(context.getString(R.string.pakistan), 1)
            }
            R.id.button_palau -> {
                inputConnection!!.commitText(context.getString(R.string.palau), 1)
            }
            R.id.button_palestinian_territories -> {
                inputConnection!!.commitText(context.getString(R.string.palestinian_territories), 1)
            }
            R.id.button_panama -> {
                inputConnection!!.commitText(context.getString(R.string.panama), 1)
            }
            R.id.button_papua_new_guinea -> {
                inputConnection!!.commitText(context.getString(R.string.papua_new_guinea), 1)
            }
            R.id.button_paraguay -> {
                inputConnection!!.commitText(context.getString(R.string.paraguay), 1)
            }
            R.id.button_peru -> {
                inputConnection!!.commitText(context.getString(R.string.peru), 1)
            }
            R.id.button_philippines -> {
                inputConnection!!.commitText(context.getString(R.string.philippines), 1)
            }
            R.id.button_pitcairn_islands -> {
                inputConnection!!.commitText(context.getString(R.string.pitcairn_islands), 1)
            }
            R.id.button_poland -> {
                inputConnection!!.commitText(context.getString(R.string.poland), 1)
            }
            R.id.button_portugal -> {
                inputConnection!!.commitText(context.getString(R.string.portugal), 1)
            }
            R.id.button_puerto_rico -> {
                inputConnection!!.commitText(context.getString(R.string.puerto_rico), 1)
            }
            R.id.button_qatar -> {
                inputConnection!!.commitText(context.getString(R.string.qatar), 1)
            }
            R.id.button_romania -> {
                inputConnection!!.commitText(context.getString(R.string.romania), 1)
            }
            R.id.button_russia -> {
                inputConnection!!.commitText(context.getString(R.string.russia), 1)
            }
            R.id.button_rwanda -> {
                inputConnection!!.commitText(context.getString(R.string.rwanda), 1)
            }
            R.id.button_samoa -> {
                inputConnection!!.commitText(context.getString(R.string.samoa), 1)
            }
            R.id.button_san_marino -> {
                inputConnection!!.commitText(context.getString(R.string.san_marino), 1)
            }
            R.id.button_sao_tome_and_principe -> {
                inputConnection!!.commitText(context.getString(R.string.sao_tome_and_principe), 1)
            }
            R.id.button_saudi_arabia -> {
                inputConnection!!.commitText(context.getString(R.string.saudi_arabia), 1)
            }
            R.id.button_senegal -> {
                inputConnection!!.commitText(context.getString(R.string.senegal), 1)
            }
            R.id.button_seychelles -> {
                inputConnection!!.commitText(context.getString(R.string.seychelles), 1)
            }
            R.id.button_serbia -> {
                inputConnection!!.commitText(context.getString(R.string.serbia), 1)
            }
            R.id.button_sierra_leone -> {
                inputConnection!!.commitText(context.getString(R.string.sierra_leone), 1)
            }
            R.id.button_singapore -> {
                inputConnection!!.commitText(context.getString(R.string.singapore), 1)
            }
            R.id.button_sint_maarten -> {
                inputConnection!!.commitText(context.getString(R.string.sint_maarten), 1)
            }
            R.id.button_slovakia -> {
                inputConnection!!.commitText(context.getString(R.string.slovakia), 1)
            }
            R.id.button_slovenia -> {
                inputConnection!!.commitText(context.getString(R.string.slovenia), 1)
            }
            R.id.button_south_georgia_and_south_sandwich_islands -> {
                inputConnection!!.commitText(context.getString(R.string.south_georgia_and_south_sandwich_islands), 1)
            }
            R.id.button_solomon_islands -> {
                inputConnection!!.commitText(context.getString(R.string.solomon_islands), 1)
            }
            R.id.button_somalia -> {
                inputConnection!!.commitText(context.getString(R.string.somalia), 1)
            }
            R.id.button_south_africa -> {
                inputConnection!!.commitText(context.getString(R.string.south_africa), 1)
            }
            R.id.button_south_korea -> {
                inputConnection!!.commitText(context.getString(R.string.south_korea), 1)
            }
            R.id.button_south_sudan -> {
                inputConnection!!.commitText(context.getString(R.string.south_sudan), 1)
            }
            R.id.button_spain -> {
                inputConnection!!.commitText(context.getString(R.string.spain), 1)
            }
            R.id.button_sri_lanka -> {
                inputConnection!!.commitText(context.getString(R.string.sri_lanka), 1)
            }
            R.id.button_st_helena -> {
                inputConnection!!.commitText(context.getString(R.string.st_helena), 1)
            }
            R.id.button_st_kitts_and_nevis -> {
                inputConnection!!.commitText(context.getString(R.string.st_kitts_and_nevis), 1)
            }
            R.id.button_st_lucia -> {
                inputConnection!!.commitText(context.getString(R.string.st_lucia), 1)
            }
            R.id.button_st_pierre_and_miquelon -> {
                inputConnection!!.commitText(context.getString(R.string.st_pierre_and_miquelon), 1)
            }
            R.id.button_st_vincent_and_grenadines -> {
                inputConnection!!.commitText(context.getString(R.string.st_vincent_and_grenadines), 1)
            }
            R.id.button_sudan -> {
                inputConnection!!.commitText(context.getString(R.string.sudan), 1)
            }
            R.id.button_suriname -> {
                inputConnection!!.commitText(context.getString(R.string.suriname), 1)
            }
            R.id.button_swaziland -> {
                inputConnection!!.commitText(context.getString(R.string.swaziland), 1)
            }
            R.id.button_sweden -> {
                inputConnection!!.commitText(context.getString(R.string.sweden), 1)
            }
            R.id.button_switzerland -> {
                inputConnection!!.commitText(context.getString(R.string.switzerland), 1)
            }
            R.id.button_syria -> {
                inputConnection!!.commitText(context.getString(R.string.syria), 1)
            }
            R.id.button_taiwan -> {
                inputConnection!!.commitText(context.getString(R.string.taiwan), 1)
            }
            R.id.button_tajikistan -> {
                inputConnection!!.commitText(context.getString(R.string.tajikistan), 1)
            }
            R.id.button_tanzania -> {
                inputConnection!!.commitText(context.getString(R.string.tanzania), 1)
            }
            R.id.button_thailand -> {
                inputConnection!!.commitText(context.getString(R.string.thailand), 1)
            }
            R.id.button_timor_leste -> {
                inputConnection!!.commitText(context.getString(R.string.timor_leste), 1)
            }
            R.id.button_togo -> {
                inputConnection!!.commitText(context.getString(R.string.togo), 1)
            }
            R.id.button_tokelau -> {
                inputConnection!!.commitText(context.getString(R.string.tokelau), 1)
            }
            R.id.button_tonga -> {
                inputConnection!!.commitText(context.getString(R.string.tonga), 1)
            }
            R.id.button_trinidad_and_tobago -> {
                inputConnection!!.commitText(context.getString(R.string.trinidad_and_tobago), 1)
            }
            R.id.button_tunisia -> {
                inputConnection!!.commitText(context.getString(R.string.tunisia), 1)
            }
            R.id.button_flag_of_turkey -> {
                inputConnection!!.commitText(context.getString(R.string.flag_of_turkey), 1)
            }
            R.id.button_turkmenistan -> {
                inputConnection!!.commitText(context.getString(R.string.turkmenistan), 1)
            }
            R.id.button_turks_and_caicos_islands -> {
                inputConnection!!.commitText(context.getString(R.string.turks_and_caicos_islands), 1)
            }
            R.id.button_tuvalu -> {
                inputConnection!!.commitText(context.getString(R.string.tuvalu), 1)
            }
            R.id.button_us_virgin_islands -> {
                inputConnection!!.commitText(context.getString(R.string.us_virgin_islands), 1)
            }
            R.id.button_uganda -> {
                inputConnection!!.commitText(context.getString(R.string.uganda), 1)
            }
            R.id.button_ukraine -> {
                inputConnection!!.commitText(context.getString(R.string.ukraine), 1)
            }
            R.id.button_united_arab_emirates -> {
                inputConnection!!.commitText(context.getString(R.string.united_arab_emirates), 1)
            }
            R.id.button_united_kingdom -> {
                inputConnection!!.commitText(context.getString(R.string.united_kingdom), 1)
            }
            R.id.button_england -> {
                inputConnection!!.commitText(context.getString(R.string.england), 1)
            }
            R.id.button_scotland -> {
                inputConnection!!.commitText(context.getString(R.string.scotland), 1)
            }
            R.id.button_wales -> {
                inputConnection!!.commitText(context.getString(R.string.wales), 1)
            }
            R.id.button_united_states -> {
                inputConnection!!.commitText(context.getString(R.string.united_states), 1)
            }
            R.id.button_uruguay -> {
                inputConnection!!.commitText(context.getString(R.string.uruguay), 1)
            }
            R.id.button_uzbekistan -> {
                inputConnection!!.commitText(context.getString(R.string.uzbekistan), 1)
            }
            R.id.button_vanuatu -> {
                inputConnection!!.commitText(context.getString(R.string.vanuatu), 1)
            }
            R.id.button_vatican_city -> {
                inputConnection!!.commitText(context.getString(R.string.vatican_city), 1)
            }
            R.id.button_venezuela -> {
                inputConnection!!.commitText(context.getString(R.string.venezuela), 1)
            }
            R.id.button_vietnam -> {
                inputConnection!!.commitText(context.getString(R.string.vietnam), 1)
            }
            R.id.button_wallis_and_futuna -> {
                inputConnection!!.commitText(context.getString(R.string.wallis_and_futuna), 1)
            }
            R.id.button_western_sahara -> {
                inputConnection!!.commitText(context.getString(R.string.western_sahara), 1)
            }
            R.id.button_yemen -> {
                inputConnection!!.commitText(context.getString(R.string.yemen), 1)
            }
            R.id.button_zambia -> {
                inputConnection!!.commitText(context.getString(R.string.zambia), 1)
            }
            R.id.button_zimbabwe -> {
                inputConnection!!.commitText(context.getString(R.string.zimbabwe), 1)
            }
        }
    }

    fun setInputConnection(ic: InputConnection) {
        inputConnection = ic
    }
}