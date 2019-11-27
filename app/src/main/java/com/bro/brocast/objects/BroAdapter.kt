package com.bro.brocast.objects

import android.app.Activity
import android.widget.ArrayAdapter
import com.bro.brocast.R

class BroAdapter(private val context: Activity,
                 private val usernames: ArrayList<String>):
    ArrayAdapter<String>(context, R.layout.bro_list, usernames) {

}