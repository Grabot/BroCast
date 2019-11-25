package com.bro.brocast

import android.os.Bundle
import android.widget.EditText
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.hbb20.CountryCodePicker


class FindBroActivity: AppCompatActivity() {

    private var ccp:CountryCodePicker?=null
    private var countryCode:String?=null
    private var countryName:String?=null

    var editTextCarrierNumber: EditText? = null


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_find_bros)

        ccp = findViewById(R.id.ccp)
        ccp!!.setOnCountryChangeListener {

            countryCode=ccp!!.selectedCountryCode
            countryName=ccp!!.selectedCountryName

            Toast.makeText(this,"Country Code "+countryCode, Toast.LENGTH_SHORT).show()
            Toast.makeText(this,"Country Name "+countryName, Toast.LENGTH_SHORT).show()
        }

        editTextCarrierNumber = findViewById(R.id.editText_carrierNumber)

        ccp!!.registerCarrierNumberEditText(editTextCarrierNumber)
        ccp!!.setPhoneNumberValidityChangeListener {

            val valid = ccp!!.isValidFullNumber
            if (valid) {
                println("Valid! :D")
            } else {
                Toast.makeText(applicationContext, "invalid phone number! Please enter a valid phone number so your bro's can find you", Toast.LENGTH_SHORT).show()
            }
        }
    }
}
