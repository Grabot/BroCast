package com.bro.brocast.adapters

import android.app.Activity
import android.graphics.Color
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ArrayAdapter
import android.widget.TextView
import com.bro.brocast.R
import com.bro.brocast.objects.Bro

class Brodapter(private val context: Activity,
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
        val messageCount: TextView = view.findViewById(R.id.broMessageCount)

        val person: Bro = bros.get(position)

        val newMessages = person.getNewMessages()
        textView.text = person.getFullBroName()
        messageCount.text = newMessages.toString()

        // With the color '3300ff00' the first 33 is the transparancy. This is the same for all background colors
        if (newMessages >= 5) {
            view.setBackgroundColor(Color.parseColor("#3300ff00"))
        } else if (newMessages == 4) {
            view.setBackgroundColor(Color.parseColor("#3333ff3"))
        } else if (newMessages == 3) {
            view.setBackgroundColor(Color.parseColor("#3366ff66"))
        } else if (newMessages == 2) {
            view.setBackgroundColor(Color.parseColor("#3399ff99"))
        } else if (newMessages == 1) {
            view.setBackgroundColor(Color.parseColor("#33ccffcc"))
        } else {
            // If there are no messages, make it the same as the background color.
            view.setBackgroundColor(Color.parseColor("#33ACACAC"))
            messageCount.text = ""
        }

        return view
    }
}