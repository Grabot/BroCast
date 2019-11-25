package com.bro.brocast

import android.content.Context
import android.os.Bundle
import android.telephony.TelephonyManager
import android.widget.EditText
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.hbb20.CountryCodePicker
import java.util.*


class FindBroActivity: AppCompatActivity(), CountryCodePicker.OnCountryChangeListener, CountryCodePicker.PhoneNumberValidityChangeListener {

    private var ccp:CountryCodePicker?=null
    private var countryCode:String?=null
    private var countryName:String?=null

    var editTextCarrierNumber: EditText? = null


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_find_bros)

        // TODO @Sander: Work the locale and the countryISOCode into the preferences in a nice way.
        val teleMgr =
            getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        val countryISOCode = teleMgr.simCountryIso
        val locale: Locale = Locale.getDefault()
        System.out.println("The country that this user has set for himself is " +locale.country)
        println("Bro's country! $countryISOCode")
        ccp = findViewById(R.id.ccp)
        ccp!!.setCountryPreference("NL")
        ccp!!.setDefaultCountryUsingNameCode("NL")
        // For some reason you need to set the default and then reset to that default for it to work
        ccp!!.resetToDefaultCountry()

        ccp!!.setOnCountryChangeListener(this)
        editTextCarrierNumber = findViewById(R.id.editText_carrierNumber)
        ccp!!.registerCarrierNumberEditText(editTextCarrierNumber)
        ccp!!.setPhoneNumberValidityChangeListener(this)
    }

    override fun onValidityChanged(isValidNumber: Boolean) {
        if (isValidNumber) {
            println("Valid! :D")
        } else {
            Toast.makeText(applicationContext, "invalid phone number! Please enter a valid phone number so your bro's can find you", Toast.LENGTH_SHORT).show()
        }
    }

    override fun onCountrySelected() {
        countryCode=ccp!!.selectedCountryCode
        countryName=ccp!!.selectedCountryName

        Toast.makeText(this,"Country Code "+countryCode,Toast.LENGTH_SHORT).show()
        Toast.makeText(this,"Country Name "+countryName,Toast.LENGTH_SHORT).show()
    }
}
