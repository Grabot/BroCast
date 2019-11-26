package com.bro.brocast

import android.os.Bundle
import android.widget.EditText
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.hbb20.CountryCodePicker
import java.util.*



// deprecated!!! This has now become obsolete.
// Maybe I'll use it in the future, for now I'll leave it on the backlog
class FindPhoneActivity: AppCompatActivity(), CountryCodePicker.OnCountryChangeListener, CountryCodePicker.PhoneNumberValidityChangeListener {

    private var ccp:CountryCodePicker?=null
    private var countryCode:String?=null
    private var countryName:String?=null

    var editTextCarrierNumber: EditText? = null


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_find_phones)

        val locale: Locale = Locale.getDefault()
        ccp = findViewById(R.id.ccp)
        ccp!!.setCountryPreference(locale.country)
        ccp!!.setDefaultCountryUsingNameCode(locale.country)
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