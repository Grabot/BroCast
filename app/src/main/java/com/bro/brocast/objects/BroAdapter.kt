package com.bro.brocast.objects

import android.app.Activity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ArrayAdapter
import android.widget.TextView
import com.bro.brocast.R

class BroAdapter(private val context: Activity,
                 resource:Int,
                 private val bros: ArrayList<Bro>):
    ArrayAdapter<Bro>(context, resource, bros) {

    override fun getView(position: Int, convertView: View?, parent: ViewGroup): View {
        var view: View? = convertView

        if (view == null) {
            val layoutInflater: LayoutInflater = LayoutInflater.from(context)
            // We will just assume that this always holds.
            view = layoutInflater.inflate(R.layout.bro_list, parent, false)
        }

        val textView: TextView = view!!.findViewById(R.id.broListBroName)

        val person: Bro = bros.get(position)

        textView.text = person.broName

        return view
    }
}